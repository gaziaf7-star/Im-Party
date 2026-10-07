/// Response model returned by the UTD Stream Engine token generation API.
///
/// Contains the LiveKit [token], server [url], and resolved [roomName].
class UTDTokenResponse {
  final String token;
  final String url;
  final String roomName;

  /// Per-user bearer (engine `user_token`) used for server-verified moderation/WS. Empty in
  /// legacy responses that predate it.
  final String userToken;

  UTDTokenResponse({
    required this.token,
    required this.url,
    required this.roomName,
    this.userToken = '',
  });

  factory UTDTokenResponse.fromJson(Map<String, dynamic> json) {
    // The engine uses snake_case everywhere else; accept both and never let an
    // unguarded cast throw a TypeError (which would bypass the 403 ban handler
    // and be misreported as a connection failure). roomName is not consumed by
    // any caller, so its parse must be especially harmless.
    return UTDTokenResponse(
      token: (json['token'] ?? '') as String,
      url: (json['url'] ?? '') as String,
      roomName: (json['room_name'] ?? json['roomName'] ?? '') as String,
      userToken: (json['user_token'] ?? json['userToken'] ?? '') as String,
    );
  }
}
