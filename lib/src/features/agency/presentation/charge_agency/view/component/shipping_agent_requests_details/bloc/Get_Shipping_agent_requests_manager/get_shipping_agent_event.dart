part of 'get_shipping_agent_bloc.dart';

abstract class BaseGetShippingAgentRequestsEvent extends Equatable {
  const BaseGetShippingAgentRequestsEvent();

  @override
  List<Object?> get props => [];
}

class GetShippingAgentWaitingRequestsEvent
    extends BaseGetShippingAgentRequestsEvent {
  final bool isFirstLoading;

  const GetShippingAgentWaitingRequestsEvent({
    this.isFirstLoading = false,
  });

  @override
  List<Object?> get props => [isFirstLoading];
}

class GetShippingAgentAcceptedRequestsEvent
    extends BaseGetShippingAgentRequestsEvent {
  final bool isFirstLoading;

  const GetShippingAgentAcceptedRequestsEvent({
    this.isFirstLoading = false,
  });

  @override
  List<Object?> get props => [isFirstLoading];
}

class GetShippingAgentRejectedRequestsEvent
    extends BaseGetShippingAgentRequestsEvent {
  final bool isFirstLoading;

  const GetShippingAgentRejectedRequestsEvent({
    this.isFirstLoading = false,
  });

  @override
  List<Object?> get props => [isFirstLoading];
}

class GetShippingAgentTransferredRequestsEvent
    extends BaseGetShippingAgentRequestsEvent {
  final bool isFirstLoading;

  const GetShippingAgentTransferredRequestsEvent({
    this.isFirstLoading = false,
  });

  @override
  List<Object?> get props => [isFirstLoading];
}

class GetShippingAgentCompleteRequestsEvent
    extends BaseGetShippingAgentRequestsEvent {
  final bool isFirstLoading;

  const GetShippingAgentCompleteRequestsEvent({
    this.isFirstLoading = false,
  });

  @override
  List<Object?> get props => [isFirstLoading];
}

class WaitingAddListenerEvent extends BaseGetShippingAgentRequestsEvent {
 const WaitingAddListenerEvent();


  @override
  List<Object?> get props => [];
}

class WaitingRemoveListenerEvent extends BaseGetShippingAgentRequestsEvent {
  const WaitingRemoveListenerEvent();

  @override
  List<Object?> get props => [];
}

class AcceptedAddListenerEvent extends BaseGetShippingAgentRequestsEvent {
  const AcceptedAddListenerEvent();

  @override
  List<Object?> get props => [];
}

class AcceptedRemoveListenerEvent extends BaseGetShippingAgentRequestsEvent {
  const AcceptedRemoveListenerEvent();

  @override
  List<Object?> get props => [];
}

class TransferredAddListenerEvent extends BaseGetShippingAgentRequestsEvent {
  const TransferredAddListenerEvent();

  @override
  List<Object?> get props => [];
}

class TransferredRemoveListenerEvent extends BaseGetShippingAgentRequestsEvent {
  const TransferredRemoveListenerEvent();

  @override
  List<Object?> get props => [];
}

class CompletedAddListenerEvent extends BaseGetShippingAgentRequestsEvent {

  const CompletedAddListenerEvent();
  @override
  List<Object?> get props => [];
}

class CompletedRemoveListenerEvent extends BaseGetShippingAgentRequestsEvent {
  const CompletedRemoveListenerEvent();
  @override
  List<Object?> get props => [];
}

class RejectedAddListenerEvent extends BaseGetShippingAgentRequestsEvent {
  const RejectedAddListenerEvent();
  @override
  List<Object?> get props => [];
}

class RejectedRemoveListenerEvent extends BaseGetShippingAgentRequestsEvent {
  const RejectedRemoveListenerEvent();
  @override
  List<Object?> get props => [];
}




class AddListenerForAllEvent extends BaseGetShippingAgentRequestsEvent {
  const AddListenerForAllEvent();
  @override
  List<Object?> get props => [];
}

class RemoveListenerForAllEvent extends BaseGetShippingAgentRequestsEvent {
  const RemoveListenerForAllEvent();
  @override
  List<Object?> get props => [];
}






class AcceptRequestLocalEvent extends BaseGetShippingAgentRequestsEvent {
  final int? id;

  const AcceptRequestLocalEvent({
    required this.id,
  });
}

class RejectRequestLocalEvent extends BaseGetShippingAgentRequestsEvent {
  final int? id;

  const RejectRequestLocalEvent({
    required this.id,
  });
}

class ConfirmRequestLocalEvent extends BaseGetShippingAgentRequestsEvent {
  final int? id;

  const ConfirmRequestLocalEvent({
    required this.id,
  });
}

class HandleConfirmationBodyEvent extends BaseGetShippingAgentRequestsEvent {
  final int? id;

  const HandleConfirmationBodyEvent({this.id});
}

class PickConfirmationImageEvent extends BaseGetShippingAgentRequestsEvent {
  final int quality;

  const PickConfirmationImageEvent({required this.quality});

  @override
  List<Object?> get props => [quality];
}

class UnPickConfirmationImageEvent extends BaseGetShippingAgentRequestsEvent {
  const UnPickConfirmationImageEvent();

  @override
  List<Object?> get props => [];
}