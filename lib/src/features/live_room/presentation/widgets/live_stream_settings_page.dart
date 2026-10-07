import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/room/presentation/component/profile/component/utd_role_helper.dart';
import 'package:general/src/features/room/room.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

/// The live stream's own settings page (the audio room-settings screen does not
/// apply to a live show): live-stream admins management.
///
/// Shows the current admins ("مشرفين البث المباشر") with a remove-admin action
/// on each row, and an empty state with an "أضف مشرفين الآن" CTA. Adding opens
/// [_LiveAudiencePicker] — everyone currently in the stream, paginated 10 at a
/// time on scroll, with an assign-admin icon (or remove-admin for existing
/// admins) on each row. Host-only (the engine enforces it server-side too).
class LiveStreamSettingsPage extends StatefulWidget {
  const LiveStreamSettingsPage({super.key});

  @override
  State<LiveStreamSettingsPage> createState() => _LiveStreamSettingsPageState();
}

class _LiveStreamSettingsPageState extends State<LiveStreamSettingsPage> {
  EnterRoomModel get _room => LiveRoomData.instance.room;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    di<AdminRoomBloc>().add(GetAdminsEvent(
      ownerId: _room.ownerId.toString(),
      roomId: _room.id.toString(),
    ));
  }

  Future<void> _openAudiencePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _LiveAudiencePicker(),
    );
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBg,
      appBar: AppBarWidget(
        backgroundColor: ColorManager.headerColor,
        title: StringManager.liveManager,
        titleStyle: context.bodyLarge.bold.colorExt(ColorManager.textPrimary),
        iconColor: ColorManager.iconColor,
        actions: [
          IconButton(
            onPressed: _openAudiencePicker,
            icon: Icon(Icons.person_add_alt_1_outlined,
                color: ColorManager.iconColor),
            tooltip: StringManager.addAdminsNow.tr(),
          ),
        ],
      ),
      body: BlocBuilder<AdminRoomBloc, AdminRoomStates>(
        bloc: di<AdminRoomBloc>(),
        buildWhen: (prev, curr) =>
            prev.adminsReqState != curr.adminsReqState ||
            prev.admins != curr.admins,
        builder: (context, state) {
          if (state.adminsReqState == RequestState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.admins.isEmpty) {
            return _emptyState(context);
          }
          return RefreshIndicatorWidget(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: context.paddingZero(),
              itemCount: state.admins.length,
              separatorBuilder: (_, __) => Container(
                color: ColorManager.grey.withValues(alpha: 0.1),
                height: 1.h,
                width: ScreenUtil().screenWidth,
              ),
              itemBuilder: (context, index) {
                final admin = state.admins[index];
                return ListTile(
                  leading: UserImage(
                    image: admin.profile?.image ?? '',
                    imageSize: 44.h,
                    displayName: admin.name ?? '',
                  ),
                  title: GradientName(child: Text(
                    admin.name ?? '',
                    style: context.bodyMedium.bold
                        .colorExt(ColorManager.textPrimary),
                  )),
                  subtitle: Text(
                    'ID: ${admin.uuid ?? ''}',
                    style: context.bodySmall.colorExt(ColorManager.grey),
                  ),
                  trailing: IconButton(
                    tooltip: StringManager.removeAdmin.tr(),
                    icon: const Icon(Icons.person_remove_alt_1_outlined,
                        color: ColorManager.red),
                    onPressed: () async {
                      await demoteToAudienceById(
                        admin.id.toString(),
                        admin.name ?? '',
                      );
                      _refresh();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.admin_panel_settings_outlined,
              size: 64.sp, color: ColorManager.grey),
          12.hBox,
          Text(
            StringManager.noAdminsLive.tr(),
            style: context.bodyLarge.bold.colorExt(ColorManager.textPrimary),
          ),
          20.hBox,
          ButtonWidget(
            onPressed: _openAudiencePicker,
            title: Text(
              StringManager.addAdminsNow.tr(),
              style: context.bodyMedium.colorExt(ColorManager.buttonTextColor),
            ),
            backgroundColor: ColorManager.primary,
            width: 200.w,
            height: 44.h,
            radius: 22,
          ),
        ],
      ),
    );
  }
}

/// Everyone currently in the stream (live participants minus the host), 10 rows
/// per page loaded as the list scrolls. Each row carries an assign-admin icon —
/// or a remove-admin icon when the user is already an admin.
class _LiveAudiencePicker extends StatefulWidget {
  const _LiveAudiencePicker();

  @override
  State<_LiveAudiencePicker> createState() => _LiveAudiencePickerState();
}

class _LiveAudiencePickerState extends State<_LiveAudiencePicker> {
  static const int _pageSize = 10;
  int _visible = _pageSize;

  /// Ids being promoted/demoted right now (row shows a spinner instead of the
  /// action icon so double taps can't fire twice).
  final Set<String> _busy = {};

  bool _onScroll(ScrollNotification notification, int total) {
    if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 80 &&
        _visible < total) {
      setState(() {
        _visible = (_visible + _pageSize).clamp(0, total);
      });
    }
    return false;
  }

  Future<void> _toggleAdmin(live.UTDParticipant p, bool isAdmin) async {
    setState(() => _busy.add(p.id));
    try {
      if (isAdmin) {
        await demoteToAudienceById(p.id, p.name);
      } else {
        await changeUserRole(id: p.id, name: p.name, role: 'admin');
      }
    } finally {
      if (mounted) setState(() => _busy.remove(p.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = LiveRoomData.instance.room;
    final hostId = room.ownerId?.toString();
    final participants =
        LiveRoomData.instance.liveController?.participants ??
            const <live.UTDParticipant>[];
    final audience =
        participants.where((p) => p.id != hostId).toList(growable: false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: ColorManager.surfaceCardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          15.hBox,
          Padding(
            padding: context.paddingSymmetric(horizontal: 16),
            child: Text(
              StringManager.liveAudienceNow.tr(),
              style: context.bodyLarge.bold.colorExt(ColorManager.textPrimary),
            ),
          ),
          10.hBox,
          Expanded(
            child: audience.isEmpty
                ? Center(
                    child: Text(
                      StringManager.noUsers.tr(),
                      style: context.bodyMedium.colorExt(ColorManager.grey),
                    ),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (n) => _onScroll(n, audience.length),
                    // Re-render rows when a role change lands (optimistic local
                    // update or the broadcast `_role_change`).
                    child: ValueListenableBuilder<int>(
                      valueListenable: RoomData.instance.roleVersion,
                      builder: (context, _, __) => ListView.separated(
                        itemCount: _visible.clamp(0, audience.length),
                        separatorBuilder: (_, __) => Container(
                          color: ColorManager.grey.withValues(alpha: 0.1),
                          height: 1.h,
                        ),
                        itemBuilder: (context, index) {
                          final p = audience[index];
                          final isAdmin =
                              RoomData.instance.adminsInRoom.containsKey(p.id);
                          final busy = _busy.contains(p.id);
                          return ListTile(
                            leading: UserImage(
                              image: p.attributes['avatar'] ?? '',
                              imageSize: 44.h,
                              displayName: p.name,
                            ),
                            title: GradientName(child: Text(
                              p.name,
                              style: context.bodyMedium.bold
                                  .colorExt(ColorManager.textPrimary),
                            )),
                            trailing: busy
                                ? SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : IconButton(
                                    tooltip: (isAdmin
                                            ? StringManager.removeAdmin
                                            : StringManager.addAdmin)
                                        .tr(),
                                    icon: Icon(
                                      isAdmin
                                          ? Icons
                                              .person_remove_alt_1_outlined
                                          : Icons.person_add_alt_1_outlined,
                                      color: isAdmin
                                          ? ColorManager.red
                                          : ColorManager.primary,
                                    ),
                                    onPressed: () =>
                                        _toggleAdmin(p, isAdmin),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
