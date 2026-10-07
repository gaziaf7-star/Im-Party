import 'dart:io';

import 'package:general/reels_viewer/reels_viewer.dart';
import 'package:general/src/core/services/notification/notification_service.dart';
import 'package:general/src/features/reels/domain/use_case/upload_reel_use_case.dart';

part 'upload_reel_event.dart';
part 'upload_reel_state.dart';

class UploadReelBloc extends Bloc<BaseUploadReelEvent, UploadReelState> {
  final GetPreSignedUrlUseCase getPreSignedUrlUseCase;
  final UploadFileToStorageUseCase uploadFileToStorageUseCase;
  final NotifyBackendUseCase notifyBackendUseCase;

  UploadReelBloc(
    this.getPreSignedUrlUseCase,
    this.uploadFileToStorageUseCase,
    this.notifyBackendUseCase,
  ) : super(const UploadReelState()) {
    on<GetPreSignedUrlEvent>(_onGetPreSignedUrl);
    on<UploadFileToStorageEvent>(_onUploadFile);
    on<NotifyBackendEvent>(_onNotifyBackend);
    on<UpdateUploadProgressEvent>(_onUpdateProgress);
    on<RetryUploadEvent>(_onRetry);
    on<ResetUploadStateEvent>(_onReset);
    on<UpdateUploadStageEvent>(_onUpdateStage);
  }

  Future<void> _onGetPreSignedUrl(
    GetPreSignedUrlEvent event,
    Emitter<UploadReelState> emit,
  ) async {
    emit(state.copyWith(
      uploadStage: UploadStage.uploading,
      uploadProgress: 0.0,
      pendingFile: event.param.reel,
      descreption: event.param.description,
    ));

    final result = await getPreSignedUrlUseCase(event.param.reel!);
    result.fold(
      (failure) => emit(state.copyWith(
        requestState: handleErrorResponse(failure),
        message: NetworkExceptions.getErrorMessage(failure),
        uploadStage: UploadStage.failed,
        failureReason: NetworkExceptions.getErrorMessage(failure),
      )),
      (success) {
        emit(state.copyWith(
          backendName: success['name'],
          preSignedUrl: success['upload_url'],
          descreption: event.param.description,
        ));
        add(UploadFileToStorageEvent(UploadReelParam(
          backendName: success['name'],
          preSignedUrl: success['upload_url'],
          description: event.param.description,
          reel: event.param.reel,
          onProgress: (progress) => add(UpdateUploadProgressEvent(progress)),
        )));
      },
    );
  }

  Future<void> _onUploadFile(
    UploadFileToStorageEvent event,
    Emitter<UploadReelState> emit,
  ) async {
    const maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final result = await uploadFileToStorageUseCase(event.param);
      final failed = result.fold<bool>(
        (failure) {
          if (attempt == maxRetries) {
            emit(state.copyWith(
              requestState: handleErrorResponse(failure),
              message: NetworkExceptions.getErrorMessage(failure),
              uploadStage: UploadStage.failed,
              failureReason: NetworkExceptions.getErrorMessage(failure),
            ));
          }
          return true;
        },
        (success) {
          emit(state.copyWith(
            uploadStage: UploadStage.processing,
            uploadProgress: 1.0,
          ));
          add(const NotifyBackendEvent());
          return false;
        },
      );
      if (!failed) break;
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
  }

  Future<void> _onNotifyBackend(
    NotifyBackendEvent event,
    Emitter<UploadReelState> emit,
  ) async {
    final result = await notifyBackendUseCase(UploadReelParam(
      description: state.descreption,
      backendName: state.backendName,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        requestState: handleErrorResponse(failure),
        message: NetworkExceptions.getErrorMessage(failure),
        uploadStage: UploadStage.failed,
        failureReason: NetworkExceptions.getErrorMessage(failure),
      )),
      (success) {
        emit(state.copyWith(
          requestState: RequestState.loaded,
          uploadStage: UploadStage.completed,
        ));
        final reel = success.data;
        if (reel == null) return;
        di<GetReelsBloc>().add(LocalAddReelEvent(reel));
        di<ReelViewerBloc>()
            .add(const ChangeActiveReelEvent(0, ReelsType.forYou));
        NotificationService().showReelReadyNotification(
          (reel.id ?? 0).toString(),
        );
      },
    );
  }

  void _onUpdateProgress(
    UpdateUploadProgressEvent event,
    Emitter<UploadReelState> emit,
  ) {
    emit(state.copyWith(uploadProgress: event.progress));
  }

  Future<void> _onRetry(
    RetryUploadEvent event,
    Emitter<UploadReelState> emit,
  ) async {
    if (state.pendingFile == null) return;
    add(GetPreSignedUrlEvent(UploadReelParam(
      reel: state.pendingFile,
      description: state.descreption,
    )));
  }

  void _onReset(
    ResetUploadStateEvent event,
    Emitter<UploadReelState> emit,
  ) {
    emit(const UploadReelState());
  }

  void _onUpdateStage(
    UpdateUploadStageEvent event,
    Emitter<UploadReelState> emit,
  ) {
    emit(state.copyWith(uploadStage: event.stage));
  }
}
