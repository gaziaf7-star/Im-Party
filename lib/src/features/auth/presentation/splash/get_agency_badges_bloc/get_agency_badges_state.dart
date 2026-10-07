part of 'get_agency_badges_bloc.dart';

class GetAgencyBadgesState extends Equatable {
  final RequestState requestState;
  final List<AgencyBadgeModel>? data;

  const GetAgencyBadgesState({
    this.requestState = RequestState.idle,
    this.data,
  });

  GetAgencyBadgesState copyWith({
    RequestState? requestState,
    List<AgencyBadgeModel>? data,
  }) {
    return GetAgencyBadgesState(
      requestState: requestState ?? this.requestState,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
        requestState,
        data,
      ];
}
