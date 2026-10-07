part of 'get_vip_frames_bloc.dart';

abstract class BaseGetVipFrameEvent extends Equatable {
  const BaseGetVipFrameEvent();
  @override
  List<Object?> get props => [];
}

final class GetVipFramesEvent extends BaseGetVipFrameEvent {}

