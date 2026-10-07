

part of"agency_host_report_bloc.dart";
class AgencyHostReportState extends Equatable {
  final RequestState requestState;
  final AgencyHostReportEntity? data;
  final String? error;
  final String? month;
  final String? year;

  const AgencyHostReportState({
    this.requestState = RequestState.idle,
    this.data,
    this.error,
    this.month,
    this.year,
  });

  AgencyHostReportState copyWith({
    RequestState? requestState,
    AgencyHostReportEntity? data,
    String? error,
    String? month,
    String? year,
  }) {
    return AgencyHostReportState(
      requestState: requestState ?? this.requestState,
      data: data ?? this.data,
      error: error??this.error,
      month: month??this.month,
      year: year??this.year,
    );
  }

  @override
  List<Object?> get props => [requestState, data, error,month,year];
}
