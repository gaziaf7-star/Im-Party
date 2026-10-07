part of'manger_get_vip_prev_bloc.dart';

class MangerGetVipPrevState extends Equatable {
  final List<GetVipPrevModel> data;
  final String? error;
  final RequestState? requestState;

  const MangerGetVipPrevState({
    this.requestState = RequestState.loading,
    this.error = '',
    this.data=const[],
  });

  @override
  List<Object?> get props => [data, error, requestState];

  MangerGetVipPrevState copyWith({
    List<GetVipPrevModel>? data,
    String? error,
    RequestState? requestState,
  }) {
    return MangerGetVipPrevState(
      data: data ?? this.data,
      error: error ?? this.error,
      requestState: requestState ?? this.requestState,
    );
  }
}
