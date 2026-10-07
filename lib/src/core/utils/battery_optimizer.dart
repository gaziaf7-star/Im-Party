import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';

class BatteryOptimizer with WidgetsBindingObserver {
  static final BatteryOptimizer _instance = BatteryOptimizer._internal();
  factory BatteryOptimizer() => _instance;
  BatteryOptimizer._internal();

  bool _isInBackground = false;

  /// Initialize - call once at app start
  Future<void> initialize() async {
    try {
      WidgetsBinding.instance.addObserver(this);

      Methods.printLog('Battery optimizer initialized');
    } catch (e) {
      Methods.printLog('Error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _handleBackground();
        break;
      case AppLifecycleState.resumed:
        _handleForeground();
        break;
      default:
        break;
    }
  }

  void _handleBackground() async {
    _isInBackground = true;
    try {
      di<GiftBloc>().add(const ShowBannerEvent(show: false));
      di<GiftBloc>().add(
        const ShowGiftsEvent(
          isShowGift: false,
          pathGift: '',
          giftType: ShowGiftType.svga,
        ),
      );
      di<AlphaGiftManagerBloc>().add(const EndAlphaGift());
      GiftController().resetBannerQueue();
      GiftController().normalGiftsToShow.clear();

      Methods.printLog('Background mode');
    } catch (e) {
      Methods.printLog('Background error: $e');
    }
  }

  void _handleForeground() async {
    _isInBackground = false;
    try {
      Methods.printLog('Foreground mode');
    } catch (e) {
      Methods.printLog('Foreground error: $e');
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Methods.printLog('Battery optimizer disposed');
  }

  void resetState() {
    _isInBackground = false;
  }

  bool get isInBackground => _isInBackground;
}
