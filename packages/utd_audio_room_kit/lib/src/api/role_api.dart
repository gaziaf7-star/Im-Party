import 'utd_api_client.dart';
import '../models/role_model.dart';

export '../models/role_model.dart';

/// REST API client for the UTD Stream Engine role endpoints.
///
/// Base paths:
/// - `PUT /api/v1/rooms/{room}/participants/{target}/role` (change role)
/// - `GET /api/v1/rooms/{room}/participants/by-role` (list by role)
///
/// Authenticated by the per-user bearer (`Authorization: Bearer`) plus `X-App-Id`,
/// already attached by [UTDApiClient]. The server enforces **owner-only** for
/// role changes (returns `403` otherwise) — gate the UI to the room owner too.
class UTDRoleApi {
  final UTDApiClient _client;

  UTDRoleApi(this._client);

  /// Changes [targetIdentity]'s role to [role] (owner-only).
  ///
  /// [actorIdentity] must equal the room owner, otherwise the server returns
  /// `403`. On success the engine updates the target's RTC permissions and
  /// metadata, and broadcasts a `_role_change` data message to everyone.
  ///
  /// Lets [DioException] propagate so callers can map the status:
  /// `403` owner-only, `404` participant/room not found, `409` already in role,
  /// `422` validation.
  ///
  /// PUT /api/v1/rooms/{room}/participants/{target}/role
  Future<UTDRoleChangeResult> changeRole({
    required String roomName,
    required String targetIdentity,
    required String actorIdentity,
    required String role,
  }) async {
    final res = await _client.put(
      '/api/v1/rooms/${Uri.encodeComponent(roomName)}'
      '/participants/${Uri.encodeComponent(targetIdentity)}/role',
      data: {'actor_identity': actorIdentity, 'role': role},
    );
    return UTDRoleChangeResult.fromJson(res);
  }

  /// Lists participants currently holding [role] (paginated, newest first).
  ///
  /// [perPage] is capped at 100 by the server.
  ///
  /// GET /api/v1/rooms/{room}/participants/by-role?role&page&per_page
  Future<UTDRoleListPage> listByRole({
    required String roomName,
    required String role,
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await _client.get(
      '/api/v1/rooms/${Uri.encodeComponent(roomName)}/participants/by-role',
      queryParameters: {'role': role, 'page': page, 'per_page': perPage},
    );
    return UTDRoleListPage.fromJson(res);
  }
}
