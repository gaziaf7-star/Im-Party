part of 'cp_request_bloc.dart';

class CpRequestStates extends Equatable {
  final RequestState userStates;
  final String errorMessage;
  final String message;
  final String? loadingUserId;

  const CpRequestStates({
    this.userStates = RequestState.idle,
    this.errorMessage = '',
    this.message = '',
    this.loadingUserId = '',
  });

  CpRequestStates copyWith({
    RequestState? userStates,
    String? errorMessage,
    String? message,
    String? loadingUserId,
  }) {
    return CpRequestStates(
      userStates: userStates ?? this.userStates,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      loadingUserId: loadingUserId ?? this.loadingUserId,
    );
  }

  @override
  List<Object?> get props => [
        userStates,
        errorMessage,
        message,
        loadingUserId,
      ];
}
