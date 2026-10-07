import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/core/utils/relative_time.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/user_online/user_online_bloc.dart';
import 'package:general/src/features/cp/presentation/cp_store/bloc/cp_profile_bloc/cp_profile_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_state.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/widget/user_images_carousel.dart';
import 'package:general/src/features/theme2_app/user_profile/presentation/widgets/theme2_live_badge.dart';
import 'package:general/src/core/widgets/gender_widget.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/vip_container.dart';

/// Left-aligned "VIP room profile" header, on request. The cover photo is
/// the background all the way DOWN to the follow-stats row -- name/gender,
/// ID, online status, host/manager badge, level badges + country,
/// achievement + VIP badges, and the follow stats all sit directly on top
/// of it (BoxFit.cover, so the photo is never distorted/stretched, just
/// extended), behind a dark gradient scrim so the white text stays
/// readable regardless of the photo. On request: "cover image ta following
/// section ar nes porjonto thakba" -- no separate solid panel underneath
/// anymore. The avatar sits top-left, inside the photo. The tab bar right
/// below this widget ([Theme2VisitorProfilePage]'s Personal/Moment/Gift/
/// Relation/Achievements bar) is untouched.
///
/// Deliberately left out (no backing field/asset anywhere in this codebase,
/// so nothing to build them from): the giant "SVIP" watermark, "Noble"
/// badge, the "Good Host 9pm-11pm" schedule ribbon, the CP/family
/// mini-avatar's own separate "Lv3" tag, the decorative crown/wings/rose
/// artwork, the "YOU ARE INVITED" banner, and the ornate cursive name font.
class Theme2VisitorProfileHeader extends StatelessWidget {
  final UserEntity? user;
  final bool isMyProfile;
  final CpProfileBloc cpProfileBloc;
  final UserOnlineBloc userOnlineBloc;
  final UserBadgesBloc userBadgesBloc;
  final VoidCallback onEditTap;
  final VoidCallback onMoreTap;

  // A bit more compact than before, on request ("profile image ar size").
  static const double avatarRadius = 36;

  const Theme2VisitorProfileHeader({
    super.key,
    required this.user,
    required this.isMyProfile,
    required this.cpProfileBloc,
    required this.userOnlineBloc,
    required this.userBadgesBloc,
    required this.onEditTap,
    required this.onMoreTap,
  });

  String _lastSeenLabel(String? iso) {
    final rel = RelativeTime.fromIso(iso);
    if (rel == null) return StringManager.offline.tr();
    return StringManager.lastSeenAt.tr(namedArgs: {'time': rel});
  }

