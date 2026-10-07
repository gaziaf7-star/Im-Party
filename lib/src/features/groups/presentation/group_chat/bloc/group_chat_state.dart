part of 'group_chat_bloc.dart';

class GroupChatState extends Equatable {
  /// The group being viewed.
  final GroupEntity group;

  /// Resolved local drift room id (0 until the conversation is opened).
  final int roomLocalId;

  /// Newest-first window of messages from drift (pending rows sort to the top).
  final List<Message> messages;

  /// Members (for read-receipt names + per-member read seqs). Empty until loaded.
  final List<GroupMemberEntity> members;

  /// Initial open / sync state for the empty + error placeholders.
  final RequestState reqState;

  /// True while an older keyset page is being fetched.
  final bool isLoadingOlder;

  /// True once the top of history is reached (no more older pages).
  final bool reachedTop;

  /// Current reply target, if any.
  final Message? replyTo;

  final String message;

  const GroupChatState({
    required this.group,
    this.roomLocalId = 0,
    this.messages = const [],
    this.members = const [],
    this.reqState = RequestState.idle,
    this.isLoadingOlder = false,
    this.reachedTop = false,
    this.replyTo,
    this.message = '',
  });

  GroupChatState copyWith({
    GroupEntity? group,
    int? roomLocalId,
    List<Message>? messages,
    List<GroupMemberEntity>? members,
    RequestState? reqState,
    bool? isLoadingOlder,
    bool? reachedTop,
    Message? replyTo,
    bool clearReply = false,
    String? message,
  }) {
    return GroupChatState(
      group: group ?? this.group,
      roomLocalId: roomLocalId ?? this.roomLocalId,
      messages: messages ?? this.messages,
      members: members ?? this.members,
      reqState: reqState ?? this.reqState,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      reachedTop: reachedTop ?? this.reachedTop,
      replyTo: clearReply ? null : (replyTo ?? this.replyTo),
      message: message ?? this.message,
    );
  }

  /// Cosmetic permission gate derived from the current user's role.
  GroupPermissions get permissions => GroupPermissions.fromGroup(group);

  @override
  List<Object?> get props => [
        group,
        roomLocalId,
        messages,
        members,
        reqState,
        isLoadingOlder,
        reachedTop,
        replyTo,
        message,
      ];
}
