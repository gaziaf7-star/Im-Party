import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/room_manager.dart';
import '../models/video_quality.dart';

/// Controls mic, camera, and speaker state.
/// Mic/camera/speaker controls.
class UTDMediaController {
  final UTDRoomManager _roomManager;

  UTDMediaController(this._roomManager);

  /// Builds a fresh LiveKit video-effects processor for each camera capture, or
  /// null for none (default). Attached to the host self-preview track in
  /// [startPreview] and re-attached by [ensureVideoProcessorAttached] whenever
  /// LiveKit drops it (camera flip / unmute — see that method). preview→[goLive]
  /// publishes the same track object, so it carries the processor. The
  /// SDK-internal camera paths (reconnect, autoHostCamera, guest go-live) are
  /// covered by [UTDRoomManager.videoProcessorFactory] instead. Set via
  /// [UTDRoomController.setVideoProcessorFactory].
  TrackProcessor<VideoProcessorOptions> Function(bool entitled)?
      videoProcessorFactory;

  /// Listener for LiveKit track mute/unmute events. Keeps [isMicEnabled] in
  /// sync with server/host-initiated mutes — not just local toggles.
  EventsListener<RoomEvent>? _listener;

  /// Whether the local mic is enabled.
  final ValueNotifier<bool> isMicEnabled = ValueNotifier(false);

  /// Whether the local camera is enabled.
  final ValueNotifier<bool> isCameraEnabled = ValueNotifier(false);

  /// Whether the speaker is on.
  final ValueNotifier<bool> isSpeakerOn = ValueNotifier(true);

  /// Whether all remote audio is muted (speaker button state).
  final ValueNotifier<bool> isAllRemoteAudioMuted = ValueNotifier(false);

  /// Whether the LOCAL participant may publish (mic/camera). Driven by
  /// [ParticipantPermissionsUpdatedEvent]. On demotion the engine revokes
  /// publish and stops the user's tracks — gate the mic/camera UI on this.
  final ValueNotifier<bool> canPublish = ValueNotifier(true);

  /// Current front/back position of the local camera. Kept authoritative across
  /// [switchCamera] and [startPreview] so flips are deterministic (the bare
  /// `restartTrack()` reused the same position and never actually flipped).
  final ValueNotifier<CameraPosition> cameraPosition =
      ValueNotifier(CameraPosition.front);

  /// Whether a LOCAL, UNPUBLISHED camera preview is active (host "Go Live"
  /// screen). The preview track is rendered locally only — no remote sees it.
  final ValueNotifier<bool> isPreviewing = ValueNotifier(false);

  /// Wall-clock instant the host first went live ([goLive]), or null before
  /// then. Set once and never reset for the session (camera toggles / reconnect
  /// don't restart it), so the header's host-only live-duration timer keeps
  /// counting for the whole broadcast. Only the host ever calls [goLive], so a
  /// non-null value here means "this device is the live host".
  final ValueNotifier<DateTime?> liveStartedAt = ValueNotifier(null);

  /// The local, unpublished camera preview track, or null. Reused by [goLive]
  /// so publishing continues the same camera session with no flicker.
  LocalVideoTrack? _previewTrack;

  /// The local, unpublished camera preview track (host "Go Live" screen).
  LocalVideoTrack? get previewTrack => _previewTrack;

  /// Toggle microphone on/off.
  /// Turns the microphone on.
  Future<void> toggleMicrophone() async {
    final lp = _roomManager.localParticipant;
    if (lp == null) return;

    final newState = !isMicEnabled.value;
    await lp.setMicrophoneEnabled(newState);
    isMicEnabled.value = newState;
  }

  /// Set microphone to a specific state.
  Future<void> setMicrophoneEnabled(bool enabled) async {
    final lp = _roomManager.localParticipant;
    if (lp == null) {
      debugPrint('[UTDMediaController] setMicrophoneEnabled($enabled) — localParticipant is NULL, cannot set mic');
      return;
    }

    debugPrint('[UTDMediaController] setMicrophoneEnabled($enabled) — localParticipant found, setting mic...');
    try {
      await lp.setMicrophoneEnabled(enabled, audioCaptureOptions: _captureOptions);
      isMicEnabled.value = enabled;
      debugPrint('[UTDMediaController] setMicrophoneEnabled SUCCESS — mic is now $enabled');
    } catch (e) {
      debugPrint('[UTDMediaController] setMicrophoneEnabled FAILED: $e');
    }
  }

