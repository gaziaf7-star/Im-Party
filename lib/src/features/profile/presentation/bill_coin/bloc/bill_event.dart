part of'bill_bloc.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object> get props => [];
}

class GetBillRechargeEvent extends BillEvent {
  final BillParam? param;
  const GetBillRechargeEvent({this.param});
}

class AddListenerRechargeEvent extends BillEvent {
  final BillParam? param;
  const AddListenerRechargeEvent({this.param});
}

class RemoveListenerRechargeEvent extends BillEvent {
  final BillParam? param;
  const RemoveListenerRechargeEvent({this.param});
}

class GetBillReceivedEvent extends BillEvent {

  final BillParam? param;
  const GetBillReceivedEvent({this.param});
}

class AddListenerBillReceivedEvent extends BillEvent {

  final BillParam? param;
  const AddListenerBillReceivedEvent({this.param});
}

class RemoveListenerBillReceivedEvent extends BillEvent {

  final BillParam? param;
  const RemoveListenerBillReceivedEvent({this.param});
}
class GetBillGivingEvent extends BillEvent {

  final BillParam? param;
  const GetBillGivingEvent({this.param});
}

class AddListenerBillGivingEvent extends BillEvent {

  final BillParam? param;
  const AddListenerBillGivingEvent({this.param});
}

class RemoveListenerBillGivingEvent extends BillEvent {

  final BillParam? param;
  const RemoveListenerBillGivingEvent({this.param});
}

class BillSelectEvent extends BillEvent {

  final String? start;
  final String? end;
  const BillSelectEvent({this.start,this.end});
}


