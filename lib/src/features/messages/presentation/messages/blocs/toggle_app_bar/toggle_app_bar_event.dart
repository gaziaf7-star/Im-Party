part of 'toggle_app_bar_bloc.dart';

sealed class BaseToggleAppBarEvent extends Equatable {
  const BaseToggleAppBarEvent();

  @override
  List<Object?> get props => [];
}
final class InitAppBarEvent extends BaseToggleAppBarEvent {
  const InitAppBarEvent();

}
final class ToggleAppBarEvent extends BaseToggleAppBarEvent {
  final bool isToggle;
  const ToggleAppBarEvent({required this.isToggle});

  @override
  List<Object?> get props => [isToggle];
}

final class ShowReplayBoxEvent extends BaseToggleAppBarEvent {
  final bool isReplying;
  const ShowReplayBoxEvent({required this.isReplying});

  @override
  List<Object?> get props => [isReplying];
}
final class CopyEvent extends BaseToggleAppBarEvent {
  const CopyEvent();

  @override
  List<Object?> get props => [];
}

final class ShowAttachBoxEvent extends BaseToggleAppBarEvent {
    final bool isShowMore;
  const ShowAttachBoxEvent({required this.isShowMore });

}

final class ShowRoomCardEvent extends BaseToggleAppBarEvent {
  final bool? isShowRoomCard;
  const ShowRoomCardEvent({this.isShowRoomCard});
}

final class ShowEmojeBoxEvent extends BaseToggleAppBarEvent {
  const ShowEmojeBoxEvent();
}

final class SelectedMessagesEvent extends BaseToggleAppBarEvent {
  final String messageId;
  final String senderId;
  final String? url;
  final String message;
  final String messageType;

  const SelectedMessagesEvent({
    required this.messageId,
    required this.senderId,
    this.url,
    required this.message,
    required this.messageType,
  });

  @override
  List<Object?> get props => [
        messageId,
        senderId,
        url,
        message,
        messageType,
      ];
}
