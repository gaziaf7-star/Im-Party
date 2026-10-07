part of 'get_users_chat_bloc.dart';

class GetUsersChatState extends Equatable {
  final int totalChatMessages;
  final List<UserChatEntity> data;
  final NetworkExceptions? error;
  final RequestState reqState;
  final ScrollController scrollController;
  final int currentPage, lastPage;
  const GetUsersChatState({
    this.data = const [],
    this.error,
    this.reqState = RequestState.idle,
    this.totalChatMessages = 0,
    required this.scrollController,
    this.currentPage = 1,
    this.lastPage = -1,
  });

  GetUsersChatState copyWith({
    List<UserChatEntity>? data,
    NetworkExceptions? error,
    RequestState? reqState,
    int? totalChatMessages,
    ScrollController? scrollController,
    int? currentPage,
    int? lastPage,
  }) {
    return GetUsersChatState(
      totalChatMessages: totalChatMessages ?? this.totalChatMessages,
      data: data ?? this.data,
      error: error ?? this.error,
      reqState: reqState ?? this.reqState,
      scrollController: scrollController ?? this.scrollController,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
    );
  }

  /// Live unread total derived from the merged drift room list (#31/#32).
  /// Replaces the stale REST-only [totalChatMessages] counter in the badge:
  /// increments automatically when [MergeRoomsFromDrift] delivers new unread
  /// counts and decrements the instant [ReadMessageEvent] zeroes a room.
  int get totalUnreadFromDrift =>
      data.fold(0, (sum, room) => sum + room.unreadMessage);

  @override
  List<Object?> get props => [
    data,
    error,
    reqState,
    totalChatMessages,
    scrollController,
    currentPage,
    lastPage,
  ];
}
