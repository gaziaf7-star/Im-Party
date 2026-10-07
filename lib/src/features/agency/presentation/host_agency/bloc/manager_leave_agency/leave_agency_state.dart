part of 'leave_agency_bloc.dart';





class LeaveAgencyState extends Equatable {
  final RequestState state;
  final String? message;
  final String? error;

  const LeaveAgencyState({
    this.state = RequestState.idle,
    this.message,
    this.error,
  });

  LeaveAgencyState copyWith({
    RequestState? state,
    String? message,
    String? error,
  }) {
    return LeaveAgencyState(
      state: state ?? this.state,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [state, message, error];
}
