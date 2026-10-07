part of 'get_charge_agency_details_bloc.dart';

abstract class BaseGetChargeAgencyDetailsEvent extends Equatable {
  const BaseGetChargeAgencyDetailsEvent();

  @override
  List<Object?> get props => [];
}

class GetChargeAgencyDetailsSenderEvent
    extends BaseGetChargeAgencyDetailsEvent {
  final bool isFirstLoading;

  const GetChargeAgencyDetailsSenderEvent({this.isFirstLoading = false});

  @override
  List<Object?> get props => [isFirstLoading];
}

class GetChargeAgencyDetailsReceiverEvent
    extends BaseGetChargeAgencyDetailsEvent {
  final bool isFirstLoading;

  const GetChargeAgencyDetailsReceiverEvent({this.isFirstLoading = false});

  @override
  List<Object?> get props => [isFirstLoading];
}

class SenderAddListenerEvent extends BaseGetChargeAgencyDetailsEvent {
  const SenderAddListenerEvent();
}

class SenderRemoveListenerEvent extends BaseGetChargeAgencyDetailsEvent {
  const SenderRemoveListenerEvent();
}

class ReceiverAddListenerEvent extends BaseGetChargeAgencyDetailsEvent {
  const ReceiverAddListenerEvent();
}

class ReceiverRemoveListenerEvent extends BaseGetChargeAgencyDetailsEvent {
  const ReceiverRemoveListenerEvent();
}

class ClearDataSenderEvent extends BaseGetChargeAgencyDetailsEvent {
  const ClearDataSenderEvent();
}

class ClearDataReceiverEvent extends BaseGetChargeAgencyDetailsEvent {
  const ClearDataReceiverEvent();
}
