part of 'group_members_bloc.dart';

class GroupMembersState extends Equatable {
  final List<GroupMemberEntity> members;
  final RequestState reqState;
  final RequestState actionState;
  final String message;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  /// Set once when the members fetch 404s — the group was deleted server-side.
  /// Distinct from [reqState] == empty (a live group with no members yet) so the
  /// screen can pop + clean the stale drift row instead of showing "no members".
  final bool groupGone;

  const GroupMembersState({
    this.members = const [],
    this.reqState = RequestState.idle,
    this.actionState = RequestState.idle,
    this.message = '',
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.groupGone = false,
  });

  List<GroupMemberEntity> get owners =>
      members.where((m) => m.role == GroupRole.owner).toList();

  List<GroupMemberEntity> get admins =>
      members.where((m) => m.role == GroupRole.admin).toList();

  List<GroupMemberEntity> get plainMembers =>
      members.where((m) => m.role == GroupRole.member).toList();

  GroupMembersState copyWith({
    List<GroupMemberEntity>? members,
    RequestState? reqState,
    RequestState? actionState,
    String? message,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? groupGone,
  }) {
    return GroupMembersState(
      members: members ?? this.members,
      reqState: reqState ?? this.reqState,
      actionState: actionState ?? this.actionState,
      message: message ?? this.message,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      groupGone: groupGone ?? this.groupGone,
    );
  }

  @override
  List<Object?> get props => [
        members,
        reqState,
        actionState,
        message,
        currentPage,
        lastPage,
        isLoadingMore,
        groupGone,
      ];
}
