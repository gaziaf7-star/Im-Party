part of 'information_agency_bloc.dart';

abstract class BaseInformationAgencyEvent extends Equatable {
  const BaseInformationAgencyEvent();

  @override
  List<Object?> get props => [];
}

class InformationAgencyEvent extends BaseInformationAgencyEvent {
  final String month;
  final String year;
final bool? isFirstLoading;
final String? agencyId;
  const InformationAgencyEvent({
    required this.month,
    required this.year,
     this.agencyId,
    this.isFirstLoading = false,
  });

  @override
  List<Object?> get props => [month, year,agencyId];
}

class EditAgencyInformationLocallyEvent
    extends BaseInformationAgencyEvent {
  final String type;

  const EditAgencyInformationLocallyEvent({required this.type});

  @override
  List<Object?> get props => [type];
}
class EditAgentSalaryInformationLocallyEvent
    extends BaseInformationAgencyEvent {
  final int agentUsd;

  const EditAgentSalaryInformationLocallyEvent({required this.agentUsd});

  @override
  List<Object?> get props => [agentUsd];
}
