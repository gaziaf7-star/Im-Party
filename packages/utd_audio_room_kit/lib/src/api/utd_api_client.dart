import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// HTTP client for the UTD Stream Engine API.
///
/// Two hosts are in play:
/// - In-room operations (seats, speakers, bans, roles) use the grey-cloud
///   engine host `https://engine.udt-stream.com` (see [defaultBaseUrl]). These
///   are the long-lived calls that hit the 0-byte room timeouts on the edge.
/// - Token generation (`/api/v1/token`) uses the edge host
///   `https://udt-stream.com` (see [defaultTokenBaseUrl]).
/// All seat & speaker endpoints live under `/api/v1/rooms/:name/...`
class UTDApiClient {
  /// Default base URL for in-room engine operations (seats, speakers, bans, roles).
  static const String defaultBaseUrl = 'https://iamparty.linlive.fr';

  /// Default base URL for token generation (`/api/v1/token`).
  static const String defaultTokenBaseUrl = 'https://iamparty.linlive.fr';

  /// Process-wide HTTP transport shared by every [UTDApiClient]. One dart:io
  /// [HttpClient] kept alive across room enter/exit means a re-entry reuses
  /// the pooled TLS connection to the engine hosts instead of paying a fresh
  /// DNS+TCP+TLS handshake (~60-200ms on mobile) — the pool used to be
  /// per-controller and was closed on room exit. idleTimeout is raised from
  /// dart:io's 15s default so a leave→rejoin within a minute still hits a warm
  /// socket. Never closed: connection warm-up must survive [dispose].
  static final HttpClient sharedHttpClient =
      HttpClient()..idleTimeout = const Duration(seconds: 60);

  final Dio _dio;
  final String baseUrl;

  /// Whether this instance rides [sharedHttpClient] (default-constructed Dio).
  /// An injected [Dio] (tests) keeps its own transport and is closed on dispose.
  final bool _usesSharedTransport;

  /// Creates a new [UTDApiClient].
  ///
  /// [baseUrl] defaults to [defaultBaseUrl] (`https://engine.udt-stream.com`).
  UTDApiClient({
    this.baseUrl = defaultBaseUrl,
    String? appId,
    String? appKey,
    Dio? dio,
  }) : _dio = dio ?? Dio(),
       _usesSharedTransport = dio == null && !kIsWeb {
    if (_usesSharedTransport) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () => sharedHttpClient,
      );
    }
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
          // Headers and bodies stay off: requests carry the per-user bearer
          // (and X-App-Key) and the token response carries the JWT — none may
          // be echoed to logs — and dumping bodies inflates debug join timings.
          requestHeader: false,
          requestBody: false,
          responseBody: false,
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
    final response = await _dio.get(path, queryParameters: queryParameters);
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

  /// Dispose resources. When riding the shared transport, the Dio is NOT
  /// closed — closing it would tear down [sharedHttpClient]'s warm connections,
  /// which must survive room exit → re-entry. Injected Dios close as before.
  void dispose() {
    if (!_usesSharedTransport) _dio.close();
  }
}
