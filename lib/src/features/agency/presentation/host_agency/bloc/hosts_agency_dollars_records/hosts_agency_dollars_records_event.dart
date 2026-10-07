part of 'hosts_agency_dollars_records_bloc.dart';


abstract class HostsAgencyDollarsRecordsEvent extends Equatable {
 const HostsAgencyDollarsRecordsEvent();

 @override
 List<Object?> get props => [];
}

class GetSenderHostsAgencyRecordsEvent extends HostsAgencyDollarsRecordsEvent {
 final bool isFirstLoading;

 const GetSenderHostsAgencyRecordsEvent({this.isFirstLoading = true});
}

class GetReceiverHostsAgencyRecordsEvent extends HostsAgencyDollarsRecordsEvent {
 final bool isFirstLoading;

 const GetReceiverHostsAgencyRecordsEvent({this.isFirstLoading = true});
}

class SenderAddListenerEvent extends HostsAgencyDollarsRecordsEvent {}

class SenderRemoveListenerEvent extends HostsAgencyDollarsRecordsEvent {}

class ReceiverAddListenerEvent extends HostsAgencyDollarsRecordsEvent {}

class ReceiverRemoveListenerEvent extends HostsAgencyDollarsRecordsEvent {}
