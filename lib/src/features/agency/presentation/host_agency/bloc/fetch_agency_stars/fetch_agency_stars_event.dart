part of 'fetch_agency_stars_bloc.dart';




abstract class FetchAgencyStarsEvent extends Equatable {
  const FetchAgencyStarsEvent();

  @override
  List<Object?> get props => [];
}

class FetchStarsForMonthEvent extends FetchAgencyStarsEvent {
  final String year;
  final String month;
  final String agencyId;
  final String? page;

  const FetchStarsForMonthEvent({
    required this.year,
    required this.month,
    required this.agencyId,
     this.page,
  });

  @override
  List<Object?> get props => [year, month, page];
}
