import 'package:equatable/equatable.dart';

abstract class LuckyGiftWinEvent extends Equatable {
  const LuckyGiftWinEvent();

  @override
  List<Object?> get props => [];
}

class AddLuckyWinEvent extends LuckyGiftWinEvent {
  final int winTimes;
  final String winnerImage;

  const AddLuckyWinEvent({required this.winTimes, required this.winnerImage});

  @override
  List<Object?> get props => [winTimes, winnerImage];
}

class RemoveLuckyWinEvent extends LuckyGiftWinEvent {
  const RemoveLuckyWinEvent();
}
class PlayNextLuckyWinEvent extends LuckyGiftWinEvent {
  const PlayNextLuckyWinEvent();
}

class ClearLuckyWinEvent extends LuckyGiftWinEvent {
  const ClearLuckyWinEvent();
}
