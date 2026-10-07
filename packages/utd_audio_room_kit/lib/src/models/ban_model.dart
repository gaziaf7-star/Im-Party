// Models for the UTD Stream Engine user-ban feature.
//
// Covers the REST list endpoint (`GET /api/v1/rooms/bans`), the realtime
// `_banned` data message, and the token-fetch `403 User is banned` response.

/// Attributes snapshotted for a banned user (mirrors the participant attributes
/// the client set: `fr`, `frt`, `avatar`, `cn`). All fields are optional —
/// the whole object is `null` when the user was offline at ban time.
class UTDBanUserAttributes {
  final String? fr;
  final String? frt;
  final String? avatar;
  final String? cn;

  const UTDBanUserAttributes({this.fr, this.frt, this.avatar, this.cn});

  factory UTDBanUserAttributes.fromJson(Map<String, dynamic> json) {
    return UTDBanUserAttributes(
      fr: json['fr'] as String?,
      frt: json['frt'] as String?,
      avatar: json['avatar'] as String?,
      cn: json['cn'] as String?,
    );
  }
}

/// A single active ban row from `GET /api/v1/rooms/bans`.
class UTDBannedUser {
  final int id;
  final String identity;
  final String? name;
  final UTDBanUserAttributes? attributes;

  /// `null` => global ban (all rooms in the project).
  final String? roomName;
  final String? reason;
  final DateTime? bannedAt;

  /// `null` => permanent ban.
  final DateTime? expiresAt;

  const UTDBannedUser({
    required this.id,
    required this.identity,
    this.name,
    this.attributes,
    this.roomName,
    this.reason,
    this.bannedAt,
    this.expiresAt,
  });

  bool get isGlobal => roomName == null;
  bool get isPermanent => expiresAt == null;

  factory UTDBannedUser.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    return UTDBannedUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      identity: json['identity'] as String? ?? '',
      name: json['name'] as String?,
      attributes: attrs is Map<String, dynamic>
          ? UTDBanUserAttributes.fromJson(attrs)
          : null,
      roomName: json['room_name'] as String?,
      reason: json['reason'] as String?,
      bannedAt: json['banned_at'] != null
          ? DateTime.tryParse(json['banned_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
    );
  }
}

/// One page of the paginated bans list.
class UTDBanListPage {
  final List<UTDBannedUser> data;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  const UTDBanListPage({
    required this.data,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory UTDBanListPage.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? const [];
    final pagination =
        (json['pagination'] as Map<String, dynamic>?) ?? const {};
    final parsed = list
        .whereType<Map<String, dynamic>>()
        .map(UTDBannedUser.fromJson)
        .toList();
    return UTDBanListPage(
      data: parsed,
      page: (pagination['page'] as num?)?.toInt() ?? 1,
      perPage: (pagination['per_page'] as num?)?.toInt() ?? parsed.length,
      total: (pagination['total'] as num?)?.toInt() ?? parsed.length,
      totalPages: (pagination['total_pages'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Where a forced-exit notice originated — affects how much info is available
/// and which message is shown. (Most are bans; [signedInElsewhere] is a
/// single-active-session takeover, surfaced through the same exit funnel.)
enum UTDBanSource {
  /// A `_banned` data message — richest (reason + expiry known).
  dataMessage,

  /// `DisconnectReason.participantRemoved` — fallback, reason/expiry unknown.
  disconnect,

  /// A `403 User is banned` on token (re)fetch — re-entry blocked.
  tokenForbidden,

  /// A `_kicked` data message with reason `signed_in_elsewhere` — this account
  /// started a session on another device (newest-wins). NOT a ban.
  signedInElsewhere,
}

/// A ban notice delivered to the local (banned) user.
class UTDBanNotice {
  final String? roomName;
  final String? reason;
  final DateTime? expiresAt;
  final UTDBanSource source;

  const UTDBanNotice({
    this.roomName,
    this.reason,
    this.expiresAt,
    this.source = UTDBanSource.dataMessage,
  });

  bool get isPermanent => expiresAt == null;

  /// Builds a notice from a `_banned` data message payload.
  factory UTDBanNotice.fromData(Map<String, dynamic> data) {
    return UTDBanNotice(
      roomName: data['room_name'] as String?,
      reason: data['reason'] as String?,
      expiresAt: data['expires_at'] != null
          ? DateTime.tryParse(data['expires_at'] as String)
          : null,
      source: UTDBanSource.dataMessage,
    );
  }

  /// Built when the server removed the participant but the `_banned` message
  /// was not received (reason/expiry unknown).
  const UTDBanNotice.fromDisconnect()
      : roomName = null,
        reason = null,
        expiresAt = null,
        source = UTDBanSource.disconnect;

  /// Built when (re)joining is blocked by a `403 User is banned` token error.
  const UTDBanNotice.fromTokenForbidden()
      : roomName = null,
        reason = null,
        expiresAt = null,
        source = UTDBanSource.tokenForbidden;

  /// Built from a `_kicked` (`signed_in_elsewhere`) data message — the account
  /// signed in on another device, so this session is being ended (not a ban).
  const UTDBanNotice.fromKicked([this.reason])
      : roomName = null,
        expiresAt = null,
        source = UTDBanSource.signedInElsewhere;
}

/// Thrown by token generation when the server returns `403 User is banned`.
class UTDBannedException implements Exception {
  final String message;
  final int statusCode;

  const UTDBannedException([
    this.message = 'User is banned',
    this.statusCode = 403,
  ]);

  @override
  String toString() => 'UTDBannedException($statusCode): $message';
}
