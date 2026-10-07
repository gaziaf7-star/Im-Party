import 'package:dio/dio.dart';

/// Narrow HTTP seam the realtime workers depend on.
///
/// Deliberately depends ONLY on `dio` (no app barrel), so the outbox/sync logic
/// and its tests compile in isolation from the rest of the app. The production
/// adapter over [DioFactory] lives in `dio_realtime_http.dart`.
abstract class RealtimeHttp {
  Future<Response<dynamic>> get(String path);

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  });
}
