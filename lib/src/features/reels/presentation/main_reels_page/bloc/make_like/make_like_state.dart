part of 'make_like_bloc.dart';

class MakeLikeState extends Equatable {
  final RequestState requestState;
  final String? successMessage;
  final String? errorMessage;

  const MakeLikeState({
    this.requestState = RequestState.idle,
    this.successMessage,
    this.errorMessage,
  });

  MakeLikeState copyWith({
    RequestState? requestState,
    String? successMessage,
    String? errorMessage,
  }) {
    return MakeLikeState(
      requestState: requestState ?? this.requestState,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    requestState,
    successMessage ?? '',
    errorMessage ?? '',
  ];
}
