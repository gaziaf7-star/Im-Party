import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';

import '../core/constants.dart';
import '../core/room_manager.dart';

/// Controls mic, camera, and speaker state.
/// Mic/camera/speaker controls.
class UTDMediaController {
  final UTDRoomManager _roomManager;

  UTDMediaController(this._roomManager);

  /// Listener for RTC track mute/unmute events. Keeps [isMicEnabled] in
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

  /// Monotonic guard for publish operations. Bumped by [cancelPendingPublish]
  /// (room leave) and [dispose]: any mic/camera op that was queued or awaited
  /// across the bump must not apply state afterwards.
  int _opEpoch = 0;

  /// The in-flight mic publish, if any. Room teardown awaits it (bounded by
  /// [UTDConstants.mediaOpTimeout]) so disconnect can't dispose the local audio
  /// track while the SDK is mid-publish — that race is exactly the live
  /// `addTransceiver track-is-null` fatal (publish resolves engine.addTrack,
  /// then reads `track.mediaStreamTrack` AFTER the track was disposed).
  Future<void>? _pendingMicOp;

  /// Whether a publish may be started right now: the controller is live and the
  /// room is genuinely connected. Publishing while connecting/reconnecting/
  /// tearing down is the addTransceiver-on-disposed-track crash window.
  bool get _canStartPublish =>
      !_disposed &&
      _roomManager.connectionState.value == UTDConnectionState.connected;

  /// Invalidate any queued publish and wait for an in-flight one to settle.
  /// MUST be called on room leave BEFORE the room disconnects, so the local
  /// track can't be disposed underneath a publish that already passed the
  /// entry guards (the SDK's addTransceiver would then see a null track).
  Future<void> cancelPendingPublish() async {
    _opEpoch++;
    final pending = _pendingMicOp;
    if (pending != null) {
      try {
        await pending;
      } catch (_) {
        // Already surfaced by the op's own catch; teardown proceeds regardless.
      }
      _pendingMicOp = null;
    }
  }

  /// Toggle microphone on/off.
  /// Turns the microphone on.
  Future<void> toggleMicrophone() => setMicrophoneEnabled(!isMicEnabled.value);

  /// Set microphone to a specific state.
  Future<void> setMicrophoneEnabled(bool enabled) async {
    final lp = _roomManager.localParticipant;
    if (lp == null) {
      debugPrint('[UTDMediaController] setMicrophoneEnabled($enabled) — localParticipant is NULL, cannot set mic');
      return;
    }
    // Publishing (enabled=true) on a room that is not connected hands the SDK a
    // track that teardown/reconnect can dispose mid-publish → the live
    // `addTransceiver track-is-null` fatal. Refuse at the entry instead.
    if (enabled && !_canStartPublish) {
      debugPrint('[UTDMediaController] setMicrophoneEnabled($enabled) refused — '
          'room not connected (state=${_roomManager.connectionState.value})');
      return;
    }

    debugPrint('[UTDMediaController] setMicrophoneEnabled($enabled) — localParticipant found, setting mic...');
    final epoch = _opEpoch;
    Future<void>? op;
    try {
      op = lp
          .setMicrophoneEnabled(enabled, audioCaptureOptions: _captureOptions)
          .timeout(UTDConstants.mediaOpTimeout);
      _pendingMicOp = op;
      await op;
      // The room was left/disposed while the op was in flight: the track is
      // being torn down, so the stale result must not flip the UI state.
      if (_disposed || epoch != _opEpoch) return;
      isMicEnabled.value = enabled;
      debugPrint('[UTDMediaController] setMicrophoneEnabled SUCCESS — mic is now $enabled');
    } catch (e) {
      debugPrint('[UTDMediaController] setMicrophoneEnabled FAILED: $e');
    } finally {
      if (identical(_pendingMicOp, op)) _pendingMicOp = null;
    }
  }

  /// Subscribe to RTC mute/unmute events for the local mic.
  ///
  /// A host/admin server-side mute (UTD API `POST /seats/{i}/mute`) mutes the
  /// local published track via the RTC engine without going through [toggleMicrophone]
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
    if (lp != null) canPublish.value = lp.permissions.canPublish;

