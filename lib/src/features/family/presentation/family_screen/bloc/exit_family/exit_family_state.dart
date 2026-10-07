part of 'exit_family_bloc.dart';


class ExitFamilyState extends Equatable {
  final String? message;
  final String? error;
  final RequestState reqState;

  const ExitFamilyState({
    this.message ,
    this.error ,
    this.reqState = RequestState.loading,
  });

  ExitFamilyState copyWith({
    String? message,
    String? errorMsg,
    RequestState? reqState,
  }) {
    return ExitFamilyState(
      message: message ?? this.message,
      error: errorMsg ?? error,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [
    message,
    error,
    reqState,
  ];
}