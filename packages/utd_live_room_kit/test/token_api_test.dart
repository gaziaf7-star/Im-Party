import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utd_live_room_kit/src/api/utd_api_client.dart';
import 'package:utd_live_room_kit/src/api/token_api.dart';
import 'package:utd_live_room_kit/src/models/ban_model.dart';

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
  test('403 "User is banned" -> UTDBannedException', () async {
    final api = makeApiWithError(403, 'User is banned');
    await expectLater(
      api.generateToken(identity: 'u1', roomName: 'r', roomOwnerId: 'u1'),
      throwsA(isA<UTDBannedException>()),
    );
  });

  test('403 type-not-enabled -> UTDServiceNotAvailableException (not a ban)', () async {
    final api = makeApiWithError(403, "Type 'live_stream' is not enabled for this project");
    await expectLater(
      api.generateToken(identity: 'u1', roomName: 'r', roomOwnerId: 'u1'),
      throwsA(isA<UTDServiceNotAvailableException>()),
    );
  });
}