  /// Whether the mic is currently captured in MUSIC mode.
  final ValueNotifier<bool> isMusicMode = ValueNotifier<bool>(false);

  /// Republish the microphone with the voice-processing chain switched off, so
  /// music playing out of the loudspeaker is actually heard by everyone else.
  ///
  /// This app plays room music with a LOCAL audio player. LiveKit has no
  /// `startAudioMixing` the way Agora and Zego do, so the only path from that
  /// player to the room is back in through the microphone — and WebRTC's
  /// echo canceller exists precisely to remove loudspeaker output from the mic.
  /// With the default capture options the host hears their music and every
  /// viewer hears silence, which is exactly the reported behaviour.
  ///
  /// Turning off echo cancellation, noise suppression, AGC and voice isolation
  /// lets the music through. The trade is real and unavoidable: while music is
  /// playing the host's own voice is unprocessed, and a host on loudspeaker can
  /// echo. That is why it is a MODE, entered when playback starts and left when
  /// it stops, rather than the permanent capture setting.
  Future<void> setMusicMode(bool enabled) async {
    if (isMusicMode.value == enabled) return;

    final lp = _roomManager.localParticipant;
    if (lp == null) {
      debugPrint('[UTDMediaController] setMusicMode($enabled) — no localParticipant');
      return;
    }

    isMusicMode.value = enabled;

    // Nothing to republish if the mic is off; the flag alone is enough, and the
    // next unmute picks the right options up.
    if (!isMicEnabled.value) return;

    try {
      // Stop and recapture: capture options are fixed at track creation, so an
      // already-published track cannot be reconfigured in place.
      await lp.setMicrophoneEnabled(false);
      await lp.setMicrophoneEnabled(true, audioCaptureOptions: _captureOptions);
      debugPrint('[UTDMediaController] setMusicMode($enabled) — mic republished');
    } catch (e) {
      debugPrint('[UTDMediaController] setMusicMode FAILED: $e');
    }
  }

  /// Capture options for the current mode.
  AudioCaptureOptions get _captureOptions => isMusicMode.value
      ? const AudioCaptureOptions(
          echoCancellation: false,
          noiseSuppression: false,
          autoGainControl: false,
          voiceIsolation: false,
          typingNoiseDetection: false,
        )
      : const AudioCaptureOptions();

  /// Subscribe to LiveKit mute/unmute events for the local mic.
  ///
  /// A host/admin server-side mute (UTD API `POST /seats/{i}/mute`) mutes the
  /// local published track via LiveKit without going through [toggleMicrophone]
  /// or [setMicrophoneEnabled], so [isMicEnabled] would otherwise go stale and
  /// the controls-bar mic icon would keep showing the old state. Listening to
  /// [TrackMutedEvent]/[TrackUnmutedEvent] keeps [isMicEnabled] authoritative.
  ///
  /// Call after the room is connected (idempotent — safe to call again).
  void startListening() {
    final room = _roomManager.room;
    if (room == null) {
      debugPrint('[UTDMediaController] startListening — room is null, skipping');
      return;
    }
    // Seed the initial publish permission from the local participant.
    final lp = room.localParticipant;
    if (lp != null) {
      canPublish.value = lp.permissions.canPublish;
      // Seed the mic/camera button state from the participant's ACTUAL track
      // state so the controls bar is honest the moment the room opens, before
      // any mute/unmute event fires. The event listeners below + the 300ms poll
      // keep them in sync afterwards.
      isMicEnabled.value = lp.isMicrophoneEnabled();
      isCameraEnabled.value = lp.isCameraEnabled();
    }

    _listener?.dispose();
    _listener = room.createListener()
      ..on<TrackMutedEvent>((e) {
        _syncLocalMic(e.participant, e.publication, micOn: false);
        _syncLocalCamera(e.participant, e.publication, cameraOn: false);
      })
      ..on<TrackUnmutedEvent>((e) {
        _syncLocalMic(e.participant, e.publication, micOn: true);
        _syncLocalCamera(e.participant, e.publication, cameraOn: true);
        _reattachProcessorOnCameraUnmute(e.participant, e.publication);
      })
      ..on<TrackSubscribedEvent>(_enforceRemoteMuteOnNewTrack)
      ..on<ParticipantPermissionsUpdatedEvent>(_syncCanPublish)
      ..on<RoomReconnectedEvent>(_onRoomReconnected);
  }

