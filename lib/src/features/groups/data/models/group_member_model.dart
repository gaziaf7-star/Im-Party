import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';

class GroupMemberModel extends GroupMemberEntity {
  const GroupMemberModel({
    required super.userId,
    super.name,
    super.avatar,
    super.role,
    super.status,
    super.mutedUntil,
    super.lastReadSeq,
    super.isOnline,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final mutedRaw = parseValue<String>(json['muted_until'], '');
    return GroupMemberModel(
      userId: parseValue<int>(json['user_id'] ?? json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      avatar: parseValue<String>(json['avatar'] ?? json['image'], ''),
      role: GroupRole.fromString(parseValue<String>(json['role'], 'member')),
      status: GroupMemberStatus.fromString(
          parseValue<String>(json['status'], 'active')),
      mutedUntil: mutedRaw.isEmpty ? null : DateTime.tryParse(mutedRaw),
      lastReadSeq: parseValue<int>(json['last_read_seq'], 0),
      isOnline: parseValue<bool>(json['is_online'] ?? json['online'], false),
    );
  }
}
