part of"agency_host_report_bloc.dart";

abstract class BaseAgencyHostReportEvent extends Equatable {
  const BaseAgencyHostReportEvent();
}

class AgencyHostReportEvent extends BaseAgencyHostReportEvent {
  final String mounth;
  final String year;
  final bool isFirsLoading;

  const AgencyHostReportEvent({
    required this.mounth,
    required this.year,
    this.isFirsLoading = false,
  });

  @override
  List<Object?> get props => [mounth, year, isFirsLoading];
}

class EditCutOutLocallyEvent extends BaseAgencyHostReportEvent {
  final int usd;

  const EditCutOutLocallyEvent({
    required this.usd
  });

  @override
  List<Object?> get props => [usd];
}
