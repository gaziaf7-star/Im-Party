part of'agency_requests_bloc.dart';

abstract class BaseAgencyRequestsEvent extends Equatable {
  const BaseAgencyRequestsEvent();

  @override
  List<Object?> get props => [];
}

class AgencyRequestsEvent extends BaseAgencyRequestsEvent {
  final String type;
final bool isFirstLoading;
  const AgencyRequestsEvent({
    required this.type,
     this.isFirstLoading=false,
  });

  @override
  List<Object?> get props => [type];
}
class AgencyRequestsMakeActionHandelerLocallyEvent extends BaseAgencyRequestsEvent {
  final String type;
  final String userId;
  const AgencyRequestsMakeActionHandelerLocallyEvent({
    required this.type,
    required this.userId,
  });

  @override
  List<Object?> get props => [type,userId];
}



class ApplicationAddListenerEvent extends BaseAgencyRequestsEvent {

  const ApplicationAddListenerEvent();
}

class ApplicationRemoveListenerEvent extends BaseAgencyRequestsEvent {
  const ApplicationRemoveListenerEvent();

}

class RecordAddListenerEvent extends BaseAgencyRequestsEvent {
  const RecordAddListenerEvent();
}

class RecordRemoveListenerEvent extends BaseAgencyRequestsEvent {
  const RecordRemoveListenerEvent();

}
