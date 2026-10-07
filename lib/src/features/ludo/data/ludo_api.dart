import 'package:general/src/core/index.dart';

import 'ludo_models.dart';

/// REST client for the Ludo backend. Authentication, base URL and language
/// headers come from the shared [DioFactory].
class LudoApi {
  const LudoApi();

  static String _url(String path) => '${EndPoints.baseURL}/ludo$path';

  Future<LudoConfig> config() async {
    final data = await _call(() => DioFactory().get(_url('/config')));
    final cfg = data['config'];
    return cfg is Map
        ? LudoConfig.fromJson(Map<String, dynamic>.from(cfg))
        : LudoConfig.fallback;
  }

  Future<LudoServerGame> create({
    required int roomId,
    required String mode,
    required String rule,
    required bool magic,
    required int entryFee,
  }) => _game(
    () => DioFactory().post(
      _url('/games'),
      data: {
        'room_id': roomId,
        'mode': mode,
        'rule': rule,
        'magic': magic,
        'entry_fee': entryFee,
      },
    ),
  );

  Future<LudoServerGame> join(int id) =>
      _game(() => DioFactory().post(_url('/games/$id/join')));

  Future<void> leave(int id) =>
      _call(() => DioFactory().post(_url('/games/$id/leave')));

  Future<LudoServerGame> start(int id) =>
      _game(() => DioFactory().post(_url('/games/$id/start')));

  Future<void> cancel(int id) =>
      _call(() => DioFactory().post(_url('/games/$id/cancel')));

  Future<LudoServerGame> roll(int id) =>
      _game(() => DioFactory().post(_url('/games/$id/roll')));

  Future<LudoServerGame> move(int id, int tokenSlot) => _game(
    () => DioFactory().post(
      _url('/games/$id/move'),
      data: {'token_slot': tokenSlot},
    ),
  );

  /// Current live game of a room (null when none).
  Future<LudoServerGame?> active(int roomId) async {
    final data = await _call(
      () => DioFactory().get(
        _url('/games/active'),
        queryParameters: {'room_id': roomId},
      ),
    );
    final g = data['game'];
    return g is Map ? LudoServerGame.fromJson(Map<String, dynamic>.from(g)) : null;
  }

  // -------------------------------------------------------------------------

  Future<LudoServerGame> _game(Future<Response<dynamic>> Function() req) async {
    final data = await _call(req);
    final g = data['game'];
    if (g is! Map) throw const LudoException('BAD_RESPONSE', 'Invalid response');
    return LudoServerGame.fromJson(Map<String, dynamic>.from(g));
  }

  /// Runs [req] and returns `data` of a `{status:true,data:{..}}` envelope, or
  /// throws a [LudoException] built from `{status:false,code,message}`.
  Future<Map<String, dynamic>> _call(
    Future<Response<dynamic>> Function() req,
  ) async {
    try {
      final res = await req();
      return _unwrap(res.data);
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map && body['code'] != null) {
        throw LudoException('${body['code']}', '${body['message'] ?? ''}');
      }
      throw LudoException(
        'NETWORK',
        body is Map ? '${body['message'] ?? ''}' : (e.message ?? 'Network error'),
      );
    }
  }

  Map<String, dynamic> _unwrap(dynamic body) {
    if (body is Map) {
      if (body['status'] == false) {
        throw LudoException('${body['code'] ?? 'ERROR'}', '${body['message'] ?? ''}');
      }
      final d = body['data'];
      return d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
    }
    return <String, dynamic>{};
  }
}
