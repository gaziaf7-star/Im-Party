part of 'use_un_use_bloc.dart';

class UseUnUseState {
  final String? useSuccess;
  final RequestState? useState;
  final String? useError;
  final String? unUseSuccess;
  final RequestState? unUseState;
  final String? unUseError;

  const UseUnUseState(
      {this.unUseError = '',
      this.unUseState = RequestState.loading,
      this.unUseSuccess = '',
      this.useError = '',
      this.useState = RequestState.loading,
      this.useSuccess = ''});

  UseUnUseState copyWith({
    String? useSuccess,
    RequestState? useState,
    String? useError,
    String? unUseSuccess,
    RequestState? unUseState,
    String? unUseError,
  }) {
    return UseUnUseState(
      unUseError: unUseError??this.unUseError,
      unUseState: unUseState??this.unUseState,
      unUseSuccess: unUseSuccess??this.unUseSuccess,
      useError: useError??this.useError,
      useState: useState??this.useState,
      useSuccess: useSuccess??this.useSuccess,
    );
  }
}
