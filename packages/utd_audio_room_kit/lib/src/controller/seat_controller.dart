import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/seat_api.dart';
import '../core/room_manager.dart';
import '../core/reconnection_handler.dart';
import '../core/sync_manager.dart';
import '../models/seat_model.dart';

/// Manages seat state for the audio room.
///
/// **Architecture (per UIKit Developer Guide):**
/// - All seat mutations go through the REST API (UTD Stream Engine).
/// - The backend pushes `_seat_update` data messages after every change.
/// - This controller updates local state ONLY from `_seat_update` or
///   room metadata `_seats` — never from local optimistic updates.
///
/// Two sources of truth:
/// 1. **Room metadata (`_seats`)** — read on join & reconnect.
/// 2. **Data messages (`_seat_update`)** — real-time updates while connected.
class UTDSeatController {
  static const _tag = '[UTDSeatController]';

  /// Cosmetic attribute keys that the seat avatar renders. Unlike other seat
  /// fields, these are NOT server-moderated — the backend only ever *reads*
  /// them — so a participant's own latest live-published value is authoritative
  /// over the (possibly stale) `_seats` snapshot. This is what lets an avatar /
  /// frame change made mid-session repaint an already-occupied seat, and what
  /// lets a late joiner see the occupant's current cosmetics. See
  /// [_withLiveAttributes].
  ///
  /// NOT a hardcoded constant: it is seeded at runtime from the exact keys the
  /// app publishes as the local participant's attributes (the
  /// `userInRoomAttributes` map at connect, plus any later
  /// [UTDRoomController.updateSelfAttributes]) via [registerCosmeticKeys]. The
  /// app publishes ONLY cosmetics as participant attributes, so this can never
  /// drift from the app's cosmetic key set. Empty until the app registers its
  /// keys — in which case [_withLiveAttributes] falls back to blank-fill-only,
  /// the original safe behavior.
  final Set<String> _liveCosmeticKeys = <String>{};

  /// Register the keys the app publishes as the local participant's cosmetic
  /// attributes so [_withLiveAttributes] treats them as live-authoritative.
  /// Called by [UTDRoomController] with `userInRoomAttributes.keys` at connect
  /// and with the delta on every `updateSelfAttributes`. Union (never resets),
  /// so the set only ever grows to cover every cosmetic the app has published.
  void registerCosmeticKeys(Iterable<String> keys) {
    _liveCosmeticKeys.addAll(keys.where((k) => k.isNotEmpty));
  }

  final UTDRoomManager _roomManager;
  StreamSubscription<Map<String, dynamic>>? _dataSub;

  /// The UTD Seat API client — set via [setSeatApi].
  UTDSeatApi? _seatApi;

  /// The RTC room name — needed for API calls.
  String? _roomId;

  /// Exposes the room ID for use by UTDRoomController speaker helpers.
  String? get roomId => _roomId;

  /// Subscription to room metadata changes (live _seats sync).
  StreamSubscription<String>? _metadataSub;

  /// Subscription to live participant-attribute changes (blank-seat repair).
  StreamSubscription<dynamic>? _attrsSub;

  /// Local-user cosmetic overrides published mid-session via
  /// [applyLocalCosmeticOverride] but not yet reflected in
  /// `localParticipant.attributes` (LiveKit's setAttributes does not update the
  /// local map until/unless the SFU echoes the change back — see
  /// [applyLocalCosmeticOverride]). Overlaid on top of the live participant map
  /// in [_liveParticipantInfo] so a subsequent `_seats` reapply cannot revert
  /// the seat to the stale published values. Cleared on reset/teardown.
  final Map<String, String> _localCosmeticOverrides = <String, String>{};

  /// Live profile changes (name/avatar/...) pushed by the host app for OTHER
  /// users in the room, overlaid on their RTC attributes so their seat repaints
  /// at once and a later `_seats` reapply cannot revert it.
  final Map<String, Map<String, String>> _remoteCosmeticOverrides =
      <String, Map<String, String>>{};

  /// Reconnection handler — tiered reconnect strategy.
  UTDReconnectionHandler? _reconnectionHandler;

  /// Sync manager — periodic light sync.
  UTDSyncManager? _syncManager;

  UTDSeatController(this._roomManager);

  /// Configure the seat API and room name for backend calls.
  /// Must be called after [initApi] on [UTDRoomController].
  void setSeatApi(UTDSeatApi seatApi, String roomId) {
    _seatApi = seatApi;
    _roomId = roomId;
    debugPrint('$_tag setSeatApi configured for room: $roomId');
  }

  /// Reactive seat state list.
  final ValueNotifier<List<SeatState>> seats = ValueNotifier([]);

  /// Current seat mode — "free" or "request".
  final ValueNotifier<String> seatMode = ValueNotifier('free');

  /// Current room mode ID (e.g. "3", "5", "cinema").
  /// Distinct from seatMode ("free"/"request").
  final ValueNotifier<String?> modeId = ValueNotifier(null);

  /// Pending speaker requests (for host/admin UI).
  final ValueNotifier<List<SpeakerRequest>> pendingRequests = ValueNotifier([]);

  final StreamController<List<SeatState>> _occupiedSeatsController =
      StreamController<List<SeatState>>.broadcast();
  VoidCallback? _seatsListener;

  /// Stream of occupied seats — emits whenever the seat state changes.
  Stream<List<SeatState>> get occupiedSeatsStream =>
      _occupiedSeatsController.stream;

