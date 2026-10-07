part of'delete_account_bloc.dart';

class DeleteAccountState extends Equatable {
  final bool isActive;
  final String message;
  final RequestState requestState;

  const DeleteAccountState({
    this.requestState = RequestState.idle,
    this.message = '',
    this.isActive=false,
  });



  DeleteAccountState copyWith({
    bool? isActive,
    String? message,
    RequestState? requestState,
  }) {
    return DeleteAccountState(
      isActive: isActive ?? this.isActive,
      message: message ?? this.message,
      requestState: requestState ?? this.requestState,
    );
  }

  @override
  List<Object?> get props => [isActive, message, requestState];
}
