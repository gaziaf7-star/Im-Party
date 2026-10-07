import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.chatRoomId,
    super.name,
    super.avatar,
    super.ownerId,
    super.myRole,
    super.membersCount,
    super.unreadCount,
    super.privacy,
    super.joinPolicy,
    super.onlyAdminsPost,
    super.maxMembers,
    super.mutedUntil,
    super.inviteToken,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final mutedRaw = parseValue<String>(json['muted_until'], '');
    return GroupModel(
      id: parseValue<int>(json['id'], 0),
      chatRoomId: parseValue<int>(json['chat_room_id'] ?? json['room_id'], 0),
      name: parseValue<String>(json['name'], ''),
      avatar: parseValue<String>(json['avatar'] ?? json['image'], ''),
      ownerId: parseValue<int>(json['owner_id'], 0),
      myRole: GroupRole.fromString(parseValue<String>(json['my_role'], 'member')),
      membersCount:
          parseValue<int>(json['members_count'] ?? json['member_count'], 0),
      unreadCount: parseValue<int>(json['unread_count'], 0),
      privacy: GroupPrivacy.fromString(
          parseValue<String>(json['privacy'], 'public')),
      joinPolicy: GroupJoinPolicy.fromString(
          parseValue<String>(json['join_policy'], 'open')),
      onlyAdminsPost: parseValue<bool>(json['only_admins_post'], false),
      maxMembers: parseValue<int>(json['max_members'], 256),
      mutedUntil: mutedRaw.isEmpty ? null : DateTime.tryParse(mutedRaw),
      inviteToken: () {
        final token = parseValue<String>(json['invite_token'], '');
        return token.isEmpty ? null : token;
      }(),
    );
  }
}
