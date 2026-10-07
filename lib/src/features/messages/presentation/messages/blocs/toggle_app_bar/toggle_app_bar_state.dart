part of 'toggle_app_bar_bloc.dart';

class ToggleAppBarState extends Equatable {
  final bool isToggle,isShowRoomCard, isReplying, isShowMore , isShowEmoje;
  final int counter;
  final String userId;
  final Map<int, MessageData> messageSelectionMap;
  final MessageData? replay;

  const ToggleAppBarState({
    this.isShowMore = false,  
    this.isToggle = false,
    this.isReplying = false,
    this.isShowEmoje = false,
    this.isShowRoomCard = false,
    this.counter = 0,
    this.userId = "-1",
    this.messageSelectionMap = const {},
    this.replay,
  });

  ToggleAppBarState copyWith({
    bool? isToggle,
    bool? isReplying,
    bool? isShowMore,
    bool? isShowEmoje,
    bool? isShowRoomCard,
    int? counter,
    String? userId,
    Map<int, MessageData>? messageSelectionMap,
    MessageData? replay,
    bool isReplayNull = false,
  }) {
    return ToggleAppBarState(
      isShowRoomCard: isShowRoomCard ?? this.isShowRoomCard,
      isToggle: isToggle ?? this.isToggle,
      isReplying: isReplying ?? this.isReplying,
      isShowMore: isShowMore ?? this.isShowMore,
      isShowEmoje: isShowEmoje ?? this.isShowEmoje,
      counter: counter ?? this.counter,
      userId: userId ?? this.userId,
      messageSelectionMap: messageSelectionMap ?? this.messageSelectionMap,
      replay: isReplayNull ? null : replay ?? this.replay,
    );
  }

  @override
  List<Object?> get props => [
        isToggle,
        isReplying,
        isShowMore,
        isShowEmoje,
        counter,
        userId,
        messageSelectionMap,
        replay,
    isShowRoomCard,
      ];
}

class MessageData extends Equatable {
  final String? senderId;
  final String? messageId;
  final bool isSelected;
  final String? url;
  final String? message;
  final String? messageType;

  const MessageData({
     this.senderId,
     this.messageId,
    this.isSelected = false,
     this.url,
     this.message,
     this.messageType,
  });

  // MessageData copyWith({
  //   String? senderId,
  //   String? messageId,
  //   bool? isSelected,
  //   String? url,
  //   String? message,
  //   String? type,
  // }) {
  //   return MessageData(
  //     senderId: senderId ?? this.senderId,
  //     messageId: messageId ?? this.messageId,
  //     isSelected: isSelected ?? this.isSelected,
  //     url: url ?? this.url,
  //     message: message ?? this.message,
  //     type: type ?? this.type,
  //   );
  // }

  @override
  List<Object?> get props => [
        senderId,
        messageId,
        isSelected,
        url,
        message,
        messageType,
      ];
}
