part of 'mall_send_bloc.dart';

abstract class MallSendState extends Equatable {
  const MallSendState();

  @override
  List<Object> get props => [];
}

class MallSendInitial extends MallSendState {}

class SendLoadingState extends MallSendState {}

class SendSuccessState extends MallSendState {
  final String message;
  const SendSuccessState({required this.message});

  @override
  List<Object> get props => [message];
}

class SendErrorState extends MallSendState {
  final String message;
  const SendErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
