import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';

class GroupEntity extends Equatable {
  final int id;
  final int chatRoomId;
  final String name;
  final String avatar;
  final int ownerId;
  final GroupRole myRole;
  final int membersCount;
  final int unreadCount;
  final GroupPrivacy privacy;
  final GroupJoinPolicy joinPolicy;
  final bool onlyAdminsPost;
  final int maxMembers;
  final DateTime? mutedUntil;
  final String? inviteToken;

  const GroupEntity({
    required this.id,
    required this.chatRoomId,
    this.name = '',
    this.avatar = '',
    this.ownerId = 0,
    this.myRole = GroupRole.member,
    this.membersCount = 0,
    this.unreadCount = 0,
    this.privacy = GroupPrivacy.public,
    this.joinPolicy = GroupJoinPolicy.open,
    this.onlyAdminsPost = false,
    this.maxMembers = 256,
    this.mutedUntil,
    this.inviteToken,
  });

  bool get isMuted => mutedUntil != null && mutedUntil!.isAfter(DateTime.now());

  GroupEntity copyWith({
    int? id,
    int? chatRoomId,
    String? name,
    String? avatar,
    int? ownerId,
    GroupRole? myRole,
    int? membersCount,
    int? unreadCount,
    GroupPrivacy? privacy,
    GroupJoinPolicy? joinPolicy,
    bool? onlyAdminsPost,
    int? maxMembers,
    DateTime? mutedUntil,
    bool clearMutedUntil = false,
    String? inviteToken,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      ownerId: ownerId ?? this.ownerId,
      myRole: myRole ?? this.myRole,
      membersCount: membersCount ?? this.membersCount,
      unreadCount: unreadCount ?? this.unreadCount,
      privacy: privacy ?? this.privacy,
      joinPolicy: joinPolicy ?? this.joinPolicy,
      onlyAdminsPost: onlyAdminsPost ?? this.onlyAdminsPost,
      maxMembers: maxMembers ?? this.maxMembers,
      mutedUntil: clearMutedUntil ? null : (mutedUntil ?? this.mutedUntil),
      inviteToken: inviteToken ?? this.inviteToken,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatRoomId,
        name,
        avatar,
        ownerId,
        myRole,
        membersCount,
        unreadCount,
        privacy,
        joinPolicy,
        onlyAdminsPost,
        maxMembers,
        mutedUntil,
        inviteToken,
      ];
}
