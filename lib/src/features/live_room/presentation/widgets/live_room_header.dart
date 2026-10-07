import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_duration_chip.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:intl/intl.dart' as intl;
import 'package:general/src/features/room/presentation/gifts/bloc/gift_bloc/gift_bloc.dart';
import 'package:general/src/features/live_room/presentation/taps/live_taps_controller.dart';
import 'package:general/src/features/room/room.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

import 'package:general/src/features/room/presentation/component/room_header/exit_room/exit_side_panel_overlay.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_end_confirm_dialog.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_follow_host_button.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_stream_details_sheet.dart';

/// The live room's header (its own widget — does not reuse the audio
/// `RoomHeader`). Visually mirrors the audio header: an owner card + exit
/// on the top row, and the rank chip + live visitor count on the second row.
///
/// Reads the live controller from [live.UTDRoomScope] (it is rendered inside the
/// kit's scope) and the room metadata from [RoomData.instance.room]. It opens
/// the shared feature *screens* (room settings, rank page, visitors list)
/// — only the chrome is duplicated, not those features.
class LiveRoomHeader extends StatelessWidget {
  const LiveRoomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final room = RoomData.instance.room;
    return Padding(
      // Small top padding: the live kit already wraps the header in a SafeArea.
      padding: context.paddingOnly(start: 8, end: 8, bottom: 8, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                // The card IS the broadcast: open the stream's own details
                // sheet (cover/name/intro/likes/admins) — same for host and
                // viewers. The host's profile is reachable from inside it.
                onTap: () => LiveStreamDetailsSheet.show(context),
                child: const _LiveOwnerCard(),
              ),
              6.wBox,
              // Viewers strip + count moved INTO the top row next to the
              // exit icon (owner 2026-06-12 — saves a whole header row).
              const Expanded(child: _LiveVisitors()),
              6.wBox,
              // Minimize. The machinery was configured and the restore paths
              // existed, but nothing in a LIVE room ever called it: the exit
              // route goes to the side panel (viewers) or the end-live dialog
              // (host), never to ExitPanel, which is where the only minimize
              // action lived. So a live could not be minimized at all.
              InkWell(
                onTap: () => LiveRoomData.instance.liveController?.minimize
                    .startMinimize(context),
                child: Image.asset(
                  AssetsManager.miniRoomIcon,
                  width: 24.w,
                  height: 24.w,
                  color: ColorManager.white,
                ),
              ),
              6.wBox,
              // Share moved out of the header (owner 2026-06-12): viewers get
              // it on the bottom controls bar, the host inside the (...) sheet.
              InkWell(
                // The host ends the stream (explicit confirmation);
                // viewers get the "more live streams" exit side panel.
                onTap: () =>
                    MyDataModel.getInstance().id == room.ownerId
                        ? showEndLiveConfirmDialog(context)
                        : ExitSidePanelOverlay.show(context),
                child: Image.asset(
                  AssetsManager.exitRoomIcon,
                  width: 26.w,
                  height: 26.w,
                  color: ColorManager.white,
                ),
              ),
            ],
          ),
          8.hBox,
          // Slim second row: rank chip + how long this broadcast has been on
          // air. The elapsed time is server-owned so every viewer sees the same
          // number (see LiveDurationChip).
          Row(
            children: [
              _LiveRankChip(room: room),
              6.wBox,
              LiveDurationChip(
                isHost: MyDataModel.getInstance().id == room.ownerId,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Host card (host avatar + scrolling host name + copyable id). The host's
/// live avatar/name come from the connected participants (what viewers see in
/// the room), falling back to the room record before the host connects.
class _LiveOwnerCard extends StatelessWidget {
  const _LiveOwnerCard();

  @override
  Widget build(BuildContext context) {
    final room = RoomData.instance.room;
    final vipColor = room.vip?.colorName;
    final controller = live.UTDRoomScope.of(context).controller;
    return StreamBuilder<List<live.UTDParticipant>>(
      stream: controller.participantsStream,
      initialData: controller.participants,
      builder: (context, snapshot) {
        live.UTDParticipant? host;
        for (final p in snapshot.data ?? const <live.UTDParticipant>[]) {
          if (p.id == room.ownerId?.toString()) {
            host = p;
            break;
          }
        }
        // The host's picture, in order of reliability.
        //
        // The participant attribute alone was wrong: it only exists once the
        // host is in the LiveKit roster, and the host is not always THERE — a
        // local participant is not always listed among remotes, and a viewer
        // can render this header before the roster has arrived. That is why the
        // pill showed an initials square while the viewer strip beside it (which
        // only ever draws people who ARE in the roster) showed real pictures.
        //
        // `owner_image` comes from the enter-room response, so it is known
        // before any media connects and for everyone.
        final hostAvatar = _firstNonEmpty([
          host?.attributes['avatar'],
          room.ownerImage,
        ]);
        // The card carries the BROADCAST's name (owner 2026-06-12) — the
        // host's own name lives in the details sheet / profile.
        final broadcastName =
            ((room.roomName ?? '').trim().isNotEmpty)
                ? room.roomName!
                : (host?.name ?? '');
        // Lucky-gift fly target: the host's header avatar — exact per-userId
        // hit when the host is the recipient, and the live-room fallback when
        // nothing else resolves (see LuckyGiftController.resolveSeat).
        final ownerId = room.ownerId?.toString();
        final hostKey = ownerId == null
            ? null
            : LuckyGiftController.liveAvatarKeys
                .putIfAbsent(ownerId, () => GlobalKey());
        LuckyGiftController.liveHostAvatarKey = hostKey;
        return Container(
      height: 50.h,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12.r),
      ),
      // Compact, content-hugging card (owner 2026-06-12): avatar + name slot
      // + follow pill with ZERO dead space. The old fixed 150.w block + a
      // physical `right: 15.w` padding left a big gap between short names and
      // the pill. The name slot is now a CAP (max 90.w): long names marquee
      // inside it (the card never stretches past its known max width), short
      // names shrink the slot so the pill hugs the name.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              key: hostKey,
              // UserImage, not ImageViewWidget: the latter cannot draw a
              // frame at all, which is why the host's frame never appeared
              // here however many the host owned.
              child: UserImage(
                // The BROADCAST's own image (the live now has its own
                // cover, set from the pre-live composer); the host's
                // avatar is only the fallback for broadcasts that
                // never set one.
                // Absolute URLs only: UserImage hands `image` straight to
                // ImageViewWidget, which does NOT prefix the storage host — a
                // bare `rooms/xxx.png` fails to load and falls back to initials,
                // which is exactly what the pill was showing.
                image: EndPoints.getImage(
                  (room.roomCover ?? '').isNotEmpty
                      ? room.roomCover!
                      : hostAvatar,
                ),
                frame: EndPoints.getImage(room.ownerFrame),
                frameType: room.ownerFrameType,
                imageSize: 40.h,
                // The frame is artwork drawn AROUND the avatar, so it needs
                // room of its own or it clips into the picture.
                frameSize: 54.h,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorManager.white, width: 0.4),
                displayName: broadcastName,
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsetsDirectional.only(start: 4.w, end: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 90.w),
                  child: TextScroll(
                    broadcastName,
                    velocity:
                        const Velocity(pixelsPerSecond: Offset(30, 0)),
                    delayBefore: const Duration(milliseconds: 1000),
                    pauseBetween: const Duration(milliseconds: 1000),
                    style: context.bodyMedium.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: (vipColor != null && vipColor.isNotEmpty)
                          ? Color(int.parse(
                              vipColor.replaceFirst('#', '0xff')))
                          : ColorManager.white,
                    ),
                    // Arabic names must marquee in their own direction —
                    // the old hard-coded LTR scrolled them backwards.
                    textDirection:
                        intl.Bidi.detectRtlDirectionality(broadcastName)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                  ),
                ),
                // Tap-hearts total replaces the owner ID (owner spec
                // 2026-06-11): the live counter everyone watches rise.
                ValueListenableBuilder<int>(
                  valueListenable:
                      LiveTapsController.instance.displayTotal,
                  builder: (context, total, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('❤️', style: TextStyle(fontSize: 9.sp)),
                      3.wBox,
                      Text(
                        Methods().convertToAbbreviatedString(total),
                        style: context.bodyMedium.w600
                            .colorExt(ColorManager.white)
                            .copyWith(height: 1.0, fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // "متابعة" pill at the card's end edge: zero-width for followers /
          // the host, animates away on follow. Its own dense end-padding is
          // the card's end inset.
          const LiveFollowHostButton(dense: true),
        ],
      ),
        );
      },
    );
  }
}

/// Rank / gift-price chip. Tapping opens the shared [RankRoomPage].
class _LiveRankChip extends StatelessWidget {
  final EnterRoomModel room;
  const _LiveRankChip({required this.room});

  String _priceText(String? price) {
    String normalize(String? value) {
      final v = (value ?? '').trim().toLowerCase();
      return (v.isEmpty || v == 'null') ? '' : v;
    }

    final safePrice = normalize(price);
    final safeGiftPrice = normalize(room.giftPrice);
    return safePrice.isNotEmpty
        ? safePrice
        : safeGiftPrice.isNotEmpty
            ? safeGiftPrice
            : '0.0';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        bottomDailog(
          context: context,
          height: MediaQuery.sizeOf(context).height / 1.25,
          widget: RankRoomPage(roomEntity: room),
        );
      },
      child: ConstantsManager.isVariantBuildA
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(AssetsManager.roomRankBadge,
                    fit: BoxFit.cover, width: 75.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: BlocSelector<GiftBloc, GiftState, String?>(
                    bloc: di<GiftBloc>(),
                    selector: (state) => state.price,
                    builder: (context, price) => Text(
                      ' ${_priceText(price)}',
                      style: context.bodyMedium
                          .size(8.5)
                          .colorExt(ColorManager.gold3),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              padding: context.paddingSymmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AssetsManager.reward,
                    height: 15.h,
                    width: 15.w,
                    fit: BoxFit.contain,
                  ),
                  3.wBox,
                  BlocSelector<GiftBloc, GiftState, String?>(
                    bloc: di<GiftBloc>(),
                    selector: (state) => state.price,
                    builder: (context, price) => Text(
                      ' ${_priceText(price)}',
                      style: context.bodyMedium
                          .size(12)
                          .colorExt(ColorManager.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Live visitors strip: a single horizontally-scrollable row of viewer avatars
/// that grows from the count chip toward the rank chip and stops there (the
/// oldest scroll out of view), plus a people-icon + live count chip.
///
/// Taps: an avatar opens that viewer's in-room profile; the count chip opens
/// the shared visitors list.
class _LiveVisitors extends StatelessWidget {
  const _LiveVisitors();

  @override
  Widget build(BuildContext context) {
    final controller = live.UTDRoomScope.of(context).controller;
    final room = RoomData.instance.room;
    return StreamBuilder<List<live.UTDParticipant>>(
      stream: controller.participantsStream,
      initialData: controller.participants,
      builder: (context, snapshot) {
        final visitors = snapshot.data ?? const <live.UTDParticipant>[];
        final count = visitors.length;
        // Newest joiner sits next to the count chip; older ones extend toward
        // the rank chip and scroll out when the strip fills up.
        final ordered = visitors.reversed.toList();

        // Lucky-gift fly targets: every current viewer gets a per-userId
        // render-box key (exact hit while their avatar is laid out). The host
        // keeps the owner-card key — a GlobalKey may only be attached to one
        // widget, so the host's strip avatar stays on a ValueKey. Keys of
        // viewers who left are dropped so the map doesn't grow with churn.
        final hostId = room.ownerId?.toString();
        final currentIds = <String>{for (final p in visitors) p.id};
        LuckyGiftController.liveAvatarKeys.removeWhere(
            (uid, _) => uid != hostId && !currentIds.contains(uid));
        // Bar-area fallback target for recipients without a visible avatar.
        final barKey = LuckyGiftController.liveVisitorsBarKey ??= GlobalKey();

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                key: barKey,
                height: 30.h,
                child: ListView.builder(
                  // reverse anchors item 0 (the newest viewer) at the chip
                  // edge; the list grows toward the rank chip.
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: ordered.length,
                  itemBuilder: (context, i) {
                    final visitor = ordered[i];
                    return Padding(
                      padding: context.paddingSymmetric(horizontal: 3.0),
                      child: InkWell(
                        onTap: () => bottomDailog(
                          context: context,
                          widget: UserRoomProfile(
                            userId: visitor.id,
                            roomData: room,
                          ),
                        ),
                        child: UserImage(
                          key: visitor.id == hostId
                              ? ValueKey('live_visitor_${visitor.id}')
                              : LuckyGiftController.liveAvatarKeys
                                  .putIfAbsent(visitor.id, () => GlobalKey()),
                          image: visitor.attributes['avatar'] ?? '',
                          displayName: visitor.attributes['name'] ?? '',
                          imageSize: 30.0.h,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            4.wBox,
            InkWell(
              onTap: () {
                bottomDailog(
                  context: context,
                  widget: VisitorsRoomScreen(
                    roomData: room,
                    vistors: [
                      for (final p in visitors)
                        UTDParticipant(
                          id: p.id,
                          name: p.name,
                          attributes: p.attributes,
                        ),
                    ],
                  ),
                );
              },
              child: Container(
                padding:
                    context.paddingSymmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_alt_rounded,
                        size: 16.sp, color: ColorManager.white),
                    3.wBox,
                    Text(
                      count.toString(),
                      style: context.bodyMedium.colorExt(ColorManager.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// First value that is neither null nor blank, or `''` when there is none.
///
/// Used for picture and name fallbacks: an empty string from one source must
/// not win over a real value from the next, which is what `??` would do.
String _firstNonEmpty(List<String?> candidates) {
  for (final value in candidates) {
    if (value != null && value.trim().isNotEmpty) return value;
  }

  return '';
}
