import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/domain/repository/groups_repository.dart';

/// Read-only WhatsApp-style group info page. The editable counterpart is
/// [GroupInfoScreen]; this screen never mutates the group and only surfaces the
/// owner/admin shortcuts through the 3-dots menu.
class GroupViewScreen extends StatefulWidget {
  final GroupEntity group;

  const GroupViewScreen({super.key, required this.group});

  @override
  State<GroupViewScreen> createState() => _GroupViewScreenState();
}

class _GroupViewScreenState extends State<GroupViewScreen> {
  RequestState _reqState = RequestState.idle;
  List<GroupMemberEntity> _members = const [];

  bool get _isManager =>
      widget.group.myRole == GroupRole.owner ||
      widget.group.myRole == GroupRole.admin;

  bool get _membersHidden => widget.group.privacy == GroupPrivacy.public;

  @override
  void initState() {
    super.initState();
    if (!_membersHidden) _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _reqState = RequestState.loading);
    final result = await di<GroupsRepository>()
        .fetchMembers(GroupMembersParams(groupId: widget.group.id));
    if (!mounted) return;
    result.fold(
      (left) {
        // A 404 means the group was deleted server-side; drop the stale drift
        // room, tell the user and leave the (now-broken) screen instead of
        // showing a generic "couldn't load members" error.
        if (left is NotFound) {
          _handleGroupGone();
          return;
        }
        setState(() => _reqState = handleErrorResponse(left));
      },
      (right) {
        final members = right.data ?? const <GroupMemberEntity>[];
        setState(() {
          _members = members;
          _reqState = handleLoadedResponse<List<GroupMemberEntity>>(members);
        });
      },
    );
  }

  /// The group no longer exists on the server: purge the stale drift room (so the
  /// unified chats list, which renders off RoomsDao, drops it) and back out.
  void _handleGroupGone() {
    di<RoomsDao>().deleteRoomByServerRoomId(widget.group.chatRoomId);
    if (!mounted) return;
    Methods.showToast(context,
        isError: true, message: StringManager.groupNoLongerExists.tr());
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _openFullPhoto() {
    if (widget.group.avatar.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: ColorManager.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: 16.radius,
            child: ImageViewWidget(
              url: EndPoints.getImage(widget.group.avatar),
              boxFit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _onMenuSelected(_GroupViewMenu value) {
    switch (value) {
      case _GroupViewMenu.edit:
        // INTEGRATION: navigates to the existing edit screen.
        context.pushNamedRoute(
          Routes.groupInfoScreen,
          arguments: widget.group,
        );
        break;
      case _GroupViewMenu.addMembers:
        context.pushNamedRoute(
          Routes.groupMembersScreen,
          arguments: widget.group,
        );
        break;
      case _GroupViewMenu.copyInvite:
        _copyInviteLink();
        break;
    }
  }

  void _copyInviteLink() {
    final token = widget.group.inviteToken;
    if (token == null || token.isEmpty) {
      Methods.showToast(
        context,
        isError: true,
        message: StringManager.noInviteLinkForGroup.tr(),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: token));
    Methods.showToast(context, message: StringManager.inviteLinkCopied.tr());
  }

  Future<void> _confirmLeave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ColorManager.surfaceCardColor,
        title: TextWidget(
          StringManager.leaveGroup.tr(),
          isTranslate: false,
          style: context.bodyLarge.w600.colorExt(ColorManager.black),
        ),
        content: TextWidget(
          StringManager.confirmLeaveNamedGroup
              .tr(namedArgs: {'name': widget.group.name}),
          isTranslate: false,
          style: context.bodyMedium.colorExt(ColorManager.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: TextWidget(
              StringManager.cancel.tr(),
              isTranslate: false,
              style: context.bodyMedium.colorExt(ColorManager.greyTextColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: TextWidget(
              StringManager.leaveAction.tr(),
              isTranslate: false,
              style:
                  context.bodyMedium.w600.colorExt(ColorManager.redAccount),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final result = await di<GroupsRepository>().leaveGroup(widget.group.id);
    if (!mounted) return;
    result.fold(
      (left) => Methods.showToast(
        context,
        isError: true,
        message: StringManager.leaveGroupFailed.tr(),
      ),
      (_) {
        Methods.showToast(context, message: StringManager.leftGroup.tr());
        // Drop the drift room so the unified chats list (rendered off RoomsDao)
        // loses the row immediately, then pop back to the chats list.
        di<RoomsDao>().deleteRoomByServerRoomId(widget.group.chatRoomId);
        Navigator.of(context).popUntil((r) => r.isFirst);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    return BackgroundImgWidget(
      child: Scaffold(
        backgroundColor: ColorManager.transparent,
        appBar: AppBarWidget(
          title: StringManager.groupInfo.tr(),
          backgroundColor: ColorManager.transparent,
          actions: _isManager
              ? [
                  PopupMenuButton<_GroupViewMenu>(
                    icon: Icon(Icons.more_vert,
                        color: ColorManager.textPrimary, size: 22.h),
                    color: ColorManager.surfaceCardColor,
                    onSelected: _onMenuSelected,
                    itemBuilder: (_) => [
                      _menuItem(
                          _GroupViewMenu.edit, StringManager.editGroup.tr()),
                      _menuItem(_GroupViewMenu.addMembers,
                          StringManager.addMembers.tr()),
                      _menuItem(_GroupViewMenu.copyInvite,
                          StringManager.copyInviteLink.tr()),
                    ],
                  ),
                ]
              : const [SizedBox()],
        ),
        body: SingleChildScrollView(
          padding: context.paddingAll(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _openFullPhoto,
                  child: ClipRRect(
                    borderRadius: 60.radius,
                    child: UserImage(
                      image: group.avatar.isEmpty
                          ? ''
                          : EndPoints.getImage(group.avatar),
                      displayName: group.name,
                      imageSize: 110.w,
                    ),
                  ),
                ),
              ),
              12.hBox,
              Center(
                child: TextWidget(
                  group.name,
                  isTranslate: false,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style:
                      context.titleLarge.w600.colorExt(ColorManager.textPrimary),
                ),
              ),
              6.hBox,
              // Public badge + members count on one line, centered, so the user
              // knows what kind of group they're in at a glance.
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (group.privacy == GroupPrivacy.public) ...[
                      Container(
                        padding: context.paddingSymmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withValues(alpha: 0.12),
                          borderRadius: 12.radius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.public,
                                size: 12.h, color: ColorManager.primary),
                            4.wBox,
                            TextWidget(
                              StringManager.publicGroupLabel.tr(),
                              isTranslate: false,
                              style: context.bodySmall
                                  .colorExt(ColorManager.primary)
                                  .w600
                                  .size(11),
                            ),
                          ],
                        ),
                      ),
                      8.wBox,
                    ],
                    TextWidget(
                      '${group.membersCount} ${StringManager.membersCount.tr()}',
                      isTranslate: false,
                      style: context.bodyMedium
                          .colorExt(ColorManager.greyTextColor),
                    ),
                  ],
                ),
              ),
              // My role badge — surfaces the caller's status in this group
              // without making them hunt for their own row in the members list.
              if (group.myRole != GroupRole.member) ...[
                10.hBox,
                Center(
                  child: Container(
                    padding: context.paddingSymmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (group.myRole == GroupRole.owner
                              ? ColorManager.primary
                              : ColorManager.blue)
                          .withValues(alpha: 0.15),
                      borderRadius: 16.radius,
                    ),
                    child: TextWidget(
                      group.myRole == GroupRole.owner
                          ? StringManager.youAreOwner.tr()
                          : StringManager.youAreAdmin.tr(),
                      isTranslate: false,
                      style: context.bodyMedium
                          .colorExt(group.myRole == GroupRole.owner
                              ? ColorManager.primary
                              : ColorManager.blue)
                          .w600
                          .size(12),
                    ),
                  ),
                ),
              ],
              24.hBox,
              TextWidget(
                StringManager.groupMembers.tr(),
                isTranslate: false,
                style:
                    context.bodyMedium.w600.colorExt(ColorManager.textPrimary),
              ),
              12.hBox,
              _buildMembersSection(),
              20.hBox,
              // Leave button at the bottom — owner can't simply leave (must
              // transfer ownership first), so the row hides for them.
              if (group.myRole != GroupRole.owner)
                Center(
                  child: TextButton.icon(
                    onPressed: _confirmLeave,
                    icon: Icon(Icons.logout,
                        color: ColorManager.redAccount, size: 20.h),
                    label: TextWidget(
                      StringManager.leaveGroup.tr(),
                      isTranslate: false,
                      style: context.bodyLarge
                          .colorExt(ColorManager.redAccount)
                          .w600,
                    ),
                  ),
                ),
              16.hBox,
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<_GroupViewMenu> _menuItem(_GroupViewMenu value, String label) {
    return PopupMenuItem<_GroupViewMenu>(
      value: value,
      child: TextWidget(
        label,
        isTranslate: false,
        style: context.bodyMedium.colorExt(ColorManager.textPrimary),
      ),
    );
  }

  Widget _buildMembersSection() {
    if (_membersHidden) {
      return Container(
        width: double.infinity,
        padding: context.paddingSymmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: ColorManager.surfaceCardColor,
          borderRadius: 12.radius,
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline,
                color: ColorManager.greyTextColor, size: 20.h),
            12.wBox,
            Expanded(
              child: TextWidget(
                StringManager.membersHiddenInPublicGroups.tr(),
                isTranslate: false,
                style:
                    context.bodyMedium.colorExt(ColorManager.greyTextColor),
              ),
            ),
          ],
        ),
      );
    }

    if (_reqState.isLoading) {
      return Padding(
        padding: context.paddingAll(20),
        child: const LoadingWidget(),
      );
    }

    if (_reqState.isError || _reqState.isOffline) {
      return Center(
        child: Padding(
          padding: context.paddingAll(16),
          child: TextWidget(
            StringManager.couldNotLoadMembers.tr(),
            isTranslate: false,
            style: context.bodyMedium.colorExt(ColorManager.greyTextColor),
          ),
        ),
      );
    }

    if (_reqState.isEmpty || _members.isEmpty) {
      return Center(
        child: Padding(
          padding: context.paddingAll(16),
          child: TextWidget(
            StringManager.noMembersYet.tr(),
            isTranslate: false,
            style: context.bodyMedium.colorExt(ColorManager.greyTextColor),
          ),
        ),
      );
    }

    // Pin the current user to the top so "أنت + my phone" is the first row
    // — quickly answers "what role am I in this group?" without scrolling.
    final me = MyDataModel.getInstance().id;
    final myPhone = MyDataModel.getInstance().phone ?? '';
    final sorted = [..._members];
    if (me != null && me != 0) {
      final myIndex = sorted.indexWhere((m) => m.userId == me);
      if (myIndex > 0) {
        final mine = sorted.removeAt(myIndex);
        sorted.insert(0, mine);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorManager.surfaceCardColor,
        borderRadius: 12.radius,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: context.paddingSymmetric(vertical: 6),
        itemCount: sorted.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: ColorManager.divider),
        itemBuilder: (_, index) {
          final member = sorted[index];
          final isMe = me != null && me != 0 && member.userId == me;
          return _MemberRow(
            member: member,
            isMe: isMe,
            myPhone: isMe ? myPhone : '',
          );
        },
      ),
    );
  }
}

enum _GroupViewMenu { edit, addMembers, copyInvite }

class _MemberRow extends StatelessWidget {
  final GroupMemberEntity member;
  final bool isMe;
  final String myPhone;

  const _MemberRow({
    required this.member,
    this.isMe = false,
    this.myPhone = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserImage(
            image:
                member.avatar.isEmpty ? '' : EndPoints.getImage(member.avatar),
            displayName: member.name,
            imageSize: 46.w,
          ),
          12.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: GradientName(child: TextWidget(
                        member.name,
                        isTranslate: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // Row sits on a white card, so use a dark color.
                        style:
                            context.bodyMedium.w600.colorExt(ColorManager.textPrimary),
                      )),
                    ),
                    if (isMe) ...[
                      6.wBox,
                      Container(
                        padding: context.paddingSymmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorManager.primary,
                          borderRadius: 10.radius,
                        ),
                        child: TextWidget(
                          StringManager.you.tr(),
                          isTranslate: false,
                          style: context.bodySmall
                              .colorExt(ColorManager.buttonTextColor)
                              .size(10)
                              .w600,
                        ),
                      ),
                    ],
                  ],
                ),
                if (isMe && myPhone.isNotEmpty) ...[
                  2.hBox,
                  TextWidget(
                    myPhone,
                    isTranslate: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodySmall.colorExt(
                      ColorManager.greyTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _RoleChip(role: member.role),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final GroupRole role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == GroupRole.member) return const SizedBox.shrink();
    final isOwner = role == GroupRole.owner;
    final label =
        isOwner ? StringManager.groupOwner.tr() : StringManager.groupAdmin.tr();
    final color = isOwner ? ColorManager.primary : ColorManager.blue;
    return Container(
      padding: context.paddingSymmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: 20.radius,
      ),
      child: TextWidget(
        label,
        isTranslate: false,
        style: context.bodyMedium.w600.colorExt(color).size(11),
      ),
    );
  }
}
