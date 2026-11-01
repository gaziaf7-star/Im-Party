import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// Realtime state for the Rocket room-reward mini-game (Phase 2). Backend
/// broadcasts land here (via [RealtimeClient.nonChatEvents], see
/// `get_my_data_bloc.dart`'s `_listenToCentrifugoNonChatEvents`, which routes
/// the four `rocket_*` Centrifugo events to [handleEvent]) and are re-published
/// as [ValueNotifier]s so any open widget (the carousel icon, the bottom
/// sheet, the launch overlay) can react live instead of only polling REST.
///
/// action_type contract (confirmed by the backend team):
///   rocket_progress_updated -- progress bar should move live
///   rocket_launched         -- play the ~7s launch animation + reward board
///   rocket_session_reset    -- new rocket started at 0, clear stale state
///   rocket_session_expired  -- session died without launching, clear state
class RocketRealtimeController {
  RocketRealtimeController._();
  static final RocketRealtimeController instance = RocketRealtimeController._();

  /// Latest `rocket` object from a `rocket_progress_updated` event, or null
  /// after a reset/expiry. Listeners should fall back to their own REST
  /// fetch when this is null (it does not mean "no rocket", just "no fresher
  /// realtime data yet").
  final ValueNotifier<Map<String, dynamic>?> latestRocket = ValueNotifier(null);

  /// The full `rocket_launched` payload while the launch overlay should be
  /// showing; null when idle. Setting this back to null is how the overlay
  /// is dismissed (see [finishLaunch]).
  final ValueNotifier<Map<String, dynamic>?> launchEvent = ValueNotifier(null);

  /// True while the launch animation is actually on screen (set by the
  /// overlay once the SVGA is ready and playing). The launch banner follows
  /// it so banner and animation start and end together.
  final ValueNotifier<bool> launchAnimating = ValueNotifier(false);

  /// The finished launch whose reward card (winners + what they got) is shown
  /// right after the animation ends; cleared by [dismissReward].
  final ValueNotifier<Map<String, dynamic>?> rewardEvent = ValueNotifier(null);

  /// Bumped on every reset/expiry so listeners (carousel icon, bottom sheet)
  /// know to re-fetch fresh REST state even though [latestRocket] just went
  /// back to null (a ValueNotifier doesn't notify on null -> null).
  final ValueNotifier<int> resetTick = ValueNotifier(0);

  /// Polls [GiftPlaybackSignal] until the currently-playing gift SVGA (there
  /// can briefly be more than one) has finished, then reveals the launch
  /// overlay -- so a `rocket_launched` event that lands mid-gift doesn't
  /// fight the gift animation for the screen. Capped so a stuck signal can
  /// never suppress the launch forever.
  Timer? _launchDelayTimer;

  /// Launch ids already played, so a duplicate broadcast is ignored.
  final Set<String> _handledLaunchIds = {};

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  /// Dispatches a decoded rocket event to the right notifier. [payload] is
  /// the raw JSON object from the Centrifugo envelope (already unwrapped by
  /// `RealtimeClient`), containing `action_type` and the room id.
  void handleEvent(dynamic payload) {
    if (payload is! Map) return;
    final json = Map<String, dynamic>.from(payload);
    final action = json['action_type']?.toString();

    final eventRoomId = json['room_id'] ?? json['stream_id'];
    // Not in any room yet (e.g. on the home page): nothing to update. `room`
    // would throw here, so read the nullable getter.
    final currentRoom = RoomData.instance.roomOrNull;
    if (currentRoom == null) return;
    final currentRoomId = currentRoom.id;
    if (eventRoomId != null &&
        currentRoomId != null &&
        _asInt(eventRoomId) != _asInt(currentRoomId)) {
      // Not this room -- ignore (the backend broadcasts to every viewer's
      // personal Centrifugo channel, not a room-scoped one, so cross-room
      // noise is expected and must be filtered client-side).
      return;
    }

    switch (action) {
      case 'rocket_progress_updated':
        final rocket = json['rocket'];
        if (rocket is Map) {
          latestRocket.value = Map<String, dynamic>.from(rocket);
          prepareFromRocket(rocket);
        }
        break;
      case 'rocket_launched':
        // The same launch can arrive on more than one realtime channel;
        // play it only once.
        final launchId = (json['launch_id'] ?? json['event_id'])?.toString();
        if (launchId != null && !_handledLaunchIds.add(launchId)) break;
        Methods.printLog('🚀 [Rocket] rocket_launched received (launch $launchId)');
        _scheduleLaunch(json);
        break;
      case 'rocket_session_reset':
      case 'rocket_session_expired':
        latestRocket.value = null;
        resetTick.value++;
        break;
    }
  }

  /// Fetchable URL for a user picture from a rocket payload. The rocket API
  /// returns `https://<host>/profile/x.jpg` (no `/storage/`), which 404s; the
  /// real file lives under the storage base. Logged so a missing picture can
  /// be traced.
  static String profileUrl(dynamic raw,
      {String label = 'profile', bool log = true}) {
    var url = raw?.toString().trim() ?? '';
    if (url.toLowerCase() == 'null') url = '';
    final fixed = _fixProfileUrl(url);
    if (log) Methods.printLog('🚀 [Rocket] $label image: "$url" -> "$fixed"');
    return fixed;
  }

