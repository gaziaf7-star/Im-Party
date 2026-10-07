part of 'fetch_agency_admins_bloc.dart';




abstract class FetchAgencyAdminsEvent extends Equatable {
  const FetchAgencyAdminsEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminsForMonthEvent extends FetchAgencyAdminsEvent {
  final String year;
  final String month;
  final String agencyId;
  final String? page;

  const FetchAdminsForMonthEvent({
    required this.year,
    required this.month,
    required this.agencyId,
    this.page,
  });

  @override
  List<Object?> get props => [year, month, agencyId,page];
}
