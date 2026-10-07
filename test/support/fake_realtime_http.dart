import 'package:dio/dio.dart';
import 'package:general/src/core/realtime/realtime_http.dart';

/// Programmable [RealtimeHttp] double for outbox/sync unit tests.
///
/// Set [onGet] / [onPost] to script responses (or throw [DioException] to
/// simulate failures). Captured calls are recorded in [getCalls] / [postCalls]
/// for assertions.
class FakeRealtimeHttp implements RealtimeHttp {
  Future<Response<dynamic>> Function(String path)? onGet;
  Future<Response<dynamic>> Function(
    String path,
    dynamic data,
    Map<String, dynamic>? headers,
  )? onPost;

  final List<String> getCalls = [];
  final List<({String path, dynamic data, Map<String, dynamic>? headers})>
      postCalls = [];

  @override
  Future<Response<dynamic>> get(String path) {
    getCalls.add(path);
    final handler = onGet;
    if (handler == null) {
      return Future.value(Response<dynamic>(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: const [],
      ));
    }
    return handler(path);
  }

  @override
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) {
    postCalls.add((path: path, data: data, headers: headers));
    final handler = onPost;
    if (handler == null) {
      return Future.value(Response<dynamic>(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: const <String, dynamic>{},
      ));
    }
    return handler(path, data, headers);
  }
}
