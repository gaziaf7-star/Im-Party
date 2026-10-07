import 'package:general/src/core/index.dart';

import 'carom_models.dart';

/// REST client for the Carrom backend. Authentication, base URL and language
/// headers come from the shared [DioFactory].
class CaromApi {
  const CaromApi();

  static String _url(String path) => '${EndPoints.baseURL}/carom$path';

  Future<CaromConfig> config() async {
    final data = await _call(() => DioFactory().get(_url('/config')));
    final cfg = data['config'];
    return cfg is Map
        ? CaromConfig.fromJson(Map<String, dynamic>.from(cfg))
        : CaromConfig.fallback;
  }

  Future<CaromServerGame> create({
    required int roomId,
    required String mode,
    required int entryFee,
  }) => _game(
    () => DioFactory().post(
      _url('/games'),
      data: {'room_id': roomId, 'mode': mode, 'entry_fee': entryFee},
    ),
  );

  Future<CaromServerGame> join(int id) =>
      _game(() => DioFactory().post(_url('/games/$id/join')));

  Future<void> leave(int id) =>
      _call(() => DioFactory().post(_url('/games/$id/leave')));

  Future<CaromServerGame> start(int id) =>
      _game(() => DioFactory().post(_url('/games/$id/start')));

  Future<void> cancel(int id) =>
      _call(() => DioFactory().post(_url('/games/$id/cancel')));

  /// The shooter fired. The server checks the turn, stores the shot and
  /// pushes a `shot` event to the whole room.
  Future<CaromServerGame> shot(
    int id, {
    required int shotId,
    required double strikerX,
    required double strikerY,
    required double angle,
    required double power,
  }) => _game(
    () => DioFactory().post(
      _url('/games/$id/shot'),
      data: {
        'shot_id': shotId,
        'striker_x': strikerX,
        'striker_y': strikerY,
        'angle': angle,
        'power': power,
      },
    ),
  );

  /// The shooter's board after the pieces stopped. The server applies the
  /// rules and answers with the authoritative snapshot (also pushed as a
  /// `shot_result` event).
  Future<CaromServerGame> shotResult(
    int id, {
    required int shotId,
    required List<CaromPieceState> pieces,
    required bool strikerPocketed,
  }) => _game(
    () => DioFactory().post(
      _url('/games/$id/shot/result'),
      data: {
        'shot_id': shotId,
        'striker_pocketed': strikerPocketed,
        'pieces': pieces.map((p) => p.toJson()).toList(),
      },
    ),
  );

  /// Live striker position / aim of the active player (relayed to the room as
  /// an un-versioned `aim` event). Fire-and-forget.
  Future<void> aim(
    int id, {
    required double sliderX,
    required bool aiming,
    required double angle,
    required double power,
  }) => _call(
    () => DioFactory().post(
      _url('/games/$id/aim'),
      data: {
        'slider': sliderX,
        'slider_x': sliderX,
        'aiming': aiming,
        'angle': angle,
        'power': power,
      },
    ),
  );

  /// Current live game of a room (null when none).
  Future<CaromServerGame?> active(int roomId) async {
    final data = await _call(
      () => DioFactory().get(
        _url('/games/active'),
        queryParameters: {'room_id': roomId},
      ),
    );
    final g = data['game'];
    return g is Map
        ? CaromServerGame.fromJson(Map<String, dynamic>.from(g))
        : null;
  }

  // -------------------------------------------------------------------------

  Future<CaromServerGame> _game(
    Future<Response<dynamic>> Function() req,
  ) async {
    final data = await _call(req);
    final g = data['game'];
    if (g is! Map) {
      throw const CaromException('BAD_RESPONSE', 'Invalid response');
    }
    return CaromServerGame.fromJson(Map<String, dynamic>.from(g));
  }

  Future<Map<String, dynamic>> _call(
    Future<Response<dynamic>> Function() req,
  ) async {
    try {
      final res = await req();
      return _unwrap(res.data);
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map && body['code'] != null) {
        throw CaromException('${body['code']}', '${body['message'] ?? ''}');
      }
      throw CaromException(
        'NETWORK',
        body is Map ? '${body['message'] ?? ''}' : (e.message ?? 'Network error'),
      );
    }
  }

  Map<String, dynamic> _unwrap(dynamic body) {
    if (body is Map) {
      if (body['status'] == false) {
        throw CaromException(
          '${body['code'] ?? 'ERROR'}',
          '${body['message'] ?? ''}',
        );
      }
      final d = body['data'];
      return d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
    }
    return <String, dynamic>{};
  }
}
