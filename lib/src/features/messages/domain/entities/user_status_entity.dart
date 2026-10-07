/// Presence + last-seen for a 1:1 peer (from GET /user-status/{id}).
/// [online] is the legacy 0/1 flag; [lastSeen] is an ISO-8601 UTC string used to
/// render the relative "آخر ظهور ..." label when the peer is offline.
class UserStatusEntity {
  const UserStatusEntity({required this.online, this.lastSeen});

  final int online;
  final String? lastSeen;
}
