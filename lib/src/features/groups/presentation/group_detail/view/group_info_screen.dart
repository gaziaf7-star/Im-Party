import 'dart:io';

import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/domain/entities/group_permissions.dart';
import 'package:general/src/features/groups/presentation/group_detail/bloc/group_detail_bloc.dart';
import 'package:general/src/features/groups/presentation/groups_list/bloc/groups_list_bloc.dart';
import 'package:general/src/features/groups/presentation/widgets/group_confirm_dialog.dart';
import 'package:general/src/features/groups/presentation/widgets/group_form_fields.dart';

class GroupInfoScreen extends StatefulWidget {
  final GroupEntity group;

  const GroupInfoScreen({super.key, required this.group});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  late final TextEditingController _nameController;

  File? _avatar;
  late GroupPrivacy _privacy;
  late GroupJoinPolicy _joinPolicy;
  late bool _onlyAdminsPost;

  @override
  void initState() {
    super.initState();
    final g = widget.group;
    _nameController = TextEditingController(text: g.name);
    _privacy = g.privacy;
    _joinPolicy = g.joinPolicy;
    _onlyAdminsPost = g.onlyAdminsPost;
    di<GroupDetailBloc>().add(LoadGroupDetailEvent(g.id));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// True once the form has been seeded from a server-loaded group, so a fresh
  /// detail load only re-seeds the toggles the FIRST time real data arrives —
  /// never on every rebuild. Re-hydrating in `build` previously reset _privacy /
  /// _joinPolicy / _onlyAdminsPost from state.group on the rebuild that a toggle's
  /// setState triggered, wiping the user's choice before they hit Save (so the
  /// setting "wouldn't change" and the old value was POSTed). Hydration now runs
  /// exactly once, from the listener, when server data lands.
  bool _hydratedFromServer = false;

  void _hydrate(GroupEntity g) {
    if (_nameController.text.isEmpty) _nameController.text = g.name;
    _privacy = g.privacy;
    _joinPolicy = g.joinPolicy;
    _onlyAdminsPost = g.onlyAdminsPost;
  }

  Future<void> _pickAvatar() async {
    final picked =
        await Methods.pickImageSafely(ImagePicker(), source: ImageSource.gallery);
    if (picked != null) setState(() => _avatar = File(picked.path));
  }

  void _save(GroupEntity group) {
    di<GroupDetailBloc>().add(
      UpdateGroupEvent(
        UpdateGroupParams(
          groupId: group.id,
          name: _nameController.text.trim(),
          avatar: _avatar,
          privacy: _privacy,
          joinPolicy: _joinPolicy,
          onlyAdminsPost: _onlyAdminsPost,
        ),
      ),
    );
  }

  Future<void> _leave(GroupEntity group) async {
    final ok = await showGroupConfirmDialog(
      context,
      title: StringManager.leaveGroup.tr(),
      message: StringManager.confirmLeaveGroup.tr(),
      confirmText: StringManager.leaveGroup.tr(),
    );
    if (ok) di<GroupDetailBloc>().add(LeaveGroupEvent(group.id));
  }

  Future<void> _delete(GroupEntity group) async {
    final ok = await showGroupConfirmDialog(
      context,
      title: StringManager.deleteGroup.tr(),
      message: StringManager.confirmDeleteGroup.tr(),
      confirmText: StringManager.deleteGroup.tr(),
    );
    if (ok) di<GroupDetailBloc>().add(DeleteGroupEvent(group.id));
  }

  void _handleAction(GroupDetailState state) {
    final group = state.group ?? widget.group;
    switch (state.lastAction) {
      case GroupAction.updated:
        Methods.showToast(context, message: StringManager.groupUpdated.tr());
        di<GroupsListBloc>().add(UpsertGroupLocallyEvent(group));
        break;
      case GroupAction.deleted:
        Methods.showToast(context, message: StringManager.groupDeleted.tr());
        di<GroupsListBloc>().add(RemoveGroupLocallyEvent(group.id));
        // Drop the drift room so the unified (offline-first) chats list, which
        // renders straight off RoomsDao.watchRoomsWithLast, loses the row too —
        // the GroupsListBloc only owns the in-memory groups tab.
        di<RoomsDao>().deleteRoomByServerRoomId(group.chatRoomId);
        Navigator.pop(context);
        break;
      case GroupAction.left:
        Methods.showToast(context, message: StringManager.leftGroup.tr());
        di<GroupsListBloc>().add(RemoveGroupLocallyEvent(group.id));
        di<RoomsDao>().deleteRoomByServerRoomId(group.chatRoomId);
        Navigator.pop(context);
        break;
      case GroupAction.ownershipTransferred:
        Methods.showToast(
            context, message: StringManager.ownershipTransferred.tr());
        di<GroupDetailBloc>().add(LoadGroupDetailEvent(group.id));
        break;
      case GroupAction.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBg,
      appBar: AppBarWidget(
        title: StringManager.groupInfo.tr(),
        backgroundColor: ColorManager.scaffoldBg,
      ),
      body: BlocConsumer<GroupDetailBloc, GroupDetailState>(
        bloc: di<GroupDetailBloc>(),
        listenWhen: (prev, curr) =>
            prev.lastAction != curr.lastAction ||
            (curr.actionState.isError && prev.actionState != curr.actionState) ||
            (prev.group != curr.group),
        listener: (context, state) {
          // Seed the editable toggles ONCE, the first time server data lands, so
          // a later toggle's setState rebuild can never reset the user's choice.
          if (!_hydratedFromServer && state.group != null) {
            _hydratedFromServer = true;
            _hydrate(state.group!);
          }
          if (state.actionState.isError) {
            Methods.showToast(context, isError: true, message: state.message);
            return;
          }
          _handleAction(state);
        },
        builder: (context, state) {
          final group = state.group ?? widget.group;
          final perms = GroupPermissions.fromGroup(group);
          final canEdit = perms.canEditGroup;

          return SingleChildScrollView(
            padding: context.paddingAll(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GroupAvatarPicker(
                    avatarFile: _avatar,
                    avatarUrl: group.avatar,
                    onTap: canEdit ? _pickAvatar : () {},
                  ),
                ),
                16.hBox,
                if (canEdit)
                  GroupNameField(controller: _nameController)
                else
                  Center(
                    child: TextWidget(
                      group.name,
                      isTranslate: false,
                      style: context.titleLarge.w600
                          .colorExt(ColorManager.textPrimary),
                    ),
                  ),
                8.hBox,
                Center(
                  child: TextWidget(
                    '${group.membersCount} ${StringManager.membersCount.tr()}',
                    isTranslate: false,
                    style: context.bodyMedium
                        .colorExt(ColorManager.greyTextColor),
                  ),
                ),
                20.hBox,
                _SectionTile(
                  icon: Icons.people_outline,
                  title: StringManager.groupMembers.tr(),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 14.h, color: ColorManager.greyTextColor),
                  onTap: () => context.pushNamedRoute(
                    Routes.groupMembersScreen,
                    arguments: group,
                  ),
                ),
                if (canEdit) ...[
                  20.hBox,
                  TextWidget(
                    StringManager.groupSettings.tr(),
                    style: context.bodyMedium.w600
                        .colorExt(ColorManager.textPrimary),
                  ),
                  12.hBox,
                  GroupPrivacySelector(
                    privacy: _privacy,
                    onChanged: (v) => setState(() => _privacy = v),
                  ),
                  16.hBox,
                  GroupJoinPolicySelector(
                    joinPolicy: _joinPolicy,
                    onChanged: (v) => setState(() => _joinPolicy = v),
                  ),
                  16.hBox,
                  GroupSwitchTile(
                    title: StringManager.onlyAdminsPost.tr(),
                    value: _onlyAdminsPost,
                    onChanged: (v) => setState(() => _onlyAdminsPost = v),
                  ),
                  24.hBox,
                  MainButton(
                    title: StringManager.saveChanges.tr(),
                    height: 50,
                    titleSize: 16,
                    buttonColor: ColorManager.primary,
                    isLoading: state.actionState.isLoading,
                    onTap: () => _save(group),
                  ),
                ],
                24.hBox,
                _DangerTile(
                  title: StringManager.leaveGroup.tr(),
                  onTap: () => _leave(group),
                ),
                if (perms.canDelete) ...[
                  8.hBox,
                  _DangerTile(
                    title: StringManager.deleteGroup.tr(),
                    onTap: () => _delete(group),
                  ),
                ],
                20.hBox,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SectionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: 12.radius,
      child: Container(
        padding: context.paddingSymmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: 12.radius,
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorManager.primary, size: 22.h),
            12.wBox,
            Expanded(
              child: TextWidget(
                title,
                isTranslate: false,
                style: context.bodyMedium.w600
                    .colorExt(ColorManager.textPrimary),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _DangerTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _DangerTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: 12.radius,
      child: Container(
        width: double.infinity,
        padding: context.paddingSymmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: 12.radius,
        ),
        child: TextWidget(
          title,
          isTranslate: false,
          style: context.bodyMedium.w600.colorExt(ColorManager.red),
        ),
      ),
    );
  }
}
