import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/home/presentation/daily_prize/bloc/daily_prizes_bloc.dart';
import 'package:general/src/features/home/presentation/daily_prize/view/daily_prize_dialog.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

/// Unified menu section ("me" tab).
///
/// One cohesive polygon: a 4-column grid of shortcut icons (family / grade /
/// check-in / badge / VIP / store / bag / agency / invite) clipped into an
/// L-shape, with the coins balance ([Theme2CoinsCard]) nested into the cut-out
/// at the visual top-right (~2 grid cells wide). The two read as a single
/// block, not separate cards. (The diamonds card stays removed; diamonds are
/// reachable inside the coins screen's tabs.)
class Theme2MenuGrid extends StatelessWidget {
  static const int _columns = 4;
  // Number of top-row cells reserved for the coins notch (visual top-right).
  static const int _notchColumns = 2;

  final MyDataEntity data;

  const Theme2MenuGrid({super.key, required this.data});

  // Width of a single grid cell, derived from the screen width minus the
  // section's outer margins (16.w*2), inner horizontal padding (10.w*2) and the
  // inter-cell spacing (12.w * 3 gaps).
  double get _cellWidth =>
      (ScreenUtil().screenWidth - 32.w - 20.w - 36.w) / _columns;

  // Notch covers TWO cells + the gap between them; height covers the top
  // padding + one icon row + the label + half the run spacing so exactly the
  // top-right 2-tile area is cut out and the icons fill the remaining L.
  double get _notchWidth => _notchColumns * _cellWidth + 12.w;
  double get _notchHeight => 16.h + 50.h + 6.h + 16.sp + 10.h;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final cellWidth = _cellWidth;
    final notchWidth = _notchWidth;
    final notchHeight = _notchHeight;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Stack(
        children: [
          // Base: icon grid clipped into the L-shape (notch at visual top-right).
          ClipPath(
            clipper: _LShapeClipper(
              notchWidth: notchWidth + 10.w,
              notchHeight: notchHeight,
              radius: 14.r,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
              decoration: ColorManager.cardDecoration(
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
                bloc: di<FetchUserDataBloc>(),
                buildWhen:
                    (prev, curr) =>
                        prev.userEntity?.showInvitationCode !=
                        curr.userEntity?.showInvitationCode,
                builder: (context, state) {
                  final items = _buildMenuItems(context, state);
                  final tiles = <Widget>[
                    for (final item in items)
                      SizedBox(
                        width: cellWidth,
                        child: _GridMenuItem(
                          icon: item.icon,
                          label: item.label,
                          onTap: item.onTap,
                          hasDot: item.hasDot,
                        ),
                      ),
                  ];
                  // Reserve the top-right 2 cells for the coins notch. In RTL
                  // the wrap starts from the visual right, so the spacer leads;
                  // in LTR it closes the first row (visual right).
                  final notchSpacer = SizedBox(width: notchWidth);
                  final children =
                      isRtl
                          ? [notchSpacer, ...tiles]
                          : [
                            ...tiles.take(_columns - _notchColumns),
                            notchSpacer,
                            ...tiles.skip(_columns - _notchColumns),
                          ];

                  return Wrap(
                    spacing: 12.w,
                    runSpacing: 20.h,
                    alignment: WrapAlignment.start,
                    children: children,
                  );
                },
              ),
            ),
          ),
          // Coins card nested into the notch at the GEOMETRIC top-right. The
          // clipper cuts the notch at the geometric right in BOTH directions, so
          // the card must use a geometric (non-directional) Positioned — a
          // PositionedDirectional(end:0) would flip it to the visual left in RTL
          // and land it opposite the empty notch. A small inset keeps the card
          // from touching the adjacent/below icons.
          Positioned(
            top: 0,
            right: 0,
            width: notchWidth + 10.w,
            height: notchHeight,
            child: Padding(
              padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
              child: BlocBuilder<MyStoreBloc, MyStoreState>(
                bloc: di<MyStoreBloc>(),
                buildWhen:
                    (prev, curr) => prev.myStore?.coins != curr.myStore?.coins,
                builder: (context, storeState) {
                  return Theme2CoinsCard(coins: storeState.myStore?.coins ?? 0);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_MenuItemData> _buildMenuItems(
    BuildContext context,
    FetchUserDataState state,
  ) {
    final List<_MenuItemData> items = [];

    items.add(
      _MenuItemData(
        icon: AssetsManager.icMeAudioRoom,
        label: StringManager.family.tr(),
        onTap:
            () => navKey.currentContext?.pushNamedRoute(Routes.familyRankPage),
        hasDot: true,
      ),
    );

    items.add(
      _MenuItemData(
        icon: AssetsManager.icMeLevel,
        label: StringManager.grade.tr(),
        onTap: () => navKey.currentContext?.pushNamedRoute(Routes.levelScreen),
      ),
    );

    items.add(
      _MenuItemData(
        icon: AssetsManager.gift,
        label: StringManager.checkIn.tr(),
        onTap: () {
          final context = SafeNavigator.context;
          if (context == null) return;
          if (di<DailyPrizesBloc>().state.requestStateGetPrize.isLoaded) {
            showDialog(
              context: context,
              builder:
                  (_) => const Dialog(
                    backgroundColor: ColorManager.transparent,
                    insetPadding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 0,
                    ),
                    child: DailyPrizeDialog(isNeedCompleteInfoDialog: false),
                  ),
            );
          } else {
            di<DailyPrizesBloc>().add(GetDailyPrizesEvent(context: context));
            Methods.safeShowToast(message: StringManager.noGift.tr());
          }
        },
        hasDot: true,
      ),
    );

    items.add(
      _MenuItemData(
        icon: AssetsManager.icMeMedal,
        label: StringManager.badge.tr(),
        onTap: () => navKey.currentContext?.pushNamedRoute(Routes.medalsScreen),
      ),
    );

    items.add(
      _MenuItemData(
        icon: AssetsManager.icMeVip,
        label: StringManager.vip.tr(),
        onTap: () => navKey.currentContext?.pushNamedRoute(Routes.vipScreen),
      ),
    );

    items.add(
      _MenuItemData(
        icon: AssetsManager.icMeShop,
        label: StringManager.store.tr(),
        onTap: () => navKey.currentContext?.pushNamedRoute(Routes.mallScreen),
        hasDot: true,
      ),
    );

    items.add(
      _MenuItemData(
        icon: AssetsManager.icDecoration,
        label: StringManager.myBag.tr(),
        onTap: () => navKey.currentContext?.pushNamedRoute(Routes.bagScreen),
      ),
    );

    if (ConstantsManager.isHostAgencyVisible) {
      items.add(
        _MenuItemData(
          icon: AssetsManager.icMeAgency,
          label: StringManager.agency1.tr(),
          onTap: () {
            if (StringManager.userType[2]! || StringManager.userType[1]!) {
              navKey.currentContext?.pushNamedRoute(Routes.newAgencyScreen);
            } else {
              navKey.currentContext?.pushNamedRoute(
                Routes.searchForAgencyScreen,
              );
            }
          },
        ),
      );
    }

    if (StringManager.userType[3]! || StringManager.userType[6]!) {
      items.add(
        _MenuItemData(
          icon: AssetsManager.icMeAgency,
          label: StringManager.chargeAgency.tr(),
          onTap:
              () => navKey.currentContext?.pushNamedRoute(
                Routes.chargeAgencyScreen,
              ),
        ),
      );
    }

    // Invite friends (دعوة الأصدقاء)
    if (state.userEntity?.showInvitationCode == true) {
      items.add(
        _MenuItemData(
          icon: AssetsManager.icMeInvitation,
          label: StringManager.inviteFriendsTitle.tr(),
          onTap:
              () => navKey.currentContext?.pushNamedRoute(Routes.inviteBonus),
        ),
      );
    }

    // Customer service (خدمة العملاء) — relocated from settings section
    // to grid, next to invite friends per user request
    items.add(
      _MenuItemData(
        icon: AssetsManager.icMeSupport,
        label: StringManager.feedBack.tr(),
        onTap:
            () => navKey.currentContext?.pushNamedRoute(Routes.problemReportsScreen),
      ),
    );

    return items;
  }
}

/// Clips the menu card into an L-shape by cutting a rectangle out of the
/// geometric top-right corner (== the visual right edge of the screen, which is
/// where the coins card nests in BOTH layouts). All corners — the four outer
/// corners AND the inner notch corner — are rounded so the shape reads as a
/// smooth, elegant polygon rather than hard right angles.
class _LShapeClipper extends CustomClipper<Path> {
  final double notchWidth;
  final double notchHeight;
  final double radius;

  const _LShapeClipper({
    required this.notchWidth,
    required this.notchHeight,
    required this.radius,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final r = radius;
    final w = size.width;
    final h = size.height;

    // Inner notch corner gets a gentler rounding than the outer corners.
    final ir = r * 0.6;

    // Notch at the geometric top-right (visual right on screen). Walk the
    // outline clockwise from just after the top-left corner, rounding every
    // turn — including the concave inner notch corner at (w - notchWidth,
    // notchHeight).
    path.moveTo(r, 0);

    // Top edge → down into the notch's left wall (convex notch-mouth corner).
    path.lineTo(w - notchWidth - ir, 0);
    path.arcToPoint(
      Offset(w - notchWidth, ir),
      radius: Radius.circular(ir),
    );

    // Down the notch's left wall → the concave inner corner.
    path.lineTo(w - notchWidth, notchHeight - ir);
    path.arcToPoint(
      Offset(w - notchWidth + ir, notchHeight),
      radius: Radius.circular(ir),
      clockwise: false,
    );

    // Across the notch floor → the convex top-right outer corner of the L.
    path.lineTo(w - r, notchHeight);
    path.arcToPoint(
      Offset(w, notchHeight + r),
      radius: Radius.circular(r),
    );

    // Down the right edge → bottom-right corner.
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));

    // Bottom edge → bottom-left corner.
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));

    // Left edge → back to the top-left corner.
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_LShapeClipper oldClipper) =>
      oldClipper.notchWidth != notchWidth ||
      oldClipper.notchHeight != notchHeight ||
      oldClipper.radius != radius;
}

/// Coins card (العملات المعدنية) — compact card nested into the menu grid's
/// top-right L-notch (sized by its parent to fit ~2 grid cells). Opens the
/// coins screen whose tabs cover coins / diamonds / earnings.
class Theme2CoinsCard extends StatelessWidget {
  final int coins;

  const Theme2CoinsCard({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamedRoute(Routes.coinsPage),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: ColorManager.cardDecoration(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageWidget(
                  image: AssetsManager.icCoinBgV2,
                  height: 24.h,
                  width: 24.w,
                  boxFit: BoxFit.contain,
                ),
                6.wBox,
                Flexible(
                  child: Text(
                    '$coins',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorManager.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            6.hBox,
            Text(
              StringManager.coins.tr(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ColorManager.secondaryText, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool hasDot;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hasDot = false,
  });
}

class _GridMenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool hasDot;

  const _GridMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 50.h,
                width: 50.w,
                decoration: ColorManager.cardDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: ImageWidget(
                    image: icon,
                    height: 30.h,
                    width: 30.w,
                    boxFit: BoxFit.contain,
                  ),
                ),
              ),
              // Red dot
              if (hasDot)
                Positioned(
                  top: -3.h,
                  right: -3.w,
                  child: Container(
                    height: 8.h,
                    width: 8.w,
                    decoration: const BoxDecoration(
                      color: ColorManager.bColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          6.hBox,
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ColorManager.secondaryText,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
