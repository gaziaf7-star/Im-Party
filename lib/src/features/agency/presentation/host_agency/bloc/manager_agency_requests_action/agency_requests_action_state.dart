part of 'agency_requests_action_bloc.dart';



class AgencyRequestsActionState extends Equatable {
  final RequestState state;
  final String? message;
  final String? error;

  const AgencyRequestsActionState({
    this.state = RequestState.idle,
    this.message,
    this.error,
  });

  AgencyRequestsActionState copyWith({
    RequestState? state,
    String? message,
    String? error,
  }) {
    return AgencyRequestsActionState(
      state: state ?? this.state,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [state, message, error];
}
