/// Role of the current/other member inside a group. Backed by the string the
/// API returns (`owner` | `admin` | `member`). Kept as a value-type enum so the
/// wire value round-trips losslessly and unknown values degrade to [member].
enum GroupRole {
  owner('owner'),
  admin('admin'),
  member('member');

  final String value;
  const GroupRole(this.value);

  static GroupRole fromString(String? value) {
    switch (value) {
      case 'owner':
        return GroupRole.owner;
      case 'admin':
        return GroupRole.admin;
      default:
        return GroupRole.member;
    }
  }
}

/// Membership lifecycle state on `chat_room_members.status`.
enum GroupMemberStatus {
  active('active'),
  muted('muted'),
  left('left'),
  kicked('kicked'),
  banned('banned');

  final String value;
  const GroupMemberStatus(this.value);

  static GroupMemberStatus fromString(String? value) {
    switch (value) {
      case 'muted':
        return GroupMemberStatus.muted;
      case 'left':
        return GroupMemberStatus.left;
      case 'kicked':
        return GroupMemberStatus.kicked;
      case 'banned':
        return GroupMemberStatus.banned;
      default:
        return GroupMemberStatus.active;
    }
  }
}

/// Discovery/visibility of the group.
enum GroupPrivacy {
  public('public'),
  private('private');

  final String value;
  const GroupPrivacy(this.value);

  static GroupPrivacy fromString(String? value) {
    return value == 'private' ? GroupPrivacy.private : GroupPrivacy.public;
  }
}

/// How a non-member can join the group. Wire values match the backend
/// vocabulary (`open` | `approval` | `invite_only`); unknown values degrade to
/// [open].
enum GroupJoinPolicy {
  open('open'),
  approval('approval'),
  inviteOnly('invite_only');

  final String value;
  const GroupJoinPolicy(this.value);

  static GroupJoinPolicy fromString(String? value) {
    switch (value) {
      case 'approval':
        return GroupJoinPolicy.approval;
      case 'invite_only':
        return GroupJoinPolicy.inviteOnly;
      default:
        return GroupJoinPolicy.open;
    }
  }
}
