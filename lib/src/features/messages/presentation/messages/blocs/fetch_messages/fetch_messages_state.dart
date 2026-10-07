part of 'fetch_messages_bloc.dart';

class FetchMessagesState extends Equatable {
  final List<MessagesEntity> data;
  final UserNowRoomEntity? room;
  final bool? moveToMessage;
  final int? messageIdToMove;
  final int chatId;
  final String userId;
  final RequestState reqState;
  final ScrollController scrollController;
  final int currentPage, lastPage;
  final bool isPagination;

  const FetchMessagesState({
    this.data = const [],
    this.moveToMessage,
    this.userId = '-1',
    this.messageIdToMove,
    this.chatId = -1,
    this.reqState = RequestState.loading,
    required this.scrollController,
    this.currentPage = 1,
    this.lastPage = -1,
    this.room,
    this.isPagination=false,
  });

  FetchMessagesState copyWith({
    List<MessagesEntity>? data,
    UserNowRoomEntity? room,
    RequestState? reqState,
    bool? moveToMessage,
    bool? isPagination,
    int? messageIdToMove,
    int? chatId,
    ScrollController? scrollController,
    int? currentPage,
    int? lastPage,
    String? userId,
  }) {
    return FetchMessagesState(
        data: data ?? this.data,
        userId: userId ?? this.userId,
        room: room ?? this.room,
        reqState: reqState ?? this.reqState,
        moveToMessage: moveToMessage ?? this.moveToMessage,
        isPagination: isPagination ?? this.isPagination,
        messageIdToMove: messageIdToMove ?? this.messageIdToMove,
        chatId: chatId ?? this.chatId,
        scrollController: scrollController ?? this.scrollController,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage);
  }

  @override
  List<Object?> get props => [
        data,
        reqState,
        chatId,
        userId,
        messageIdToMove,
        moveToMessage,
        scrollController,
        currentPage,
        lastPage,
        room,
        isPagination
      ];
}
