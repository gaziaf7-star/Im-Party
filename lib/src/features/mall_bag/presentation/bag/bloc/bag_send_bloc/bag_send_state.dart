part of 'bag_send_bloc.dart';

abstract class BagSendState extends Equatable {

  @override
  List<Object?> get props => [];

  const BagSendState();
}

final class BagSendInitial extends BagSendState {}

class SendLoadingState extends BagSendState {}

class SendSuccessState extends BagSendState {
  final String message;
  const SendSuccessState({required this.message});

  @override
  List<Object> get props => [message];
}

class SendErrorState extends BagSendState {
  final String message;
  const SendErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
