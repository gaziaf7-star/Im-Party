import 'utd_api_client.dart';
import '../models/ban_model.dart';

export '../models/ban_model.dart';

/// REST API client for the UTD Stream Engine user-ban endpoints.
///
/// Base path: `/api/v1/rooms/ban` (+ `/api/v1/rooms/bans` for the list).
///
/// Authenticated by the per-user bearer token already attached by
/// [UTDApiClient]. There is no per-user role check on the server — gate
/// ban/unban actions to host/admin in the UI.
class UTDBanApi {
  final UTDApiClient _client;

  UTDBanApi(this._client);

  /// Bans a user.
  ///
  /// - [roomName] omitted/null => **global** ban (all rooms in the project).
  /// - [durationSeconds] omitted/null => **permanent** ban.
  ///
  /// If the user is connected they are instantly kicked and receive a
  /// `_banned` data message.
  ///
  /// POST /api/v1/rooms/ban
  Future<Map<String, dynamic>> banUser({
    required String identity,
    String? roomName,
    String? reason,
    int? durationSeconds,
  }) {
    final data = <String, dynamic>{'identity': identity};
    if (roomName != null) data['room_name'] = roomName;
    if (reason != null) data['reason'] = reason;
    if (durationSeconds != null) data['duration'] = durationSeconds;

    return _client.post('/api/v1/rooms/ban', data: data);
  }

  /// Removes a ban.
  ///
  /// - [roomName] null => remove **all** bans for this identity in the project.
  ///
  /// DELETE /api/v1/rooms/ban
  Future<Map<String, dynamic>> unbanUser({
    required String identity,
    String? roomName,
  }) {
    final data = <String, dynamic>{'identity': identity};
    if (roomName != null) data['room_name'] = roomName;

    return _client.delete('/api/v1/rooms/ban', data: data);
  }

  /// Returns the project's active bans (expired bans excluded), newest first.
  ///
  /// [perPage] is capped at 100 by the server.
  ///
  /// GET /api/v1/rooms/bans?page&per_page
  Future<UTDBanListPage> listBans({int page = 1, int perPage = 20}) async {
    final res = await _client.get(
      '/api/v1/rooms/bans',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return UTDBanListPage.fromJson(res);
  }
}