  // Small dot + "Online"/"Offline" text, on request -- a clean,
  // professional-looking status line instead of just the little dot on
  // the avatar.
  Widget _onlineStatusLabel(bool online) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.r,
          height: 7.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: online
                ? const Color(0xFF4CD964)
                : ColorManager.white.withValues(alpha: 0.45),
          ),
        ),
        5.wBox,
        Text(
          online ? StringManager.online.tr() : StringManager.offline.tr(),
          style: TextStyle(
            color: online
                ? const Color(0xFF4CD964)
                : ColorManager.white.withValues(alpha: 0.75),
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  bool _inRoom(UserEntity? user) {
    if (isMyProfile) return false;
    final room = user?.nowRoom;
    return room != null && (room.id ?? 0) > 0 && (room.isnInRoom ?? false);
  }

  void _openFullImage(BuildContext context) {
    bottomDailog(
      context: context,
      widget: Scaffold(
        backgroundColor: ColorManager.black,
        appBar: const AppBarWidget(
          iconColor: Colors.grey,
          backgroundColor: ColorManager.black,
          title: '',
        ),
        body: InteractiveViewer(
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.all(10.r),
            child: ImageViewWidget(
              url: EndPoints.getImage(user?.profile?.image ?? ''),
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              boxFit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhotos = (user?.images ?? []).isNotEmpty;
    // Re-derived from the platform view directly (same fix already applied
    // to SettingScreen/MusicServerPage this session) -- opening a profile
    // from INSIDE a live/audio room (often running immersive, hidden system
    // UI) left the ambient MediaQuery.padding.top stale/zero here, which
    // pushed the back/edit buttons up under the status bar.
    final topInset = MediaQueryData.fromView(View.of(context)).padding.top;
    // Nudged up a bit more, on request ("profile image ta ar akto upora
    // othba").
    final avatarTop = topInset + 64.h;
    // Even more breathing room under the avatar than before, on request
    // ("profile image ar thaka name ar gap ta akto barba").
    final infoTop = avatarTop + (avatarRadius.h * 2) + 28.h;

    return Stack(
      // No StackFit.expand here, on purpose: the cover photo below is
      // Positioned.fill, so it takes on whatever height the ONE
      // non-positioned child (the sizing SizedBox further down, which
      // wraps the actual name/id/badges/stats content) naturally needs.
      // That's what makes the photo's height match the content exactly,
      // with zero leftover empty photo before the tab bar, on request
      // ("cover image ar height gap ... sm to sm hoba").
      clipBehavior: Clip.none,
      children: [
        // Cover — the user's own uploaded photos (BoxFit.cover inside
        // UserImagesCarousel, so it fills this box without ever
        // stretching/distorting), or the app's default artwork with an
        // "Add photos" prompt (own profile only) when there are none.
        Positioned.fill(
          child: UserImagesCarousel(userData: user ?? const UserEntity()),
        ),
        if (isMyProfile && !hasPhotos)
          Positioned.fill(
            child: _AddPhotosPrompt(
              onTap: () => Navigator.pushNamed(
                context,
                Routes.addMultiPicture,
                arguments: true,
              ),
            ),
          ),
        // Dark scrim, on request the photo now runs the full height
        // ("cover image ta following section porjonto thakba") -- this
        // is what keeps the left-aligned white text readable over it,
        // however bright the photo is, all the way down to the stats
        // row.
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorManager.black.withValues(alpha: 0.18),
                  ColorManager.black.withValues(alpha: 0.38),
                  ColorManager.black.withValues(alpha: 0.78),
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            ),
          ),
        ),

        // Avatar (+ CP partner), top-left.
        Positioned(
          top: avatarTop,
          left: 16.w,
          child: BlocBuilder<CpProfileBloc, CpProfileStates>(
            bloc: cpProfileBloc,
            buildWhen: (prev, curr) =>
            prev.reqStates != curr.reqStates ||
                prev.data?.mainCp != curr.data?.mainCp,
            builder: (context, cpState) {
              final cpUser = cpState.data?.mainCp?.user;
              final hasCp = cpUser != null && (cpUser.image ?? '').isNotEmpty;

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () => _openFullImage(context),
                            child: (user?.frame ?? '') != ''
                                ? UserImage(
                              image: user?.profile?.image ?? '',
                              displayName: user?.name,
                              imageSize: avatarRadius.h * 1.6,
                              frameSize: avatarRadius.h * 2.8,
                              frameType: user?.frameType ?? '',
                              frame: user?.frame ?? '',
                              boxFit: BoxFit.cover,
                              borderRadius: 60.radius,
                            )
                                : Container(
                              width: avatarRadius.h * 2,
                              height: avatarRadius.h * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: ColorManager.white, width: 3),
                              ),
                              child: CircleAvatar(
                                radius: avatarRadius.r,
                                backgroundColor: ColorManager.grey2,
                                child: UserImage(
                                  image: user?.profile?.image ?? '',
                                  displayName: user?.name,
                                  imageSize: avatarRadius.h * 1.9,
                                  frameSize: avatarRadius.h * 1.9,
                                  frameType: user?.frameType ?? '',
                                  frame: user?.frame ?? '',
                                  boxFit: BoxFit.cover,
                                  borderRadius: 60.radius,
                                ),
                              ),
                            ),
                          ),
                          // Online dot — always on for your own profile;
                          // reflects real presence on a visited one.
                          Positioned(
                            right: 2.w,
                            bottom: 2.h,
                            child: isMyProfile
                                ? _OnlineDot(online: true)
                                : BlocBuilder<UserOnlineBloc, UserOnlineState>(
                              bloc: userOnlineBloc,
                              buildWhen: (prev, curr) =>
                              prev.online != curr.online,
                              builder: (context, state) =>
                                  _OnlineDot(online: state.online != 0),
                            ),
                          ),
                        ],
                      ),
                      if (hasCp) ...[
                        // Was a plain gap; now the CP "connected" heart
                        // animation sits between the two avatars, on request,
                        // so the pairing reads as two equal profiles joined
                        // by a connection rather than one avatar with a
                        // small photo tucked beside it. Made bigger (was
                        // 1.1x) on request, which also pushes the partner
                        // avatar further right since this box IS the gap.
                        SizedBox(
                          width: avatarRadius.h * 1.6,
                          child: ShowSVGA(
                            svgaAssetPath: AssetsManager.cpLoveIcon,
                            fit: BoxFit.contain,
                            height: avatarRadius.h * 1.6,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Methods().userProfileNavigator(
                              context: context,
                              userId: '${cpUser.id}',
                            );
                          },
                          child: (cpUser.frame ?? '').isNotEmpty
                              ? UserImage(
                            image: cpUser.image ?? '',
                            displayName: cpUser.name,
                            // Same size as the user's own avatar (was
                            // 1.1/1.9 -- visibly smaller) so the pair reads
                            // as two equal profiles side by side.
                            imageSize: avatarRadius.h * 1.6,
                            frameSize: avatarRadius.h * 2.8,
                            frameType: '',
                            frame: cpUser.frame ?? '',
                            boxFit: BoxFit.cover,
                            borderRadius: 60.radius,
                          )
                              : Container(
                            width: avatarRadius.h * 2,
                            height: avatarRadius.h * 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: ColorManager.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: avatarRadius.r,
                              backgroundColor: ColorManager.grey2,
                              child: UserImage(
                                image: cpUser.image ?? '',
                                displayName: cpUser.name,
                                imageSize: avatarRadius.h * 1.9,
                                frameSize: avatarRadius.h * 1.9,
                                frameType: '',
                                frame: cpUser.frame ?? '',
                                boxFit: BoxFit.cover,
                                borderRadius: 60.radius,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_inRoom(user))
                    Positioned(
                      // Bigger Live badge sits on the avatar's top-right edge.
                      // Keep it anchored to the main profile avatar (not the CP
                      // partner) so its position is stable for every profile.
                      top: -10.h,
                      left: 58.w,
                      child: Theme2LiveBadge(nowRoom: user!.nowRoom!),
                    ),
                ],
              );
            },
          ),
        ),

        // Left-aligned info column: name/gender, ID, online status,
        // host/manager badge, level badges + country, achievement + VIP
        // badges, then the follow stats. This is the ONE non-positioned
        // Stack child -- its natural height (reserved top space for the
        // avatar + this content's own height + a little bottom padding)
        // is what the cover photo above ends up matching exactly.
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: infoTop),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name + gender. NOT mainAxisSize.min -- combining that
                    // with a Flexible child was overflowing by a couple of
                    // pixels on some names/screens (device log, "RIGHT
                    // OVERFLOWED BY 2.2 PIXELS") -- a full-width Row lets the
                    // Flexible text actually shrink into whatever room is
                    // left after the fixed-size icon/pill siblings.
                    8.hBox,
                    Row(
                      children: [
                        if (user?.vip?.img1 != null &&
                            user!.vip!.img1!.isNotEmpty) ...[
                          ImageViewWidget(
                            // Bigger, on request, for better visibility.
                            url: user!.vip!.img1!,
                            width: 32.w,
                            height: 23.h,
                            boxFit: BoxFit.fill,
                            radius: 20,
                          ),
                          6.wBox,
                        ],
                        Flexible(
                          child: GradientName(child: Text(
                            user?.name ?? '',
                            maxLines: 1,
                            style: TextStyle(
                              color: ColorManager.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              shadows: const [
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          )),
                        ),
                        if ((user?.profile?.gender ?? 0) != 0) ...[
                          6.wBox,
                          // A bit wider than before so the badge's own icon+age
                          // text never clips/overflows, on request ("gender
                          // base atai over follow dhksa, ata responsive hoba").
                          GenderWidget(
                            age: user?.profile?.age ?? 0,
                            gender: user?.profile?.gender ?? 2,
                            widthSize: 36,
                          ),
                        ],
                      ],
                    ),
                    10.hBox,
                    // Online/Offline status -- now shown before the ID line,
                    // for every profile including your own (not just visited
                    // ones), on request ("amar id ar aga online text lekha
                    // thakba"). Just "Online"/"Offline", no relative "last
                    // seen X ago" text here anymore, on request ("offline

                    // ID + copy.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // thakla offline").
                        if (isMyProfile || !(user?.lastActiveHidden ?? false))
                          isMyProfile
                              ? _onlineStatusLabel(true)
                              : BlocBuilder<UserOnlineBloc, UserOnlineState>(
                            bloc: userOnlineBloc,
                            buildWhen: (prev, curr) =>
                            prev.online != curr.online,
                            builder: (context, state) =>
                                _onlineStatusLabel(state.online != 0),
                          ),
                        SizedBox(width: 10,),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: '${user?.uuid ?? user?.id ?? ''}'),
                            );
                            Methods.showToast(context,
                                message: StringManager.theTextHasBeenCopied.tr());
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Special ID badge art instead of plain "ID: n"
                              // text when the user owns one -- this page
                              // never read user.specialId/idImage before, so
                              // it silently fell back to the numeric ID even
                              // for users who'd bought a special ID (which
                              // the Mine tab already shows correctly).
                              (user?.specialId != 0 &&
                                  (user?.specialId ?? '') != '' &&
                                  (user?.idImage ?? '').isNotEmpty)
                                  ? ImageViewWidget(
                                url: user?.idImage ?? '',
                                height: 22.h,
                                width: 80.w,
                                boxFit: BoxFit.fill,
                              )
                                  : Text(
                                "${StringManager.appName} ID: ${user?.uuid ?? user?.id ?? ''}",
                                style: TextStyle(
                                  color: ColorManager.white.withValues(alpha: 0.9),
                                  fontSize: 14.sp,
                                  shadows: const [
                                    Shadow(color: Colors.black54, blurRadius: 3),
                                  ],
                                ),
                              ),
                              4.wBox,
                              Icon(Icons.copy,
                                  size: 14.sp,
                                  color: ColorManager.white.withValues(alpha: 0.75)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    10.hBox,
                    // Host/agency/admin/... user-type pill — real data:
                    // [UserEntity.managerType].
                    if ((user?.managerType?.image ?? '').isNotEmpty ||
                        (user?.managerType?.name ?? '').isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient: ColorManager.brandGradient,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if ((user?.managerType?.image ?? '').isNotEmpty) ...[
                                ImageViewWidget(
                                  url: EndPoints.getImage(user!.managerType!.image!),
                                  width: 14.w,
                                  height: 14.h,
                                  boxFit: BoxFit.contain,
                                ),
                                4.wBox,
                              ],
                              Text(
                                user?.managerType?.name ?? '',
                                style: TextStyle(
                                  color: ColorManager.onBrandGradient,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                    // Level badges (sender/charm, receiver/wealth) + country
                    // flag, on one flowing line.
                    Builder(builder: (context) {
                      final hasSender = (user?.level?.senderImage ?? '').isNotEmpty;
                      final hasReceiver =
                          (user?.level?.receiverImage ?? '').isNotEmpty;
                      final hasCountry = (user?.country?.photo ?? '').isNotEmpty;
                      if (!hasSender && !hasReceiver && !hasCountry) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            if (hasSender)
                              LevelContainer(
                                boxFit: BoxFit.cover,
                                level: user?.level?.senderLevel ?? 1,
                                image: user?.level?.senderImage ?? '',
                                height: 19.h,
                                width: 60.w,
                              ),
                            if (hasReceiver)
                              LevelContainer(
                                boxFit: BoxFit.contain,
                                level: user?.level?.reciverLevel ?? 1,
                                image: user?.level?.receiverImage ?? '',
                                height: 19.h,
                                width: 60.w,
                              ),
                            if (hasCountry)
                              ImageViewWidget(
                                url: user?.country?.photo ?? '',
                                height: 19.h,
                                width: 27.w,
                              ),
                          ],
                        ),
                      );
                    }),
                    // Admin-assigned badges (/api/badges/users/{id}) + the
                    // SVIP badge, together on one row, on request -- and
                    // bigger than the first pass. VipContainer moved here
                    // from the achievement row below so it isn't shown twice.
                    BlocBuilder<GetUserBadgesBloc, GetUserBadgesState>(
                      bloc: di<GetUserBadgesBloc>(),
                      buildWhen: (prev, curr) =>
                      prev.userBadge?.top != curr.userBadge?.top,
                      builder: (context, state) {
                        final ownedBadges = state.userBadge?.top ?? [];
                        final hasVip =
                            user?.vip != null && (user?.vip?.level ?? 0) != 0;
                        if (ownedBadges.isEmpty && !hasVip) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          // One line, scrollable -- never wraps to a second
                          // row (on request).
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasVip) ...[
                                  VipContainer(
                                    vip: user!.vip!.img1 ?? '',
                                    width: 64.w,
                                    height: 34.h,
                                  ),
                                  3.wBox,
                                ],
                                for (final badge in ownedBadges) ...[
                                  badge.imageType == "svga"
                                      ? CacheSvgaWidget(
                                    url: EndPoints.getImage(badge.image),
                                    boxFit: BoxFit.contain,
                                    height: 42.h,
                                    width: 84.w,
                                  )
                                      : ImageViewWidget(
                                    url: EndPoints.getImage(badge.image),
                                    height: 42.h,
                                    width: 84.w,
                                    boxFit: BoxFit.contain,
                                  ),
                                  if (badge != ownedBadges.last) 3.wBox,
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Achievement badges (same list the Achievements tab shows
                    // in full) -- "noble"/"cp badge" have no backing field
                    // anywhere in this codebase, so they're skipped rather
                    // than faked. The SVIP badge moved to the row above.
                    BlocBuilder<UserBadgesBloc, UserBadgesState>(
                      bloc: userBadgesBloc,
                      buildWhen: (prev, curr) => prev.userBadge != curr.userBadge,
                      builder: (context, state) {
                        final badges = (state.userBadge ?? []).take(6).toList();
                        if (badges.isEmpty) return const SizedBox();
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          // Shifted right again, on request. Was a Wrap
                          // (could fall onto a second line) -- now a single
                          // horizontally-scrollable line, with a small 3px
                          // gap between badges.
                          child: Transform.translate(
                            offset: Offset(-1.w, 0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final b in badges)
                                  // Narrower still (was 60.w), on request
                                  // ("aro akto pasha pasi").
                                    ImageViewWidget(
                                      url: EndPoints.getImage(b.image),
                                      height: 46.h,
                                      width: 48.w,
                                      boxFit: BoxFit.contain,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    12.hBox,
                    _StatsTextRow(user: user, isMyProfile: isMyProfile),
                  ],
                ),
              ),
              // Breathing room before the tab bar starts, on request
              // ("cover image ar height gap").
              20.hBox,
            ],
          ),
        ),

        // Top bar: back + Edit (own) / More (visited) — over the cover.
        // Nudged up further still, on request ("tp back arro ar section
        // ta ar akto upora othba").
        Positioned(
          top: topInset + 8,
          left: 8.w,
          right: 8.w,
          child: Row(
            children: [
              _RoundIconButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              if (isMyProfile) ...[
                // Photo-management, beside Edit — this existed as its own
                // button before and is back on request.
                _RoundIconButton(
                  icon: Icons.add_photo_alternate_outlined,
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.addMultiPicture,
                    arguments: true,
                  ),
                ),
                8.wBox,
                _RoundIconButton(icon: Icons.edit, onTap: onEditTap),
              ] else if (user?.id != null && user!.id != 0)
                _RoundIconButton(icon: Icons.more_horiz, onTap: onMoreTap),
            ],
          ),
        ),
      ],
    );
  }
}

