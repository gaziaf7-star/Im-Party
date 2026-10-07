part of 'fetch_agency_stars_bloc.dart';

class FetchAgencyStarsState extends Equatable {
  final List<UserStarEntity>? stars;
  final String? message;
  final RequestState requestState;

  const FetchAgencyStarsState({
    this.stars,
    this.message,
    this.requestState = RequestState.idle,
  });

  FetchAgencyStarsState copyWith({
    List<UserStarEntity>? stars,
    String? message,
    RequestState? requestState,
  }) {
    return FetchAgencyStarsState(
      stars: stars ?? this.stars,
      message: message ?? this.message,
      requestState: requestState ?? this.requestState,
    );
  }

  @override
  List<Object?> get props => [stars, message, requestState];
}
