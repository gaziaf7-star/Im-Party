import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';

/// Cosmetic-only derivation of the section 5.2 permission matrix from [myRole].
/// The backend is the real guard on every endpoint (Policy/Gate); this only
/// decides whether to show or hide an action so a member never sees admin-only
/// buttons. Never treat these as authorization.
class GroupPermissions {
  final GroupRole myRole;
  final bool onlyAdminsPost;

  const GroupPermissions({
    required this.myRole,
    this.onlyAdminsPost = false,
  });

  factory GroupPermissions.fromGroup(GroupEntity group) => GroupPermissions(
        myRole: group.myRole,
        onlyAdminsPost: group.onlyAdminsPost,
      );

  bool get _isOwner => myRole == GroupRole.owner;
  bool get _isAdmin => myRole == GroupRole.admin;
  bool get _isOwnerOrAdmin => _isOwner || _isAdmin;

  /// Can post a message. Everyone can, unless `only_admins_post` is on and the
  /// caller is a plain member.
  bool get canPost => _isOwnerOrAdmin || !onlyAdminsPost;

  /// Delete another member's message: owner + admin.
  bool get canDeleteOthers => _isOwnerOrAdmin;

  /// Edit group metadata (name/avatar/privacy/only_admins_post): owner + admin.
  bool get canEditGroup => _isOwnerOrAdmin;

  /// Promote/demote admins: owner only.
  bool get canPromote => _isOwner;
  bool get canDemote => _isOwner;

  /// Transfer ownership: owner only.
  bool get canTransfer => _isOwner;

  /// Delete the whole group permanently: owner only.
  bool get canDelete => _isOwner;

  /// Whether the role row should be tappable at all for management actions.
  bool get canManageMembers => _isOwnerOrAdmin;

  /// Kick a specific [target]. Owner can kick anyone but self; admin can kick
  /// plain members only (not owner, not other admins).
  bool canKick(GroupMemberEntity target) {
    if (target.role == GroupRole.owner) return false;
    if (_isOwner) return true;
    if (_isAdmin) return target.role == GroupRole.member;
    return false;
  }

  /// Mute a specific [target]. Same envelope as kick.
  bool canMute(GroupMemberEntity target) => canKick(target);

  /// Promote a plain member to admin: owner only, target must be a member.
  bool canPromoteMember(GroupMemberEntity target) =>
      _isOwner && target.role == GroupRole.member;

  /// Demote an admin back to member: owner only, target must be an admin.
  bool canDemoteMember(GroupMemberEntity target) =>
      _isOwner && target.role == GroupRole.admin;

  /// Transfer ownership to [target]: owner only, target cannot be self/owner.
  bool canTransferTo(GroupMemberEntity target) =>
      _isOwner && target.role != GroupRole.owner;
}
