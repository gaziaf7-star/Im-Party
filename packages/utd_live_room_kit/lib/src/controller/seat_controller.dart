import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/stage_api.dart';
import '../core/room_manager.dart';
import '../core/reconnection_handler.dart';
import '../models/seat_model.dart';

/// Drives the live_stream **stage**: the host plus host-invited co-publishers.
///
/// `live_stream` is always the unbounded seatless stage. This controller keeps a
/// tile-shaped view of it ([seats]) for the existing tile UI — the host is
/// rendered separately (full-bleed), so [seats] only carries the GUEST
/// publishers, placed positionally at tile indices 1..N (capped to the layout
/// size; the engine imposes no cap). Publishing is decoupled from moderation:
/// the stage list is publishers only (host/guest); admins moderate without
/// publishing and never appear here.
///
/// Two sources of truth (mirroring the old seat sync):
/// 1. **Room metadata (`_stage`)** — read on join & reconnect.
/// 2. **Data messages (`_stage_update`)** — real-time updates while connected.
///
/// The class name is retained for API stability; internally it is the stage.
class UTDSeatController {
  static const _tag = '[UTDStage]';
  final UTDRoomManager _roomManager;
  StreamSubscription<Map<String, dynamic>>? _dataSub;

  /// The stage API client — set via [setStageApi].
  UTDStageApi? _stageApi;

  /// The LiveKit room name — needed for API calls.
  String? _roomId;

  /// Exposes the room ID for use by UTDRoomController stage helpers.
  String? get roomId => _roomId;

  /// Subscription to room metadata changes (live _stage sync).
  StreamSubscription<String>? _metadataSub;

  /// Local-user cosmetic overrides published mid-session (avatar/frame/name…)
  /// but not yet reflected in `localParticipant.attributes`. LiveKit's
  /// setAttributes only sends the change to the SFU and awaits an ack — it does
  /// NOT update the local attribute map, and the server does not necessarily
  /// echo the update back to the sender. Without overlaying these, a user who
  /// changes their photo/frame in Profile or the Mall never sees it on their own
  /// tile until they rejoin. Read by the stage's `_avatarOf`/`_nameOf` for the
  /// local identity. Cleared on teardown.
  final Map<String, String> localCosmeticOverrides = <String, String>{};

  /// Reconnection handler — tiered reconnect strategy.
  UTDReconnectionHandler? _reconnectionHandler;

  UTDSeatController(this._roomManager);

  /// Configure the stage API and room name for backend calls.
  /// Must be called after [initApi] on [UTDRoomController].
  void setStageApi(UTDStageApi stageApi, String roomId) {
    _stageApi = stageApi;
    _roomId = roomId;
    debugPrint('$_tag setStageApi configured for room: $roomId');
  }

  /// Reactive tile view of the stage — index 0 is the (separately-rendered)
  /// host slot; indices 1..N are guest publishers.
  final ValueNotifier<List<SeatState>> seats = ValueNotifier([]);

  /// Publish-request mode. The stage is always request-to-publish (the host
  /// invites or approves), so this is fixed to 'request'; kept for the controls
  /// bar that gates the apply-to-speak button on it.
  final ValueNotifier<String> seatMode = ValueNotifier('request');

  /// Pending stage requests (for the host/admin queue). Built from transient
  /// `_stage_request` data messages — there is no persisted server queue.
  final ValueNotifier<List<SpeakerRequest>> pendingRequests = ValueNotifier([]);

  /// Whether the LOCAL user has a stage request outstanding. `_stage_request`
  /// is delivered only to host/admins, so the requester tracks its own pending
  /// state locally to flip the apply/cancel button. Cleared when the local user
  /// lands on stage or cancels.
  final ValueNotifier<bool> localStageRequested = ValueNotifier(false);

  final StreamController<List<SeatState>> _occupiedSeatsController =
      StreamController<List<SeatState>>.broadcast();
  VoidCallback? _seatsListener;

