part of 'join_to_agency_bloc.dart';

class JoinToAgencyState extends Equatable {
  final RequestState state; // To track loading, success, error
  final bool? success; // Only used in success state
  final String? message; // Only used in error state

  const JoinToAgencyState({
    this.state = RequestState.idle,
    this.success,
    this.message,
  });

  JoinToAgencyState copyWith({
    RequestState? state,
    bool? success,
    String? message,
  }) {
    return JoinToAgencyState(
      state: state ?? this.state,
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [state, success, message];
}
