import 'package:alpha_player_plugin/alpha_player_simple_view.dart';
import 'package:alpha_player_plugin/alpha_player_view.dart';
import 'package:general/src/core/cache/alpha_cache_manager.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/app_lifecycle_signal.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/gift_bloc/gift_bloc.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_bloc.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_event.dart';
import 'package:general/src/features/room/room.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CacheAlphaWidget extends StatefulWidget {
  final String url;
  final double? height, width;
  final bool? isLoop;
  final void Function()? detectError;

  /// When true, the looping native player is paused while off-screen or the app
  /// is backgrounded, and resumed when visible + foregrounded. Only honored for
  /// looping instances ([isLoop] == true); non-loop (gift) instances are never
  /// gated. Defaults to false so gift instances are unaffected.
  final bool pauseWhenHidden;

  const CacheAlphaWidget({
    required this.url,
    this.height,
    this.width,
    this.isLoop,
    this.detectError,
    this.pauseWhenHidden = false,
    super.key,
  });

  @override
  State<CacheAlphaWidget> createState() => _CacheAlphaWidgetState();
}

class _CacheAlphaWidgetState extends State<CacheAlphaWidget> {
  final AlphaAssetCacheManager _alphaCacheManager = AlphaAssetCacheManager();
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<bool?> _isError = ValueNotifier(null);

  String _cachedFilePath = '';
  bool _isDisposed = false;

  // ---- Looping-frame gating (only when widget.pauseWhenHidden && isLoop) ----
  late final GlobalKey _visibilityKey =
      GlobalKey(debugLabel: 'alpha_frame_gate');
  AlphaPlayerController? _alphaController;
  bool _isVisible = true;
  bool _isPaused = false;

  bool get _gateEnabled => widget.pauseWhenHidden && (widget.isLoop ?? false);

  @override
  void initState() {
    super.initState();
    if (_gateEnabled) {
      AppLifecycleSignal.isForeground.addListener(_applyGate);
    }
    if (widget.url.isNotEmpty) {
      _loadFile();
    } else {
      widget.detectError?.call();
      _isError.value = true;
    }
  }

  /// Resume the native loop when visible + foregrounded, pause it otherwise.
  /// Only runs for looping frame instances ([_gateEnabled]); gift (non-loop)
  /// instances never reach here. Idempotent via [_isPaused].
  void _applyGate() {
    if (!_gateEnabled || _isDisposed) return;
    final controller = _alphaController;
    if (controller == null) return;

    final shouldRun = _isVisible && AppLifecycleSignal.isForeground.value;

    if (shouldRun) {
      if (_isPaused) {
        _isPaused = false;
        controller.resume();
      }
    } else {
      if (!_isPaused) {
        _isPaused = true;
        controller.pause();
      }
    }
  }

  Future<void> _loadFile() async {
    final url = EndPoints.getImage(widget.url);

    _isLoading.value = true;
    _isError.value = null;

    try {
      final file = await _alphaCacheManager.getProcessedVideoFile(url);

      if (_isDisposed) return;

      if (file != null && await file.exists()) {
        _cachedFilePath = file.path;
        _isError.value = null;
      } else {
        _handleLoadError('[AlphaWidget Error] Asset not found');
      }
    } catch (e) {
      _handleLoadError('[AlphaWidget Error] $e');
    } finally {
      if (!_isDisposed) _isLoading.value = false;
    }
  }

  void _handleLoadError(String log) {
    widget.detectError?.call();
    _isError.value = true;
    Methods.printLog(log);
    _handleGiftFallback();
  }

