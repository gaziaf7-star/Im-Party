import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'constants.dart';
import 'token_entitlement.dart';
import '../models/video_quality.dart';

/// Connection state for the room.
enum UTDConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Wraps LiveKit [Room] and exposes a simplified API.
/// The kit's central RTC engine + UI handle.
class UTDRoomManager {
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  /// Builds a fresh LiveKit video-effects processor for each camera capture, or
  /// null for none (default). Applied to [RoomOptions.defaultCameraCaptureOptions]
  /// so every SDK-internal camera creation — `setCameraEnabled(true)`, reconnect
  /// re-publish, autoHostCamera, guest go-live — carries the effects. The host
  /// self-preview path is handled separately in [UTDMediaController.startPreview].
  /// Set via [UTDRoomController.setVideoProcessorFactory] BEFORE [connect].
  TrackProcessor<VideoProcessorOptions> Function(bool entitled)?
      videoProcessorFactory;

  /// Trusted Video Effects entitlement decoded from the join token's signed
  /// `videoEffects` claim (set at the top of [connect]). Passed into the factory
  /// so the processor runs effects only when the customer has activated + paid.
  bool videoEffectsEntitled = true;

  /// Video publish quality for local camera tracks (capture resolution +
  /// publish encoding). Baked into [RoomOptions] at Room construction, so it
  /// must be set BEFORE [connect] (via [UTDRoomController.setVideoQuality] /
  /// [UTDLiveRoomConfig.videoQuality]). Default HD (720p).
  UTDVideoQuality videoQuality = UTDVideoQuality.hd;

  /// Notifies UI of connection state changes.
  final ValueNotifier<UTDConnectionState> connectionState =
      ValueNotifier(UTDConnectionState.disconnected);

  /// Remote camera [VideoTrack]s, keyed by participant identity. Populated from
  /// [TrackSubscribedEvent]/[TrackUnsubscribedEvent] filtered to the camera
  /// source (mic / screen-share tracks are ignored here).
  ///
  /// The LOCAL camera track is NOT in this map — there is no "subscribe" to
  /// your own track; resolve it directly via
  /// `localParticipant.getTrackPublicationBySource(TrackSource.camera)?.track`.
  ///
  /// A NEW map instance is assigned on every change so [ValueNotifier] fires
  /// (Map has no value equality).
  final ValueNotifier<Map<String, VideoTrack>> videoTracksNotifier =
      ValueNotifier<Map<String, VideoTrack>>(const {});

  /// The current remote camera [VideoTrack] for [identity], or null when that
  /// participant is not publishing a camera track (or it is not yet subscribed).
  VideoTrack? getRemoteVideoTrack(String identity) =>
      videoTracksNotifier.value[identity];

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

  Stream<Participant> get participantJoinedStream =>
      _participantJoinedController.stream;
  Stream<Participant> get participantLeftStream =>
      _participantLeftController.stream;
  Stream<Participant> get participantAttributesChangedStream =>
      _participantAttributesChangedController.stream;

  /// Emits a participant whenever their metadata changes (e.g. the engine
  /// rewrites their `role`).
  Stream<Participant> get participantMetadataChangedStream =>
      _participantMetadataChangedController.stream;

  /// Stream of the current active-speaker list, emitted by LiveKit the instant
  /// the SFU's audio-level detection flips a participant in/out of "speaking"
  /// (includes the local participant; audio-driven, independent of camera). This
  /// drives the camera-off avatar wave rings without waiting for the 300ms poll.
  final StreamController<List<Participant>> _activeSpeakersController =
      StreamController.broadcast();

  /// Listen for active-speaker changes (loudest first; includes local).
  Stream<List<Participant>> get activeSpeakersStream =>
      _activeSpeakersController.stream;

  /// The underlying LiveKit room (for advanced usage).
  Room? get room => _room;

  /// Local participant.
  LocalParticipant? get localParticipant => _room?.localParticipant;

  /// All remote participants.
  List<RemoteParticipant> get remoteParticipants =>
      _room?.remoteParticipants.values.toList() ?? [];

