import 'package:general/src/features/room/presentation/gifts/view/component/lucky_gift/lucky_gift_animation.dart';

abstract class LuckyGiftAnaimationManagerState {
  List<LuckyGiftSeatAnimation>? data;
  LuckyGiftAnaimationManagerState(this.data);
}

class LuckyGiftAnimationInitial extends LuckyGiftAnaimationManagerState {
  LuckyGiftAnimationInitial(super.data);
}

class LuckyGiftAnimationSucssesState extends LuckyGiftAnaimationManagerState {
  LuckyGiftAnimationSucssesState({required data}) : super(data);
}
