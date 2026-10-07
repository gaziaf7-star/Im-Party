import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/body_theme_background.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/live_room/presentation/taps/live_taps_controller.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_follow_host_button.dart';
import 'package:general/src/features/room/room.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

/// The BROADCAST's own details sheet (تفاصيل البث) — opened by tapping the
/// broadcast image/name in the live header. This is the live show's identity
/// card (cover, name, intro, likes, viewers, host, admins), NOT the host's
/// profile, and it is the SAME sheet for the host and for viewers.
class LiveStreamDetailsSheet {
  static Future<void> show(BuildContext context) {
    final room = LiveRoomData.instance.roomOrNull;
    if (room == null) return Future.value();
    // Refresh the broadcast's admin list for the "مشرفين البث المباشر" block.
    di<AdminRoomBloc>().add(GetAdminsEvent(
      ownerId: room.ownerId.toString(),
      roomId: room.id.toString(),
    ));
    final controller = live.UTDRoomScope.maybeOf(context)?.controller ??
        LiveRoomData.instance.liveController;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LiveStreamDetailsBody(room: room, controller: controller),
    );
  }
}

class _LiveStreamDetailsBody extends StatelessWidget {
  final EnterRoomModel room;
  final live.UTDRoomController? controller;

  const _LiveStreamDetailsBody({required this.room, required this.controller});

  live.UTDParticipant? _host(List<live.UTDParticipant> participants) {
    final ownerId = room.ownerId?.toString();
    for (final p in participants) {
      if (p.id == ownerId) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Follows the app body theme (color/gradient/image) like the home, via the
    // clipped Stack pattern; text uses adaptive tokens so it stays readable.
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.75,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: BodyThemeBackground()),
          StreamBuilder<List<live.UTDParticipant>>(
        stream: controller?.participantsStream,
        initialData: controller?.participants ?? const <live.UTDParticipant>[],
        builder: (context, snapshot) {
          final participants =
              snapshot.data ?? const <live.UTDParticipant>[];
          final host = _host(participants);
          final hostAvatar = host?.attributes['avatar'] ?? '';
          final hostName = host?.name ?? room.roomName ?? '';
          final cover = (room.roomCover ?? '').isNotEmpty
              ? EndPoints.getImage(room.roomCover!)
              : hostAvatar;
          final intro = (room.roomIntro ?? '').trim();
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 28.h),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorManager.secondaryText.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                14.hBox,
                // The broadcast's own cover, name and intro.
                ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: ImageViewWidget(
                    url: cover,
                    width: 96.r,
                    height: 96.r,
                    boxFit: BoxFit.cover,
                    displayName: room.roomName ?? hostName,
                  ),
                ),
                12.hBox,
                Text(
                  room.roomName ?? '',
                  textAlign: TextAlign.center,
                  style:
                      context.bodyLarge.w700.colorExt(ColorManager.textPrimary),
                ),
                if (intro.isNotEmpty) ...[
                  6.hBox,
                  Text(
                    intro,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style:
                        context.bodySmall.colorExt(ColorManager.secondaryText),
                  ),
                ],
                18.hBox,
                // Live stats: likes (الإعجابات) + current viewers.
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable:
                            LiveTapsController.instance.displayTotal,
                        builder: (context, total, _) => _StatCard(
                          emoji: '❤️',
                          value:
                              Methods().convertToAbbreviatedString(total),
                          label: StringManager.likes.tr(),
                        ),
                      ),
                    ),
                    10.wBox,
                    Expanded(
                      // CUMULATIVE unique viewers of THIS broadcast (counted
                      // server-side per session, reset on end-live) — the
                      // CURRENT participants count lives in the header strip.
                      child: _StatCard(
                        emoji: '👀',
                        value: Methods().convertToAbbreviatedString(
                            room.liveViewersTotal ?? 0),
                        label: StringManager.viewersLabel.tr(),
                      ),
                    ),
                  ],
                ),
                18.hBox,
                // Host block — tapping it opens the host's in-room profile
                // (the header itself no longer does; it opens THIS sheet).
                _SectionTitle(StringManager.streamOwner.tr()),
                8.hBox,
                InkWell(
                  onTap: () {
                    final ownerId = room.ownerId;
                    if (ownerId == null) return;
                    bottomDailog(
                      context: context,
                      widget: UserRoomProfile(
                        userId: ownerId.toString(),
                        roomData: room,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: ColorManager.secondaryText.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        UserImage(
                          image: hostAvatar,
                          imageSize: 44.h,
                          displayName: hostName,
                        ),
                        10.wBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GradientName(child: Text(
                                hostName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.bodyMedium.w600
                                    .colorExt(ColorManager.textPrimary),
                              )),
                              if ((room.uuidOwnerRoom ?? '').isNotEmpty)
                                Text(
                                  'ID: ${room.uuidOwnerRoom}',
                                  style: context.bodySmall
                                      .colorExt(ColorManager.secondaryText),
                                ),
                            ],
                          ),
                        ),
                        // Same follow pill as the header — visible only while
                        // the local user doesn't follow the host.
                        const LiveFollowHostButton(),
                        Icon(Icons.chevron_right,
                            color: ColorManager.secondaryText, size: 22.sp),
                      ],
                    ),
                  ),
                ),
                18.hBox,
                // Broadcast admins (read-only here; managed from the host's
                // "المشرفين" page in the more-sheet).
                _SectionTitle(StringManager.liveManager.tr()),
                8.hBox,
                BlocBuilder<AdminRoomBloc, AdminRoomStates>(
                  bloc: di<AdminRoomBloc>(),
                  buildWhen: (prev, curr) =>
                      prev.adminsReqState != curr.adminsReqState ||
                      prev.admins != curr.admins,
                  builder: (context, state) {
                    if (state.adminsReqState == RequestState.loading) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    if (state.admins.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text(
                          StringManager.noAdminsLive.tr(),
                          style: context.bodySmall
                              .colorExt(ColorManager.secondaryText),
                        ),
                      );
                    }
                    return SizedBox(
                      height: 86.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.admins.length,
                        separatorBuilder: (_, __) => 14.wBox,
                        itemBuilder: (context, index) {
                          final admin = state.admins[index];
                          return InkWell(
                            onTap: () => bottomDailog(
                              context: context,
                              widget: UserRoomProfile(
                                userId: admin.id.toString(),
                                roomData: room,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                UserImage(
                                  image: admin.profile?.image ?? '',
                                  imageSize: 48.h,
                                  displayName: admin.name ?? '',
                                ),
                                6.hBox,
                                SizedBox(
                                  width: 64.w,
                                  child: GradientName(child: Text(
                                    admin.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: context.bodySmall
                                        .colorExt(ColorManager.secondaryText)
                                        .copyWith(fontSize: 10.sp),
                                  )),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: context.bodyMedium.w600.colorExt(ColorManager.textPrimary),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: ColorManager.secondaryText.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Text('$emoji $value',
              style: context.bodyLarge.w700.colorExt(ColorManager.textPrimary)),
          4.hBox,
          Text(label,
              style: context.bodySmall.colorExt(ColorManager.secondaryText)),
        ],
      ),
    );
  }
}
