part of'delete_account_bloc.dart';

abstract class BaseDeleteAccountEvent extends Equatable {
  const BaseDeleteAccountEvent();

  @override
  List<Object> get props => [];
}

class DeleteAccountEvent extends BaseDeleteAccountEvent {
  const DeleteAccountEvent();
}

class SelectToReadEvent extends BaseDeleteAccountEvent{
  final bool isActive;

  const SelectToReadEvent({required this.isActive});
}