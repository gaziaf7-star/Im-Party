import 'package:general/src/core/index.dart';

class AddBlocOrRemoveState extends Equatable {
  final NetworkExceptions? errorMsgAddBloc;
  final RequestState requestStateAddBloc;
  final String? successAddBloc;

  final NetworkExceptions? errorMsgRemoveBloc;
  final RequestState requestStateRemoveBloc;
  final String? successRemoveBloc;

  const AddBlocOrRemoveState({
    this.errorMsgAddBloc,
    this.successAddBloc = '',
    this.requestStateAddBloc = RequestState.loading,

    this.errorMsgRemoveBloc,
    this.successRemoveBloc = '',
    this.requestStateRemoveBloc = RequestState.loading,
  });

  AddBlocOrRemoveState copyWith({
    NetworkExceptions? errorMsgAddBloc,
    RequestState? requestStateAddBloc,
    String? successAddBloc,

    NetworkExceptions? errorMsgRemoveBloc,
    RequestState? requestStateRemoveBloc,
    String? successRemoveBloc,
  }) {
    return AddBlocOrRemoveState(
      errorMsgAddBloc: errorMsgAddBloc ?? this.errorMsgAddBloc,
      requestStateAddBloc: requestStateAddBloc ?? this.requestStateAddBloc,
      successAddBloc: successAddBloc ?? this.successAddBloc,

      errorMsgRemoveBloc: errorMsgRemoveBloc ?? this.errorMsgRemoveBloc,
      requestStateRemoveBloc: requestStateRemoveBloc ?? this.requestStateRemoveBloc,
      successRemoveBloc: successRemoveBloc ?? this.successRemoveBloc,
    );
  }

  @override
  List<Object?> get props => [
        errorMsgAddBloc,
        requestStateAddBloc,
        successAddBloc,

        errorMsgRemoveBloc,
        requestStateRemoveBloc,
        successRemoveBloc,
      ];
}
