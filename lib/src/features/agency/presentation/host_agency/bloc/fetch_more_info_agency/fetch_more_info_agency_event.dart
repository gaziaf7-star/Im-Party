part of 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_more_info_agency/fetch_more_info_agency_bloc.dart';

abstract class FetchMoreInfoAgencyEvent extends Equatable {
  const FetchMoreInfoAgencyEvent();

  @override
  List<Object?> get props => [];
}

class FetchMoreInfoForMonthEvent extends FetchMoreInfoAgencyEvent {
  final String year;
  final String month;
  final String agencyId;
  final String page;

  const FetchMoreInfoForMonthEvent({
    required this.year,
    required this.month,
    required this.agencyId,
    required this.page,
  });

  @override
  List<Object?> get props => [year, month, agencyId, page];
}

class HostSAgencyDataUCEvent extends FetchMoreInfoAgencyEvent {
  final String year;
  final String month;
  final String agencyId;

  const HostSAgencyDataUCEvent({
    required this.year,
    required this.month,
    required this.agencyId,
  });

  @override
  List<Object?> get props => [year, month, agencyId];
}

class AddUserTargetScrollListenerEvent extends FetchMoreInfoAgencyEvent {
  const AddUserTargetScrollListenerEvent();
}

class RemoveUserTargetScrollListenerEvent extends FetchMoreInfoAgencyEvent {
  const RemoveUserTargetScrollListenerEvent();
}
