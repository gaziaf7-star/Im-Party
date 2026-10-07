import 'dart:async';

import 'package:flutter/foundation.dart';
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
    final currentRoomId = RoomData.instance.room.id;
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
        }
        break;
      case 'rocket_launched':
        _scheduleLaunch(json);
        break;
      case 'rocket_session_reset':
      case 'rocket_session_expired':
        latestRocket.value = null;
        resetTick.value++;
        break;
    }
  }

  /// Called by the launch overlay once its ~7s animation + reward board have
  /// both finished playing, to dismiss itself and let the next rocket's
  /// progress render normally.
  void finishLaunch() {
    _launchDelayTimer?.cancel();
    launchEvent.value = null;
  }

  /// Waits for the gift-send SVGA (the one that likely just completed the
  /// rocket's target) to finish playing before revealing the launch overlay,
  /// so the two animations play back-to-back instead of on top of each
  /// other. Always waits at least one grace tick before the first check --
  /// the `rocket_launched` broadcast is a websocket round trip and can beat
  /// the local gift-send response to the client by a few frames, so checking
  /// [GiftPlaybackSignal] instantly on arrival could see "not playing yet"
  /// for a gift that is about to start.
  void _scheduleLaunch(Map<String, dynamic> json) {
    _launchDelayTimer?.cancel();
    final deadline = DateTime.now().add(const Duration(seconds: 8));

    void tryShow() {
      if (GiftPlaybackSignal.isPlaying && DateTime.now().isBefore(deadline)) {
        _launchDelayTimer =
            Timer(const Duration(milliseconds: 250), tryShow);
        return;
      }
      launchEvent.value = json;
    }

    _launchDelayTimer = Timer(const Duration(milliseconds: 200), tryShow);
  }
}
