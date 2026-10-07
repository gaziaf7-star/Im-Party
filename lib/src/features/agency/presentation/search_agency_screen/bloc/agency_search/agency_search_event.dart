part of 'agency_search_bloc.dart';

abstract class BaseAgencySearchEvent extends Equatable {
  const BaseAgencySearchEvent();

  @override
  List<Object?> get props => [];
}

class FetchFixedAgencyEvent extends BaseAgencySearchEvent {
  final String id;

  const FetchFixedAgencyEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class FetchRegularAgencyEvent extends BaseAgencySearchEvent {
  final String id;
  // When true the request is a pagination fetch (append next page) instead of a
  // fresh first-page search (replace).
  final bool isLoadMore;

  const FetchRegularAgencyEvent({required this.id, this.isLoadMore = false});

  @override
  List<Object?> get props => [id, isLoadMore];
}

class AgencySearchAddListenerEvent extends BaseAgencySearchEvent {
  const AgencySearchAddListenerEvent();
}

class AgencySearchRemoveListenerEvent extends BaseAgencySearchEvent {
  const AgencySearchRemoveListenerEvent();
}

class ResetAgencyEvent extends BaseAgencySearchEvent {}

class FetchFormListEvent extends BaseAgencySearchEvent {
  final String type;
  final BuildContext context;

  const FetchFormListEvent({required this.context, this.type = ''});

  @override
  List<Object?> get props => [type, context];
}

class JoinAgencyLocalEvent extends BaseAgencySearchEvent {
  final String agencyId;

  const JoinAgencyLocalEvent(this.agencyId);

  @override
  List<Object> get props => [agencyId];
}

