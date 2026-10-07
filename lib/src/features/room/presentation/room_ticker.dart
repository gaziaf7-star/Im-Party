import 'dart:async';

class RoomTicker {
  RoomTicker._();
  static final RoomTicker instance = RoomTicker._();

  Timer? _timer;
  StreamController<int> _controller = StreamController<int>.broadcast();
  int _subscriberCount = 0;
  int _tick = 0;

  Stream<int> get stream => _controller.stream;

  StreamSubscription<int> subscribe(void Function(int tick) onTick) {
    _subscriberCount++;
    if (_subscriberCount == 1) _startTimer();
    final subscription = _controller.stream.listen(onTick);
    return subscription;
  }

  void unsubscribe(StreamSubscription<int>? subscription) {
    // Only mutate the shared ref-count when a real subscription is cancelled.
    // Callers commonly pass a null _tickerSubscription on first start / after a
    // prior stop; decrementing for those corrupts the count and can stop the
    // shared timer while other subscribers (PK / super-bomb) are still live.
    if (subscription == null) return;
    subscription.cancel();
    _subscriberCount--;
    if (_subscriberCount <= 0) {
      _subscriberCount = 0;
      _stopTimer();
    }
  }

  void _startTimer() {
    _tick = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick++;
      _controller.add(_tick);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _tick = 0;
  }

  void dispose() {
    _stopTimer();
    _subscriberCount = 0;
    _controller.close();
    // Re-create so the singleton is reusable for the next room session.
    _controller = StreamController<int>.broadcast();
  }
}
