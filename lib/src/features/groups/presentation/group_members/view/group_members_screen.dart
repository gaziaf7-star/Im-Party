import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/domain/entities/group_permissions.dart';
import 'package:general/src/features/groups/presentation/group_detail/bloc/group_detail_bloc.dart';
import 'package:general/src/features/groups/presentation/group_members/bloc/group_members_bloc.dart';
import 'package:general/src/features/groups/presentation/group_members/view/widgets/group_member_card.dart';
import 'package:general/src/features/groups/presentation/group_members/view/widgets/member_action_sheet.dart';
import 'package:general/src/features/groups/presentation/widgets/group_confirm_dialog.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_state.dart';

class GroupMembersScreen extends StatefulWidget {
  final GroupEntity group;

  const GroupMembersScreen({super.key, required this.group});

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  final ScrollController _scrollController = ScrollController();

  late final GroupPermissions _permissions;

  @override
  void initState() {
    super.initState();
    _permissions = GroupPermissions.fromGroup(widget.group);
    di<GroupMembersBloc>().add(FetchMembersEvent(widget.group.id));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      di<GroupMembersBloc>().add(LoadMoreMembersEvent(widget.group.id));
    }
  }

  Future<void> _openActions(GroupMemberEntity member) async {
    final action = await showMemberActionSheet(
      context,
      member: member,
      permissions: _permissions,
    );
    if (action == null || !mounted) return;
    await _dispatch(action, member);
  }

  Future<void> _dispatch(MemberAction action, GroupMemberEntity member) async {
    final groupId = widget.group.id;
    switch (action.type) {
      case MemberActionType.promote:
        di<GroupMembersBloc>()
            .add(PromoteMemberEvent(groupId: groupId, userId: member.userId));
        break;
      case MemberActionType.demote:
        di<GroupMembersBloc>()
            .add(DemoteMemberEvent(groupId: groupId, userId: member.userId));
        break;
      case MemberActionType.mute:
        di<GroupMembersBloc>().add(MuteMemberEvent(
          groupId: groupId,
          userId: member.userId,
          durationMinutes: action.muteDurationMinutes,
        ));
        break;
      case MemberActionType.kick:
        final ok = await showGroupConfirmDialog(
          context,
          title: StringManager.kickMember.tr(),
          message: StringManager.confirmKickMember.tr(),
          confirmText: StringManager.kickMember.tr(),
        );
        if (ok) {
          di<GroupMembersBloc>()
              .add(KickMemberEvent(groupId: groupId, userId: member.userId));
        }
        break;
      case MemberActionType.transferOwnership:
        final ok = await showGroupConfirmDialog(
          context,
          title: StringManager.transferOwnership.tr(),
          message: StringManager.confirmTransferOwnership.tr(),
          confirmText: StringManager.transferOwnership.tr(),
        );
        if (ok) {
          di<GroupDetailBloc>().add(
            TransferOwnershipEvent(
              TransferOwnershipParams(
                groupId: groupId,
                newOwnerId: member.userId,
              ),
            ),
          );
        }
        break;
    }
  }

  /// The group was deleted server-side (members fetch 404'd): purge the stale
  /// drift room so the unified chats list (rendered off RoomsDao) drops it, tell
  /// the user and back out to the chats list.
  void _handleGroupGone() {
    di<RoomsDao>().deleteRoomByServerRoomId(widget.group.chatRoomId);
    if (!mounted) return;
    Methods.showToast(context,
        isError: true, message: StringManager.groupNoLongerExists.tr());
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _openAddMembers() async {
    final existingIds = di<GroupMembersBloc>()
        .state
        .members
        .map((m) => m.userId)
        .toSet();
    final selected = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorManager.scaffoldBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddMembersSheet(excludeUserIds: existingIds),
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    di<GroupMembersBloc>()
        .add(AddMembersEvent(groupId: widget.group.id, userIds: selected));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBg,
      appBar: AppBarWidget(
        title: StringManager.groupMembers.tr(),
        backgroundColor: ColorManager.scaffoldBg,
      ),
      floatingActionButton: _permissions.canManageMembers
          ? FloatingActionButton(
              backgroundColor: ColorManager.primary,
              onPressed: _openAddMembers,
              child: Icon(Icons.person_add,
                  color: ColorManager.buttonTextColor),
            )
          : null,
      body: BlocConsumer<GroupMembersBloc, GroupMembersState>(
        bloc: di<GroupMembersBloc>(),
        listenWhen: (prev, curr) =>
            (prev.actionState != curr.actionState && curr.actionState.isError) ||
            (!prev.groupGone && curr.groupGone),
        listener: (context, state) {
          if (state.groupGone) {
            _handleGroupGone();
            return;
          }
          if (state.actionState.isError) {
            Methods.showToast(context, isError: true, message: state.message);
          }
        },
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.reqState,
            title: StringManager.noMembersYet,
            subTitle: StringManager.noMembersYetMsg,
            onTap: () =>
                di<GroupMembersBloc>().add(FetchMembersEvent(widget.group.id)),
            child: RefreshIndicatorWidget(
              onRefresh: () async => di<GroupMembersBloc>()
                  .add(FetchMembersEvent(widget.group.id)),
              child: _MembersList(
                state: state,
                permissions: _permissions,
                scrollController: _scrollController,
                onMemberTap: _openActions,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MembersList extends StatelessWidget {
  final GroupMembersState state;
  final GroupPermissions permissions;
  final ScrollController scrollController;
  final void Function(GroupMemberEntity) onMemberTap;

  const _MembersList({
    required this.state,
    required this.permissions,
    required this.scrollController,
    required this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];

    void addSection(String title, List<GroupMemberEntity> members) {
      if (members.isEmpty) return;
      sections.add(_SectionHeader(title: title, count: members.length));
      sections.addAll(members.map(
        (m) => GroupMemberCard(
          member: m,
          canManage: permissions.canManageMembers,
          onTap: () => onMemberTap(m),
        ),
      ));
    }

    addSection(StringManager.groupOwner.tr(), state.owners);
    addSection(StringManager.groupAdmins.tr(), state.admins);
    addSection(StringManager.groupMembers.tr(), state.plainMembers);

    if (state.isLoadingMore) {
      sections.add(Padding(
        padding: context.paddingAll(12),
        child: const LoadingWidget(),
      ));
    }

    return ListView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.paddingSymmetric(vertical: 8),
      children: sections,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingOnly(start: 16, end: 16, top: 14, bottom: 6),
      child: TextWidget(
        '$title ($count)',
        isTranslate: false,
        style: context.bodyMedium.w600
            .colorExt(ColorManager.greyTextColor)
            .size(12),
      ),
    );
  }
}

/// Friend multi-select sheet opened from the add-members FAB. Lists the
/// caller's friends (minus those already in the group via [excludeUserIds]) and
/// pops back the selected user ids; null/empty on dismiss.
class _AddMembersSheet extends StatefulWidget {
  final Set<int> excludeUserIds;

  const _AddMembersSheet({required this.excludeUserIds});

  @override
  State<_AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends State<_AddMembersSheet> {
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    if (!di<GetFollowerOrFollowingBloc>().state.friendsRequestState.isLoaded) {
      di<GetFollowerOrFollowingBloc>().add(const GetFriendsEvent(loading: true));
    }
  }

  void _toggle(int userId) {
    setState(() {
      if (!_selected.add(userId)) _selected.remove(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: context.paddingOnly(start: 16, end: 16, top: 16, bottom: 8),
              child: TextWidget(
                StringManager.addMembers,
                style: context.bodyLarge.w600.colorExt(ColorManager.textPrimary),
              ),
            ),
            Expanded(
              child: BlocBuilder<GetFollowerOrFollowingBloc,
                  GetFollowerOrFollowingState>(
                bloc: di<GetFollowerOrFollowingBloc>(),
                buildWhen: (prev, curr) =>
                    prev.getFriendsRequest != curr.getFriendsRequest ||
                    prev.getFriends != curr.getFriends,
                builder: (context, state) {
                  final friends = state.getFriends
                      .where((u) =>
                          u.id != null &&
                          !widget.excludeUserIds.contains(u.id))
                      .toList();
                  return HandlingDataWidget(
                    reqState: state.getFriendsRequest,
                    title: StringManager.titleFriend,
                    subTitle: StringManager.subtitleFriend,
                    onTap: () => di<GetFollowerOrFollowingBloc>()
                        .add(const GetFriendsEvent(loading: true)),
                    child: friends.isEmpty
                        ? Center(
                            child: TextWidget(
                              StringManager.noFriends,
                              style: context.bodyLarge
                                  .colorExt(ColorManager.greyTextColor),
                            ),
                          )
                        : ListView.separated(
                            padding: context.paddingSymmetric(vertical: 8),
                            itemCount: friends.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: ColorManager.divider,
                              indent: 75.w,
                            ),
                            itemBuilder: (_, i) {
                              final u = friends[i];
                              final isChecked = _selected.contains(u.id);
                              return InkWell(
                                onTap: () => _toggle(u.id!),
                                child: Padding(
                                  padding: context.paddingSymmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Row(
                                    children: [
                                      UserImage(
                                        borderRadius: 50.radius,
                                        imageSize: 46.h,
                                        image: EndPoints.getImage(
                                            u.profile?.image ?? ''),
                                        displayName: u.name,
                                      ),
                                      12.wBox,
                                      Expanded(
                                        child: GradientName(child: TextWidget(
                                          u.name ?? '',
                                          isTranslate: false,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.bodyLarge
                                              .colorExt(ColorManager.textPrimary)
                                              .w500,
                                        )),
                                      ),
                                      Icon(
                                        isChecked
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: isChecked
                                            ? ColorManager.primary
                                            : ColorManager.greyTextColor,
                                        size: 24.h,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
            Padding(
              padding: context.paddingAll(16),
              child: MainButton(
                title: StringManager.addMembers,
                height: 50,
                titleSize: 16,
                buttonColor: _selected.isEmpty
                    ? ColorManager.greyTextColor
                    : ColorManager.primary,
                onTap: () {
                  if (_selected.isEmpty) return;
                  Navigator.pop(context, _selected.toList());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
