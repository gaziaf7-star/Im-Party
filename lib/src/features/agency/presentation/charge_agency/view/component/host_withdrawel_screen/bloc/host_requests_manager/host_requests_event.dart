part of 'host_requests_bloc.dart';

abstract class HostRequestsEvent {
  const HostRequestsEvent();
}

class GetHostRequestsEvent extends HostRequestsEvent {
  final String type;
  const GetHostRequestsEvent({required this.type});
}

class HostRequestActionEvent extends HostRequestsEvent {
  final String id;
  final String answer;
  const HostRequestActionEvent({required this.id , required this.answer});
}
class HostRequestDialogViewEvent extends HostRequestsEvent {
  final int newValue;
  const HostRequestDialogViewEvent({
    required this.newValue ,
});
}