  /// Same fix for any backend picture (profile, reward, gift...): the rocket
  /// payload gives `https://host/files/x.png` while the file really lives under
  /// `https://host/storage/files/x.png`.
  static String mediaUrl(dynamic raw,
      {String label = 'media', bool log = false}) {
    var url = raw?.toString().trim() ?? '';
    if (url.toLowerCase() == 'null') url = '';
    final fixed = _fixProfileUrl(url);
    if (log) Methods.printLog('🚀 [Rocket] $label: "$url" -> "$fixed"');
    return fixed;
  }

  static const _storageFolders = [
    'profile/',
    'files/',
    'images/',
    'rooms/',
    'families/',
    'chat/',
    'extradata/',
  ];

  static String _fixProfileUrl(String url) {
    if (url.isEmpty) return '';
    final host = '${EndPoints.domainURL}/';
    if (url.startsWith(host)) {
      final rest = url.substring(host.length);
      if (_storageFolders.any(rest.startsWith)) {
        return EndPoints.getImage(rest);
      }
    }
    return EndPoints.getImage(url);
  }

  // ---- Launch animation preloading ---------------------------------------
  //
  // The level's `launch_animation` SVGA is ~24 MB: downloading + decoding it
  // only when the rocket launches made it appear late and stutter. It is
  // fetched and decoded ahead of time (as soon as the rocket level is known)
  // and handed to the overlay already prepared.

  final Map<String, Future<MovieEntity?>> _preparedLaunch = {};

  /// Starts preparing the `launch_animation` of [rocket] (current level, and
  /// the next one if present). Safe to call repeatedly: each URL is prepared
  /// once, and at most two prepared animations are kept.
  void prepareFromRocket(dynamic rocket) {
    if (rocket is! Map) return;
    for (final key in const ['level', 'current_level', 'next_level']) {
      final level = rocket[key];
      if (level is Map) {
        final url = level['launch_animation']?.toString().trim() ?? '';
        if (url.isNotEmpty && url.toLowerCase() != 'null') {
          _prepareLaunchAnimation(url);
        }
      }
    }
  }

  void _prepareLaunchAnimation(String url) {
    final resolved = EndPoints.getImage(url);
    if (resolved.isEmpty || _preparedLaunch.containsKey(resolved)) return;
    while (_preparedLaunch.length >= 2) {
      _preparedLaunch.remove(_preparedLaunch.keys.first);
    }
    _preparedLaunch[resolved] = _loadMovie(resolved);
  }

  Future<MovieEntity?> _loadMovie(String resolved) async {
    try {
      final movie = await SvgaMovieCache.instance.loadFromUrl(resolved);
      // The movie is decoded: drop the raw 24 MB buffer from the byte cache.
      SvgaMovieCache.instance.evict(resolved);
      return movie;
    } catch (e) {
      Methods.printLog('⚠️ [Rocket] preparing launch animation failed: $e');
      return null;
    }
  }

  /// The prepared (or still preparing) movie for [url], consumed on use; null
  /// when it was never prepared.
  Future<MovieEntity?>? takePreparedLaunch(String url) =>
      _preparedLaunch.remove(EndPoints.getImage(url));

  /// Called by the launch overlay once its ~7s animation + reward board have
  /// both finished playing, to dismiss itself and let the next rocket's
  /// progress render normally.
  void finishLaunch() {
    _launchDelayTimer?.cancel();
    final finished = launchEvent.value;
    launchAnimating.value = false;
    launchEvent.value = null;
    final winners = finished?['winners'];
    if (finished != null && winners is List && winners.isNotEmpty) {
      rewardEvent.value = finished;
    }
  }

  void dismissReward() => rewardEvent.value = null;

  /// Reveals the launch animation only AFTER the gift animation that completed
  /// the rocket has finished, so the two never play on top of each other and
  /// the rocket starts right as the gift ends.
  ///
  /// The `rocket_launched` broadcast can beat the local gift display by a
  /// moment, so a short grace period waits for a gift to START playing; once
  /// one has been seen playing, it waits for it to END. When no gift ever
  /// starts (grace passed) the launch plays straight away. A hard cap keeps a
  /// stuck signal from suppressing the launch forever.
  void _scheduleLaunch(Map<String, dynamic> json) {
    _launchDelayTimer?.cancel();
    prepareFromRocket(json);
    final started = DateTime.now();
    const grace = Duration(seconds: 4);
    const cap = Duration(seconds: 30);
    var sawGift = false;

    void tick() {
      final elapsed = DateTime.now().difference(started);
      if (GiftPlaybackSignal.isPlaying) {
        sawGift = true;
        if (elapsed < cap) {
          _launchDelayTimer = Timer(const Duration(milliseconds: 100), tick);
          return;
        }
      } else if (!sawGift && elapsed < grace) {
        _launchDelayTimer = Timer(const Duration(milliseconds: 100), tick);
        return;
      }
      launchEvent.value = json;
    }

    _launchDelayTimer = Timer(const Duration(milliseconds: 100), tick);
  }
}
