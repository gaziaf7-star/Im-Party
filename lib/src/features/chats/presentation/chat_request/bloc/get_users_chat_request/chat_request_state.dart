part of 'chat_request_bloc.dart';

class FetchChatRequestState extends Equatable {
  final int totalChatMessages;
  final List<UserChatEntity> data;
  final NetworkExceptions? error;
  final RequestState reqState;


  const FetchChatRequestState({
    this.data =  const [],
    this.error,
    this.reqState = RequestState.idle,
    this.totalChatMessages=0,
  });

  FetchChatRequestState copyWith({
    List<UserChatEntity>? data,
    NetworkExceptions? error,
    RequestState? reqState,
    int? totalChatMessages,
  }) {
    return FetchChatRequestState(
      totalChatMessages: totalChatMessages ?? this.totalChatMessages,
      data: data ?? this.data,
      error: error ?? this.error,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [
        data,
        error,
        reqState,
    totalChatMessages,
      ];
}