  /// After a reconnect, re-assert local publish state: if the camera/mic were on
  /// before the blip but the track did not survive, re-publish so the host/guest
  /// doesn't silently go dark/quiet. Idempotent — no-op when already published.
  Future<void> _onRoomReconnected(RoomReconnectedEvent event) async {
    if (_disposed) return;
    final lp = _roomManager.localParticipant;
    if (lp == null) return;
    try {
      if (isCameraEnabled.value && !lp.isCameraEnabled()) {
        await lp.setCameraEnabled(true);
      }
      if (isMicEnabled.value && !lp.isMicrophoneEnabled()) {
        await lp.setMicrophoneEnabled(true);
      }
      // A reconnect can resurrect the camera via unmute/restart paths that
      // drop the effects processor — heal it here too (idempotent).
      await ensureVideoProcessorAttached();
    } catch (e) {
      debugPrint('[UTDMediaController] reconnect re-publish failed: $e');
    }
  }

  /// Re-applies "mute all remote audio" to tracks that are subscribed AFTER the
  /// mute-all toggle. [muteAllRemoteAudio] only loops over participants present
  /// at call time, so a late joiner (or someone who publishes their mic later)
  /// would otherwise play out loud while the UI still shows "sound off". This
  /// keeps the actual track state in sync with [isAllRemoteAudioMuted].
  void _enforceRemoteMuteOnNewTrack(TrackSubscribedEvent event) {
    if (_disposed) return;
    if (!isAllRemoteAudioMuted.value) return;
    if (event.publication.source != TrackSource.microphone) return;
    final localId = _roomManager.localParticipant?.identity;
    if (event.participant.identity == localId) return;
    event.publication.disable();
  }

  /// Updates [canPublish] from a permissions event, but only for the LOCAL
  /// participant. On a demotion (publish revoked) the engine stops the user's
  /// tracks; reflect that locally so the mic icon doesn't go stale.
  void _syncCanPublish(ParticipantPermissionsUpdatedEvent event) {
    if (_disposed) return;
    final localId = _roomManager.localParticipant?.identity;
    if (localId == null || event.participant.identity != localId) return;
    final allowed = event.permissions.canPublish;
    if (canPublish.value != allowed) {
      debugPrint('[UTDMediaController] local canPublish=$allowed via '
          'ParticipantPermissionsUpdatedEvent');
      canPublish.value = allowed;
    }
    if (!allowed && isMicEnabled.value) {
      isMicEnabled.value = false;
    }
    if (!allowed && isCameraEnabled.value) {
      isCameraEnabled.value = false;
    }
  }

  /// Updates [isMicEnabled] from a track mute/unmute event, but only for the
  /// LOCAL participant's microphone track (ignores remote participants, the
  /// camera, and screen-share tracks).
  void _syncLocalMic(
    Participant participant,
    TrackPublication publication, {
    required bool micOn,
  }) {
    if (_disposed) return;
    if (publication.source != TrackSource.microphone) return;
    final localId = _roomManager.localParticipant?.identity;
    if (localId == null || participant.identity != localId) return;
    if (isMicEnabled.value != micOn) {
      debugPrint('[UTDMediaController] local mic ${micOn ? "unmuted" : "muted"} '
          'via LiveKit event — syncing isMicEnabled=$micOn');
      isMicEnabled.value = micOn;
    }
  }

