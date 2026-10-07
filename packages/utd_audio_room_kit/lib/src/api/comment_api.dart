import 'utd_api_client.dart';

/// REST API client for the UTD Stream Engine comment-lock endpoints.
///
/// Base paths:
/// - `POST /api/v1/rooms/{room}/comments/lock`
/// - `POST /api/v1/rooms/{room}/comments/unlock`
///
/// Authenticated by the per-user bearer (`Authorization: Bearer`) plus `X-App-Id`,
/// already attached by [UTDApiClient]. The server enforces **host/admin-only**
/// (returns `403` otherwise) — gate the UI to host/admin too.
///
/// Locking only blocks in-room chat (`{ "type": "chat" }` data messages); gifts,
/// reactions and seat actions keep flowing. The server publishes the lock state
/// (room metadata `chat_locked` + a broadcast `_chat_lock` data message) and the
/// client enforces it — see [UTDChatController.canSendChat].
class UTDCommentApi {
  final UTDApiClient _client;

  UTDCommentApi(this._client);

  /// Locks room chat (host/admin only).
  ///
  /// [identity] is the acting user; the server returns `403` if they are not a
  /// host or admin. Idempotent — locking an already-locked room returns `200`
  /// with the current state. On success the engine writes `chat_locked` into the
  /// room metadata and broadcasts a `_chat_lock {locked:true}` data message.
  ///
  /// Lets [DioException] propagate so callers can map the status
  /// (`403` host/admin-only, `404` room not active, `422` validation).
  ///
  /// POST /api/v1/rooms/{room}/comments/lock
  Future<Map<String, dynamic>> lock({
    required String roomName,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/${Uri.encodeComponent(roomName)}/comments/lock',
      data: {'identity': identity},
    );
  }

  /// Unlocks room chat (host/admin only). Mirror of [lock].
  ///
  /// POST /api/v1/rooms/{room}/comments/unlock
  Future<Map<String, dynamic>> unlock({
    required String roomName,
    required String identity,
  }) {
    return _client.post(
      '/api/v1/rooms/${Uri.encodeComponent(roomName)}/comments/unlock',
      data: {'identity': identity},
    );
  }
}
