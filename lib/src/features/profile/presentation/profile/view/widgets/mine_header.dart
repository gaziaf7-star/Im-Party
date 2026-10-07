part of 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

/// The owner's own header at the top of Mine.
///
/// Replaces the shared [UserInfoRow] here only. That widget is used on other
/// people's profiles, in room sheets and in search results, so restyling it
/// would change all of them; this header exists to match the reference app's
/// Mine screen specifically:
///
///   avatar · name · (flag + ID + copy) · level and charm badges · chevron
///
/// Two things it fixes versus what was here before: the country flag sat on its
/// own line below the ID instead of beside it, wasting a row and reading as
/// unrelated; and the level/charm badges were not shown at all even though the
/// API has always sent their artwork.
class MineHeader extends StatelessWidget {
  const MineHeader({
    required this.user,
    required this.level,
    required this.frame,
    super.key,
  });

  final UserEntity user;
  final LevelEntity? level;

  /// Panel-assigned avatar frame, drawn around the picture when the owner has one.
  final String frame;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // The arrow opens the FULL-SCREEN PROFILE, not the edit form. Editing
      // belongs inside that profile — the reference app works this way, and
      // sending the header straight to the edit screen skipped the profile
      // entirely, so there was no way to view your own page as others see it.
      onTap: () => Methods().userProfileNavigator(
        context: context,
        userId: '${user.id}',
      ),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // The name sat almost against the status bar. The reference app leaves a
        // clear gap above the avatar, so breathe at the top and keep the bottom
        // tight against the stats row.
        padding: context.paddingOnly(start: 14, end: 14, top: 34, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserImage(
              borderRadius: 50.radius,
              imageSize: 68.h,
              image: user.profile?.image ?? '',
              displayName: '${user.name}',
              frame: frame.isEmpty ? null : frame,
              // Both of these were missing, and each broke the frame on its own.
              //
              // frameType selects the renderer inside UserImage. Without it an
              // .svga frame fell through to the still-image branch, which cannot
              // decode one -- so on the owner's own header an animated frame drew
              // nothing while a static PNG happened to work.
              frameType: user.frameType ?? '',
              // A frame's artwork sits on a canvas much wider than the hole it
              // leaves for the picture, so it must be drawn BIGGER than the avatar
              // or the avatar spills past the inner ring. 1.73x is the ratio the
              // rest of the app already uses (75 -> 130 in user_info_bar).
              frameSize: 118.h,
            ),
            12.wBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientName(child: TextWidget(
                    '${user.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyLarge.w700
                        .size(17)
                        .colorExt(ColorManager.momentPostTextColor),
                  )),
                  4.hBox,
                  _IdRow(user: user),
                  6.hBox,
                  LevelCharmPills(level: level),
                  _MineBadgesRow(user: user),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 26.r,
              color: ColorManager.momentPostTextColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// SVIP badge + admin-assigned badges (/api/badges/users/{id}), one row,
/// right after the level pills -- same combined layout and sizing as the
/// visitor profile header (theme2_visitor_profile_header.dart), on request,
/// so Mine and the full profile agree.
class _MineBadgesRow extends StatelessWidget {
  const _MineBadgesRow({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetUserBadgesBloc, GetUserBadgesState>(
      bloc: di<GetUserBadgesBloc>(),
      buildWhen: (prev, curr) => prev.userBadge?.top != curr.userBadge?.top,
      builder: (context, state) {
        final ownedBadges = state.userBadge?.top ?? [];
        final hasVip = user.vip != null && (user.vip?.level ?? 0) != 0;
        if (ownedBadges.isEmpty && !hasVip) return const SizedBox();

        return Padding(
          padding: EdgeInsets.only(top: 6.h),
          // One line, scrollable -- never wraps to a second row (on request).
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasVip) ...[
                  VipContainer(
                    vip: user.vip!.img1 ?? '',
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
    );
  }
}

/// Flag, ID and copy button on one line, as in the reference app.
class _IdRow extends StatelessWidget {
  const _IdRow({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final flag = user.country?.photo ?? '';
    final showFlag = flag.isNotEmpty &&
        (user.country?.id ?? 0) != 0 &&
        (user.country?.name ?? '').isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFlag) ...[
          CountryIcon(
            country: flag,
            countryId: (user.country?.id ?? -1).toString(),
            borderRadius: 3.radius,
          ),
          6.wBox,
        ],
        Flexible(
          child: IdWithCopyIcon(
            userId: user.uuid ?? '',
            isNeedCopyIcon: true,
            isSpecial:
            (user.specialId != 0 && (user.specialId ?? '') != ''),
            specialImg: user.idImage ?? '',
            // Wider than the shared default (50.w) -- was cramping the
            // special-id badge art on this header specifically.
            specialImgWidth: 80.w,
            color: user.imageColorEntity?.color,
            img: user.imageColorEntity?.image,
            mainAxisAlignment: MainAxisAlignment.start,
            idColor: ColorManager.momentPostTextColor.withValues(alpha: 0.6),
            idStyle: context.bodyMedium
                .size(12)
                .w500
                .colorExt(ColorManager.momentPostTextColor.withValues(alpha: 0.6)),
          ),
        ),
      ],
    );
  }
}