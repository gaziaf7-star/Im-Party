part of 'make_user_admin_bloc.dart';
class MakeUserAdminState extends Equatable {
  final RequestState requestState;
  final String? error;
  final String? message;

  const MakeUserAdminState({
    this.requestState = RequestState.idle,
    this.error,
    this.message,
  });

  MakeUserAdminState copyWith({
    RequestState? requestState,
    String? error,
    String? message,
  }) {
    return MakeUserAdminState(
      requestState: requestState ?? this.requestState,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [requestState, error, message];
}