  /// Speaker request/invitation event streams for the UIKit to listen to.
  final StreamController<Map<String, dynamic>> _speakerEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of speaker events (_speaker_request, _speaker_request_approved,
  /// _speaker_request_rejected, _speaker_invitation, etc.)
  Stream<Map<String, dynamic>> get speakerEventStream =>
      _speakerEventController.stream;

  /// Callback invoked when a `_speaker_invitation` event is received.
  /// Set this from the app layer to show the invitation dialog.
  /// The callback receives the full event data map.
  void Function(Map<String, dynamic> data)? onSpeakerInvitationReceived;

  /// Callback invoked when a `_speaker_invitation_accepted` event is received.
  void Function(Map<String, dynamic> data)? onSpeakerInvitationAccepted;

  /// Callback invoked when a `_speaker_invitation_declined` event is received.
  void Function(Map<String, dynamic> data)? onSpeakerInvitationDeclined;

  /// Callback invoked when a `_speaker_request` event is received (for host/admin).
  void Function(Map<String, dynamic> data)? onSpeakerRequestReceived;

  /// Callback invoked when a `_speaker_request_approved` event is received.
  void Function(Map<String, dynamic> data)? onSpeakerRequestApproved;

  /// Callback invoked when a `_speaker_request_rejected` event is received.
  void Function(Map<String, dynamic> data)? onSpeakerRequestRejected;

  /// Callback invoked when a `_mode_change` event is received.
  void Function(Map<String, dynamic> data)? onModeChange;

  /// Callback invoked when a `_banned` event targets the local user.
  void Function(Map<String, dynamic> data)? onBanned;

  /// Callback invoked when a `_kicked` (`signed_in_elsewhere`) event targets the
  /// local user — the account started a session on another device (newest-wins).
  void Function(Map<String, dynamic> data)? onKicked;

  /// Callback invoked when a `_role_change` event is received (for ANY user).
  /// Set by [UTDRoomController]; never filtered by identity here.
  void Function(Map<String, dynamic> data)? onRoleChanged;

  /// Callback invoked on a **live** `_chat_lock` data message (comments locked /
  /// unlocked). Distinct from [onChatLockMetadata] so the controller can announce
  /// only on the live toggle, not on the silent metadata sync.
  void Function(bool locked)? onChatLockEvent;

  /// Callback invoked when the room metadata's `chat_locked` is read — on join
  /// (initial state, covers a late joiner) and on every metadata change (a
  /// backstop for a missed `_chat_lock`). Carries no announcement.
  void Function(bool locked)? onChatLockMetadata;

  /// Callback invoked when the room has been disconnected long enough (>60s)
  /// that the reconnection handler gives up. Set by [UTDRoomController] so the
  /// app can tear down the dead room and navigate away. Without this the user
  /// is stranded on a frozen room.
  void Function()? onForceExit;

  /// Internal handler for the full invitation flow — set by UTDRoomController.
  /// When set, `_speaker_invitation` events trigger `handleIncomingInvitation`
  /// on the controller, which manages accept/decline + takeSeat + mic.
  Future<void> Function(Map<String, dynamic> data)? _onInvitationHandler;

  /// Sets the invitation handler. Called by UTDRoomController after connect.
  void setInvitationHandler(
      Future<void> Function(Map<String, dynamic> data)? handler) {
    _onInvitationHandler = handler;
  }

  /// Current layout mode seat count.
  int _seatCount = 9;

  /// Monotonic counter bumped on every [_applyBackendSeatState]. Used by the
  /// awaited GET /seats paths to detect that a fresher real-time apply
  /// (`_seat_update` / metadata) landed during the await, so a stale GET result
  /// is not allowed to clobber newer state. (The backend payload carries no
  /// version field, so this is the best available ordering guard.)
  int _applyGeneration = 0;

  /// Room id the grid was pre-seeded for via [prepareSeats] — lets [initSeats]
  /// keep the pre-connect snapshot instead of resetting to empty seats (which
  /// would flash the grid blank between token receipt and the metadata read).
  String? _preparedRoomId;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Pre-connect seat priming (called after a successful token response, in
  /// parallel with the RTC dial): resets the grid for THIS room, then applies
  /// the engine-provided [snapshot] when the token response embedded one, or
  /// falls back to a GET /seats fetch. Marks the room as prepared so the
  /// [initSeats] call at connect time preserves this state instead of
  /// clobbering it back to empty seats.
  Future<void> prepareSeats({
    required int seatCount,
    Map<String, dynamic>? snapshot,
  }) async {
    if (_disposed) return;
    // The reset IS an apply-ordering event: bump the generation so any
    // in-flight generation-guarded apply captured in the PREVIOUS room (e.g.
    // a takeSeat response whose broadcast died with the old RTC session)
    // fails its guard instead of contaminating the new room's grid.
    _applyGeneration++;
    _seatCount = seatCount;
    // Fresh empty grid for THIS room — never carry a previous room's
    // occupants across a room switch.
    seats.value = List.generate(seatCount, (i) => SeatState(index: i));
    _preparedRoomId = _roomId;

    if (snapshot != null) {
      debugPrint('$_tag prepareSeats — applying token-embedded snapshot');
      _applyBackendSeatState(snapshot);
      return;
    }
    if (_seatApi == null || _roomId == null) return;
    final gen = _applyGeneration;
    try {
      final data = await _seatApi!.getSeats(roomId: _roomId!);
      // Skip if a fresher apply (metadata read at connect / _seat_update)
      // landed during the await.
      if (!_disposed && _applyGeneration == gen) {
        _applyBackendSeatState(data);
        debugPrint('$_tag prepareSeats — pre-connect GET /seats applied');
      }
    } catch (e) {
      debugPrint('$_tag prepareSeats — pre-connect GET /seats failed: $e');
    }
  }

  /// Initialize seats for a given layout mode.
  /// Seats are populated from room metadata (`_seats`) automatically.
  void initSeats(int seatCount) {
    debugPrint('$_tag initSeats(seatCount: $seatCount)');
    // When prepareSeats already seeded THIS room's grid (pre-connect snapshot
    // racing the RTC dial), keep it — resetting would blank the seats the
    // user is already looking at; the metadata read below still applies any
    // fresher state. A prepare for a DIFFERENT room (or none) resets as
    // before.
    final prepared = _preparedRoomId != null && _preparedRoomId == _roomId;
    _preparedRoomId = null;
    if (prepared && seats.value.isNotEmpty) {
      _seatCount = seats.value.length;
    } else {
      _seatCount = seatCount;
      seats.value = List.generate(seatCount, (i) => SeatState(index: i));
    }
    _seatsListener = () {
      if (_disposed) return;
      final occupied = seats.value.where((s) => s.isOccupied).toList();
      _occupiedSeatsController.add(occupied);
    };
    seats.addListener(_seatsListener!);
    _listenToBackendMessages();
    _listenToRoomMetadataChanges();
    _listenToLiveAttributeChanges();
    _initReconnectionHandler();
    _initSyncManager();

    // Read initial seat state from room metadata
    _readRoomMetadataSeats();

    debugPrint(
        '$_tag initSeats complete — ${seats.value.length} seats created');
  }

  // ---------------------------------------------------------------------------
  // Read seat state from Room Metadata (_seats)
  // ---------------------------------------------------------------------------

  /// Reads `_seats` from room metadata and applies it to local state.
  /// Called on join and reconnect.
  void _readRoomMetadataSeats() {
    final room = _roomManager.room;
    if (room == null) {
      debugPrint('$_tag _readRoomMetadataSeats — room is null, skipping');
      return;
    }

    final metadataStr = room.metadata;
    if (metadataStr == null || metadataStr.isEmpty) {
      debugPrint(
          '$_tag _readRoomMetadataSeats — no room metadata, falling back to GET /seats');
      _fetchSeatsFromApiOnce();
      return;
    }

    try {
      final meta = jsonDecode(metadataStr) as Map<String, dynamic>;
      // Comment-lock initial state — read regardless of whether `_seats` is
      // present (covers a late joiner who connects while comments are locked).
      onChatLockMetadata?.call(meta['chat_locked'] == true);
      final seatsData = meta['_seats'] as Map<String, dynamic>?;
      if (seatsData != null) {
        // Payload logged in debug only: stringifying the full seat map on the
        // UI isolate (debugPrint runs in release too) janks the first paint.
        if (kDebugMode) {
          debugPrint(
              '$_tag _readRoomMetadataSeats — found _seats in metadata: $seatsData');
        }
        _applyBackendSeatState(seatsData);
      } else {
        debugPrint(
            '$_tag _readRoomMetadataSeats — no _seats in metadata, falling back to GET /seats');
        _fetchSeatsFromApiOnce();
      }
    } catch (e) {
      debugPrint('$_tag _readRoomMetadataSeats — parse error: $e');
      _fetchSeatsFromApiOnce();
    }
  }

  /// One-time fallback: fetches seat state from GET /seats API.
  /// Called only when room metadata is null/empty on first join.
  Future<void> _fetchSeatsFromApiOnce() async {
    if (_seatApi == null || _roomId == null) {
      debugPrint('$_tag _fetchSeatsFromApiOnce — API not configured, skipping');
      return;
    }

    try {
      debugPrint(
          '$_tag _fetchSeatsFromApiOnce — fetching seats via GET /seats');
      final gen = _applyGeneration;
      final data = await _seatApi!.getSeats(roomId: _roomId!);
      // Skip if a real-time _seat_update / metadata apply already landed during
      // the await (it is fresher than this one-time fallback fetch).
      if (_applyGeneration == gen) {
        _applyBackendSeatState(data);
        debugPrint('$_tag _fetchSeatsFromApiOnce — applied successfully');
      } else {
        debugPrint(
            '$_tag _fetchSeatsFromApiOnce — skipped (newer apply landed)');
      }
    } catch (e) {
      debugPrint('$_tag _fetchSeatsFromApiOnce — error: $e');
    }
  }

  /// Re-sync seats from room metadata. Call this on reconnect.
  void resyncFromMetadata() {
    debugPrint('$_tag resyncFromMetadata');
    _readRoomMetadataSeats();
  }

  // ---------------------------------------------------------------------------
  // Apply backend seat state (_seat_update or _seats metadata)
  // ---------------------------------------------------------------------------

  /// Applies the full seat state from backend data.
  /// Both `_seat_update` data messages and `_seats` metadata use the same structure:
  /// ```json
  /// { "count": 9, "mode": "free", "seats": [...], "requests": [...] }
  /// ```
  /// Resize the local seat list to [count], preserving existing seat state for
  /// overlapping indices. Used after a `_mode_change` changes the seat count so
  /// `seats.value.length` stays in sync with [_seatCount] until the next
  /// `_seat_update` arrives.
  void _resizeSeats(int count) {
    if (_disposed || count <= 0) return;
    final old = seats.value;
    if (old.length == count) return;
    seats.value = List<SeatState>.generate(
      count,
      (i) => i < old.length ? old[i] : SeatState(index: i),
    );
  }

  void _applyBackendSeatState(Map<String, dynamic> data) {
    // Reached through awaited async paths (reconnect full-sync, GET /seats
    // fallback). If dispose() ran during the await gap, the ValueNotifiers
    // below are already disposed — writing to them throws. Bail out.
    if (_disposed) return;
    _applyGeneration++;
    final roomState = RoomSeatState.fromJson(data);

    debugPrint(
        '$_tag _applyBackendSeatState — count: ${roomState.count}, mode: ${roomState.mode}, '
        'seats: ${roomState.seats.length}, requests: ${roomState.requests.length}');

    // Update seat mode
    seatMode.value = roomState.mode;

    // Update mode ID if present
    if (roomState.modeId != null) {
      modeId.value = roomState.modeId;
    }

    // Update pending requests
    pendingRequests.value = roomState.requests;

    // Update seat count if changed
    if (roomState.count != _seatCount && roomState.count > 0) {
      _seatCount = roomState.count;
    }

    // Build new seat list from backend data
    final newSeats = List<SeatState>.generate(_seatCount, (i) {
      // Find matching seat from backend
      final backendSeat =
          roomState.seats.where((s) => s.index == i).firstOrNull;

      if (backendSeat != null) {
        // Backend attributes win, but blanks are repaired PER KEY: (a) from
        // the previous local state when the SAME user still occupies this
        // index (a partial server payload — e.g. the DB fallback knows only
        // the avatar — must not strip a frame we already had), then (b) from
        // the occupant's LIVE RTC participant state, so seats never render
        // anonymous while the user is right there in the room. Never merged
        // across different occupants — a vacated-and-retaken seat must not
        // graft the previous occupant's identity onto the new one.
        var seat = backendSeat;
        if (seat.occupantUserId != null) {
          final existing = i < seats.value.length ? seats.value[i] : null;
          if (existing != null &&
              existing.occupantUserId == seat.occupantUserId &&
              existing.attributes.isNotEmpty) {
            final merged = Map<String, String>.from(seat.attributes);
            var changed = false;
            existing.attributes.forEach((key, value) {
              if (value.isNotEmpty && (merged[key] ?? '').isEmpty) {
                merged[key] = value;
                changed = true;
              }
            });
            if (changed) seat = seat.copyWith(attributes: merged);
          }
          seat = _withLiveAttributes(seat);
        }
        return seat;
      }
      return SeatState(index: i);
    });

    // Only reassign (and thus notify -> rebuild the whole seat grid) when the
    // seat content actually changed. The backend pushes _seat_update frequently
    // and a fresh List instance always != the old one by identity, so without
    // this guard every redundant push rebuilt all SeatAvatarWidgets. SeatState
    // is Equatable, so listEquals compares by content.
    if (!listEquals(newSeats, seats.value)) {
      seats.value = newSeats;
    }
  }

  /// Live name/attributes for a connected participant, or null when [identity]
  /// is not (yet) in the room.
  ({String name, Map<String, String> attributes})? _liveParticipantInfo(
      String identity) {
    final local = _roomManager.localParticipant;
    if (local != null && local.identity == identity) {
      // Overlay any mid-session cosmetic overrides that have not yet echoed back
      // into local.attributes, so a `_seats` reapply can't revert them.
      final attrs = Map<String, String>.from(local.attributes);
      if (_localCosmeticOverrides.isNotEmpty) {
        _localCosmeticOverrides.forEach((k, v) {
          if (v.isNotEmpty) attrs[k] = v;
        });
      }
      return (name: local.name, attributes: attrs);
    }
    for (final p in _roomManager.remoteParticipants) {
      if (p.identity == identity) {
        final remoteAttrs = Map<String, String>.from(p.attributes);
        _remoteCosmeticOverrides[identity]?.forEach((k, v) {
          if (v.isNotEmpty) remoteAttrs[k] = v;
        });
        return (
          name: p.name,
          attributes: remoteAttrs,
        );
      }
    }
    return null;
  }

  /// Fills occupant info (name/avatar/frame…) from the occupant's live RTC
  /// participant state. The `_seats` metadata is enriched server-side at the
  /// time of the LAST seat mutation — a failed lookup there, or a user who took
  /// a seat before their post-connect setAttributes landed, would otherwise
  /// render as an anonymous circle until the next mutation.
  ///
  /// Merge rule:
  /// - For [_liveCosmeticKeys] (avatar/frame/geometry/name/color): a non-empty
  ///   *live* value WINS over the `_seats` value. These are not server-moderated
  ///   (the backend only reads them), so the occupant's own latest published
  ///   value is authoritative — this is what makes a mid-session avatar/frame
  ///   change repaint an occupied seat and reach late joiners.
  /// - For every other key: backend wins; only blanks are filled from live.
  SeatState _withLiveAttributes(SeatState seat) {
    final occupant = seat.occupantUserId;
    if (occupant == null) return seat;
    final live = _liveParticipantInfo(occupant);
    if (live == null) return seat;
    final attrs = seat.attributes;
    final merged = Map<String, String>.from(attrs);
    var changed = false;
    // Name is a cosmetic key too, but historically filled from live.name (which
    // may live outside the attributes map on some participants) — keep that
    // source. Let a live value override a stale one ONLY when 'name' is a
    // registered cosmetic; otherwise blank-fill only, preserving the original
    // behavior when the app registers no keys.
    if (live.name.isNotEmpty) {
      final nameIsCosmetic = _liveCosmeticKeys.contains('name');
      final current = merged['name'] ?? '';
      final shouldApply = nameIsCosmetic ? current != live.name : current.isEmpty;
      if (shouldApply) {
        merged['name'] = live.name;
        changed = true;
      }
    }
    live.attributes.forEach((key, value) {
      if (value.isEmpty) return;
      final current = merged[key] ?? '';
      final isCosmetic = _liveCosmeticKeys.contains(key);
      // Cosmetic: live wins on any difference. Non-cosmetic: fill blanks only.
      final shouldApply = isCosmetic ? value != current : current.isEmpty;
      if (shouldApply) {
        merged[key] = value;
        changed = true;
      }
    });
    if (!changed) return seat;
    return seat.copyWith(attributes: merged);
  }

  /// Re-runs the live-attribute fill for [identity]'s seat when their RTC
  /// attributes change (e.g. the unawaited post-connect setAttributes finally
  /// landed after they were already seated) — repairs blanks without waiting
  /// for the next seat mutation. Purely local enrichment: deliberately does
  /// NOT bump [_applyGeneration].
  void _onLiveAttributesChanged(String identity) {
    if (_disposed) return;
    final current = seats.value;
    var changed = false;
    final updated = List<SeatState>.generate(current.length, (i) {
      final seat = current[i];
      if (seat.occupantUserId != identity) return seat;
      final enriched = _withLiveAttributes(seat);
      if (enriched != seat) changed = true;
      return enriched;
    });
    if (changed) seats.value = updated;
  }

  /// Optimistically merges freshly re-published cosmetic [attrs] onto
  /// [identity]'s occupied seat WITHOUT waiting for the RTC echo.
  ///
  /// This is the local-user counterpart to [_onLiveAttributesChanged]. LiveKit's
  /// [LocalParticipant.setAttributes] only sends the change to the SFU and awaits
  /// an ack — it does NOT update `localParticipant.attributes` locally. The
  /// local attribute map (and therefore the local user's own seat) only refreshes
  /// if/when the server broadcasts a full participant update back to the sender,
  /// which some SFU configs do not echo to the origin. Without this, a user who
  /// changes their avatar/frame in Profile or the Mall never sees it on their own
  /// seat until they rejoin (a rejoin reads the fresh backend `_seats`). Applying
  /// the published values directly closes that gap; the eventual echo (if any) is
  /// then a no-op through [_withLiveAttributes].
  ///
  /// Only the passed keys are written, and only non-empty values, so this never
  /// clobbers server-owned seat fields. Purely local; does NOT bump
  /// [_applyGeneration].
  void applyLocalCosmeticOverride(String identity, Map<String, String> attrs) {
    if (_disposed || attrs.isEmpty) return;
    registerCosmeticKeys(attrs.keys);
    // Record the overrides so a later `_seats` reapply (which re-reads the still
    // stale local.attributes) cannot revert the seat — [_liveParticipantInfo]
    // overlays these for the local participant.
    attrs.forEach((k, v) {
      if (v.isNotEmpty) _localCosmeticOverrides[k] = v;
    });
    // Repaint the local seat now via the same merge path used for RTC echoes.
    _onLiveAttributesChanged(identity);
  }

  /// Applies a live profile change for ANOTHER user ([identity]) to their seat.
  /// Only non-empty values are written. Purely local; does NOT bump
  /// [_applyGeneration].
  void applyRemoteCosmeticOverride(String identity, Map<String, String> attrs) {
    if (_disposed || attrs.isEmpty) return;
    registerCosmeticKeys(attrs.keys);
    final store = _remoteCosmeticOverrides.putIfAbsent(
        identity, () => <String, String>{});
    attrs.forEach((k, v) {
      if (v.isNotEmpty) store[k] = v;
    });
    _onLiveAttributesChanged(identity);
  }

  // ---------------------------------------------------------------------------
  // API Operations — Call REST API, let _seat_update handle state
  // ---------------------------------------------------------------------------

  /// User takes a seat at [index].
  /// Calls UTD Stream API — state update comes via `_seat_update`.
  Future<bool> takeSeat(
    int index,
    String userId,
  ) async {
    debugPrint('$_tag takeSeat(index: $index, userId: $userId)');

    final micStatus = await Permission.microphone.status;
    if (micStatus.isDenied) {
      await Permission.microphone.request();
    }

    // Android 12+ needs BLUETOOTH_CONNECT at runtime to route mic audio to a
    // paired Bluetooth headset. Without it, taking the mic falls back to the
    // phone speaker/mic even when a BT headset is connected. (Declared in the
    // manifest but never requested before.) iOS handles BT routing without this.
    if (Platform.isAndroid) {
      final btStatus = await Permission.bluetoothConnect.status;
      if (btStatus.isDenied) {
        await Permission.bluetoothConnect.request();
      }
    }

    if (index < 0 || index >= _seatCount) {
      debugPrint(
          '$_tag takeSeat REJECTED — index out of range (seatCount: $_seatCount)');
      return false;
    }

    if (_seatApi == null || _roomId == null) {
      debugPrint('$_tag takeSeat REJECTED — API not configured');
      return false;
    }

    // The grid renders (and is tappable) from token receipt, BEFORE the RTC
    // connect resolves. A take issued in that window would seat the user in
    // the DB while the engine's mic-permission grant no-ops (the participant
    // isn't in the room yet) — seated but never able to unmute; and if the
    // connect then fails, no participant_left webhook ever frees the ghost
    // seat. Mutations wait for the live connection.
    if (_roomManager.connectionState.value != UTDConnectionState.connected) {
      debugPrint('$_tag takeSeat REJECTED — RTC not connected yet');
      return false;
    }

    try {
      debugPrint('$_tag takeSeat — calling UTD API: POST /seats/$index/take');
      final gen = _applyGeneration;
      final rid = _roomId!;
      final res = await _seatApi!.takeSeat(
        roomId: rid,
        seatIndex: index,
        identity: userId,
      );
      applyMutationResponse(res, gen: gen, roomId: rid);
      debugPrint('$_tag takeSeat — UTD API SUCCESS');
      return true;
    } catch (e) {
      // The backend's own seat DB can know the user is already seated
      // (e.g. their reserved owner seat, or a stale prior session) even
      // when the room-metadata snapshot this controller read on join
      // still shows that seat's occupant as null — that gap is exactly
      // what the 409 body says ("Already on this seat" / "Already
      // seated — use move"). Failing here with just an error toast left
      // the user unable to sit down at all until they backed out and
      // re-entered the room. Retrying as a move (what the server itself
      // is telling us to do) completes the action instead.
      if (e is DioException && e.response?.statusCode == 409) {
        debugPrint(
            '$_tag takeSeat — 409 conflict, retrying as moveSeat(userId: $userId, targetSeat: $index)');
        return moveSeat(userId, index);
      }
      debugPrint('$_tag takeSeat — UTD API ERROR: $e');
      return false;
    }
  }

  /// Generation counter snapshot for [applyMutationResponse] callers outside
  /// this controller (invitation accept / request approve flows) — capture it
  /// BEFORE issuing the request.
  int get applyGeneration => _applyGeneration;

  /// Applies the enriched `state` snapshot newer engines return inline on seat
  /// mutation responses, so the actor's own UI updates one broadcast round
  /// trip earlier (the `_seat_update` broadcast still updates everyone else
  /// and remains authoritative). [gen] is the [_applyGeneration] captured
  /// before the request: if any backend apply landed during it — e.g. our own
  /// broadcast beat the response, or someone else's change did — the response
  /// snapshot is stale and is skipped. [roomId] is the room the request was
  /// issued against: a room switch during the await (prepareSeats/setSeatApi
  /// repointed the controller) also invalidates the response. Older engines
  /// send no `state`; this is then a no-op.
  void applyMutationResponse(
    Map<String, dynamic>? response, {
    required int gen,
    required String? roomId,
  }) {
    if (response == null || _disposed) return;
    if (gen != _applyGeneration) return;
    if (roomId == null || roomId != _roomId) return;
    final state = response['state'];
    if (state is Map<String, dynamic>) _applyBackendSeatState(state);
  }

  /// User leaves their current seat.
  /// Calls UTD Stream API — state update comes via `_seat_update`.
  Future<bool> leaveSeat(String userId) async {
    debugPrint('$_tag leaveSeat(userId: $userId)');

    if (_seatApi == null || _roomId == null) {
      debugPrint('$_tag leaveSeat REJECTED — API not configured');
      return false;
    }

    try {
      debugPrint('$_tag leaveSeat — calling UTD API: POST /seats/leave');
      final gen = _applyGeneration;
      final rid = _roomId!;
      final res = await _seatApi!.leaveSeat(
        roomId: rid,
        identity: userId,
      );
      applyMutationResponse(res, gen: gen, roomId: rid);
      debugPrint('$_tag leaveSeat — UTD API SUCCESS');
      return true;
    } catch (e) {
      debugPrint('$_tag leaveSeat — UTD API ERROR: $e');
      return false;
    }
  }

  /// Move to another seat (atomic operation).
  /// Calls UTD Stream API — state update comes via `_seat_update`.
  Future<bool> moveSeat(String userId, int targetSeat) async {
    debugPrint('$_tag moveSeat(userId: $userId, targetSeat: $targetSeat)');

    if (_seatApi == null || _roomId == null) {
      debugPrint('$_tag moveSeat REJECTED — API not configured');
      return false;
    }

    // Same pre-connect gate as takeSeat (see there).
    if (_roomManager.connectionState.value != UTDConnectionState.connected) {
      debugPrint('$_tag moveSeat REJECTED — RTC not connected yet');
      return false;
    }

    try {
      debugPrint('$_tag moveSeat — calling UTD API: POST /seats/move');
      final gen = _applyGeneration;
      final rid = _roomId!;
      final res = await _seatApi!.moveSeat(
        roomId: rid,
        identity: userId,
        targetSeat: targetSeat,
      );
      applyMutationResponse(res, gen: gen, roomId: rid);
      debugPrint('$_tag moveSeat — UTD API SUCCESS');
      return true;
    } catch (e) {
      debugPrint('$_tag moveSeat — UTD API ERROR: $e');
      return false;
    }
  }

  /// Admin locks a seat at [index].
  /// Calls UTD Stream API — state update comes via `_seat_update`.
  Future<bool> lockSeat(int index, {required String identity}) async {
    debugPrint('$_tag lockSeat(index: $index, identity: $identity)');

    if (_seatApi == null || _roomId == null) {
      debugPrint('$_tag lockSeat REJECTED — API not configured');
      return false;
    }

    try {
      debugPrint('$_tag lockSeat — calling UTD API: POST /seats/$index/lock');
      final gen = _applyGeneration;
      final rid = _roomId!;
      final res = await _seatApi!.lockSeat(
        roomId: rid,
        seatIndex: index,
        identity: identity,
      );
      applyMutationResponse(res, gen: gen, roomId: rid);
      debugPrint('$_tag lockSeat — UTD API SUCCESS');
      return true;
    } catch (e) {
      debugPrint('$_tag lockSeat — UTD API ERROR: $e');
      return false;
    }
  }

  /// Admin unlocks a seat at [index].
  /// Calls UTD Stream API — state update comes via `_seat_update`.
  Future<bool> unlockSeat(int index, {required String identity}) async {
    debugPrint('$_tag unlockSeat(index: $index, identity: $identity)');

    if (_seatApi == null || _roomId == null) {
      debugPrint('$_tag unlockSeat REJECTED — API not configured');
      return false;
    }

    try {
      debugPrint(
          '$_tag unlockSeat — calling UTD API: POST /seats/$index/unlock');
      final gen = _applyGeneration;
      final rid = _roomId!;
      final res = await _seatApi!.unlockSeat(
        roomId: rid,
        seatIndex: index,
        identity: identity,
      );
      applyMutationResponse(res, gen: gen, roomId: rid);
      debugPrint('$_tag unlockSeat — UTD API SUCCESS');
      return true;
    } catch (e) {
      debugPrint('$_tag unlockSeat — UTD API ERROR: $e');
      return false;
    }
  }

  /// Remove occupant from seat at [index] (host/admin only).
  /// Calls UTD Stream API — state update comes via `_seat_update`.
  Future<bool> kickFromSeat(int index, {required String identity}) async {
    debugPrint('$_tag kickFromSeat(index: $index, identity: $identity)');

    if (_seatApi == null || _roomId == null) {
      debugPrint('$_tag kickFromSeat REJECTED — API not configured');
      return false;
    }

    try {
      debugPrint(
          '$_tag kickFromSeat — calling UTD API: POST /seats/$index/kick');
      final gen = _applyGeneration;
      final rid = _roomId!;
      final res = await _seatApi!.kickFromSeat(
        roomId: rid,
        seatIndex: index,
        identity: identity,
      );
      applyMutationResponse(res, gen: gen, roomId: rid);
      debugPrint('$_tag kickFromSeat — UTD API SUCCESS');
      return true;
    } catch (e) {
      debugPrint('$_tag kickFromSeat — UTD API ERROR: $e');
      return false;
    }
  }

  /// Mute a specific seat (host/admin only).
  /// Calls UTD Stream API — server-side mute via the RTC engine.
  Future<bool> muteSeat(int index, {required String identity}) async {
    debugPrint('$_tag muteSeat(index: $index, identity: $identity)');

    if (_seatApi == null || _roomId == null) return false;

    try {
      debugPrint('$_tag muteSeat — calling UTD API: POST /seats/$index/mute');
      await _seatApi!.muteSeat(
        roomId: _roomId!,
        seatIndex: index,
        identity: identity,
      );
      debugPrint('$_tag muteSeat — UTD API SUCCESS');
      return true;
    } catch (e) {
      debugPrint('$_tag muteSeat — UTD API ERROR: $e');
      return false;
    }
  }

  /// Unmute a specific seat (host/admin only).
  /// Calls UTD Stream API — server-side unmute via the RTC engine.
  Future<bool> unmuteSeat(int index, {required String identity}) async {
    debugPrint('$_tag unmuteSeat(index: $index, identity: $identity)');

    if (_seatApi == null || _roomId == null) return false;

    try {
      debugPrint(
          '$_tag unmuteSeat — calling UTD API: POST /seats/$index/unmute');
      await _seatApi!.unmuteSeat(
        roomId: _roomId!,
        seatIndex: index,
        identity: identity,
      );
      debugPrint('$_tag unmuteSeat — UTD API SUCCESS');
      return true;
    } catch (e) {
      debugPrint('$_tag unmuteSeat — UTD API ERROR: $e');
      return false;
    }
  }

  /// Change seat configuration mid-room (host/admin only).
  /// Calls UTD Stream API — state update comes via `_seat_update`.
  Future<bool> setupSeats({
    required String identity,
    required int seatCount,
    required String seatMode,
    String? modeId,
  }) async {
    debugPrint(
        '$_tag setupSeats(identity: $identity, count: $seatCount, mode: $seatMode, modeId: $modeId)');

    if (_seatApi == null || _roomId == null) return false;

    try {
      final gen = _applyGeneration;
      final rid = _roomId!;
      final res = await _seatApi!.setupSeats(
        roomId: rid,
        identity: identity,
        seatCount: seatCount,
        seatMode: seatMode,
        modeId: modeId,
      );
      applyMutationResponse(res, gen: gen, roomId: rid);
      debugPrint('$_tag setupSeats — UTD API SUCCESS');
      return true;
    } catch (e) {
      debugPrint('$_tag setupSeats — UTD API ERROR: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Query helpers
  // ---------------------------------------------------------------------------

  /// Get seat index by user ID. Returns -1 if not found.
  int getSeatIndexByUserId(String userId) {
    return seats.value.indexWhere((s) => s.occupantUserId == userId);
  }

  /// Whether a user is on any seat.
  bool isUserOnSeat(String userId) => getSeatIndexByUserId(userId) >= 0;

  /// Whether the seat at [index] is locked by an admin.
  bool isSeatLocked(int index) {
    if (index < 0 || index >= seats.value.length) return false;
    return seats.value[index].isLocked;
  }

  /// Whether the seat at [index] is available for a user to sit on.
  /// A seat is available when it is empty, not locked, and not reserved
  /// for someone else.
  bool isSeatAvailable(int index, {String? userId}) {
    if (index < 0 || index >= seats.value.length) return false;
    final seat = seats.value[index];
    if (seat.isOccupied) return false;
    if (seat.isLocked) return false;
    if (seat.isReserved && seat.reservedFor != userId) return false;
    return true;
  }

  /// Whether [userId] can take the seat at [index].
  ///
  /// Returns `true` when:
  /// - The seat exists and is not occupied.
  /// - The seat is not locked.
  /// - The seat is either unreserved, or reserved for this [userId].
  bool canUserTakeSeat(int index, String userId) {
    return isSeatAvailable(index, userId: userId);
  }

  /// Set of seat indices that are currently locked.
  Set<int> get lockedSeatIndices {
    return seats.value
        .where((s) => s.isLocked)
        .map((s) => s.index)
        .toSet();
  }

  /// Set of seat indices that are currently unavailable
  /// (locked or reserved for someone else).
  Set<int> get unavailableSeatIndices {
    return seats.value
        .where((s) => s.isLocked || s.isReserved)
        .map((s) => s.index)
        .toSet();
  }

  @Deprecated('Use UTDRoomController.resolveMode(modeId).seatCount instead')
  static int seatCountForMode(String mode) {
    const modeToCount = <String, int>{
      '3': 9,
      '2': 12,
      '1': 16,
      '5': 9,
      '8': 8,
      '6': 2,
      '7': 22,
      '9': 8,
    };
    return modeToCount[mode] ?? 9;
  }

  // ---------------------------------------------------------------------------
  // Private — listen to backend data messages
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Room Metadata live listener (Fix #1)
  // ---------------------------------------------------------------------------

  /// Listens to room metadata changes from the RTC engine.
  /// This is a fallback in case a `_seat_update` data message is missed.
  /// On every metadata change, we extract `_seats` and apply it.
  /// Subscribes to RTC participant-attribute changes so a seat rendered with
  /// blank name/avatar self-heals the moment the occupant's live attributes
  /// arrive (see [_onLiveAttributesChanged]).
  void _listenToLiveAttributeChanges() {
    _attrsSub?.cancel();
    _attrsSub = _roomManager.participantAttributesChangedStream.listen((p) {
      _onLiveAttributesChanged(p.identity);
    });
  }

  void _listenToRoomMetadataChanges() {
    debugPrint('$_tag _listenToRoomMetadataChanges — subscribing');
    _metadataSub = _roomManager.roomMetadataStream.listen((metadataStr) {
      try {
        final meta = jsonDecode(metadataStr) as Map<String, dynamic>;
        // Comment-lock sync — authoritative backstop for a missed `_chat_lock`.
        onChatLockMetadata?.call(meta['chat_locked'] == true);
        final seatsData = meta['_seats'] as Map<String, dynamic>?;
        if (seatsData != null) {
          debugPrint('$_tag room metadata changed — applying _seats');
          _applyBackendSeatState(seatsData);
        }
      } catch (e) {
        debugPrint('$_tag room metadata change parse error: $e');
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Reconnection Handler (Fix #4)
  // ---------------------------------------------------------------------------

  /// Initializes the reconnection handler with tiered sync strategy.
  void _initReconnectionHandler() {
    _reconnectionHandler = UTDReconnectionHandler(
      onLightSync: () async {
        debugPrint('$_tag reconnection — light sync (< 15s)');
        resyncFromMetadata();
      },
      onFullSync: () async {
        debugPrint('$_tag reconnection — full sync (15-60s)');
        // Full sync: re-read metadata + fetch seats via API if available
        resyncFromMetadata();
        if (_seatApi != null && _roomId != null) {
          final gen = _applyGeneration;
          try {
            final data = await _seatApi!.getSeats(roomId: _roomId!);
            // Skip if a fresher real-time apply (_seat_update / metadata) landed
            // during the await — otherwise the stale GET clobbers newer state.
            if (_applyGeneration == gen) {
              _applyBackendSeatState(data);
            } else {
              debugPrint(
                  '$_tag full sync — skipping stale GET /seats (newer apply landed)');
            }
          } catch (e) {
            debugPrint('$_tag reconnection full sync API error: $e');
          }
        }
      },
      onForceExit: () {
        debugPrint('$_tag reconnection — force exit (> 60s)');
        // Surface to UTDRoomController -> app so the dead room is torn down and
        // the user is navigated away (mirrors the ban/participant-removed path).
        onForceExit?.call();
      },
    );

    // Wire reconnection handler to room manager connection state changes
    _roomManager.connectionState.addListener(_onConnectionStateChanged);
  }

  /// Tracks connection state changes to trigger reconnection handler.
  void _onConnectionStateChanged() {
    final state = _roomManager.connectionState.value;
    if (state == UTDConnectionState.reconnecting ||
        state == UTDConnectionState.disconnected) {
      _reconnectionHandler?.onDisconnected();
      _syncManager?.stopPeriodicSync();
    } else if (state == UTDConnectionState.connected) {
      _reconnectionHandler?.onReconnected();
      // No periodic sync — only reconnection full sync is used.
    }
  }

  // ---------------------------------------------------------------------------
  // Sync Manager (Fix #4)
  // ---------------------------------------------------------------------------

  /// Initializes the sync manager (used only for reconnection full sync,
  /// NOT periodic polling).
  void _initSyncManager() {
    _syncManager = UTDSyncManager(
      fetchSeatMap: () async {
        if (_seatApi == null || _roomId == null) return seats.value;
        final data = await _seatApi!.getSeats(roomId: _roomId!);
        final roomState = RoomSeatState.fromJson(data);
        return roomState.seats;
      },
      fetchFullRoomState: () async {
        if (_seatApi == null || _roomId == null) return {};
        return await _seatApi!.getSeats(roomId: _roomId!);
      },
      applyFullState: (state) {
        if (state.isNotEmpty) _applyBackendSeatState(state);
      },
      applySeats: (newSeats) {
        seats.value = newSeats;
      },
    );
    // No periodic sync — we rely on _seat_update data messages +
    // room metadata _seats. GET /seats is only called as a fallback
    // when metadata is empty on first join (see _readRoomMetadataSeats).
  }

  // ---------------------------------------------------------------------------
  // Private — listen to backend data messages
  // ---------------------------------------------------------------------------

  /// Listen to ALL data messages from the backend.
  /// Routes `_seat_update` to seat state, and speaker events to their stream.
  void _listenToBackendMessages() {
    debugPrint('$_tag _listenToBackendMessages — subscribing to data stream');
    _dataSub = _roomManager.dataStream.listen((data) {
      if (_disposed) return;
      final type = data['type'] as String?;

      // Handle backend system messages (prefixed with _)
      if (type != null) {
        switch (type) {
          case '_mode_change':
            debugPrint('$_tag received _mode_change from backend: $data');
            final newModeId = data['mode_id'] as String?;
            if (newModeId != null) modeId.value = newModeId;
            final newSeatCount = (data['seat_count'] as num?)?.toInt();
            if (newSeatCount != null &&
                newSeatCount > 0 &&
                newSeatCount != _seatCount) {
              _seatCount = newSeatCount;
              // Keep seats.value.length in sync with _seatCount immediately.
              // Otherwise (until the next _seat_update) take/availability guards
              // read the new count while the UI and isSeatAvailable read the old
              // seats list, giving inconsistent results.
              _resizeSeats(newSeatCount);
            }
            onModeChange?.call(data);
            break;
          case '_seat_update':
            debugPrint('$_tag received _seat_update from backend');
            _applyBackendSeatState(data);
            break;
          case '_speaker_request':
            debugPrint('$_tag received speaker event: $type');
            _speakerEventController.add(data);
            onSpeakerRequestReceived?.call(data);
            break;
          case '_speaker_request_approved':
            debugPrint('$_tag received speaker event: $type');
            _speakerEventController.add(data);
            onSpeakerRequestApproved?.call(data);
            break;
          case '_speaker_request_rejected':
            debugPrint('$_tag received speaker event: $type');
            _speakerEventController.add(data);
            onSpeakerRequestRejected?.call(data);
            break;
          case '_speaker_invitation':
            debugPrint('$_tag received speaker event: $type');
            _speakerEventController.add(data);
            onSpeakerInvitationReceived?.call(data);
            // Also trigger the full invitation flow on UTDRoomController
            // if onInvitationUI is set (package-managed flow)
            _onInvitationHandler?.call(data);
            break;
          case '_speaker_invitation_accepted':
            debugPrint('$_tag received speaker event: $type');
            _speakerEventController.add(data);
            onSpeakerInvitationAccepted?.call(data);
            break;
          case '_speaker_invitation_declined':
            debugPrint('$_tag received speaker event: $type');
            _speakerEventController.add(data);
            onSpeakerInvitationDeclined?.call(data);
            break;
          case '_banned':
            debugPrint('$_tag received _banned from backend: $data');
            // The server only sends `_banned` to the banned participant, but
            // guard with an identity check when one is present, just in case.
            final target = data['identity'] as String?;
            final me = _roomManager.localParticipant?.identity;
            if (target == null || me == null || target == me) {
              onBanned?.call(data);
            }
            break;
          case '_kicked':
            // Single-active-session takeover: the account signed in elsewhere and
            // the engine is removing this device. Sent only to the kicked
            // participant, just before removeParticipant. Surface it as a distinct
            // "signed in elsewhere" exit (not a ban) before the disconnect lands.
            debugPrint('$_tag received _kicked from backend: $data');
            onKicked?.call(data);
            break;
          case '_role_change':
            // Broadcast to everyone (server-sent, so the event participant is
            // null). Do NOT filter by identity — the controller needs every
            // change to maintain its role cache.
            debugPrint('$_tag received _role_change from backend: $data');
            onRoleChanged?.call(data);
            break;
          case '_chat_lock':
            // Broadcast to everyone when the host locks/unlocks comments. Only
            // affects chat; gifts/reactions/seat events are never gated.
            debugPrint('$_tag received _chat_lock from backend: $data');
            onChatLockEvent?.call(data['locked'] == true);
            break;
        }
        return;
      }

      // Legacy client-side messages (messageContent pattern) — keep for backward compat
      final content = data['messageContent'] as Map<String, dynamic>?;
      if (content == null) return;

      final message = content['message'] as String?;
      if (message == null) return;

      debugPrint(
          '$_tag received legacy data channel message: $message | content: $content');
    });
  }

  /// Disarms the reconnection force-exit (and its connection-state listener)
  /// while a kit-driven (re)connect is in flight — the connect retry loop owns
  /// failure handling there, and a 60s force-exit firing mid-retry would tear
  /// down a join that is still progressing. [initSeats] re-arms a fresh
  /// handler once the connect succeeds.
  void suspendReconnectionHandling() {
    _roomManager.connectionState.removeListener(_onConnectionStateChanged);
    _reconnectionHandler?.dispose();
    _reconnectionHandler = null;
  }

  void stopListening() {
    _dataSub?.cancel();
    _dataSub = null;
    _metadataSub?.cancel();
    _metadataSub = null;
    _attrsSub?.cancel();
    _attrsSub = null;
    _roomManager.connectionState.removeListener(_onConnectionStateChanged);
    _reconnectionHandler?.dispose();
    _reconnectionHandler = null;
    _syncManager?.dispose();
    _syncManager = null;
    if (_seatsListener != null) {
      seats.removeListener(_seatsListener!);
      _seatsListener = null;
    }
  }

  bool _disposed = false;

  /// Dispose resources.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    debugPrint('$_tag dispose()');
    _localCosmeticOverrides.clear();
    _remoteCosmeticOverrides.clear();
    stopListening();
    _occupiedSeatsController.close();
    _speakerEventController.close();
    seatMode.dispose();
    modeId.dispose();
    pendingRequests.dispose();
    seats.dispose();
  }
}