/// "+ Add photos" prompt over the default cover artwork — own profile only,
/// only while there are no uploaded photos yet. Tapping opens the same
/// multi-picture screen the rest of the app already uses to manage photos.
class _AddPhotosPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotosPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: ColorManager.white.withValues(alpha: 0.7)),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(Icons.add, color: ColorManager.white, size: 22.sp),
            ),
            8.hBox,
            Text(
              StringManager.addPicture.tr(),
              style: TextStyle(
                color: ColorManager.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  final bool online;

  const _OnlineDot({required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14.r,
      height: 14.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: online ? const Color(0xFF4CD964) : ColorManager.grey2,
        border: Border.all(color: ColorManager.white, width: 2),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.black.withValues(alpha: 0.28),
        ),
        child: Icon(icon, color: ColorManager.white, size: 17.sp),
      ),
    );
  }
}

/// Follow/Following/Friends/Visitors stats — stacked count-over-label,
/// like the reference image, directly over the photo with a thin vertical
/// divider between each. Own profile shows the app's real
/// Following/Followers/Friends/Visitors counts; a visited profile keeps
/// the existing privacy rule and shows only Views + Followers.
class _StatsTextRow extends StatelessWidget {
  final UserEntity? user;
  final bool isMyProfile;

  const _StatsTextRow({required this.user, required this.isMyProfile});

