
import 'package:equatable/equatable.dart';

sealed class BaseGetBannerEvents extends Equatable {
  const BaseGetBannerEvents();
  @override
  List<Object?> get props => [];
}
 class GetBannerEvent extends BaseGetBannerEvents {
  const GetBannerEvent();

}
class StartCountdownEvent extends BaseGetBannerEvents {}

class OnSkipEvent extends BaseGetBannerEvents {}

class UpdateCountdownEvent extends BaseGetBannerEvents {
  final int countdown;

  const UpdateCountdownEvent(this.countdown);

  @override
  List<Object> get props => [countdown];
}

/*class ShowBannerEvent extends BaseGetBannerEvents {}

class HideBannerEvent extends BaseGetBannerEvents {}*/
