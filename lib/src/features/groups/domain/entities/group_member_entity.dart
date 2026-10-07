import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';

class GroupMemberEntity extends Equatable {
  final int userId;
  final String name;
  final String avatar;
  final GroupRole role;
  final GroupMemberStatus status;
  final DateTime? mutedUntil;
  final int lastReadSeq;
  final bool isOnline;

  const GroupMemberEntity({
    required this.userId,
    this.name = '',
    this.avatar = '',
    this.role = GroupRole.member,
    this.status = GroupMemberStatus.active,
    this.mutedUntil,
    this.lastReadSeq = 0,
    this.isOnline = false,
  });

  bool get isMuted =>
      status == GroupMemberStatus.muted ||
      (mutedUntil != null && mutedUntil!.isAfter(DateTime.now()));

  GroupMemberEntity copyWith({
    int? userId,
    String? name,
    String? avatar,
    GroupRole? role,
    GroupMemberStatus? status,
    DateTime? mutedUntil,
    bool clearMutedUntil = false,
    int? lastReadSeq,
    bool? isOnline,
  }) {
    return GroupMemberEntity(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      status: status ?? this.status,
      mutedUntil: clearMutedUntil ? null : (mutedUntil ?? this.mutedUntil),
      lastReadSeq: lastReadSeq ?? this.lastReadSeq,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        name,
        avatar,
        role,
        status,
        mutedUntil,
        lastReadSeq,
        isOnline,
      ];
}