    _listener?.dispose();
    _listener = room.createListener()
      ..on<TrackMutedEvent>(
          (e) => _syncLocalMic(e.participant, e.publication, micOn: false))
      ..on<TrackUnmutedEvent>(
          (e) => _syncLocalMic(e.participant, e.publication, micOn: true))
      ..on<TrackSubscribedEvent>(_enforceRemoteMuteOnNewTrack)
      ..on<ParticipantPermissionsUpdatedEvent>(_syncCanPublish);
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
          'via RTC event — syncing isMicEnabled=$micOn');
      isMicEnabled.value = micOn;
    }
  }

  /// Stop listening to track mute/unmute events.
  void stopListening() {
    _listener?.dispose();
    _listener = null;
  }

  /// Toggle camera on/off.
  Future<void> toggleCamera() => setCameraEnabled(!isCameraEnabled.value);

  /// Set camera to a specific state.
  Future<void> setCameraEnabled(bool enabled) async {
    final lp = _roomManager.localParticipant;
    if (lp == null) return;
    // Same publish-on-dead-room guard as the mic (addTransceiver crash class).
    if (enabled && !_canStartPublish) {
      debugPrint('[UTDMediaController] setCameraEnabled($enabled) refused — '
          'room not connected (state=${_roomManager.connectionState.value})');
      return;
    }

    final epoch = _opEpoch;
    try {
      await lp.setCameraEnabled(enabled).timeout(UTDConstants.mediaOpTimeout);
      if (_disposed || epoch != _opEpoch) return;
      isCameraEnabled.value = enabled;
    } catch (e) {
      debugPrint('[UTDMediaController] setCameraEnabled FAILED: $e');
    }
  }

  /// Switch between front and back camera.
  Future<void> switchCamera() async {
    final lp = _roomManager.localParticipant;
    if (lp == null) return;

    final videoTrack = lp.videoTrackPublications
        .where((pub) => pub.track != null)
        .map((pub) => pub.track as LocalVideoTrack)
        .firstOrNull;

    if (videoTrack != null) {
      // Restart with flipped camera position.
      await videoTrack.restartTrack();
    }
  }

  /// Set speaker on or off.
  /// Routes audio to the loudspeaker via the native audio manager.
  Future<void> setSpeakerOn(bool on) async {
    await Hardware.instance.setSpeakerphoneOn(on);
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

  /// THE Bluetooth fix. The RTC engine's native audio management applies
  /// `AndroidAudioConfiguration.communication` during room.connect() with
  /// `forceHandleAudioRouting` UNSET — under MODE_IN_COMMUNICATION native WebRTC
  /// then turns audio routing OFF, so `setSpeakerphoneOnButPreferBluetooth()`
  /// becomes a no-op and audio falls back to the earpiece/phone speaker.
  ///
  /// Re-applying the same communication config but with
  /// `forceHandleAudioRouting: true` tells WebRTC to perform device selection
  /// even in communication mode, so BT routing actually takes effect — for both
  /// playback (listener) AND mic capture (on-seat). MUST be called AFTER
  /// room.connect() and AFTER publishing the local mic track (that is when
  /// the RTC engine (re)applies its own config), and again on device-change/reconnect.
  Future<void> applyBluetoothAudioRouting() async {
    if (!Platform.isAndroid) {
      // iOS: the AVAudioSession allowBluetooth path handles routing.
      await rtc.Helper.setSpeakerphoneOnButPreferBluetooth();
      isSpeakerOn.value = true;
      return;
    }
    try {
      await rtc.Helper.setAndroidAudioConfiguration(
        rtc.AndroidAudioConfiguration(
          manageAudioFocus: true,
          androidAudioMode: rtc.AndroidAudioMode.inCommunication,
          androidAudioFocusMode: rtc.AndroidAudioFocusMode.gain,
          androidAudioStreamType: rtc.AndroidAudioStreamType.voiceCall,
          androidAudioAttributesUsageType:
              rtc.AndroidAudioAttributesUsageType.voiceCommunication,
          androidAudioAttributesContentType:
              rtc.AndroidAudioAttributesContentType.speech,
          forceHandleAudioRouting: true, // ← the actual fix
        ),
      );
      await rtc.Helper.setSpeakerphoneOnButPreferBluetooth();
      isSpeakerOn.value = true;
    } catch (e) {
      debugPrint('[MediaController] applyBluetoothAudioRouting failed: $e');
    }
  }

  /// Toggle speaker.
  Future<void> toggleSpeaker() async {
    await setSpeakerOn(!isSpeakerOn.value);
  }

  /// Mute or unmute all remote audio playback.
  /// Mutes or unmutes every remote audio stream at once.
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
    // Invalidate any queued/in-flight publish so it can neither start nor
    // apply state against the dead controller.
    _opEpoch++;
    _listener?.dispose();
    _listener = null;
    isMicEnabled.dispose();
    isCameraEnabled.dispose();
    isSpeakerOn.dispose();
    isAllRemoteAudioMuted.dispose();
    canPublish.dispose();
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
}
