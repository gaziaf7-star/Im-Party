part of 'check_admin_owner_bloc.dart';

class CheckAdminOwnerState extends Equatable {
  final RequestState requestState;
  final String message;

  const CheckAdminOwnerState({
    this.message = '',
    this.requestState = RequestState.idle,
  });

  CheckAdminOwnerState copyWith({
    RequestState? requestState,
    String? message,
  }) {
    return CheckAdminOwnerState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [requestState, message];
}