  /// Stream of occupied tiles — emits whenever the stage changes.
  Stream<List<SeatState>> get occupiedSeatsStream =>
      _occupiedSeatsController.stream;

  /// Stage event stream for the UIKit (`_stage_request`).
  final StreamController<Map<String, dynamic>> _stageEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get speakerEventStream =>
      _stageEventController.stream;

  /// Callback invoked when a `_stage_request` event is received (host/admin).
  void Function(Map<String, dynamic> data)? onStageRequest;

  /// Callback invoked when a `_banned` event targets the local user.
  void Function(Map<String, dynamic> data)? onBanned;

  /// Callback invoked when a `_kicked` (`signed_in_elsewhere`) event targets the
  /// local user — the account started a session on another device (newest-wins).
  void Function(Map<String, dynamic> data)? onKicked;

  /// Callback invoked when the host broadcasts `_live_ended` (the live is over).
  void Function()? onLiveEnded;

  /// Callback invoked when a `_role_change` event is received (for ANY user).
  void Function(Map<String, dynamic> data)? onRoleChanged;

  /// Callback invoked when the room has been disconnected long enough (>60s)
  /// that the reconnection handler gives up.
  void Function()? onForceExit;

  /// Tile-layout capacity (host slot + guest tiles). Guests beyond this are not
  /// shown (the package's UI cap; the engine stage is uncapped).
  int _seatCount = 4;

  /// Monotonic counter bumped on every [_applyStageState]. Lets awaited GET
  /// /stage paths detect that a fresher real-time apply landed during the await
  /// and skip a stale result.
  int _applyGeneration = 0;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialize the tile layout. Stage publishers are populated from room
  /// metadata (`_stage`) and `_stage_update` messages.
  void initSeats(int seatCount) {
    debugPrint('$_tag initSeats(seatCount: $seatCount)');
    // Idempotent re-init: a same-instance reconnect (connect() again without leave()) re-runs this.
    // Tear down the prior generation first so the old data/metadata subscriptions, the seats
    // listener, the connection-state listener and the reconnection handler are not orphaned (which
    // would double-fire stage events and leak). stopListening() is null-safe on the first call.
    stopListening();
    _seatCount = seatCount > 0 ? seatCount : 1;
    seats.value = List.generate(_seatCount, (i) => SeatState(index: i));
    _seatsListener = () {
      if (_disposed) return;
      final occupied = seats.value.where((s) => s.isOccupied).toList();
      _occupiedSeatsController.add(occupied);
    };
    seats.addListener(_seatsListener!);
    _listenToBackendMessages();
    _listenToRoomMetadataChanges();
    _initReconnectionHandler();

    // Read initial stage state from room metadata.
    _readRoomMetadataStage();
  }

  // ---------------------------------------------------------------------------
  // Read stage state from Room Metadata (_stage)
  // ---------------------------------------------------------------------------

  void _readRoomMetadataStage() {
    final room = _roomManager.room;
    if (room == null) return;

    final metadataStr = room.metadata;
    if (metadataStr == null || metadataStr.isEmpty) {
      _fetchStageFromApiOnce();
      return;
    }
    try {
      final meta = jsonDecode(metadataStr) as Map<String, dynamic>;
      final stageData = meta['_stage'] as Map<String, dynamic>?;
      if (stageData != null) {
        _applyStageState(stageData);
      } else {
        _fetchStageFromApiOnce();
      }
    } catch (e) {
      _fetchStageFromApiOnce();
    }
  }

  /// One-time fallback: fetch the stage from GET /stage when metadata is empty.
  Future<void> _fetchStageFromApiOnce() async {
    if (_stageApi == null || _roomId == null) return;
    try {
      final gen = _applyGeneration;
      final data = await _stageApi!.getStage(roomName: _roomId!);
      if (_applyGeneration == gen) _applyStageState(data);
    } catch (e) {
      debugPrint('$_tag _fetchStageFromApiOnce — error: $e');
    }
  }

  /// Re-sync the stage from room metadata. Call this on reconnect.
  void resyncFromMetadata() => _readRoomMetadataStage();

