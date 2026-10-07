import 'utd_api_client.dart';

/// REST API client for participant-level, server-authoritative media control.
///
/// Base path: `/api/v1/rooms/:name/participants/:identity/...`
///
/// In a live room the host (and admins) can force a guest's camera or
/// microphone on/off. This goes through the engine — which mutes the track
/// server-side via the LiveKit server API — rather than a cooperative
/// client→client RTM message, so it:
///   - cannot be ignored by a modified client, and
///   - survives the guest reconnecting (a cooperative mute would not).
///
/// The server-side mute fires a `TrackMutedEvent` to every participant, so all
/// clients (including the guest's own UI) converge on the same track state.
///
/// See: Live Room Kit plan § "Host controls guest (server-authoritative)".
class UTDParticipantApi {
  final UTDApiClient _client;

  UTDParticipantApi(this._client);

  // ---------------------------------------------------------------------------
  // Force mute / unmute a participant's track (host/admin only)
  // ---------------------------------------------------------------------------

  /// Forces a participant's [audio] and/or [video] track to [muted].
  ///
  /// [roomId] — LiveKit room name.
  /// [targetIdentity] — the participant whose track is being controlled.
  /// [identity] — the actor performing the action (must be host/admin).
  /// [audio] — when true, apply [muted] to the microphone track.
  /// [video] — when true, apply [muted] to the camera track.
  /// [muted] — true mutes, false unmutes.
  ///
  /// At least one of [audio]/[video] should be true; the engine ignores the
  /// flags that are false. Admin cannot act on the host (engine enforces).
  ///
  /// PUT /api/v1/rooms/:name/participants/:identity/mute
  Future<Map<String, dynamic>> muteParticipant({
    required String roomId,
    required String targetIdentity,
    required String identity,
    bool audio = false,
    bool video = false,
    required bool muted,
  }) {
    return _client.put(
      '/api/v1/rooms/$roomId/participants/$targetIdentity/mute',
      data: {
        'identity': identity,
        'audio': audio,
        'video': video,
        'muted': muted,
      },
    );
  }

  /// Convenience: force a guest's camera on/off.
  Future<Map<String, dynamic>> setCamera({
    required String roomId,
    required String targetIdentity,
    required String identity,
    required bool enabled,
  }) {
    return muteParticipant(
      roomId: roomId,
      targetIdentity: targetIdentity,
      identity: identity,
      video: true,
      muted: !enabled,
    );
  }

  /// Remove a participant from the room entirely (host/admin). The engine
  /// disconnects them via the LiveKit server API — they get the standard
  /// participant-removed teardown on their device.
  ///
  /// DELETE /api/v1/rooms/:name/participants/:identity
  Future<Map<String, dynamic>> kick({
    required String roomId,
    required String targetIdentity,
  }) {
    return _client.delete(
      '/api/v1/rooms/$roomId/participants/$targetIdentity',
    );
  }

  /// Convenience: force a guest's microphone on/off.
  Future<Map<String, dynamic>> setMic({
    required String roomId,
    required String targetIdentity,
    required String identity,
    required bool enabled,
  }) {
    return muteParticipant(
      roomId: roomId,
      targetIdentity: targetIdentity,
      identity: identity,
      audio: true,
      muted: !enabled,
    );
  }
}
