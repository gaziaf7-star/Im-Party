import 'utd_api_client.dart';

/// REST client for the live_stream **stage** endpoints.
///
/// The stage is the unbounded publisher set of a `live_stream` room: the host
/// plus any number of host-invited co-publishers. Publishing is decoupled from
/// moderation — being added to the stage grants audio/video publish only; it is
/// not a moderation role. The engine imposes NO co-publisher cap (the package
/// caps the visible tiles).
///
/// Base path: `/api/v1/rooms/:name/stage/...`
///
/// The actor is resolved server-side from the per-user bearer; `identity` is
/// sent as a dual-mode fallback. `target_identity` names the affected user.
class UTDStageApi {
  final UTDApiClient _client;

  UTDStageApi(this._client);

  /// Current stage publishers: `{ "members": [{ identity, name, role }] }`.
  ///
  /// GET /api/v1/rooms/:name/stage
  Future<Map<String, dynamic>> getStage({required String roomName}) {
    return _client.get('/api/v1/rooms/$roomName/stage');
  }

  /// Host/admin invites [targetIdentity] onto the stage (grants A/V publish).
  /// [actorIdentity] — the host/admin performing the action (dual-mode fallback).
  ///
  /// POST /api/v1/rooms/:name/stage/add
  Future<Map<String, dynamic>> addToStage({
    required String roomName,
    required String targetIdentity,
    required String actorIdentity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomName/stage/add',
      data: {'identity': actorIdentity, 'target_identity': targetIdentity},
    );
  }

  /// Host/admin removes [targetIdentity] from the stage (revokes publish).
  ///
  /// POST /api/v1/rooms/:name/stage/remove
  Future<Map<String, dynamic>> removeFromStage({
    required String roomName,
    required String targetIdentity,
    required String actorIdentity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomName/stage/remove',
      data: {'identity': actorIdentity, 'target_identity': targetIdentity},
    );
  }

  /// A co-publisher steps down from the stage on their own.
  ///
  /// POST /api/v1/rooms/:name/stage/leave
  Future<Map<String, dynamic>> leaveStage({
    required String roomName,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomName/stage/leave',
      data: {'identity': identity},
    );
  }

  /// A viewer asks to go on stage. Transient signal: the engine notifies the
  /// host/admins via a `_stage_request` data message (no persisted queue). A
  /// host then calls [addToStage].
  ///
  /// POST /api/v1/rooms/:name/stage/request
  Future<Map<String, dynamic>> requestStage({
    required String roomName,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/$roomName/stage/request',
      data: {'identity': identity},
    );
  }
}
