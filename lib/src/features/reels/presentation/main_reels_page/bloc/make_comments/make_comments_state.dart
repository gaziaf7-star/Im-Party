part of 'make_comments_bloc.dart';



class MakeCommentsState extends Equatable {
  final String errorMessage;
  final RequestState requestState;

  const MakeCommentsState({
    this.errorMessage = '',
    this.requestState = RequestState.idle,
  });

  MakeCommentsState copyWith({
    String? errorMessage,
    RequestState? requestState,
  }) {
    return MakeCommentsState(
      errorMessage: errorMessage ?? this.errorMessage,
      requestState: requestState ?? this.requestState,
    );
  }

  @override
  List<Object?> get props => [ errorMessage, requestState];
}
