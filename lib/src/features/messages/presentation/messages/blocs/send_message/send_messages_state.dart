part of 'send_messages_bloc.dart';

class SendMessagesState extends Equatable {
  final RequestState reqState;
  final String userId;
  final String? duration;
  final File? videoFile;

  const SendMessagesState({
    this.reqState = RequestState.idle,
    this.userId = '',
    this.duration = '',
    this.videoFile,
  });

  // NOTE: the `message:` param is intentionally a no-op kept for call-site
  // compatibility (error paths pass an error string). It is no longer stored —
  // the previous implementation rebuilt a TextEditingController on every
  // transition, leaking one controller per emission on the singleton bloc.
  // The view owns and disposes its own messageController; this state never fed
  // any widget.
  SendMessagesState copyWith({
    RequestState? reqState,
    String? message,
    String? userId,
    String? duration,
    File? videoFile,
  }) {
    return SendMessagesState(
      reqState: reqState ?? this.reqState,
      userId: userId ?? this.userId,
      duration: duration ?? this.duration,
      videoFile: videoFile ?? this.videoFile,
    );
  }

  @override
  List<Object?> get props => [
        reqState,
        userId,
        duration,
        videoFile,
      ];
}
