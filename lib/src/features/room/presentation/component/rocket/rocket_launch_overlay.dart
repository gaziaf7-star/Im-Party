import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_svga/flutter_svga.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/index.dart';

import 'rocket_realtime_controller.dart';

/// Full-screen rocket launch overlay. When the rocket launches it plays ONLY
/// the level's own `launch_animation` (SVGA from the rocket API) once, then
/// dismisses itself.
class RocketLaunchOverlay extends StatelessWidget {
  const RocketLaunchOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: RocketRealtimeController.instance.launchEvent,
      builder: (context, data, _) {
        if (data == null) return const SizedBox.shrink();

        return Positioned.fill(
          child: IgnorePointer(
            child: _LaunchAnimation(
              key: ValueKey(data['event_id'] ?? data['launch_id']),
              data: data,
            ),
          ),
        );
      },
    );
  }
}

class _LaunchAnimation extends StatefulWidget {
  final Map<String, dynamic> data;

  const _LaunchAnimation({super.key, required this.data});

  @override
  State<_LaunchAnimation> createState() => _LaunchAnimationState();
}

class _LaunchAnimationState extends State<_LaunchAnimation>
    with SingleTickerProviderStateMixin {
  /// Safety net so a stuck download/decode can never leave the overlay up.
  static const Duration _maxDuration = Duration(seconds: 25);

  /// How long to wait for the SVGA before showing the banner on its own.
  static const Duration _bannerFallbackDelay = Duration(seconds: 3);

  /// How long the banner stays when shown without the animation (matches the
  /// banner's own slide-in / hold / slide-out duration).
  static const Duration _bannerOnlyDuration = Duration(seconds: 10);

  late final SVGAAnimationController _controller;
  Timer? _safetyTimer;
  Timer? _bannerFallbackTimer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = SVGAAnimationController(vsync: this);
    _safetyTimer = Timer(_maxDuration, _finish);
    _play();
  }

  Map<String, dynamic>? _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  String _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.toLowerCase() == 'null' ? '' : text;
  }

  /// First non-empty `launch_animation` found anywhere under [node].
  String _findAnimation(dynamic node) {
    if (node is Map) {
      final direct = _text(node['launch_animation']);
      if (direct.isNotEmpty) return direct;
      for (final v in node.values) {
        final found = _findAnimation(v);
        if (found.isNotEmpty) return found;
      }
    } else if (node is List) {
      for (final v in node) {
        final found = _findAnimation(v);
        if (found.isNotEmpty) return found;
      }
    }
    return '';
  }

  /// The launch event may only carry the level number: fall back to the level
  /// list of the latest rocket state.
  String _animationFromLevelList() {
    final level = _asMap(widget.data['level']);
    final levelNo =
        _text(widget.data['level_no'] ?? level?['level_no'] ?? level?['level']);
    final rocket = RocketRealtimeController.instance.latestRocket.value;
    final levels = rocket?['levels'];
    if (levelNo.isEmpty || levels is! List) return '';
    for (final lv in levels) {
      if (lv is Map && _text(lv['level_no'] ?? lv['level']) == levelNo) {
        return _text(lv['launch_animation']);
      }
    }
    return '';
  }

  Future<void> _play() async {
    var url = _findAnimation(widget.data);
    if (url.isEmpty) url = _animationFromLevelList();
    Methods.printLog('🚀 [Rocket] launch animation url = "$url"');
    if (url.isEmpty) {
      _showBannerOnly();
      return;
    }
    // The launch SVGA is large; on a slow connection it may not be ready for
    // a long time. Don't hold the winner banner hostage to it.
    _bannerFallbackTimer = Timer(_bannerFallbackDelay, _showBannerOnly);
    try {
      // Prepared ahead of time (the file is ~24 MB); fall back to loading it
      // now only if it was never prepared or failed.
      final prepared =
          RocketRealtimeController.instance.takePreparedLaunch(url);
      var movie = prepared == null ? null : await prepared;
      movie ??=
          await SvgaMovieCache.instance.loadFromUrl(EndPoints.getImage(url));
      if (!mounted || _finished) return;
      if (movie == null) {
        Methods.printLog('⚠️ [Rocket] launch animation could not be loaded');
        _showBannerOnly();
        return;
      }
      _bannerFallbackTimer?.cancel();
      _safetyTimer?.cancel();
      Methods.printLog('✅ [Rocket] launch animation ready; playing');
      setState(() => _controller.videoItem = movie);
      RocketRealtimeController.instance.launchAnimating.value = true;
      _controller.forward().whenComplete(_finish);
    } catch (e) {
      Methods.printLog('⚠️ [Rocket] launch animation failed: $e');
      _showBannerOnly();
    }
  }

  /// Shows the winner banner without the animation (still downloading or
  /// failed), then dismisses after the banner's own duration. If the
  /// animation becomes ready before then, it still plays (see [_play]).
  void _showBannerOnly() {
    _bannerFallbackTimer?.cancel();
    if (_finished || !mounted || _controller.videoItem != null) return;
    final ctrl = RocketRealtimeController.instance;
    if (ctrl.launchAnimating.value) return;
    Methods.printLog(
        '🚀 [Rocket] animation not ready -- showing launch banner only');
    ctrl.launchAnimating.value = true;
    _safetyTimer?.cancel();
    _safetyTimer = Timer(_bannerOnlyDuration, _finish);
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _safetyTimer?.cancel();
    _bannerFallbackTimer?.cancel();
    RocketRealtimeController.instance.finishLaunch();
  }

  @override
  void dispose() {
    _finished = true;
    _safetyTimer?.cancel();
    _bannerFallbackTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// The TOP1 contributor (the winner shown in the badge of the animation).
  Map<String, dynamic>? get _topWinner {
    final raw = widget.data['winners'];
    if (raw is! List) return null;
    final winners =
        raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    if (winners.isEmpty) return null;
    return winners.firstWhere(
      (w) => _text(w['winner_group']).toLowerCase() == 'top1',
      orElse: () => winners.first,
    );
  }

  // Layout of the level animations (all share one template): viewBox
  // 510 x 1104 and the round TOP1 badge opening centred at (252.5, 216) with
  // a radius of ~79. The picture goes BEHIND the animation, so the badge ring
  // frames it.
  static const double _viewW = 510;
  static const double _viewH = 1104;
  static const double _holeCx = 252.5;
  static const double _holeCy = 216;
  static const double _holeR = 80;

  /// The badge is only drawn between ~3% and ~84% of the animation; fade the
  /// picture in/out with it.
  double _avatarOpacity(double t) {
    if (t < 0.03 || t > 0.86) return 0;
    if (t < 0.07) return (t - 0.03) / 0.04;
    if (t > 0.81) return (0.86 - t) / 0.05;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.videoItem == null) return const SizedBox.shrink();
    final winner = _topWinner;
    final avatar = RocketRealtimeController.profileUrl(
        winner?['profile_image'],
        label: 'TOP1 winner');
    return LayoutBuilder(builder: (context, c) {
      // BoxFit.cover mapping of the animation viewBox onto the screen.
      final scale = math.max(c.maxWidth / _viewW, c.maxHeight / _viewH);
      final cx = (c.maxWidth - _viewW * scale) / 2 + _holeCx * scale;
      final cy = (c.maxHeight - _viewH * scale) / 2 + _holeCy * scale;
      final d = _holeR * 2 * scale;
      return Stack(
        children: [
          if (avatar.isNotEmpty)
            Positioned(
              left: cx - d / 2,
              top: cy - d / 2,
              width: d,
              height: d,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, child) => Opacity(
                  opacity: _avatarOpacity(_controller.value),
                  child: child,
                ),
                child: ClipOval(
                  child: ImageViewWidget(
                    url: avatar,
                    width: d,
                    height: d,
                    boxFit: BoxFit.cover,
                    displayName: _text(winner?['name']),
                  ),
                ),
              ),
            ),
          Positioned.fill(child: SVGAImage(_controller, fit: BoxFit.cover)),
        ],
      );
    });
  }
}
