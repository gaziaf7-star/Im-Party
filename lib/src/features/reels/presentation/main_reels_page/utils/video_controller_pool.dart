import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:general/src/core/cache/reels_cache_manager.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/utils/reels_audio_session.dart';
import 'package:video_player/video_player.dart';

typedef PositionCallback = void Function(Duration position);
typedef DurationCallback = void Function(Duration duration);
typedef ErrorCallback = void Function(int index);

/// Gate verbose logging. Always false in release; dev logs only in debug.
const bool _verbose = false;

void _log(String message) {
  if (kDebugMode && _verbose) {
    dev.log(message, name: 'VideoPool');
  }
}

/// Manages the window of [VideoPlayerController]s around the active reel.
///
/// ONE-master principle: this pool NEVER decides to play/pause for lifecycle.
/// The active widget is the sole code that calls `play()`. The pool only:
/// manages the init/dispose window + preload, emits position/duration for the
/// active index, surfaces per-index errors, applies volume (mute), and drives
/// the audio session activate/deactivate.
class VideoControllerPool {
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, VoidCallback> _listeners = {};
  final Map<int, bool> _initializing = {};
  final Map<int, DateTime> _loadStartTimes = {};
  final Set<int> _errored = {};

  final PositionCallback onPositionUpdate;
  final bool preloadAdjacent;

  /// Fired when the active controller exposes a non-zero duration (after late
  /// init too, not just a synchronous read at page-change time).
  DurationCallback? onDurationReady;

  /// Fired when a controller fails to initialize or reports an error
  /// mid-playback. Carries the reel index.
  ErrorCallback? onError;

  DateTime _lastPositionEmit = DateTime(0);
  bool _disposed = false;
  bool _isMuted = false;

  /// Re-entrancy token. Bumped at the top of [onPageChanged]; every async
  /// continuation (and the delayed-preload closure) bails if the token moved.
  int _pageGen = 0;

  /// The reel currently shown. Tracked so a controller that finishes
  /// initializing AFTER the user already swiped to it still gets its volume
  /// applied and its duration surfaced for the right (active) index.
  int _currentIndex = -1;

  /// Last duration emitted for the active controller, so the listener doesn't
  /// re-fire [onDurationReady] every tick once the value is known.
  Duration _lastEmittedDuration = Duration.zero;

  VideoControllerPool({
    required this.onPositionUpdate,
    this.preloadAdjacent = true,
    this.onDurationReady,
    this.onError,
  });

  Map<int, VideoPlayerController> get controllers =>
      Map.unmodifiable(_controllers);

  VideoPlayerController? operator [](int index) => _controllers[index];

  /// The controller for the currently active reel, or null if not ready.
  VideoPlayerController? get activeController => _controllers[_currentIndex];

  int get currentIndex => _currentIndex;

  bool get isMuted => _isMuted;

  bool hasError(int index) => _errored.contains(index);

  /// Applies mute to the active controller (non-active stay silent) and
  /// remembers the choice for subsequent inits/page-changes.
  void setMuted(bool muted) {
    _isMuted = muted;
    _applyVolumes();
  }

  /// Active controller volume = mute ? 0 : 1; every non-active controller is
  /// always silent so preloaded/adjacent reels never bleed audio.
  void _applyVolumes() {
    for (final entry in _controllers.entries) {
      final isActive = entry.key == _currentIndex;
      entry.value.setVolume(isActive ? (_isMuted ? 0.0 : 1.0) : 0.0);
    }
  }

