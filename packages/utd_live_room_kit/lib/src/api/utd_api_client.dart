import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// HTTP client for the UTD Stream Engine API.
///
/// The engine is fronted by two hosts and the kit talks to both:
/// - token/auth (`/api/v1/token`) → [defaultBaseUrl] (`https://udt-stream.com`)
/// - in-room ops (`/api/v1/rooms/...`: seats, speakers, roles, bans, participants)
///   → [defaultEngineBaseUrl] (`https://engine.udt-stream.com`, grey-cloud)
///
/// This class is a single-`baseUrl` client; the controller instantiates it once
/// per host (see [UTDRoomController.initApi]).
class UTDApiClient {
  /// Default base URL for **token generation / auth** (`POST /api/v1/token`).
  static const String defaultBaseUrl = 'https://iamparty.linlive.fr';

  /// Default base URL for **in-room operations** (`/api/v1/rooms/...`).
  ///
  /// Grey-cloud host (direct to the engine, bypassing the Cloudflare proxy) —
  /// the verified fix for the 0-byte room-timeout issue. Seats, speakers, roles,
  /// bans and participant ops all go here; only token minting uses [defaultBaseUrl].
  static const String defaultEngineBaseUrl = 'https://iamparty.linlive.fr';

  final Dio _dio;
  final String baseUrl;

  /// Creates a new [UTDApiClient].
  ///
  /// [baseUrl] is the host this client targets. Pass [defaultBaseUrl] for the
  /// token client and [defaultEngineBaseUrl] for the in-room client.
  UTDApiClient({
    this.baseUrl = defaultBaseUrl,
    String? appId,
    String? appKey,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
        if (appId != null) 'X-App-Id': appId,
        // No-backend mint credential (the publishable app_key). Sent only on the token client;
        // in-room calls authenticate with the per-user bearer (see updateToken).
        if (appKey != null) 'X-App-Key': appKey,
      }
      // Fail fast into the caller's retry path: a hung engine must not eat
      // the whole join budget (15s/15s let one stuck call stall entry).
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 8)
      ..responseType = ResponseType.json;

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  /// Update the API key (e.g. after re-authentication).
  void updateApiKey(String apiKey) {
    _dio.options.headers['X-API-Key'] = apiKey;
  }

  /// Update the authorization token.
  void updateToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ---------------------------------------------------------------------------
  // HTTP Methods
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.post(path, data: data);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.put(path, data: data);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.delete(path, data: data);
    return _parseResponse(response);
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _parseResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'data': response.data};
  }

  /// Dispose resources.
  void dispose() {
    _dio.close();
  }
}