  // ---------------------------------------------------------------------------
  // Apply stage state (_stage_update or _stage metadata or GET /stage)
  // ---------------------------------------------------------------------------

  /// Applies the full stage state. All three sources share the shape
  /// `{ "members": [{ "identity": ..., "name": ..., "role": ... }] }`.
  void _applyStageState(Map<String, dynamic> data) {
    if (_disposed) return;
    _applyGeneration++;

    final rawMembers = (data['members'] as List<dynamic>?) ?? const [];
    // Publishers only (host + guests). The host fills the full-bleed tile and is
    // rendered separately, so it is excluded from the guest tile strip.
    final guests = <Map<String, dynamic>>[];
    for (final m in rawMembers) {
      if (m is! Map) continue;
      final role = m['role'] as String?;
      if (role == 'host') continue;
      guests.add(m.cast<String, dynamic>());
    }

    final newSeats = List<SeatState>.generate(_seatCount, (i) {
      if (i == 0) return const SeatState(index: 0); // host slot (rendered separately)
      final gi = i - 1;
      if (gi < guests.length) {
        final m = guests[gi];
        return SeatState(
          index: i,
          occupantUserId: m['identity'] as String?,
          attributes: _attrsOf(m),
        );
      }
      return SeatState(index: i);
    });

    if (!listEquals(newSeats, seats.value)) {
      seats.value = newSeats;
    }

    // Drop any pending request that is now on stage, and clear the local
    // requester flag once the local user is publishing.
    final onStage = guests.map((m) => m['identity'] as String?).whereType<String>().toSet();
    if (pendingRequests.value.any((r) => onStage.contains(r.identity))) {
      pendingRequests.value =
          pendingRequests.value.where((r) => !onStage.contains(r.identity)).toList();
    }
    final me = _roomManager.localParticipant?.identity;
    if (me != null && onStage.contains(me) && localStageRequested.value) {
      localStageRequested.value = false;
    }
  }

  Map<String, String> _attrsOf(Map<String, dynamic> m) {
    final attrs = <String, String>{};
    final raw = m['attributes'];
    if (raw is Map) {
      for (final e in raw.entries) {
        if (e.value != null) attrs[e.key.toString()] = e.value.toString();
      }
    }
    final name = m['name'] as String?;
    if (name != null && name.isNotEmpty) attrs['name'] = name;
    return attrs;
  }

  // ---------------------------------------------------------------------------
  // Stage operations — call the REST API, let _stage_update settle the state
  // ---------------------------------------------------------------------------

  /// The local viewer asks to go on stage (audience → request).
  Future<bool> requestStage() async {
    if (_stageApi == null || _roomId == null) return false;
    final me = _roomManager.localParticipant?.identity;
    if (me == null) return false;

    // Pre-grant the mic/BT permissions the guest will need once promoted, so the
    // jump to publishing is instant (mirrors the old takeSeat permission prep).
    final micStatus = await Permission.microphone.status;
    if (micStatus.isDenied) await Permission.microphone.request();
    if (Platform.isAndroid) {
      final btStatus = await Permission.bluetoothConnect.status;
      if (btStatus.isDenied) await Permission.bluetoothConnect.request();
    }

    try {
      await _stageApi!.requestStage(roomName: _roomId!, identity: me);
      if (_disposed) return false; // disposed during the await — don't touch the notifier
      localStageRequested.value = true;
      lastStageError = null;
      return true;
    } catch (e) {
      lastStageError = _describeFailure(e);
      debugPrint('$_tag requestStage — error: $e');
      return false;
    }
  }

  /// Clear the local user's outstanding stage request (no server round-trip —
  /// the request is a transient host-side signal).
  void cancelLocalRequest() {
    localStageRequested.value = false;
  }

  /// Why the last stage action failed, in the engine's own words.
  ///
  /// These calls only ever returned a bare `false`, and the reason went to
  /// `debugPrint` — which a release build strips. A host whose accept was
  /// refused saw "action failed" and nothing else, so a full stage, a
  /// permission problem and an unreachable engine were indistinguishable.
  /// Cleared on every success so a stale reason is never shown.
  String? lastStageError;

