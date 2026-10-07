import 'package:flutter/foundation.dart';
import 'package:general/src/features/room/room.dart';

/// Realtime signal for the Room Support (weekly room-reward/partner) mini
/// feature. Backend broadcasts `action_type: 'room_support_updated'` via
/// Centrifugo (see [RealtimeClient.nonChatEvents] / `get_my_data_bloc.dart`'s
/// `_listenToCentrifugoNonChatEvents`, which routes it here) whenever a gift
/// or level update changes the room's support progress.
///
/// Unlike Rocket's four typed events, this one doesn't carry a confirmed
/// payload shape, so this deliberately does NOT try to parse `current`/
/// `week` out of it -- it just bumps [updateTick] so listeners (the bottom
/// sheet's info tab, the carousel icon) refetch `GET /room-support`
/// themselves. That matches exactly what the backend team's own integration
/// note recommends: "if the dialog is open, refresh fetchRoomSupport() in
/// the background when this event lands."
class RoomSupportRealtimeController {
  RoomSupportRealtimeController._();
  static final RoomSupportRealtimeController instance =
      RoomSupportRealtimeController._();

  /// Bumped on every `room_support_updated` event for the current room.
  final ValueNotifier<int> updateTick = ValueNotifier(0);

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  /// Dispatches a decoded room-support event. [payload] is the raw JSON
  /// object from the Centrifugo envelope (already unwrapped by
  /// `RealtimeClient`).
  void handleEvent(dynamic payload) {
    if (payload is! Map) return;
    final json = Map<String, dynamic>.from(payload);

    final eventRoomId =
        json['room_id'] ?? json['stream_id'] ?? json['livestream_id'];
    final currentRoomId = RoomData.instance.room.id;
    if (eventRoomId != null &&
        currentRoomId != null &&
        _asInt(eventRoomId) != _asInt(currentRoomId)) {
      // Not this room -- ignore (the backend broadcasts to every viewer's
      // personal Centrifugo channel, not a room-scoped one, so cross-room
      // noise is expected and must be filtered client-side), same as Rocket.
      return;
    }

    updateTick.value++;
  }
}
