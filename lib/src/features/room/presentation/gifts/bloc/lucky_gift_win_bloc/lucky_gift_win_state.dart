import 'package:equatable/equatable.dart';

abstract class LuckyGiftWinState extends Equatable {
  const LuckyGiftWinState();

  @override
  List<Object?> get props => [];
}

class LuckyGiftWinInitial extends LuckyGiftWinState {}

class LuckyGiftWinQueueUpdated extends LuckyGiftWinState {
  final List<Map<String, dynamic>> queue;

  const LuckyGiftWinQueueUpdated(this.queue);

  @override
  List<Object?> get props => [queue];
}