  /// Connect to a LiveKit room with automatic retry on timeout.
  Future<void> connect(String url, String token) async {
    if (_disposed) return;
    // Resolve the trusted (server-signed) Video Effects entitlement from the token
    // before any camera track is created, so passthrough is enforced on the very
    // first capture when the customer hasn't activated/paid for this platform.
    videoEffectsEntitled = videoEffectsEntitledFromToken(token);
    connectionState.value = UTDConnectionState.connecting;

    // A still-connected previous Room MUST be torn down before `_room` is
    // reassigned: overwriting the reference while it is live orphans a
    // LiveKit session that stays subscribed to every audio/video track (room
    // audio keeps playing after exit) with nothing left able to disconnect
    // it (e.g. the admin token re-issue + reconnect fallback).
    await _releaseCurrentRoom();

    for (var attempt = 0;
        attempt <= UTDConstants.maxConnectRetries;
        attempt++) {
      if (_disposed) return;
      try {
        _room = Room(
          // NOT const: defaultCameraCaptureOptions.processor is a runtime value
          // (the video-effects factory). Keeping const here would forbid it.
          roomOptions: RoomOptions(
            adaptiveStream: UTDConstants.defaultAdaptiveStream,
            dynacast: UTDConstants.defaultDynacast,
            // Live room: every seat is a camera tile. Default new camera tracks
            // to the front camera at the configured [videoQuality] (HD 720p 16:9
            // unless the app overrides it). NOTE: adaptiveStream/dynacast pause
            // offscreen tiles — every rendered tile (incl. minimized/PIP) must
            // stay laid out or its video goes black.
            defaultCameraCaptureOptions: CameraCaptureOptions(
              cameraPosition: CameraPosition.front,
              params: videoQuality.parameters,
              // Beauty/filters on SDK-internal camera creations (setCameraEnabled,
              // reconnect re-publish, autoHostCamera, guest go-live). null = none.
              // The factory receives the trusted entitlement so the processor is
              // built in passthrough mode when the customer hasn't activated/paid.
              processor: videoProcessorFactory?.call(videoEffectsEntitled),
            ),
            // Publish encoding must FOLLOW the quality tier, not just capture:
            // without it LiveKit derives bitrate from its own table and the
            // developer's chosen tier would only change capture dimensions.
            defaultVideoPublishOptions: VideoPublishOptions(
              videoEncoding: videoQuality.parameters.encoding,
              videoSimulcastLayers: videoQuality.simulcastLayers,
            ),
          ),
        );

        // Wire events BEFORE connecting.
        _setupListeners();

        await _room!.connect(url, token);
        if (_disposed) {
          // disconnect()/dispose() ran while the connect was in flight (fast
          // exit during join) — tear the fresh session down, don't keep it.
          await _releaseCurrentRoom();
          return;
        }
        connectionState.value = UTDConnectionState.connected;

        debugPrint('🏠 [UTDRoomManager] ✅ Connected to LiveKit room');
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

        // The failed attempt may still complete its handshake in the
        // background — tear it down before the next attempt or it leaks a
        // live session.
        await _releaseCurrentRoom();
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
  /// and late events touch already-disposed Participant objects.
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
  ///
  /// [lossy] — best-effort UDP-style delivery for high-frequency ephemeral
  /// signals (tap-hearts pulses): no retransmission, no ordering, never
  /// queues behind reliable traffic. Default false (reliable channel).
  Future<void> sendData(
    Map<String, dynamic> data, {
    List<String>? destinationIdentities,
    bool lossy = false,
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
      await localParticipant!.publishData(
        bytes,
        reliable: lossy ? false : UTDConstants.reliableDataChannel,
        destinationIdentities: destinationIdentities,
      );
    } catch (e) {
      debugPrint('⚠️ [UTDRoomManager] sendData failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Private — LiveKit event wiring
  // ---------------------------------------------------------------------------

  void _setupListeners() {
    _listener = _room!.createListener();

    _listener!
      ..on<ParticipantConnectedEvent>(_onParticipantConnected)
      ..on<ParticipantDisconnectedEvent>(_onParticipantDisconnected)
      ..on<ParticipantAttributesChanged>(_onParticipantAttributesChanged)
      ..on<ParticipantMetadataUpdatedEvent>(_onParticipantMetadataChanged)
      ..on<TrackSubscribedEvent>(_onTrackSubscribed)
      ..on<TrackUnsubscribedEvent>(_onTrackUnsubscribed)
      ..on<DataReceivedEvent>(_onDataReceived)
      ..on<ActiveSpeakersChangedEvent>(_onActiveSpeakersChanged)
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
    if (_disposed) return;
    // Clear any lingering camera tile for the departed participant in case the
    // unsubscribe event did not arrive before the disconnect.
    _dropRemoteVideoTrack(event.participant.identity);
    if (_participantLeftController.isClosed) return;
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

  /// When true, every remote AUDIO track is disabled on subscribe — the
  /// "speaker off" state must silence ALL output (earpiece included), not
  /// just reroute the speakerphone. Maintained by UTDMediaController.
  bool remoteAudioMuted = false;

  /// Enable/disable playback of every currently-subscribed remote audio track.
  void setAllRemoteAudioEnabled(bool enabled) {
    remoteAudioMuted = !enabled;
    final room = _room;
    if (room == null) return;
    for (final participant in room.remoteParticipants.values) {
      for (final pub in participant.audioTrackPublications) {
        final track = pub.track;
        if (track == null) continue;
        try {
          enabled ? track.enable() : track.disable();
        } catch (_) {}
      }
    }
  }

  void _onTrackSubscribed(TrackSubscribedEvent event) {
    if (_disposed) return;
    // Speaker-off must also silence tracks that arrive AFTER the mute.
    if (remoteAudioMuted &&
        event.publication.source == TrackSource.microphone) {
      try {
        event.track.disable();
      } catch (_) {}
    }
    // Only camera video tiles are tracked here. Mic + screen-share are handled
    // elsewhere (audio playback / mute-all) and must not land in the tile map.
    if (event.publication.source != TrackSource.camera) return;
    final track = event.track;
    if (track is! VideoTrack) return;
    final identity = event.participant.identity;
    final next = Map<String, VideoTrack>.from(videoTracksNotifier.value)
      ..[identity] = track;
    videoTracksNotifier.value = next;
    debugPrint('🎥 [UTDRoomManager] camera track subscribed: $identity');
  }

  void _onTrackUnsubscribed(TrackUnsubscribedEvent event) {
    if (_disposed) return;
    if (event.publication.source != TrackSource.camera) return;
    final identity = event.participant.identity;
    if (!videoTracksNotifier.value.containsKey(identity)) return;
    final next = Map<String, VideoTrack>.from(videoTracksNotifier.value)
      ..remove(identity);
    videoTracksNotifier.value = next;
    debugPrint('🎥 [UTDRoomManager] camera track unsubscribed: $identity');
  }

  /// Drops [identity]'s remote camera track from [videoTracksNotifier] if
  /// present. Belt-and-suspenders for the case where a participant disconnects
  /// without a preceding [TrackUnsubscribedEvent].
  void _dropRemoteVideoTrack(String identity) {
    if (!videoTracksNotifier.value.containsKey(identity)) return;
    final next = Map<String, VideoTrack>.from(videoTracksNotifier.value)
      ..remove(identity);
    videoTracksNotifier.value = next;
  }

  void _onDataReceived(DataReceivedEvent event) {
    if (_disposed || _dataController.isClosed) return;
    try {
      final jsonString = utf8.decode(event.data);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      debugPrint('📨 [UTDRoomManager] Data received: $data');

      _dataController.add(data);
    } catch (e) {
      debugPrint('[UTDRoomManager] Failed to parse data message: $e');
    }
  }

  void _onActiveSpeakersChanged(ActiveSpeakersChangedEvent event) {
    if (_disposed || _activeSpeakersController.isClosed) return;
    _activeSpeakersController.add(event.speakers);
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
    videoTracksNotifier.dispose();
    // Defense-in-depth: every reachable exit path calls leave()/disconnect()
    // first (so _room is usually already null here), but if a consumer destroys
    // the controller while still connected, tear down the SFU socket + published
    // tracks rather than leak them. Fire-and-forget — dispose() is synchronous.
    final room = _room;
    _room = null;
    if (room != null) unawaited(_teardownRoom(room));
  }
}
