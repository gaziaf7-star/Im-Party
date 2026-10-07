part of 'send_messages_bloc.dart';

abstract class BaseSendMessagesEvent extends Equatable {
  const BaseSendMessagesEvent();

  @override
  List<Object?> get props => [];
}

final class SendMessagesEvent extends BaseSendMessagesEvent {
  final String userId;

  /// Server conversation id of the open chat (0/null for a brand-new DM). Carried
  /// so the send path can resolve the local drift room itself (peer + room id)
  /// instead of depending on FetchMessagesBloc having finished opening — which is
  /// what let a fast send fall back to the legacy REST path (the open race).
  final int? chatId;
  final String? messageId;
  final String? message;
  final File? xFile;
  final bool? isNotFriend;
  final String? videoFilePath;
  final String? duration;
  final String? type;

  const SendMessagesEvent({
    required this.userId,
    required this.messageId,
    this.chatId,
    this.message,
    this.duration,
    this.xFile,
    this.isNotFriend,
    this.videoFilePath,
    this.type,
  });

  @override
  List<Object?> get props =>
      [
        userId,
        chatId,
        isNotFriend,
        messageId,
        message,
        xFile,
        type,
        videoFilePath,
        duration
      ];
}

final class SendVideoMessagesEvent extends BaseSendMessagesEvent {
  final File? xFile;
  final String? duration;
  final String userId;

  /// Server conversation id of the open chat (0/null for a brand-new DM) — same
  /// role as on [SendMessagesEvent]: lets the send resolve the local drift room.
  final int? chatId;
  final String videoId;

  /// Local path of the extracted first-frame thumbnail, shown on the optimistic
  /// bubble while the video uploads (parity with the legacy in-memory bubble).
  final String? firstFramePath;

  const SendVideoMessagesEvent({
    this.duration,
    required this.videoId,
    this.xFile,
    this.chatId,
    this.firstFramePath,
    required this.userId,
  });

  @override
  List<Object?> get props =>
      [userId, chatId, xFile, videoId, duration, firstFramePath];
}

class PickVideoEvent extends BaseSendMessagesEvent {
  final BuildContext context;
  final String userId;
  final int? chatId;

// final CachedVideoPlayerController controller;
// final SendVideoMessageParam param;
  const PickVideoEvent(this.context, this.userId, {this.chatId}
      //  this.controller
      );

  @override
  List<Object?> get props =>
      [
        context, userId, chatId
        //controller
      ];
}
