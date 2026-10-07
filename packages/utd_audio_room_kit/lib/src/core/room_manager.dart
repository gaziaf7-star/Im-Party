import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'constants.dart';
import 'connection_state.dart';

export 'connection_state.dart';

/// Wraps the underlying real-time [Room] and exposes a simplified API.
/// The kit's central RTC engine + UI handle.
class UTDRoomManager {
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  /// Notifies UI of connection state changes.
  final ValueNotifier<UTDConnectionState> connectionState =
      ValueNotifier(UTDConnectionState.disconnected);

  /// Reason for the most recent room disconnect (if any).
  DisconnectReason? lastDisconnectReason;

  /// Fired when the SERVER removed us from the room
  /// (`DisconnectReason.participantRemoved`). Used as a ban fallback when the
  /// `_banned` data message is not delivered before removal.
  void Function()? onParticipantRemoved;

  /// Stream of incoming data channel messages (the kit's in-room data channel).
  final StreamController<Map<String, dynamic>> _dataController =
      StreamController.broadcast();

  /// Stream of incoming data messages.
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  /// Stream of room metadata changes — emits new metadata JSON string
  /// whenever the backend updates room metadata (e.g., _seats).
  final StreamController<String> _roomMetadataController =
      StreamController<String>.broadcast();

  /// Listen to this for room metadata changes (includes _seats updates).
  Stream<String> get roomMetadataStream => _roomMetadataController.stream;

  /// Stream controllers for participant events.
  final StreamController<Participant> _participantJoinedController =
      StreamController.broadcast();
  final StreamController<Participant> _participantLeftController =
      StreamController.broadcast();
  final StreamController<Participant> _participantAttributesChangedController =
      StreamController.broadcast();
  final StreamController<Participant> _participantMetadataChangedController =
      StreamController.broadcast();

  final StreamController<List<Participant>> _activeSpeakersController =
      StreamController.broadcast();

  Stream<Participant> get participantJoinedStream =>
      _participantJoinedController.stream;
  Stream<Participant> get participantLeftStream =>
      _participantLeftController.stream;
  Stream<Participant> get participantAttributesChangedStream =>
      _participantAttributesChangedController.stream;

  /// Emits the server's active-speaker list in the same event-loop turn as the
  /// RTC speaker update (no poll quantization).
  Stream<List<Participant>> get activeSpeakersStream =>
      _activeSpeakersController.stream;

  /// Emits a participant whenever their metadata changes (e.g. the engine
  /// rewrites their `role`).
  Stream<Participant> get participantMetadataChangedStream =>
      _participantMetadataChangedController.stream;

  /// The underlying real-time room (for advanced usage).
  Room? get room => _room;

  /// Local participant.
  LocalParticipant? get localParticipant => _room?.localParticipant;

  /// All remote participants.
  List<RemoteParticipant> get remoteParticipants =>
      _room?.remoteParticipants.values.toList() ?? [];

