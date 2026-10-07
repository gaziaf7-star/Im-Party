part of 'get_wabbles_bloc.dart';

class GetWabblesState extends Equatable {
  final RequestState requestState;
  final List<WabblesModel>? data;

  const GetWabblesState({
    this.requestState = RequestState.idle,
    this.data,
  });

  GetWabblesState copyWith({
    RequestState? requestState,
    List<WabblesModel>? data,
  }) {
    return GetWabblesState(
      requestState: requestState ?? this.requestState,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
        requestState,
        data,
      ];
}