  Future<void> onPageChanged({
    required int newIndex,
    required List<String?> urls,
  }) async {
    if (_disposed) return;

    final gen = ++_pageGen;

    _log('Page changed to #$newIndex | loaded=${_controllers.length}');

    _currentIndex = newIndex;
    _lastEmittedDuration = Duration.zero;

    // Window: previous + current + TWO ahead (TikTok-style look-ahead so the
    // next swipes land on an already-initialized controller). Cap = 4 live
    // controllers, bounded so we never exhaust the device's MediaCodecs.
    final windowIndices = <int>{newIndex};
    if (preloadAdjacent) {
      if (newIndex + 1 < urls.length) windowIndices.add(newIndex + 1);
      if (newIndex + 2 < urls.length) windowIndices.add(newIndex + 2);
      if (newIndex > 0) windowIndices.add(newIndex - 1);
    }

    // Dispose controllers outside the window.
    final toRemove = _controllers.keys
        .where((i) => !windowIndices.contains(i))
        .toList();
    for (final i in toRemove) {
      _log('Disposing controller #$i');
      final listener = _listeners[i];
      if (listener != null) _controllers[i]?.removeListener(listener);
      _listeners.remove(i);
      _controllers[i]?.pause();
      _controllers[i]?.dispose();
      _controllers.remove(i);
      _loadStartTimes.remove(i);
      _errored.remove(i);
    }

    // Initialize the active reel first.
    await _ensureInitialized(newIndex, urls);
    if (_disposed || gen != _pageGen) return;

    // Apply volume so the active reel is audible (subject to mute) and the
    // rest are silent. NOTE: we never call play() here — the widget does.
    _applyVolumes();

    // Surface duration synchronously if already known (late init handled in
    // the listener).
    _maybeEmitActiveDuration();

    // Preload the next TWO immediately (no settle delay) so a fast swipe lands
    // on a warm controller. Sequential so +1 is ready before +2.
    if (preloadAdjacent) {
      scheduleMicrotask(() async {
        if (_disposed || gen != _pageGen) return;
        if (newIndex + 1 < urls.length) {
          await _ensureInitialized(newIndex + 1, urls);
        }
        if (_disposed || gen != _pageGen) return;
        if (newIndex + 2 < urls.length) {
          await _ensureInitialized(newIndex + 2, urls);
        }
      });
    }
  }

