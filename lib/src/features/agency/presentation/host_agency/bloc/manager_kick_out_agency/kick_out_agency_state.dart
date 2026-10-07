part of 'kick_out_agency_bloc.dart';

class KickOutAgencyState extends Equatable {
  final RequestState state;
  final String? error;
  final String? message;

  const KickOutAgencyState({
    this.state = RequestState.idle,
    this.error,
    this.message,
  });

  @override
  List<Object?> get props => [state, error, message];

  KickOutAgencyState copyWith({
    RequestState? state,
    String? error,
    String? message,
  }) {
    return KickOutAgencyState(
      state: state ?? this.state,
      error: error,
      message: message,
    );
  }
}
