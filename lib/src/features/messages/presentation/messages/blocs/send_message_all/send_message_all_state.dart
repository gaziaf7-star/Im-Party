
part of 'send_message_all_bloc.dart';

class SendMessageAllState extends Equatable {
  final String? responseData;
  final RequestState reqState;
  final String? errorMessage;
  final TextEditingController messageController;

  const SendMessageAllState({
    this.responseData,
    this.reqState = RequestState.idle,
    this.errorMessage,
    required this.messageController,
  });

  SendMessageAllState copyWith({
    String? responseData,
    RequestState? reqState,
    String? errorMessage,
    String? message,
  }) {
    return SendMessageAllState(
      responseData: responseData ?? this.responseData,
      reqState: reqState ?? this.reqState,
      errorMessage: errorMessage ?? this.errorMessage,
      messageController: messageController.copyWith(text: message),
    );
  }

  @override
  List<Object?> get props => [responseData, reqState, errorMessage, messageController];
}
