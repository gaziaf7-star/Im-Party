
part of 'agency_time_bloc.dart';

class AgencyTimeState extends Equatable {
  final List<AgencyHistoryEntity>? data;
  final String? error;
  final RequestState requestState;
  final String? month;
  final String? year;
  final ScrollController agencyHistoryScrollController;
  final int agencyHistoryCurrentPage;
  final int agencyHistoryLastPage;

  const AgencyTimeState({
    this.data,
    this.error,
    this.month,
    this.year,
    this.requestState = RequestState.idle,
    required this.agencyHistoryScrollController,
    this.agencyHistoryCurrentPage = 1,
    this.agencyHistoryLastPage = -1,
  });

  AgencyTimeState copyWith({
    List<AgencyHistoryEntity>? data,
    String? error,
    String? month,
    String? year,
    RequestState? requestState,
    ScrollController? agencyHistoryScrollController,
    int? agencyHistoryCurrentPage,
    int? agencyHistoryLastPage,

  }) {
    return AgencyTimeState(
      data: data ?? this.data,
      error: error ?? this.error,
      month: month ?? this.month,
      year: year ?? this.year,
      requestState: requestState ?? this.requestState,
      agencyHistoryScrollController:
          agencyHistoryScrollController ?? this.agencyHistoryScrollController,
      agencyHistoryCurrentPage:
          agencyHistoryCurrentPage ?? this.agencyHistoryCurrentPage,
      agencyHistoryLastPage:
          agencyHistoryLastPage ?? this.agencyHistoryLastPage,
    );
  }

  @override
  List<Object?> get props => [
        data,
        error,
        requestState,
        agencyHistoryScrollController,
        agencyHistoryCurrentPage,
        agencyHistoryLastPage,
      ];
}
