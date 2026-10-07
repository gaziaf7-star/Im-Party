import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/database/tables/chat_tables.dart'
    show MessageContentType;
import 'package:general/src/core/realtime/chat_repository.dart';
import 'package:general/src/features/messages/domain/usecases/upload_video_message_use_case.dart';
import 'package:general/src/features/messages/messages.dart';
import 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

part 'send_messages_event.dart';

part 'send_messages_state.dart';

class SendMessagesBloc extends Bloc<BaseSendMessagesEvent, SendMessagesState> {
  final GetPreSignedUrlmessageVideoUseCase getPreSignedUrlUseCase;
  final UploadFileToStorageMessageVideoUseCase uploadFileToStorageUseCase;

  // Offline-first transport (Centrifugo + drift). The SOLE 1:1 send path now —
  // text and media both route through the durable outbox. Required, not optional.
  final ChatRepository _chatRepo;

  SendMessagesBloc(
    this.getPreSignedUrlUseCase,
    this.uploadFileToStorageUseCase,
    this._chatRepo,
  ) : super(
          const SendMessagesState(),
        ) {
    on<SendVideoMessagesEvent>(_sendVideoMessageEvent);
    on<SendMessagesEvent>(_sendMessageEvent);
    on<PickVideoEvent>((event, emit) async {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        // onError("No file selected.");
        return;
      }

      final PlatformFile pickedFile = result.files.first;
      final File videoFile = File(pickedFile.path!);

      navKey.currentState?.pushNamed(Routes.addVideoScreen,
          arguments: SendVideoParam(
              video: videoFile,
              isReels: false,
              userId: event.userId,
              chatId: event.chatId));

      // final duration = await _getVideoDuration(videoFile);
      //
      // if (duration == null || duration > 120) {
      //   Methods.showToast(event.context,
      //       isError: true, message: StringManager.largeVideo.tr());
      //   return;
      // } else {
      //   Navigator.pushNamed(event.context, Routes.addVideoScreen,
      //       arguments: SendVideoMessageParam(
      //         video: videoFile,
      //         // controller: event.controller
      //       ));
      // }

      emit(state.copyWith(
        userId: event.userId,
        videoFile: videoFile,
      ));
    });
  }

  /// The single 1:1 send entry point for text, image and voice. Everything is
  /// optimistic + durable: it resolves the local drift room itself (by server
  /// room id when known, else by peer for a brand-new DM — never depending on
  /// FetchMessagesBloc having finished opening, which was the open-race that
  /// dropped sends to the legacy REST path), then routes through
  /// ChatRepository: text via [send], image/voice via [sendMedia] (which queues
  /// the upload + outbox op). The open conversation's drift stream renders the
  /// pending bubble instantly and the OutboxWorker delivers it (idempotent on
  /// client_uuid). Video has its own pre-upload pipeline in [_sendVideoMessageEvent].
  Future<void> _sendMessageEvent(
    SendMessagesEvent event,
    Emitter<SendMessagesState> emit,
  ) async {
    final peerId = int.tryParse(event.userId) ?? 0;
    if (peerId <= 0) return; // no valid recipient — nothing to send

    // Reply target: the backend ties a reply by the server message id (the
    // legacy `message_id` field), so carry it through the outbox unchanged.
    final replyToId =
        int.tryParse('${di<ToggleAppBarBloc>().state.replay?.messageId}');

    emit(state.copyWith(reqState: RequestState.loading, message: ''));

    // Resolve (or create) the local room from the peer + server room id, and when
    // the send carries no chat_id (composed from a profile/picker that never
    // resolved one) resolve the REAL server room id first via the lightweight
    // get-or-create endpoint, then bind the local drift room to it. This keeps the
    // local room linked to the real server id (no peer-keyed orphan) and is the
    // client twin of the server-side get-or-create now in ChatMessagesController::
    // store — so a first message to a brand-new peer is never lost. Resolution is
    // best-effort: on offline/failure (resolved 0) it still returns a localId>0
    // local room and the durable outbox carries the peer id, which the hardened
    // backend get-or-creates on delivery.
    final int roomLocalId;
    try {
      final ref = await _chatRepo.ensureDmRoomResolved(
        serverRoomId: event.chatId ?? 0,
        peerUserId: peerId,
      );
      roomLocalId = ref.localId;
    } catch (e) {
      emit(state.copyWith(reqState: RequestState.error));
      return;
    }

    try {
      if (event.xFile != null) {
        // Image vs voice: an explicit type:'image' marks gallery/camera picks;
        // every other attachment from this path is a voice note (the only other
        // xFile sender). Both ride the SAME outbox + media-upload pipeline.
        final isImage = event.type == 'image';
        await _chatRepo.sendMedia(
          roomLocalId: roomLocalId,
          peerUserId: peerId,
          localPath: event.xFile!.path,
          type: isImage
              ? MessageContentType.image
              : MessageContentType.audio,
          replyToServerMessageId: replyToId,
        );
      } else {
        final body = event.message?.trim();
        if (body == null || body.isEmpty) {
          emit(state.copyWith(reqState: RequestState.loaded));
          return;
        }
        await _chatRepo.send(
          roomLocalId: roomLocalId,
          peerUserId: peerId,
          body: event.message,
          replyToServerMessageId: replyToId,
        );
      }
      // Clear the reply composer once the message is queued (parity with the
      // legacy success path, which reset the app bar after sending).
      di<ToggleAppBarBloc>().add(const InitAppBarEvent());
      emit(state.copyWith(reqState: RequestState.loaded));
    } catch (e) {
      emit(state.copyWith(reqState: RequestState.error));
    }
  }

  /// 1:1 VIDEO send. Video pre-uploads its bytes (presign + PUT, with the live
  /// progress ring) BEFORE enqueue — its size makes the deferred MediaUploadWorker
  /// pattern (used for image/voice) a poor fit — then registers through the SAME
  /// durable outbox as everything else via [ChatRepository.send] with the resolved
  /// storage object name. The optimistic drift row carries the on-device video +
  /// first-frame so the bubble renders instantly; the server echo (client_uuid)
  /// swaps it to the remote url. No legacy REST send path.
  Future<void> _sendVideoMessageEvent(
    SendVideoMessagesEvent event,
    Emitter<SendMessagesState> emit,
  ) async {
    final peerId = int.tryParse(event.userId) ?? 0;
    if (peerId <= 0 || event.xFile == null) {
      di<FetchMessagesBloc>().add(
        FinishUploadingVideoEvent(videoId: event.videoId, userId: event.userId),
      );
      return;
    }

    emit(state.copyWith(
      reqState: RequestState.loading,
      duration: event.duration,
    ));
    int index = MessageVideoWidgetState.currentTime[event.videoId] ?? 0;
    MessageVideoWidgetState.videoProgressNotifier.value[index] = 0.05;
    MessageVideoWidgetState.videoProgressNotifier.notifyListeners();

    // Use the original file directly (compression is disabled — see history).
    final File videoFile = event.xFile!;
    final replyToId =
        int.tryParse('${di<ToggleAppBarBloc>().state.replay?.messageId}');

    final presign = await getPreSignedUrlUseCase(SendVideoParam(
      video: videoFile,
      duration: event.duration,
    ));

    await presign.fold(
      (failure) async {
        emit(state.copyWith(
          reqState: handleErrorResponse(failure),
          message: NetworkExceptions.getErrorMessage(failure),
        ));
        di<FetchMessagesBloc>().add(
          FinishUploadingVideoEvent(
              videoId: event.videoId, userId: event.userId),
        );
      },
      (presignData) async {
        final uploaded = await uploadFileToStorageUseCase(SendVideoParam(
          backendName: presignData['name'],
          preSignedUrl: presignData['upload_url'],
          description: null,
          video: videoFile,
          videoProgressId: event.videoId,
        ));

        await uploaded.fold(
          (failure) async {
            emit(state.copyWith(
              reqState: handleErrorResponse(failure),
              message: NetworkExceptions.getErrorMessage(failure),
            ));
            di<FetchMessagesBloc>().add(
              FinishUploadingVideoEvent(
                  videoId: event.videoId, userId: event.userId),
            );
          },
          (_) async {
            try {
              final ref = await _chatRepo.ensureDmRoomResolved(
                serverRoomId: event.chatId ?? 0,
                peerUserId: peerId,
              );
              final roomLocalId = ref.localId;
              await _chatRepo.send(
                roomLocalId: roomLocalId,
                peerUserId: peerId,
                type: MessageContentType.video,
                mediaRemoteRef: presignData['name'],
                duration: event.duration,
                replyToServerMessageId: replyToId,
                attachmentJson: ChatRepository.localAttachmentJson(
                  file: videoFile.path,
                  type: 'video',
                  firstFrame: event.firstFramePath,
                  duration: event.duration,
                ),
              );
              di<ToggleAppBarBloc>().add(const InitAppBarEvent());
              emit(state.copyWith(reqState: RequestState.loaded));
            } catch (e) {
              emit(state.copyWith(reqState: RequestState.error));
            }
            di<FetchMessagesBloc>().add(
              FinishUploadingVideoEvent(
                  videoId: event.videoId, userId: event.userId),
            );
          },
        );
      },
    );
  }
}
