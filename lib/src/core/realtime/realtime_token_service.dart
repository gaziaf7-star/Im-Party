import 'package:general/src/core/index.dart';

/// Fetches Centrifugo auth tokens from Laravel (Plan section 2).
///
/// Two kinds of tokens:
///  - **connection JWT** (`POST /centrifugo/token`) — used by the
///    centrifuge-dart `getToken` callback. The SDK calls this automatically
///    before the connection token expires (refresh cycle).
///  - **subscription token** (`POST /centrifugo/subscription`) — per-channel
///    JWT for the private 1:1 chat channel. The SDK calls this via the
///    subscription `getToken` callback when (re)subscribing.
///
/// This service only talks HTTP; it holds no socket state. The user's bearer
/// token is attached by [DioFactory]'s interceptor, so we never pass it here.
class RealtimeTokenService {
  RealtimeTokenService(this._dio);

  final DioFactory _dio;

  /// Connection JWT for the WebSocket handshake. Returns the raw token string
  /// the SDK expects. Throws on transport/parse failure so the SDK retries.
  Future<String> connectionToken() async {
    final response = await _dio.post(EndPoints.centrifugoToken);
    return _extractToken(response.data);
  }

  /// Subscription token for the 1:1 chat channel of the given peer.
  ///
  /// The backend derives the exact channel name (`chat:dm.{min}_{max}`) from
  /// the authenticated user + [peerUserId] and stamps it into the JWT `channel`
  /// claim, so we only need to send the peer id.
  Future<String> subscriptionToken({required int peerUserId}) async {
    final response = await _dio.post(
      EndPoints.centrifugoSubscription,
      data: {'user_id': peerUserId},
    );
    return _extractToken(response.data);
  }

  /// Both endpoints return `{token: "JWT..."}` (optionally wrapped in `data`).
  String _extractToken(dynamic body) {
    if (body is Map) {
      final direct = body['token'];
      if (direct is String && direct.isNotEmpty) return direct;
      final data = body['data'];
      if (data is Map) {
        final nested = data['token'];
        if (nested is String && nested.isNotEmpty) return nested;
      }
    }
    throw StateError('Centrifugo token missing in response');
  }
}
