import 'package:dio/dio.dart';

import 'utd_api_client.dart';
import '../models/token_response_model.dart';
import '../models/ban_model.dart';

export '../models/token_response_model.dart';

/// Thrown when token generation fails for a non-ban reason (network/timeout,
/// engine 5xx, malformed body). Carries the HTTP [statusCode] when available so
/// callers can tell a transport failure apart from an engine error.
class UTDTokenException implements Exception {
  final int? statusCode;
  final String message;
  UTDTokenException(this.message, {this.statusCode});
  @override
  String toString() => 'UTDTokenException($statusCode): $message';
}

/// Thrown on a `429` from the token endpoint — either the per-(project, identity,
/// device) issuance rate limit, or the single-session takeover cooldown (a session
/// is already active on another device and was claimed too recently to supersede).
/// Callers should back off and retry, NOT hammer the endpoint.
class UTDRateLimitedException implements Exception {
  final String message;
  const UTDRateLimitedException([this.message = 'Too many token requests']);
  @override
  String toString() => 'UTDRateLimitedException: $message';
}

/// Thrown on a non-ban `403` from the token endpoint — the project has NOT
/// activated this service (e.g. `Type 'audio_room' is not enabled for this
/// project`) in the dashboard. Distinct from [UTDBannedException] so the UI can
/// say "not available" (retrying can't help) instead of showing the ban flow.
class UTDServiceNotAvailableException implements Exception {
  final String message;
  final int statusCode;
  const UTDServiceNotAvailableException([
    this.message = 'This service is not enabled for this project',
    this.statusCode = 403,
  ]);
  @override
  String toString() => 'UTDServiceNotAvailableException($statusCode): $message';
}

class UTDTokenApi {
  final UTDApiClient _client;

  UTDTokenApi(this._client);

  Future<UTDTokenResponse> generateToken({
    required String identity,
    required String roomName,
    required String roomOwnerId,
    // The engine is type-first; an audio room kit is always the 'audio_room' product type. The
    // legacy service/kind fields are no longer sent — the engine derives everything from `type`.
    String type = 'audio_room',
    String? name,
    String role = 'audience',
    int? seatCount,
    String? seatMode,
    int? hostSeat,
    String? modeId,
    String? deviceModel,
    String? os,
    String? osVersion,
    String? appVersion,
    String? deviceId,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final data = <String, dynamic>{
      'identity': identity,
      'room_name': roomName,
      'type': type,
      'room_owner_id': roomOwnerId,
    };

    if (name != null) data['name'] = name;
    data['role'] = role;
    if (seatCount != null) data['seat_count'] = seatCount;
    if (seatMode != null) data['seat_mode'] = seatMode;
    if (hostSeat != null) data['host_seat'] = hostSeat;
    if (modeId != null) data['mode_id'] = modeId;
    // Stable per-install id — drives the engine's single-active-session enforcement.
    if (deviceId != null) data['device_id'] = deviceId;
    if (deviceModel != null) data['device_model'] = deviceModel;
    if (os != null) data['os'] = os;
    if (osVersion != null) data['os_version'] = osVersion;
    if (appVersion != null) data['app_version'] = appVersion;
    // Profile image URL — persisted server-side and shown in the dashboard.
    if (imageUrl != null) data['image'] = imageUrl;
    if (metadata != null) data['metadata'] = metadata;

    try {
      final response = await _client.post('/api/v1/token', data: data);
      final parsed = UTDTokenResponse.fromJson(response);
      if (parsed.token.isEmpty || parsed.url.isEmpty) {
        throw UTDTokenException('Malformed token response from engine');
      }
      return parsed;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final body = e.response?.data;
        final message = (body is Map && body['message'] != null)
            ? body['message'].toString()
            : 'User is banned';
        // The engine overloads 403: an actual ban ("User is banned") vs. the
        // service not being activated ("Type '...' is not enabled ..."). Only the
        // former is a ban; the latter is a not-available refusal.
        if (message.toLowerCase().contains('ban')) {
          throw UTDBannedException(message);
        }
        throw UTDServiceNotAvailableException(message);
      }
      if (e.response?.statusCode == 429) {
        final body = e.response?.data;
        final message = (body is Map && body['message'] != null)
            ? body['message'].toString()
            : 'Too many token requests';
        throw UTDRateLimitedException(message);
      }
      final body = e.response?.data;
      final message = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : (e.message ?? 'Token request failed');
      throw UTDTokenException(message, statusCode: e.response?.statusCode);
    }
  }
}
