part of 'agency_time_bloc.dart';

abstract class BaseAgencyTimeEvent extends Equatable {
  const BaseAgencyTimeEvent();

  @override
  List<Object?> get props => [];
}

class AgencyHistoryEvent extends BaseAgencyTimeEvent {
  final bool? isFirstLoading;
  final String month;
  final String year;
  const AgencyHistoryEvent({
        required this.month,
    required this.year,
    this.isFirstLoading = false,
  });

  @override
  List<Object?> get props => [month,year];
}
//
// class SetAgencyTimeHistoryEvent extends BaseAgencyTimeEvent {
//   final String month;
//   final String year;
//   final bool? isCallTheEvent;
//
//   const SetAgencyTimeHistoryEvent({
//     required this.month,
//     required this.year,
//     this.isCallTheEvent = false,
//   });
//
//   @override
//   List<Object?> get props => [month, year];
// }

class AgencyHistoryAddListenerEvent extends BaseAgencyTimeEvent {
  const AgencyHistoryAddListenerEvent();

  @override
  List<Object?> get props => [];
}

class AgencyHistoryRemoveListenerEvent extends BaseAgencyTimeEvent {
  const AgencyHistoryRemoveListenerEvent();

  @override
  List<Object?> get props => [];
}

class AgencyHistoryEditListLocallyEvent extends BaseAgencyTimeEvent {
  final String? userId;
  final String type;
final AgencyHistoryEntity? userAdded;
  const AgencyHistoryEditListLocallyEvent({
     this.userId,
    required this.type,
     this.userAdded,
  });

  @override
  List<Object?> get props => [userId, type,userAdded];
}
