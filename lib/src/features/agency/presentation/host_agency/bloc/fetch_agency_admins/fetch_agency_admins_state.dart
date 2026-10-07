part of 'fetch_agency_admins_bloc.dart';




class FetchAgencyAdminsState extends Equatable {
  final List<UserStarEntity>? admins;
  final String? message;
  final RequestState requestState;

  const FetchAgencyAdminsState({
    this.admins,
    this.message,
    this.requestState = RequestState.idle,
  });

  FetchAgencyAdminsState copyWith({
    List<UserStarEntity>? admins,
    String? message,
    RequestState? requestState,
  }) {
    return FetchAgencyAdminsState(
      admins: admins ?? this.admins,
      message: message ?? this.message,
      requestState: requestState ?? this.requestState,
    );
  }

  @override
  List<Object?> get props => [admins, message, requestState];
}
