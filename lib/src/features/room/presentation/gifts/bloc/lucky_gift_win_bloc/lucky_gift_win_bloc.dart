import 'package:flutter_bloc/flutter_bloc.dart';
import 'lucky_gift_win_event.dart';
import 'lucky_gift_win_state.dart';

class LuckyGiftWinBloc extends Bloc<LuckyGiftWinEvent, LuckyGiftWinState> {
  final List<Map<String, dynamic>> _queue = [];

  LuckyGiftWinBloc() : super(LuckyGiftWinInitial()) {
    on<AddLuckyWinEvent>((event, emit) async {
      _queue.add({
        'winTimes': event.winTimes,
        'winnerImage': event.winnerImage,
      });
      if (_queue.length == 1) {
        emit(LuckyGiftWinQueueUpdated(List.unmodifiable(_queue)));
      }
    });

    on<RemoveLuckyWinEvent>((event, emit) {
      if (_queue.isNotEmpty) {
        _queue.removeAt(0);
        emit(LuckyGiftWinInitial());
      }
    });

    on<PlayNextLuckyWinEvent>((event, emit) {
      if (_queue.isNotEmpty) {
        emit(LuckyGiftWinQueueUpdated(List.unmodifiable(_queue)));
      }
    });

    on<ClearLuckyWinEvent>((event, emit) {
      if (_queue.isNotEmpty) {
        _queue.clear();
        emit(LuckyGiftWinInitial());
      }
    });
  }

  List<Map<String, String>> get queue => List.unmodifiable(_queue);
}