  void _handleGiftFallback() {
    if (GiftController().normalGiftsToShow.isEmpty) return;

    Future.delayed(const Duration(seconds: 3), () {
      if (_isDisposed) return;

      if (GiftController().normalGiftsToShow.isNotEmpty) {
        GiftController().normalGiftsToShow.removeAt(0);
        final next = GiftController().normalGiftsToShow.isNotEmpty
            ? GiftController().normalGiftsToShow[0]
            : null;

        if (next != null && next['wappel']['wappelImage'] != '') {
          ShowEntroWidget.showEntro.value = next['wappel'];
        }
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (_isDisposed) return;

      if (GiftController().normalGiftsToShow.isEmpty) {
        di<GiftBloc>().add(const ShowGiftsEvent(
          pathGift: '',
          isShowGift: false,
          giftType: ShowGiftType.mp4,
        ));
        return;
      }

      final next = GiftController().normalGiftsToShow[0];
      final giftType = next['giftType'];
      final path = next['pathGift'];

      if (giftType == 'alpha') {
        di<AlphaGiftManagerBloc>().add(ShowAlphaGift(
          imgFile: path,
          isFamousGift: next['isShowGift'],
        ));
      } else {
        final type = {
          'vap': ShowGiftType.vap,
          'mp4': ShowGiftType.mp4,
          'svga': ShowGiftType.svga,
        }[giftType];

        di<GiftBloc>().add(ShowGiftsEvent(
          isShowGift: true,
          pathGift: path,
          isFamousGift: next['isFamousGift'],
          giftType: type ?? ShowGiftType.alpha,
        ));
      }

      if (next['wappel']['wappelImage'] != '') {
        ShowEntroWidget.showEntro.value = next['wappel'];
      }
    });
  }

  @override
  void didUpdateWidget(CacheAlphaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _loadFile();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (widget.pauseWhenHidden) {
      AppLifecycleSignal.isForeground.removeListener(_applyGate);
    }
    _alphaController = null;
    _isLoading.dispose();
    _isError.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (_, isLoading, __) {
        if (isLoading) return const SizedBox.shrink();

        return ValueListenableBuilder<bool?>(
          valueListenable: _isError,
          builder: (_, isError, __) {
            if (isError == true || _isDisposed || _cachedFilePath.isEmpty) {
              return const SizedBox.shrink();
            }

            final Widget player = AlphaPlayerSimpleView(
              path: _cachedFilePath,
              width: widget.width ?? MediaQuery.of(context).size.width,
              height: widget.height ?? MediaQuery.of(context).size.height,
              isLooping: widget.isLoop ?? false,
              onStarted: _gateEnabled
                  ? (controller) {
                      if (_isDisposed) return;
                      _alphaController = controller;
                      // A frame may finish starting while already hidden /
                      // backgrounded; reflect current gate state immediately.
                      _isPaused = false;
                      _applyGate();
                    }
                  : null,
              onCompleted: (_) {
                if (_isDisposed) return;

                SuperBoomController.superBoomVideo.value = "";
                SuperBoomController.superBoomVideoType.value = "";
                di<AlphaGiftManagerBloc>().add(const EndAlphaGift());

                if (GiftController().normalGiftsToShow.isNotEmpty) {
                  GiftController().normalGiftsToShow.removeAt(0);
                  Future.delayed(const Duration(milliseconds: 10), () {
                    _handleNextGift();
                  });
                }
              },
            );

            if (!_gateEnabled) return player;

            return VisibilityDetector(
              key: _visibilityKey,
              onVisibilityChanged: (info) {
                if (_isDisposed) return;
                final visible = info.visibleFraction > 0;
                if (visible == _isVisible) return;
                _isVisible = visible;
                _applyGate();
              },
              child: player,
            );
          },
        );
      },
    );
  }

  void _handleNextGift() {
    if (GiftController().normalGiftsToShow.isEmpty) {
      di<AlphaGiftManagerBloc>().add(const ShowAlphaGift(imgFile: ""));
      return;
    }

    final next = GiftController().normalGiftsToShow[0];
    final giftType = next['giftType'];
    final path = next['pathGift'];
    final wappel = next['wappel'];

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isDisposed) return;

      switch (giftType) {
        case 'alpha':
          di<AlphaGiftManagerBloc>().add(ShowAlphaGift(
            imgFile: path,
            isFamousGift: next['isShowGift'],
          ));
          break;
        case 'vap':
          di<GiftBloc>().add(ShowGiftsEvent(
            isShowGift: true,
            pathGift: path,
            isFamousGift: next['isFamousGift'],
            giftType: ShowGiftType.vap,
          ));
          break;
        case 'mp4':
          di<GiftBloc>().add(ShowGiftsEvent(
            isShowGift: true,
            pathGift: path,
            isFamousGift: next['isFamousGift'],
            giftType: ShowGiftType.mp4,
          ));
          break;
        default:
          di<GiftBloc>().add(ShowGiftsEvent(
            isShowGift: true,
            pathGift: path,
            isFamousGift: next['isFamousGift'],
            giftType: ShowGiftType.svga,
          ));
      }

      if (wappel != null && wappel['wappelImage'] != '') {
        ShowEntroWidget.showEntro.value = wappel;
      }
    });
  }
}