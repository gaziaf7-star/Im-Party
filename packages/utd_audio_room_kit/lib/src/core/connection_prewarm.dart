import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/utd_api_client.dart';

/// Best-effort connection pre-warming for the two hosts on the join critical
/// path: the token host (HTTP POST) and the RTC edge (WSS dial). Every method
/// swallows all errors — pre-warming may never break or delay a join, only
/// overlap handshakes that would otherwise run serially:
///
/// - token host: the join's first request used to pay DNS+TCP+TLS inline;
///   pre-opening the pooled connection (same shared [HttpClient] the API
///   clients ride) moves that off the critical path.
/// - RTC edge: the WSS dial starts only AFTER the token response, so its
///   DNS+TLS handshake serialized behind the token round trip. The edge URL is
///   stable per project+region, so the URL remembered from the LAST join lets
///   the NEXT join warm it in parallel with its token request (the same trick
///   as the RTC SDK's own prepareConnection: an HTTP HEAD seeds the OS DNS
///   cache and the process TLS session cache, letting the real dial resume
///   instead of running a full handshake).
class UTDConnectionPrewarm {
  UTDConnectionPrewarm._();

  static const String _rtcUrlKey = 'utd_last_rtc_url';
  static String? _lastRtcUrl;

  /// Remembers the RTC edge URL returned by the token endpoint (in memory and
  /// in SharedPreferences for cold starts) so the next join can pre-warm it.
  static void rememberRtcUrl(String url) {
    if (url.isEmpty || url == _lastRtcUrl) return;
    _lastRtcUrl = url;
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_rtcUrlKey, url);
      } catch (_) {}
    }());
  }

  /// Pre-warms DNS + TLS to the RTC edge remembered from the last successful
  /// join. No-op when no join has happened yet on this install.
  static Future<void> prewarmRtc() async {
    try {
      var url = _lastRtcUrl;
      if (url == null) {
        final prefs = await SharedPreferences.getInstance();
        url = prefs.getString(_rtcUrlKey);
        _lastRtcUrl = url;
      }
      if (url == null || url.isEmpty) return;
      var httpUrl = url;
      if (httpUrl.startsWith('wss://')) {
        httpUrl = 'https://${httpUrl.substring(6)}';
      } else if (httpUrl.startsWith('ws://')) {
        httpUrl = 'http://${httpUrl.substring(5)}';
      }
      await _head(Uri.parse(httpUrl));
    } catch (_) {}
  }

  /// Pre-opens the pooled TLS connection to the token host so the join's token
  /// POST rides a warm socket. Uses the SAME shared [HttpClient] as the API
  /// clients, so the handshake done here is literally the connection reused.
  /// `/health` is the engine's unauthenticated liveness endpoint.
  static Future<void> prewarmTokenHost(String baseUrl) async {
    try {
      await _head(Uri.parse(baseUrl).replace(path: '/health'));
    } catch (_) {}
  }

  static Future<void> _head(Uri uri) async {
    final req = await UTDApiClient.sharedHttpClient
        .headUrl(uri)
        .timeout(const Duration(seconds: 4));
    final res = await req.close().timeout(const Duration(seconds: 4));
    await res.drain<void>();
  }
}
