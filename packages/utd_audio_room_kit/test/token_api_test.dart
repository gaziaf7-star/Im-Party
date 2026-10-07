import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utd_audio_room_kit/src/api/utd_api_client.dart';
import 'package:utd_audio_room_kit/src/api/token_api.dart';
import 'package:utd_audio_room_kit/src/models/ban_model.dart';

/// Builds a UTDTokenApi whose HTTP layer is short-circuited by an interceptor that
/// captures the outgoing request body (so we can assert the exact wire contract the
/// engine's POST /api/v1/token expects) and returns a canned token response.
(UTDTokenApi, Map<String, dynamic>) makeApi() {
  final captured = <String, dynamic>{};
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      captured
        ..clear()
        ..addAll(Map<String, dynamic>.from(options.data as Map));
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'token': 'tok',
          'url': 'wss://lk.test',
          'room_name': 'r',
          'user_token': 'usr',
        },
      ));
    },
  ));
  final api = UTDTokenApi(UTDApiClient(dio: dio, baseUrl: 'https://test'));
  return (api, captured);
}

/// Builds a UTDTokenApi whose HTTP layer always fails the token mint with the given
/// status + `{message}` body, so we can assert how the kit maps engine refusals.
UTDTokenApi makeApiWithError(int status, String message) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      handler.reject(DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: status,
          data: {'message': message},
        ),
        type: DioExceptionType.badResponse,
      ));
    },
  ));
  return UTDTokenApi(UTDApiClient(dio: dio, baseUrl: 'https://test'));
}

void main() {
  test('generateToken forwards device fields and image under the engine wire keys', () async {
    final (api, captured) = makeApi();

    final res = await api.generateToken(
      identity: 'u1',
      roomName: 'r',
      roomOwnerId: 'u1',
      deviceModel: 'Pixel 9',
      os: 'android',
      osVersion: '15',
      appVersion: '1.2.3',
      deviceId: 'dev-1',
      imageUrl: 'https://cdn.test/a.png',
    );

    expect(res.token, 'tok');
    expect(res.userToken, 'usr');
    expect(captured['device_model'], 'Pixel 9');
    expect(captured['os'], 'android');
    expect(captured['os_version'], '15');
    expect(captured['app_version'], '1.2.3');
    expect(captured['device_id'], 'dev-1');
    expect(captured['image'], 'https://cdn.test/a.png');
  });

  test('generateToken omits optional keys when not provided', () async {
    final (api, captured) = makeApi();

    await api.generateToken(identity: 'u1', roomName: 'r', roomOwnerId: 'u1');

    expect(captured.containsKey('image'), isFalse);
    expect(captured.containsKey('device_model'), isFalse);
    expect(captured.containsKey('app_version'), isFalse);
    // Required fields always present.
    expect(captured['identity'], 'u1');
    expect(captured['room_name'], 'r');
  });

  test('403 "User is banned" -> UTDBannedException', () async {
    final api = makeApiWithError(403, 'User is banned');
    await expectLater(
      api.generateToken(identity: 'u1', roomName: 'r', roomOwnerId: 'u1'),
      throwsA(isA<UTDBannedException>()),
    );
  });

  test('403 type-not-enabled -> UTDServiceNotAvailableException (not a ban)', () async {
    final api = makeApiWithError(403, "Type 'audio_room' is not enabled for this project");
    await expectLater(
      api.generateToken(identity: 'u1', roomName: 'r', roomOwnerId: 'u1'),
      throwsA(isA<UTDServiceNotAvailableException>()),
    );
  });
}
