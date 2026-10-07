part of 'get_vip_frames_bloc.dart';

class GetVipFramesState extends Equatable {

  final RequestState requestState;
  final List<VipFramesModel>? data;

  const GetVipFramesState({

    this.requestState = RequestState.idle,
    this.data,
  });

  GetVipFramesState copyWith({

    RequestState? requestState,
    List<VipFramesModel>? data,
  }) {
    return GetVipFramesState(
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