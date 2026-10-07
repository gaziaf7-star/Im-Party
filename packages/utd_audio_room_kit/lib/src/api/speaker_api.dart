import 'utd_api_client.dart';

/// REST API client for speaker request & invitation endpoints.
///
/// Base path: `/api/v1/rooms/:name/speakers/...`
///
/// See: UTD Stream Engine — UIKit Developer Guide § Speaker Requests & Invitations
class UTDSpeakerApi {
  final UTDApiClient _client;

  UTDSpeakerApi(this._client);

  // ===========================================================================
  // Speaker Requests (used when seat_mode == "request")
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Request to Speak
  // ---------------------------------------------------------------------------

  /// Submits a request to speak. Only works when room `seat_mode` is "request".
  /// Returns 409 if user already has a pending request or is already seated.
  /// Backend sends `_speaker_request` data message to all host/admin participants.
  ///
  /// POST /api/v1/rooms/:name/speakers/request
  ///
  /// Returns: `{ "request_id": 42 }`
  ///
  /// [seatIndex] is the tile the user actually tapped. Sending it makes the
  /// approval land them on that exact seat and reserves it against anyone else
  /// requesting it; omitting it (the guest button, which names no tile) leaves
  /// the host's approval to pick the first free seat.
  Future<Map<String, dynamic>> requestToSpeak({
    required String roomName,
    required String identity,
    int? seatIndex,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomName/speakers/request',
      data: {
        'identity': identity,
        if (seatIndex != null) 'seat_index': seatIndex,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Cancel Request
  // ---------------------------------------------------------------------------

  /// Cancels a pending speaker request.
  ///
  /// DELETE /api/v1/rooms/:name/speakers/request
  Future<Map<String, dynamic>> cancelRequest({
    required String roomName,
    required String identity,
  }) {
    return _client.delete(
      '/api/v1/rooms/$roomName/speakers/request',
      data: {'identity': identity},
    );
  }

  // ---------------------------------------------------------------------------
  // List Pending Requests
  // ---------------------------------------------------------------------------

  /// Returns all pending speaker requests for the room.
  ///
  /// GET /api/v1/rooms/:name/speakers/requests
  ///
  /// Returns: `{ "requests": [{ "id": 42, "identity": "user123", "created_at": "..." }] }`
  Future<Map<String, dynamic>> listRequests({
    required String roomName,
  }) {
    return _client.get('/api/v1/rooms/$roomName/speakers/requests');
  }

  // ---------------------------------------------------------------------------
  // Approve Request (host/admin only)
  // ---------------------------------------------------------------------------

  /// Approves a speaker request and **automatically seats the user** in the
  /// first available unlocked seat. Permissions are upgraded to `canPublish: true`.
  ///
  /// Backend sends:
  /// - `_speaker_request_approved` to the requesting user
  /// - `_seat_update` to everyone
  ///
  /// POST /api/v1/rooms/:name/speakers/requests/:id/approve
  ///
  /// Returns: `{ "request_id": 42, "identity": "user123", "seat_index": 2 }`
  Future<Map<String, dynamic>> approveRequest({
    required String roomName,
    required int requestId,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomName/speakers/requests/$requestId/approve',
      data: {'identity': identity},
    );
  }

  // ---------------------------------------------------------------------------
  // Reject Request (host/admin only)
  // ---------------------------------------------------------------------------

  /// Rejects a speaker request.
  /// Backend sends `_speaker_request_rejected` data message to the requesting user.
  ///
  /// POST /api/v1/rooms/:name/speakers/requests/:id/reject
  Future<Map<String, dynamic>> rejectRequest({
    required String roomName,
    required int requestId,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomName/speakers/requests/$requestId/reject',
      data: {'identity': identity},
    );
  }

  // ===========================================================================
  // Speaker Invitations (host/admin invites audience to speak)
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Invite to Speak (host/admin only)
  // ---------------------------------------------------------------------------

  /// Invites an audience member to speak on a specific seat.
  /// Target must be in the room and not already seated.
  /// Returns 409 if invitation is already pending.
  /// Backend sends `_speaker_invitation` data message to the invited user only.
  ///
  /// [seatIndex] — optional target seat index. If provided, the backend stores
  /// it with the invitation and includes it in the `_speaker_invitation` event.
  /// When accepted, the user is seated on this specific seat.
  /// If not provided, the backend auto-seats on the first available seat.
  ///
  /// POST /api/v1/rooms/:name/speakers/invite
  ///
  /// Returns: `{ "invitation_id": 55 }`
  Future<Map<String, dynamic>> inviteToSpeak({
    required String roomName,
    required String identity,
    required String targetIdentity,
    int? seatIndex,
  }) {
    final data = <String, dynamic>{
      'identity': identity,
      'target_identity': targetIdentity,
    };
    if (seatIndex != null) {
      data['seat_index'] = seatIndex;
    }
    return _client.post(
      '/api/v1/rooms/$roomName/speakers/invite',
      data: data,
    );
  }

  // ---------------------------------------------------------------------------
  // Accept Invitation
  // ---------------------------------------------------------------------------

  /// Accepts a speaker invitation. Backend **automatically seats the user**
  /// in the first available seat and upgrades permissions to `canPublish: true`.
  ///
  /// Backend sends:
  /// - `_speaker_invitation_accepted` to the host/admin who sent the invite
  /// - `_seat_update` to everyone
  ///
  /// POST /api/v1/rooms/:name/speakers/invitations/:id/accept
  ///
  /// Returns: `{ "invitation_id": 55, "seat_index": 4 }`
  Future<Map<String, dynamic>> acceptInvitation({
    required String roomName,
    required int invitationId,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomName/speakers/invitations/$invitationId/accept',
      data: {'identity': identity},
    );
  }

  // ---------------------------------------------------------------------------
  // Decline Invitation
  // ---------------------------------------------------------------------------

  /// Declines a speaker invitation.
  /// Backend sends `_speaker_invitation_declined` to the inviting host/admin.
  ///
  /// POST /api/v1/rooms/:name/speakers/invitations/:id/decline
  Future<Map<String, dynamic>> declineInvitation({
    required String roomName,
    required int invitationId,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomName/speakers/invitations/$invitationId/decline',
      data: {'identity': identity},
    );
  }
}