  /// The server's `message`, when it sent one; the transport error otherwise.
  String _describeFailure(Object error) {
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map && body['message'] is String) {
        final message = (body['message'] as String).trim();
        if (message.isNotEmpty) return message;
      }
      final status = error.response?.statusCode;
      if (status != null) return 'Engine refused the request ($status)';
      return 'Could not reach the engine';
    }
    return error.toString();
  }

  /// Host/admin adds [targetIdentity] to the stage (grant publish).
  Future<bool> addToStage(String targetIdentity) async {
    if (_stageApi == null || _roomId == null) return false;
    final actor = _roomManager.localParticipant?.identity;
    if (actor == null) return false;
    try {
      await _stageApi!.addToStage(
        roomName: _roomId!,
        targetIdentity: targetIdentity,
        actorIdentity: actor,
      );
      removeRequest(targetIdentity);
      lastStageError = null;
      return true;
    } catch (e) {
      lastStageError = _describeFailure(e);
      debugPrint('$_tag addToStage — error: $e');
      return false;
    }
  }

  /// Host/admin removes the publisher occupying tile [index] from the stage.
  Future<bool> kickFromSeat(int index, {required String identity}) async {
    final occupant = (index >= 0 && index < seats.value.length)
        ? seats.value[index].occupantUserId
        : null;
    if (occupant == null) return false;
    return removeFromStage(occupant);
  }

  /// Host/admin removes [targetIdentity] from the stage (revoke publish).
  Future<bool> removeFromStage(String targetIdentity) async {
    if (_stageApi == null || _roomId == null) return false;
    final actor = _roomManager.localParticipant?.identity;
    if (actor == null) return false;
    try {
      await _stageApi!.removeFromStage(
        roomName: _roomId!,
        targetIdentity: targetIdentity,
        actorIdentity: actor,
      );
      return true;
    } catch (e) {
      debugPrint('$_tag removeFromStage — error: $e');
      return false;
    }
  }

  /// The local co-publisher steps down from the stage themselves.
  Future<bool> leaveSeat(String identity) async {
    if (_stageApi == null || _roomId == null) return false;
    try {
      await _stageApi!.leaveStage(roomName: _roomId!, identity: identity);
      return true;
    } catch (e) {
      debugPrint('$_tag leaveStage — error: $e');
      return false;
    }
  }

  /// Drop a pending request from the host queue (after approve/reject).
  void removeRequest(String identity) {
    if (!pendingRequests.value.any((r) => r.identity == identity)) return;
    pendingRequests.value =
        pendingRequests.value.where((r) => r.identity != identity).toList();
  }

  // ---------------------------------------------------------------------------
  // Query helpers
  // ---------------------------------------------------------------------------

  /// Tile index for [userId], or -1 if they are not a guest publisher.
  int getSeatIndexByUserId(String userId) {
    return seats.value.indexWhere((s) => s.occupantUserId == userId);
  }

  // ---------------------------------------------------------------------------
  // Room metadata live listener
  // ---------------------------------------------------------------------------

  void _listenToRoomMetadataChanges() {
    _metadataSub = _roomManager.roomMetadataStream.listen((metadataStr) {
      try {
        final meta = jsonDecode(metadataStr) as Map<String, dynamic>;
        final stageData = meta['_stage'] as Map<String, dynamic>?;
        if (stageData != null) _applyStageState(stageData);
      } catch (e) {
        debugPrint('$_tag room metadata change parse error: $e');
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Reconnection Handler
  // ---------------------------------------------------------------------------

  void _initReconnectionHandler() {
    _reconnectionHandler = UTDReconnectionHandler(
      onLightSync: () async => resyncFromMetadata(),
      onFullSync: () async {
        resyncFromMetadata();
        if (_stageApi != null && _roomId != null) {
          final gen = _applyGeneration;
          try {
            final data = await _stageApi!.getStage(roomName: _roomId!);
            if (_applyGeneration == gen) _applyStageState(data);
          } catch (e) {
            debugPrint('$_tag reconnection full sync API error: $e');
          }
        }
      },
      onForceExit: () => onForceExit?.call(),
    );
    _roomManager.connectionState.addListener(_onConnectionStateChanged);
  }

  void _onConnectionStateChanged() {
    final state = _roomManager.connectionState.value;
    if (state == UTDConnectionState.reconnecting ||
        state == UTDConnectionState.disconnected) {
      _reconnectionHandler?.onDisconnected();
    } else if (state == UTDConnectionState.connected) {
      _reconnectionHandler?.onReconnected();
    }
  }

  // ---------------------------------------------------------------------------
  // Private — listen to backend data messages
  // ---------------------------------------------------------------------------

  void _listenToBackendMessages() {
    _dataSub = _roomManager.dataStream.listen((data) {
      if (_disposed) return;
      final type = data['type'] as String?;
      if (type == null) return;

      switch (type) {
        case '_stage_update':
          _applyStageState(data);
          break;
        case '_stage_request':
          _handleStageRequest(data);
          _stageEventController.add(data);
          onStageRequest?.call(data);
          break;
        case '_banned':
          final target = data['identity'] as String?;
          final me = _roomManager.localParticipant?.identity;
          if (target == null || me == null || target == me) {
            onBanned?.call(data);
          }
          break;
        case '_kicked':
          onKicked?.call(data);
          break;
        case '_role_change':
          onRoleChanged?.call(data);
          break;
        case '_live_ended':
          onLiveEnded?.call();
          break;
      }
    });
  }

  /// Accumulate a transient `_stage_request` into the host-side pending queue
  /// (deduped; skipped if the requester is already on stage).
  void _handleStageRequest(Map<String, dynamic> data) {
    final identity = data['identity'] as String?;
    if (identity == null || identity.isEmpty) return;
    if (pendingRequests.value.any((r) => r.identity == identity)) return;
    if (getSeatIndexByUserId(identity) >= 0) return; // already publishing
    pendingRequests.value = [
      ...pendingRequests.value,
      SpeakerRequest(id: identity.hashCode, identity: identity),
    ];
  }

  /// Records mid-session cosmetic overrides for the local user and forces a
  /// stage rebuild so the local user's own tile repaints immediately, without
  /// waiting for an RTC echo that may never arrive (see [localCosmeticOverrides]).
  /// Only non-empty values are stored; a fresh list instance is emitted so the
  /// stage's `Listenable.merge` on [seats] fires even though seat identity is
  /// unchanged.
  void applyLocalCosmeticOverride(Map<String, String> attrs) {
    if (_disposed || attrs.isEmpty) return;
    var changed = false;
    attrs.forEach((k, v) {
      if (v.isNotEmpty && localCosmeticOverrides[k] != v) {
        localCosmeticOverrides[k] = v;
        changed = true;
      }
    });
    if (changed) {
      // Re-emit a new list instance so the stage AnimatedBuilder rebuilds and
      // re-reads the (now overlaid) local participant attributes.
      seats.value = List<SeatState>.from(seats.value);
    }
  }

  void stopListening() {
    _dataSub?.cancel();
    _dataSub = null;
    _metadataSub?.cancel();
    _metadataSub = null;
    _roomManager.connectionState.removeListener(_onConnectionStateChanged);
    _reconnectionHandler?.dispose();
    _reconnectionHandler = null;
    if (_seatsListener != null) {
      seats.removeListener(_seatsListener!);
      _seatsListener = null;
    }
  }

  bool _disposed = false;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    debugPrint('$_tag dispose()');
    localCosmeticOverrides.clear();
    stopListening();
    _occupiedSeatsController.close();
    _stageEventController.close();
    seatMode.dispose();
    pendingRequests.dispose();
    localStageRequested.dispose();
    seats.dispose();
  }
}