  /// Updates [isCameraEnabled] from a track mute/unmute event, but only for the
  /// LOCAL participant's CAMERA track. This keeps the camera button honest when
  /// the host force-mutes a guest's camera server-side (a [TrackMutedEvent] that
  /// never goes through [toggleCamera]/[setCameraEnabled]).
  void _syncLocalCamera(
    Participant participant,
    TrackPublication publication, {
    required bool cameraOn,
  }) {
    if (_disposed) return;
    if (publication.source != TrackSource.camera) return;
    final localId = _roomManager.localParticipant?.identity;
    if (localId == null || participant.identity != localId) return;
    if (isCameraEnabled.value != cameraOn) {
      debugPrint(
          '[UTDMediaController] local camera ${cameraOn ? "on" : "off"} '
          'via LiveKit event — syncing isCameraEnabled=$cameraOn');
      isCameraEnabled.value = cameraOn;
    }
  }

  /// Stop listening to track mute/unmute events.
  void stopListening() {
    _listener?.dispose();
    _listener = null;
  }

  /// Ensures the OS camera permission is granted before any camera capture.
  /// `setCameraEnabled`/`createCameraTrack` throw without it (and without the
  /// manifest/Info.plist entry in the host app). Returns true when granted.
  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final result = await Permission.camera.request();
    return result.isGranted;
  }

  /// Toggle camera on/off.
  Future<void> toggleCamera() async {
    final lp = _roomManager.localParticipant;
    if (lp == null) return;

    final newState = !isCameraEnabled.value;
    if (newState && !await _ensureCameraPermission()) return;
    await lp.setCameraEnabled(newState);
    isCameraEnabled.value = newState;
  }

  /// Set camera to a specific state.
  Future<void> setCameraEnabled(bool enabled) async {
    final lp = _roomManager.localParticipant;
    if (lp == null) return;

    if (enabled && !await _ensureCameraPermission()) return;
    await lp.setCameraEnabled(enabled);
    isCameraEnabled.value = enabled;
  }

  /// The ACTIVE local camera track — the published camera when live, otherwise
  /// the unpublished preview (host "Go Live" screen), or null when neither.
  LocalVideoTrack? get _activeCameraTrack {
    final lp = _roomManager.localParticipant;
    final published = lp?.videoTrackPublications
        .where((pub) => pub.source == TrackSource.camera)
        .map((pub) => pub.track)
        .whereType<LocalVideoTrack>()
        .firstOrNull;
    return published ?? _previewTrack;
  }

  /// Switch between front and back camera.
  ///
  /// Uses [setCameraPosition] with the explicitly flipped position. The old
  /// implementation called a bare `restartTrack()`, which reuses the SAME
  /// `cameraPosition` in the track's current options and therefore never
  /// actually flipped the camera.
  ///
  /// Flips the published camera when live, otherwise the unpublished preview
  /// track (host "Go Live" screen).
  Future<void> switchCamera() async {
    final target = _activeCameraTrack;
    if (target == null) return;

    final next = cameraPosition.value.switched();
    try {
      if (!target.isPublished) {
        // Unpublished preview (host "Go Live" screen): setCameraPosition runs
        // restartTrack, which THROWS when the track has no RTP sender — the
        // flip silently failed here. Switch the native capturer in place
        // instead: same track object, renderer and the attached video-effects
        // processor keep working.
        await rtc.Helper.switchCamera(target.mediaStreamTrack);
        cameraPosition.value = next;
        return;
      }
      await target.setCameraPosition(next);
      cameraPosition.value = next;
      // setCameraPosition runs restartTrack, which drops the processor (see
      // ensureVideoProcessorAttached) — put beauty/filters back on the flip.
      await ensureVideoProcessorAttached();
    } catch (e) {
      debugPrint('[UTDMediaController] switchCamera failed: $e');
    }
  }

  /// Re-attaches the video-effects processor if the active camera track lost it.
  ///
  /// livekit_client 2.8.0's `restartTrack()` calls `stop()` first, and `stop()`
  /// now runs `stopProcessor()` — which destroys AND nulls `_processor` — so
  /// restartTrack's later `final processor = _processor;` capture is always null
  /// and the processor is never re-attached. Every camera flip
  /// ([switchCamera] → `setCameraPosition`) and camera re-enable
  /// (unmute → `restartTrack`) therefore silently kills beauty/filters until the
  /// next capture. This guard re-attaches a processor from
  /// [videoProcessorFactory]; the app's factory returns its session-scoped
  /// instance, which re-applies the user's current effect state (filter,
  /// smoothing, whitening) to the new native session.
  ///
  /// Idempotent — no-op when there is no factory, no camera track, or the track
  /// still has its processor.
  Future<void> ensureVideoProcessorAttached() async {
    final factory = videoProcessorFactory;
    if (factory == null) return;
    final track = _activeCameraTrack;
    if (track == null || track.processor != null) return;
    try {
      await track.setProcessor(factory.call(_roomManager.videoEffectsEntitled));
      debugPrint('[UTDMediaController] video processor re-attached after '
          'track restart (sid=${track.sid})');
    } catch (e) {
      debugPrint('[UTDMediaController] processor re-attach failed: $e');
    }
  }

  /// [ensureVideoProcessorAttached] on every LOCAL camera unmute. Camera
  /// re-enable goes `unmute → restartTrack`, which drops the processor (see
  /// above) — this catches ALL unmute paths (toggle, setCameraEnabled,
  /// reconnect, server-side) regardless of which code initiated them.
  void _reattachProcessorOnCameraUnmute(
    Participant participant,
    TrackPublication publication,
  ) {
    if (_disposed) return;
    if (publication.source != TrackSource.camera) return;
    final localId = _roomManager.localParticipant?.identity;
    if (localId == null || participant.identity != localId) return;
    ensureVideoProcessorAttached();
  }

  /// Attaches (or detaches, when [processor] is null) a video-effects processor
  /// to the ACTIVE local camera track at runtime — the published camera track if
  /// live, otherwise the unpublished preview. Use to toggle beauty on/off
  /// mid-live without re-capturing.
  ///
  /// To turn effects OFF without re-capturing, prefer the processor's own
  /// `setEnabled(false)` (a cheap native call that keeps the processor attached);
  /// passing `null` here fully detaches the processor instead. For intensity
  /// tweaks, use the processor's setters (e.g. `setSmoothing`) rather than
  /// re-attaching.
  ///
  /// No-op when there is no local camera track yet.
  Future<void> setVideoProcessor(
    TrackProcessor<VideoProcessorOptions>? processor,
  ) async {
    final target = _activeCameraTrack;
    if (target == null) return;
    try {
      if (processor == null) {
        // `setProcessor(null)` is a no-op in livekit_client; stopProcessor is the
        // real detach path (marked @internal but functional cross-package).
        // ignore: invalid_use_of_internal_member
        await target.stopProcessor();
      } else {
        await target.setProcessor(processor);
      }
    } catch (e) {
      debugPrint('[UTDMediaController] setVideoProcessor failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Preview → Go Live (host)
  // ---------------------------------------------------------------------------

  /// Creates a LOCAL, UNPUBLISHED camera preview for the host's "Go Live"
  /// screen. No remote participant sees this track until [goLive] publishes it.
  /// Idempotent — returns the existing preview track if one is already running.
  Future<LocalVideoTrack?> startPreview({
    CameraPosition position = CameraPosition.front,
  }) async {
    if (_previewTrack != null) return _previewTrack;
    if (!await _ensureCameraPermission()) {
      debugPrint('[UTDMediaController] startPreview — camera permission denied');
      return null;
    }
    try {
      cameraPosition.value = position;
      _previewTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          cameraPosition: position,
          // Capture at the configured publish quality so preview→goLive keeps
          // the same camera session (no re-capture) at the right resolution.
          params: _roomManager.videoQuality.parameters,
          // Beauty/filters on the host self-preview. preview→goLive publishes
          // this same track object, so the processor carries over; flips and
          // unmutes drop it (livekit restartTrack bug) and are healed by
          // ensureVideoProcessorAttached. null = none. The factory receives the
          // trusted entitlement so unpaid sessions build a passthrough processor.
          processor: videoProcessorFactory?.call(_roomManager.videoEffectsEntitled),
        ),
      );
      isPreviewing.value = true;
      return _previewTrack;
    } catch (e) {
      debugPrint('[UTDMediaController] startPreview failed: $e');
      return null;
    }
  }

  /// Stops and releases the preview track WITHOUT publishing it (host backs out
  /// of "Go Live"). Safe to call when no preview is active.
  Future<void> stopPreview() async {
    final t = _previewTrack;
    _previewTrack = null;
    isPreviewing.value = false;
    if (t != null) {
      try {
        await t.stop();
      } catch (e) {
        debugPrint('[UTDMediaController] stopPreview failed: $e');
      }
    }
  }

  /// Host "Go Live": publishes the camera — reusing the [previewTrack] when one
  /// exists so the same camera session continues with no flicker — and, by
  /// default, enables the mic. After this the host's tile is live for everyone.
  Future<void> goLive({bool withMic = true}) async {
    final lp = _roomManager.localParticipant;
    if (lp == null) {
      debugPrint('[UTDMediaController] goLive — localParticipant is null');
      return;
    }
    try {
      final preview = _previewTrack;
      if (preview != null) {
        await lp.publishVideoTrack(preview);
        _previewTrack = null;
        isPreviewing.value = false;
      } else {
        await lp.setCameraEnabled(true);
      }
      isCameraEnabled.value = true;
      // Anchor the live-duration timer on the first successful go-live only.
      liveStartedAt.value ??= DateTime.now();
      if (withMic) {
        await lp.setMicrophoneEnabled(true);
        isMicEnabled.value = true;
      }
    } catch (e) {
      debugPrint('[UTDMediaController] goLive failed: $e');
    }
  }

  /// Set speaker on or off.
  /// Routes audio to the loudspeaker.
  ///
  /// OFF must SILENCE the room, not merely reroute: setSpeakerphoneOn(false)
  /// alone moves playback to the earpiece and the room stays audible (owner
  /// report 2026-06-11). Disable every remote audio track too (current AND
  /// future — the room manager re-applies the flag on new subscriptions).
  Future<void> setSpeakerOn(bool on) async {
    await Hardware.instance.setSpeakerphoneOn(on);
    _roomManager.setAllRemoteAudioEnabled(on);
    isSpeakerOn.value = on;
  }

  /// Route audio to a connected Bluetooth headset when one is available,
  /// otherwise to the loudspeaker. Uses WebRTC's native BT-preferring routing
  /// (not the plain speakerphone toggle, which ignores Bluetooth). This is the
  /// correct default for a public audio room and the fix for "audio plays from
  /// the phone speaker instead of Bluetooth". Re-call it on device changes.
  Future<void> setSpeakerPreferBluetooth() async {
    await rtc.Helper.setSpeakerphoneOnButPreferBluetooth();
    isSpeakerOn.value = true;
  }

  /// Toggle speaker.
  Future<void> toggleSpeaker() async {
    await setSpeakerOn(!isSpeakerOn.value);
  }

  /// Mute or unmute all remote audio playback.
  /// Mutes or unmutes all remote-stream audio playback.
  void muteAllRemoteAudio(bool mute) {
    for (final participant in _roomManager.remoteParticipants) {
      for (final pub in participant.audioTrackPublications) {
        mute ? pub.disable() : pub.enable();
      }
    }
    isAllRemoteAudioMuted.value = mute;
  }

  bool _disposed = false;

  /// Dispose resources.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _listener?.dispose();
    _listener = null;
    // Release an unpublished preview track if "Go Live" was never tapped.
    _previewTrack?.stop();
    _previewTrack = null;
    isMicEnabled.dispose();
    isCameraEnabled.dispose();
    isSpeakerOn.dispose();
    isAllRemoteAudioMuted.dispose();
    canPublish.dispose();
    cameraPosition.dispose();
    isPreviewing.dispose();
    liveStartedAt.dispose();
  }
}