  Future<void> _ensureInitialized(int index, List<String?> urls) async {
    if (_disposed) return;
    if (_controllers.containsKey(index)) return;
    if (_initializing[index] == true) return;

    final url = (index >= 0 && index < urls.length) ? urls[index] : null;
    if (url == null || url.isEmpty) return;

    // Capture the generation at the start; every async resume below must still
    // belong to this generation or the work is stale (page changed / disposed)
    // and any controller it built must be thrown away, never stored.
    final gen = _pageGen;

    _initializing[index] = true;
    _loadStartTimes[index] = DateTime.now();
    _errored.remove(index);

    // Declared outside the try so the catch/timeout path can dispose a
    // half-initialized controller instead of leaking a native ExoPlayer.
    VideoPlayerController? controller;

    try {
      final cacheManager = ReelsCacheManager();
      final cachedFile = await cacheManager.getCachedFileOrNull(url);
      if (_disposed || gen != _pageGen) return;

      if (cachedFile != null) {
        _log('#$index from CACHE');
        controller = VideoPlayerController.file(
          cachedFile,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
        );
      } else {
        _log('#$index from NETWORK');
        controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
        );
        // Warm the cache in the background (silent).
        cacheManager.getSingleFile(url).then(
          (_) => _log('#$index cached'),
          onError: (e) => _log('#$index cache fail: $e'),
        );
      }

      // Bound init: a hung network/decoder must become a skippable error, never
      // an infinite spinner. 12s is generous for a slow connection; a genuine
      // timeout throws TimeoutException → caught below → marked errored.
      await controller.initialize().timeout(const Duration(seconds: 12));

      _log('#$index ready | duration=${controller.value.duration.inSeconds}s');

      controller.setLooping(true);

      // The page may have changed (or the pool disposed) while we were
      // initializing. Storing this controller now would leak it outside the
      // window and resurrect a dead pool — dispose it and bail.
      if (_disposed || gen != _pageGen) {
        await controller.dispose();
        // SELF-HEAL (fast-scroll fix): if the user has now landed back on this
        // index, its fresh onPageChanged init bailed on our `_initializing`
        // flag while this stale attempt was still running — so without this it
        // would be stranded with no controller and no retry (the reported
        // "fast scroll → some videos never play"). Re-run init for it once this
        // stale attempt's `finally` has cleared `_initializing` (microtask).
        if (!_disposed && index == _currentIndex) {
          scheduleMicrotask(() {
            if (!_disposed &&
                index == _currentIndex &&
                !_controllers.containsKey(index) &&
                _initializing[index] != true) {
              unawaited(_ensureInitialized(index, urls));
            }
          });
        }
        return;
      }

      _controllers[index] = controller;
      _attachListener(index, controller);

      // Apply the correct volume immediately: active reel honours mute, all
      // others stay silent. The widget owns play() — we never auto-play.
      controller.setVolume(
        index == _currentIndex ? (_isMuted ? 0.0 : 1.0) : 0.0,
      );

      if (index == _currentIndex) {
        _maybeEmitActiveDuration();
      }
    } catch (e) {
      _log('#$index init failed: $e');
      // Dispose the half-initialized controller (timeout / network / decoder
      // failure) so the native player is released and not leaked.
      if (!_controllers.containsKey(index)) {
        try {
          await controller?.dispose();
        } catch (_) {}
      }
      if (!_disposed && gen == _pageGen) {
        _errored.add(index);
        onError?.call(index);
      }
    } finally {
      _initializing.remove(index);
    }
  }

  void _attachListener(int index, VideoPlayerController controller) {
    void listener() {
      if (_disposed) return;
      final value = controller.value;

      // Surface mid-playback errors for any index.
      if (value.hasError && !_errored.contains(index)) {
        _errored.add(index);
        onError?.call(index);
        return;
      }

      // Only the ACTIVE controller emits position, and only while playing.
      if (index == _currentIndex && value.isPlaying) {
        final now = DateTime.now();
        if (now.difference(_lastPositionEmit).inMilliseconds > 250) {
          _lastPositionEmit = now;
          onPositionUpdate(value.position);
        }

        // Drive the audio session: active reel is actually playing → activate.
        unawaited(ReelsAudioSession.instance.activate());
      }

      // Duration may only become known after late init.
      if (index == _currentIndex) {
        _maybeEmitActiveDuration();
      }
    }

    _listeners[index] = listener;
    controller.addListener(listener);
  }

  void _maybeEmitActiveDuration() {
    final controller = _controllers[_currentIndex];
    if (controller == null) return;
    final dur = controller.value.duration;
    if (dur > Duration.zero && dur != _lastEmittedDuration) {
      _lastEmittedDuration = dur;
      onDurationReady?.call(dur);
    }
  }

  /// Clears the error flag for [index] and re-initializes it.
  Future<void> retry(int index, List<String?> urls) async {
    if (_disposed) return;
    _errored.remove(index);
    final existing = _controllers.remove(index);
    if (existing != null) {
      final listener = _listeners.remove(index);
      if (listener != null) existing.removeListener(listener);
      existing.pause();
      await existing.dispose();
    }
    await _ensureInitialized(index, urls);
  }

  void pauseAll() {
    for (final c in _controllers.values) {
      c.pause();
    }
    // Stopped playing → release the audio route so the room/other apps regain
    // their output and reels audio stops bleeding in.
    unawaited(ReelsAudioSession.instance.deactivate());
  }

  /// Tears down every controller and clears the window maps.
  ///
  /// [reusable] controls the disposed gate:
  /// - true  (default): the pool can be reused afterwards (the caller is just
  ///   freeing the window before re-initializing the same pool, e.g.
  ///   PlayMyReelsView._freeMemoryAndInit). The disposed gate stays DOWN.
  /// - false: this is a permanent teardown via [dispose]; the disposed gate
  ///   stays UP so every late callback / in-flight initialize() is rejected and
  ///   can never resurrect a destroyed pool (no orphan controller, no audio
  ///   re-activation after the view is gone).
  ///
  /// IMPORTANT: bump [_pageGen] so any in-flight `await controller.initialize()`
  /// started before this call fails its `gen != _pageGen` check on resume and
  /// disposes its controller instead of storing it.
  Future<void> disposeAll({bool reusable = true}) async {
    _pageGen++;

    // Snapshot BEFORE clearing maps. If we dispose() first and clear() second,
    // a Flutter frame firing in between will get a disposed controller from
    // pool[index] and the widget's initState tries addListener on it → crash.
    final controllers = Map.of(_controllers);
    final listeners = Map.of(_listeners);

    _controllers.clear();
    _listeners.clear();
    _initializing.clear();
    _loadStartTimes.clear();
    _errored.clear();
    _currentIndex = -1;
    _lastEmittedDuration = Duration.zero;

    final futures = <Future>[];
    for (final entry in controllers.entries) {
      final listener = listeners[entry.key];
      if (listener != null) entry.value.removeListener(listener);
      entry.value.pause();
      futures.add(entry.value.dispose());
    }
    await Future.wait(futures);
  }

  /// Re-arms a pool that was previously [dispose]d so it can serve a new view.
  /// Only the reuse path (PlayMyReelsView._freeMemoryAndInit /
  /// InitializeFeedControllersEvent) calls this — never an internal teardown.
  void reactivate() {
    _disposed = false;
  }

  /// Permanent teardown. Leaves the disposed gate UP so all guards stay armed.
  Future<void> dispose() async {
    _disposed = true;
    await disposeAll(reusable: false);
    await ReelsAudioSession.instance.deactivate();
  }
}
