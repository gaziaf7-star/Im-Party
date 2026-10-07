part of'manger_get_vip_prev_bloc.dart';

abstract class MangerGetVipPrevEvent extends Equatable {
  const MangerGetVipPrevEvent();

  @override
  List<Object> get props => [];
}

class GetVipPrevEvent extends MangerGetVipPrevEvent {
  const GetVipPrevEvent();
}
class UpdatePrivacyItemEvent extends MangerGetVipPrevEvent{
  final String key;
  final bool isActive;

  const UpdatePrivacyItemEvent({required this.key, required this.isActive});
}