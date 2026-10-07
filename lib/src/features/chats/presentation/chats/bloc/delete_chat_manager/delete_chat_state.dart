part of'delete_chat_bloc.dart';

class DeleteChatState extends Equatable {
  final BaseResponse<DeleteChatEntity>? data;
  final NetworkExceptions? errorMsg;
  final RequestState reqState;

  const DeleteChatState({
    this.data ,
    this.errorMsg ,
    this.reqState = RequestState.loading,
  });

  DeleteChatState copyWith({
    BaseResponse<DeleteChatEntity>? data,
    NetworkExceptions? errorMsg,
    RequestState? reqState,
  }) {
    return DeleteChatState(
      data: data ?? this.data,
      errorMsg: errorMsg ?? this.errorMsg,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [
    data,
    errorMsg,
    reqState,
  ];
}