part of 'agency_memeber_charges_history_bloc.dart';


sealed class BaseAgencyMemeberChargesHistoryEvent extends Equatable {
  const BaseAgencyMemeberChargesHistoryEvent();

  @override
  List<Object?> get props => [];
}

class AgencyMemeberToUserChargesHistoryEvent
    extends BaseAgencyMemeberChargesHistoryEvent {
  final int page;
  final bool isFirstLoading;

  const AgencyMemeberToUserChargesHistoryEvent({
    this.isFirstLoading = false,
    this.page = 1,
  });

  @override
  List<Object?> get props => [ isFirstLoading,page];
}

class AgencyMemeberToAgencyChargesHistoryEvent
    extends BaseAgencyMemeberChargesHistoryEvent {
  final int page;

  final bool isFirstLoading;

  const AgencyMemeberToAgencyChargesHistoryEvent({
    this.isFirstLoading = false,    this.page = 1,

  });

  @override
  List<Object?> get props => [ isFirstLoading,page];
}

