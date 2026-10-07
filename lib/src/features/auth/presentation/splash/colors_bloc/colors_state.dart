part of 'colors_bloc.dart';

class ColorsState extends Equatable {
  final RequestState reqState;
  final ColorsEntity? colors;
  final String message;

  const ColorsState({
    this.reqState = RequestState.idle,
    this.message = '',
    this.colors,
  });

  ColorsState copyWith({
    RequestState? reqState,
    ColorsEntity? colors,
    String? message,
  }) {
    return ColorsState(
      reqState: reqState ?? this.reqState,
      colors: colors ?? this.colors,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    colors,
    message,
    reqState,
  ];
}