  @override
  Widget build(BuildContext context) {
    void openList(int index, VoidCallback readCounter) {
      Navigator.pushNamed(context, Routes.friendFollowing, arguments: index);
      readCounter();
    }

    final items = isMyProfile
        ? [
      _StatItem(
        '${user?.numberOfFollowings ?? 0}',
        StringManager.following.tr(),
        onTap: () => openList(0,
                () => di<FetchUserDataBloc>().add(const ReadCounterFollowingsEvent())),
      ),
      _StatItem(
        '${user?.numberOfFans ?? 0}',
        StringManager.followers.tr(),
        onTap: () => openList(1,
                () => di<FetchUserDataBloc>().add(const ReadCounterFollowersEvent())),
      ),
      _StatItem(
        '${user?.numberOfFriends ?? 0}',
        StringManager.friends.tr(),
        onTap: () => openList(2,
                () => di<FetchUserDataBloc>().add(const ReadCounterFriendsEvent())),
      ),
      _StatItem(
        '${user?.profileVisitors ?? 0}',
        StringManager.visitors.tr(),
        onTap: () => openList(3,
                () => di<FetchUserDataBloc>().add(const ReadCounterVistorsEvent())),
      ),
    ]
        : [
      _StatItem('${user?.totalViews ?? 0}', StringManager.views.tr()),
      _StatItem(
        '${user?.numberOfFans ?? 0}',
        StringManager.followers.tr(),
        onTap: () => openList(1,
                () => di<FetchUserDataBloc>().add(const ReadCounterFollowersEvent())),
      ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w),
              width: 1,
              height: 26.h,
              color: ColorManager.white.withValues(alpha: 0.35),
            ),
          GestureDetector(
            onTap: items[i].onTap,
            behavior: HitTestBehavior.opaque,
            // Center-aligned count/label, on request ("total count ta
            // text ar fast a nah, meddle borabor thakba").
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  items[i].count,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ColorManager.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 3),
                    ],
                  ),
                ),
                3.hBox,
                Text(
                  items[i].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ColorManager.white.withValues(alpha: 0.8),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 3),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatItem {
  final String count;
  final String label;
  final VoidCallback? onTap;

  const _StatItem(this.count, this.label, {this.onTap});
}