part of 'fetch_agency_heros_bloc.dart';



abstract class FetchAgencyHerosEvent extends Equatable {
  const FetchAgencyHerosEvent();

  @override
  List<Object?> get props => [];
}

class FetchHerosForMonthEvent extends FetchAgencyHerosEvent {
  final String year;
  final String month;
  final String agencyId;
  final String? page;

  const FetchHerosForMonthEvent({
    required this.year,
    required this.month,
    required this.agencyId,
     this.page,
  });

  @override
  List<Object?> get props => [year, month, agencyId,page];
}

