part of 'fetch_agency_heros_bloc.dart';

class FetchAgencyHerosState extends Equatable {
  final List<UserStarEntity>? heros;
  final String? message;
  final RequestState requestState;

  const FetchAgencyHerosState({
    this.heros,
    this.message,
    this.requestState = RequestState.idle,
  });

  FetchAgencyHerosState copyWith({
    List<UserStarEntity>? heros,
    String? message,
    RequestState? requestState,
  }) {
    return FetchAgencyHerosState(
      heros: heros ?? this.heros,
      message: message ?? this.message,
      requestState: requestState ?? this.requestState,
    );
  }

  @override
  List<Object?> get props => [heros, message, requestState];
}
