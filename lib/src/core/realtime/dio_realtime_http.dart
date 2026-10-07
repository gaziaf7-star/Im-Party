import 'package:dio/dio.dart';
import 'package:general/src/core/network/dio_factory.dart';
import 'package:general/src/core/realtime/realtime_http.dart';

/// Production [RealtimeHttp] adapter over the app's [DioFactory], so all of the
/// existing interceptors (auth bearer, device id, retry, crashlytics, cache)
/// apply to realtime sync/outbox traffic exactly as they do everywhere else.
class DioRealtimeHttp implements RealtimeHttp {
  DioRealtimeHttp(this._dio);

  final DioFactory _dio;

  @override
  Future<Response<dynamic>> get(String path) => _dio.get(path);

  @override
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) =>
      _dio.post(path, data: data, headers: headers);
}
