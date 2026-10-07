part of 'make_react_bloc.dart';

class MakeReactState extends Equatable {
  final MessagesEntity? data;
  final RequestState reqState;

  const MakeReactState({
    this.data,
    this.reqState = RequestState.idle,
  });

  MakeReactState copyWith({
    MessagesEntity? data,
    RequestState? reqState,
  }) {
    return MakeReactState(
      data: data ?? this.data,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [data, reqState];
}