  /// Connect to the real-time room with automatic retry on timeout.
  Future<void> connect(String url, String token) async {
    if (_disposed) return;
    connectionState.value = UTDConnectionState.connecting;

    // A still-connected previous Room MUST be torn down before `_room` is
    // reassigned: overwriting the reference while it is live orphans an
    // RTC session that stays subscribed to every audio track (room audio
    // keeps playing after exit) with nothing left able to disconnect it
    // (e.g. the admin token re-issue + reconnect fallback).
    await _releaseCurrentRoom();

    for (var attempt = 0;
        attempt <= UTDConstants.maxConnectRetries;
        attempt++) {
      if (_disposed) return;
      try {
        _room = Room(
          roomOptions: const RoomOptions(
            adaptiveStream: UTDConstants.defaultAdaptiveStream,
            dynacast: UTDConstants.defaultDynacast,
          ),
        );

        // Wire events BEFORE connecting.
        _setupListeners();

        // Bound the SDK's signal phases (WS dial, join response) below the
        // outer backstop so failures surface fast and precisely from inside
        // the SDK; the media phases keep the SDK's 10s defaults.
        await _room!
            .connect(
              url,
              token,
              connectOptions: const ConnectOptions(
                timeouts: Timeouts(
                  connection: UTDConstants.rtcSignalTimeout,
                  debounce: Duration(milliseconds: 100),
                  publish: Duration(seconds: 10),
                  subscribe: Duration(seconds: 10),
                  peerConnection: Duration(seconds: 10),
                  iceRestart: Duration(seconds: 10),
                ),
              ),
            )
            .timeout(UTDConstants.connectTimeout);
        if (_disposed) {
          // disconnect()/dispose() ran while the connect was in flight (fast
          // exit during join) — tear the fresh session down, don't keep it.
          await _releaseCurrentRoom();
          return;
        }
        connectionState.value = UTDConnectionState.connected;

        debugPrint('🏠 [UTDRoomManager] ✅ Connected to room');
        debugPrint('🏠 [UTDRoomManager] Room name: ${_room?.name}');
        debugPrint('🏠 [UTDRoomManager] Room metadata: ${_room?.metadata}');
        debugPrint(
            '🏠 [UTDRoomManager] Remote participants: ${_room?.remoteParticipants.length}');
        // Diagnostic: if canPublishData is false, EVERY client-originated data
        // broadcast (cinema video, shared music, gifts) is silently dropped by
        // the server — only backend-originated room state (mode/seats) flows.
        final perms = _room?.localParticipant?.permissions;
        debugPrint(
            '🏠 [UTDRoomManager] Permissions: canPublish=${perms?.canPublish} '
            'canPublishData=${perms?.canPublishData} canSubscribe=${perms?.canSubscribe}');

        return;
      } catch (e) {
        log('[UTDRoomManager] Connection error (attempt ${attempt + 1}/${UTDConstants.maxConnectRetries + 1}): $e');

        // The timed-out attempt may still complete its handshake in the
        // background (timeout() does not abort the underlying connect) —
        // tear it down before the next attempt or it leaks a live session.
        // BOUNDED: on a half-dead link the SDK's disconnect can block ~10s
        // waiting for a leave ack that never comes, silently eating the join
        // budget between attempts. The next attempt builds an independent
        // Room and the server's participant_left webhook backstops an unclean
        // close (same rationale as the 2s caps in UTDRoomController.connect);
        // the teardown keeps running in the background.
        await _releaseCurrentRoom().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            debugPrint('[UTDRoomManager] inter-attempt teardown still running '
                'after 2s — proceeding to next attempt');
          },
        );
        if (_disposed) return;

        if (attempt < UTDConstants.maxConnectRetries) {
          await Future.delayed(UTDConstants.retryDelay);
        } else {
          connectionState.value = UTDConnectionState.error;
          rethrow;
        }
      }
    }
  }

  bool _disposed = false;

  /// Disconnect from the room and clean up.
  Future<void> disconnect() async {
    await _releaseCurrentRoom();

    if (!_disposed) {
      connectionState.value = UTDConnectionState.disconnected;
    }
  }

  /// Detaches the current [_room]/[_listener] (if any) and fully tears the
  /// Room down. Single teardown path for disconnect(), pre-connect cleanup
  /// and failed/aborted connect attempts.
  Future<void> _releaseCurrentRoom() async {
    _listener?.dispose();
    _listener = null;
    final room = _room;
    _room = null;
    if (room != null) await _teardownRoom(room);
  }

  /// Disconnects + disposes [room]. Disposing matters: without it the Room's
  /// engine/participant listeners keep firing after we drop our reference,
  /// and late events touch already-disposed Participant objects
  /// ("Participant disposed" surfacing in the zone handler).
  Future<void> _teardownRoom(Room room) async {
    try {
      await room.disconnect();
    } catch (e) {
      debugPrint('[UTDRoomManager] room.disconnect failed (non-fatal): $e');
    }
    try {
      await room.dispose();
    } catch (e) {
      debugPrint('[UTDRoomManager] room.dispose failed (non-fatal): $e');
    }
  }

  /// Send data to all or specific participants.
  /// Sends an in-room command to all or specific participants.
  Future<void> sendData(
    Map<String, dynamic> data, {
    List<String>? destinationIdentities,
  }) async {
    if (_room == null || localParticipant == null) return;

    // Diagnostic only. `permissions.canPublishData` is a local cache that the
    // SDK hydrates from the server (JoinResponse / participant_update); it can
    // read false transiently before hydration. The packet is still sent below,
    // and the engine now grants canPublishData as an invariant for every
    // participant, so a stale false here does not mean the packet is dropped.
    if (!localParticipant!.permissions.canPublishData) {
      debugPrint('ℹ️ [UTDRoomManager] local canPublishData cache is false '
          '(may be pre-hydration); sending data packet anyway.');
    }

    final jsonString = jsonEncode(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));

    try {
      await localParticipant!
          .publishData(
            bytes,
            reliable: UTDConstants.reliableDataChannel,
            destinationIdentities: destinationIdentities,
          )
          .timeout(UTDConstants.publishDataTimeout);
    } catch (e) {
      debugPrint('⚠️ [UTDRoomManager] sendData failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Private — RTC event wiring
  // ---------------------------------------------------------------------------

  void _setupListeners() {
    _listener = _room!.createListener();

    _listener!
      ..on<ParticipantConnectedEvent>(_onParticipantConnected)
      ..on<ParticipantDisconnectedEvent>(_onParticipantDisconnected)
      ..on<ParticipantAttributesChanged>(_onParticipantAttributesChanged)
      ..on<ParticipantMetadataUpdatedEvent>(_onParticipantMetadataChanged)
      ..on<ActiveSpeakersChangedEvent>(_onActiveSpeakersChanged)
      ..on<TrackSubscribedEvent>(_onTrackSubscribed)
      ..on<TrackUnsubscribedEvent>(_onTrackUnsubscribed)
      ..on<DataReceivedEvent>(_onDataReceived)
      ..on<RoomDisconnectedEvent>(_onRoomDisconnected)
      ..on<RoomReconnectingEvent>(_onRoomReconnecting)
      ..on<RoomReconnectedEvent>(_onRoomReconnected)
      ..on<RoomMetadataChangedEvent>(_onRoomMetadataChanged);
  }

  void _onParticipantConnected(ParticipantConnectedEvent event) {
    if (_disposed || _participantJoinedController.isClosed) return;
    _participantJoinedController.add(event.participant);
  }

  void _onParticipantDisconnected(ParticipantDisconnectedEvent event) {
    if (_disposed || _participantLeftController.isClosed) return;
    _participantLeftController.add(event.participant);
  }

  void _onParticipantAttributesChanged(ParticipantAttributesChanged event) {
    if (_disposed || _participantAttributesChangedController.isClosed) return;
    _participantAttributesChangedController.add(event.participant);
  }

  void _onParticipantMetadataChanged(ParticipantMetadataUpdatedEvent event) {
    if (_disposed || _participantMetadataChangedController.isClosed) return;
    _participantMetadataChangedController.add(event.participant);
  }

  void _onActiveSpeakersChanged(ActiveSpeakersChangedEvent event) {
    if (_disposed || _activeSpeakersController.isClosed) return;
    _activeSpeakersController.add(event.speakers);
  }

  void _onTrackSubscribed(TrackSubscribedEvent event) {
  }

  void _onTrackUnsubscribed(TrackUnsubscribedEvent event) {
  }

  void _onDataReceived(DataReceivedEvent event) {
    if (_disposed || _dataController.isClosed) return;
    try {
      final jsonString = utf8.decode(event.data);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      // debugPrint runs in RELEASE builds too — stringifying every payload on
      // the UI isolate janks frames during message bursts (worst right after
      // join, while the seat grid first paints). Log type/size only, and only
      // in debug.
      if (kDebugMode) {
        debugPrint('📨 [UTDRoomManager] Data received: '
            'type=${data['type']} (${event.data.length}B)');
      }

      _dataController.add(data);
    } catch (e) {
      debugPrint('[UTDRoomManager] Failed to parse data message: $e');
    }
  }

  /// Called when room metadata changes (backend updates _seats, etc.)
  void _onRoomMetadataChanged(RoomMetadataChangedEvent event) {
    if (_disposed || _roomMetadataController.isClosed) return;
    final metadata = event.metadata;
    if (metadata != null && metadata.isNotEmpty) {
      debugPrint('🏠 [UTDRoomManager] Room metadata changed: ${metadata.length} chars');
      _roomMetadataController.add(metadata);
    }
  }

  void _onRoomDisconnected(RoomDisconnectedEvent event) {
    if (_disposed) return;
    lastDisconnectReason = event.reason;
    connectionState.value = UTDConnectionState.disconnected;
    if (event.reason == DisconnectReason.participantRemoved) {
      onParticipantRemoved?.call();
    }
  }

  void _onRoomReconnecting(RoomReconnectingEvent event) {
    if (_disposed) return;
    connectionState.value = UTDConnectionState.reconnecting;
  }

  void _onRoomReconnected(RoomReconnectedEvent event) {
    if (_disposed) return;
    connectionState.value = UTDConnectionState.connected;
  }

  /// Dispose all resources.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _listener?.dispose();
    _dataController.close();
    _roomMetadataController.close();
    _participantJoinedController.close();
    _participantLeftController.close();
    _participantAttributesChangedController.close();
    _participantMetadataChangedController.close();
    _activeSpeakersController.close();
    connectionState.dispose();
    // Normally already torn down via disconnect(); this covers dispose()
    // without a prior leave (or mid-connect) so a still-live Room can't
    // outlive us and keep playing room audio. Fire-and-forget — dispose()
    // is synchronous.
    final room = _room;
    _room = null;
    if (room != null) unawaited(_teardownRoom(room));
  }
}
