// Models for the UTD Stream Engine role-management feature.
//
// Covers the REST change-role endpoint
// (`PUT /api/v1/rooms/{room}/participants/{target}/role`), the list-by-role
// endpoint (`GET /api/v1/rooms/{room}/participants/by-role`), and the realtime
// `_role_change` data message.
//
// Roles, lowest → highest privilege: visitor, audience, guest, admin, host.
// The room OWNER (one identity per room) is identified by `owner_identity`,
// NOT by these roles — and only the owner may change roles.

/// The known engine roles, lowest → highest privilege.
enum UTDRole { visitor, audience, guest, admin, host }

/// Serializes a [UTDRole] to its wire string (e.g. `UTDRole.admin` → `'admin'`).
String utdRoleToString(UTDRole role) => role.name;

/// Parses a wire role string to a [UTDRole]; returns `null` if unknown.
UTDRole? utdRoleFromString(String? value) {
  switch (value) {
    case 'visitor':
      return UTDRole.visitor;
    case 'audience':
      return UTDRole.audience;
    case 'guest':
      return UTDRole.guest;
    case 'admin':
      return UTDRole.admin;
    case 'host':
      return UTDRole.host;
  }
  return null;
}

/// Reads the participant id from an engine payload, tolerating the key-name
/// inconsistencies across engine endpoints.
///
/// The engine does not use a single identity key everywhere: seat occupants
/// arrive as `occupant_identity` (see [seat_model.dart]), while role payloads
/// are expected to use `identity`. Accepting the known aliases here means a
/// naming difference on the wire can never silently drop a role update (which
/// would make a promotion/demotion appear to do nothing for everyone but the
/// acting host). Returns `''` when no known key is present.
String _readIdentity(Map<String, dynamic> json) =>
    (json['identity'] ??
            json['occupant_identity'] ??
            json['participant_identity'] ??
            json['user_id']) as String? ??
    '';

/// Attributes returned for a participant by list-by-role (mirrors the
/// participant attributes the client set: `fr`, `frt`, `avatar`, `cn`).
/// Fields are empty strings if the user is not currently connected.
class UTDRoleUserAttributes {
  final String? fr;
  final String? frt;
  final String? avatar;
  final String? cn;

  const UTDRoleUserAttributes({this.fr, this.frt, this.avatar, this.cn});

  factory UTDRoleUserAttributes.fromJson(Map<String, dynamic> json) {
    return UTDRoleUserAttributes(
      fr: json['fr'] as String?,
      frt: json['frt'] as String?,
      avatar: json['avatar'] as String?,
      cn: json['cn'] as String?,
    );
  }
}

/// Result of `PUT .../role` → `{ identity, role, previous_role }`.
class UTDRoleChangeResult {
  final String identity;
  final String role;
  final String? previousRole;

  const UTDRoleChangeResult({
    required this.identity,
    required this.role,
    this.previousRole,
  });

  factory UTDRoleChangeResult.fromJson(Map<String, dynamic> json) {
    return UTDRoleChangeResult(
      identity: _readIdentity(json),
      role: json['role'] as String? ?? '',
      previousRole: json['previous_role'] as String?,
    );
  }
}

/// A single participant row from `GET .../participants/by-role`.
class UTDRoleUser {
  final String identity;
  final String? name;
  final String? role;
  final UTDRoleUserAttributes? attributes;

  const UTDRoleUser({
    required this.identity,
    this.name,
    this.role,
    this.attributes,
  });

  factory UTDRoleUser.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    return UTDRoleUser(
      identity: _readIdentity(json),
      name: json['name'] as String?,
      role: json['role'] as String?,
      attributes: attrs is Map<String, dynamic>
          ? UTDRoleUserAttributes.fromJson(attrs)
          : null,
    );
  }
}

/// One page of the paginated list-by-role response.
class UTDRoleListPage {
  final List<UTDRoleUser> data;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  const UTDRoleListPage({
    required this.data,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory UTDRoleListPage.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? const [];
    final pagination =
        (json['pagination'] as Map<String, dynamic>?) ?? const {};
    final parsed =
        list.whereType<Map<String, dynamic>>().map(UTDRoleUser.fromJson).toList();
    return UTDRoleListPage(
      data: parsed,
      page: (pagination['page'] as num?)?.toInt() ?? 1,
      perPage: (pagination['per_page'] as num?)?.toInt() ?? parsed.length,
      total: (pagination['total'] as num?)?.toInt() ?? parsed.length,
      totalPages: (pagination['total_pages'] as num?)?.toInt() ?? 1,
    );
  }
}

/// The realtime `_role_change` data message, broadcast to ALL participants
/// whenever a role changes.
///
/// ⚠️ This message is sent from the server API, so in the LiveKit
/// `DataReceivedEvent` the `participant` field is `null`. Identify the affected
/// user from [identity], never from the event sender.
class UTDRoleChangeEvent {
  final String identity;
  final String role;
  final String? previousRole;

  const UTDRoleChangeEvent({
    required this.identity,
    required this.role,
    this.previousRole,
  });

  factory UTDRoleChangeEvent.fromData(Map<String, dynamic> data) {
    return UTDRoleChangeEvent(
      identity: _readIdentity(data),
      role: data['role'] as String? ?? '',
      previousRole: data['previous_role'] as String?,
    );
  }
}
