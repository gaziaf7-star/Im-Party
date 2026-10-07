import 'package:general/src/core/index.dart';

import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_bloc.dart';
import 'package:general/src/features/profile/presentation/coin_seller/view/coin_seller_screen.dart';
import 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

import '../../../../../home/home.dart';
import '../../../../../home/presentation/daily_prize/view/daily_prize_dialog.dart';
import 'DashboardWebViewScreen.dart';

/// The menu below the SVIP banner: an icon grid (fixed 4-per-row — Wallet /
/// Invitation / My Level / Badge, then Family / Agency Center / Mall / CP)
/// followed by the remaining options as plain full-width rows (Task, My
/// Room, Check in, Charge Agency, Feedback, Settings), matching the
/// reference's own "Verify / Admin-Host Room" list rows beneath its grid.
///
/// Every grid tile sits on its own rounded square with a soft, light-white
/// gradient (was a set of bright per-item colours — flattened to this one
/// light tone on request). On top of the square, items that ship a
/// dedicated icon asset (Wallet, Invitation, My Level, Badge, Family,
/// Agency Center, Mall) show their own original artwork instead of a
/// generic Material icon. Only CP still shows a plain Material icon (tinted,
/// not white, so it stays visible on the light tile), since it has no
/// artwork of its own (it was never in this menu before being linked in).
///
/// The grid was a `Wrap`, which reflows to however many 65.w tiles fit a
/// line — on some widths that read as an uneven "5 then 4" split instead of
/// a clean 4-per-row. It's now built as explicit rows of 4 equal-width
/// slots (blank slots pad out a short last row) so the column count never
/// depends on screen width, matching how a fixed icon grid looks in other
/// apps.
///
/// CP is a fully-built feature (My Relation / CP requests / CP store /
/// leaderboard, `Routes.cpPage`) that was never linked from this menu —
/// added here per request. My Room moved out of the grid into the list
/// below, right after Task, per request.
///
/// The light-white gradient every tile now shares. A subtle two-stop white
/// (rather than one flat colour) so the square still reads as a tile
/// against the card's own pure-white background, not as an invisible box.
const List<Color> _kTileGradient = [Color(0xFFFFFFFF), Color(0xFFEFF1F5)];

class ThirdCardBody extends StatelessWidget {
  const ThirdCardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
      bloc: di<FetchUserDataBloc>(),
      buildWhen: (prev, curr) =>
      prev.userEntity?.showInvitationCode !=
          curr.userEntity?.showInvitationCode,
      builder: (context, state) {
        final showInvite = state.userEntity?.showInvitationCode == true;

        // Row 1: Wallet, Invitation, My Level, Badge.
        // Row 2: Family, Agency Center, Mall, CP.
        // (A short row just leaves blank trailing slots when Invitation or
        // Agency Center is hidden — the order of what's left is unchanged.)
        final gridItems = <_MenuIconModel>[
          _MenuIconModel(
            // New dedicated wallet artwork on request (was the shared
            // agency-wallet icon).
            image: 'assets/icons/wallet_icon_tiger.png',
            gradientColors: _kTileGradient,
            title: StringManager.wallet.tr(),
            onTap: () => Navigator.pushNamed(context, Routes.coinsPage),
          ),
          // Coin Seller (Reseller) dashboard -- only ever shown to an
          // account the backend actually flags as a seller
          // (`coin_seller` on the my-data response, see
          // StringManager.isCoinSeller / MyDataModel), never to a regular
          // user, per request.
          if (StringManager.userType[7] == true)
            _MenuIconModel(
              image: 'assets/icons/coinSeller.png',
              gradientColors: _kTileGradient,
              size: 32,
              title: StringManager.coinSeller.tr(),
              onTap: () =>
                  Navigator.pushNamed(context, Routes.coinSellerScreen),
            ),
          if (showInvite)
            _MenuIconModel(
              image: 'assets/icons/invitation.png',
              gradientColors: _kTileGradient,
              title: StringManager.invitation.tr(),
              onTap: () => Navigator.pushNamed(context, Routes.inviteScreen),
            ),
          _MenuIconModel(
            image: 'assets/icons/level_up_icon.png',
            gradientColors: _kTileGradient,
            // My Level / Badge / Family / Agency Center / Mall / CP all get
            // a bigger icon than Wallet/Invitation, on request.
            size: 32,
            title: StringManager.myLevel.tr(),
            onTap: () => Navigator.pushNamed(context, Routes.levelScreen),
          ),
          _MenuIconModel(
            image: 'assets/icons/badge_icon.png',
            gradientColors: _kTileGradient,
            size: 32,
            title: StringManager.badge.tr(),
            onTap: () => Navigator.pushNamed(context, Routes.medalsScreen),
          ),
          _MenuIconModel(
            image: AssetsManager.family,
            gradientColors: _kTileGradient,
            size: 32,
            title: StringManager.family.tr(),
            onTap: () => Navigator.pushNamed(context, Routes.familyRankPage),
          ),
          if (ConstantsManager.isHostAgencyVisible)
            _MenuIconModel(
              image: 'assets/icons/agency_profile.png',
              gradientColors: _kTileGradient,
              size: 32,
              title: StringManager.agencyCenter.tr(),
              onTap: () {
                if (StringManager.userType[2]! || StringManager.userType[1]!) {
                  Navigator.pushNamed(context, Routes.newAgencyScreen);
                } else {
                  Navigator.pushNamed(context, Routes.searchForAgencyScreen);
                }
              },
            ),
          _MenuIconModel(
            image: 'assets/icons/mall_shopping.png',
            gradientColors: _kTileGradient,
            size: 32,
            title: StringManager.mall.tr(),
            onTap: () => context.pushNamedRoute(Routes.mallScreen),
          ),
          // CP uses the dedicated couple artwork while keeping the
          // existing CP route/function unchanged.
          _MenuIconModel(
            image: 'assets/icons/coupleICon.png',
            gradientColors: _kTileGradient,
            size: 32,
            title: StringManager.cP.tr(),
            onTap: () => Navigator.pushNamed(context, Routes.cpPage),
          ),
          // Role-based external dashboards, on request — only shown to a
          // user who actually has that role, opened in-app via a plain
          // WebView (DashboardWebViewScreen), with the user's own id in
          // the URL path.
          //
          // "Agency" here reuses the SAME role flag
          // (StringManager.userType[2], "hosts agent") that already gates
          // the Agency Center item above — i.e. the app's existing notion
          // // of "this account is an agency".
          // if (StringManager.userType[2] == true)
          //   _MenuIconModel(
          //     image: 'assets/icons/agency_profile.png',
          //     gradientColors: _kTileGradient,
          //     size: 32,
          //     title: 'Agency Dashboard',
          //     onTap: () => Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => DashboardWebViewScreen(
          //           url:
          //           'https://iamparty.linlive.fr/agency_dashboard/${state.userEntity?.id ?? ''}',
          //           title: 'Agency Dashboard',
          //         ),
          //       ),
          //     ),
          //   ),
          // "Manager" reuses the existing StringManager.userType[5]
          // ("manager") role flag.
          if (StringManager.userType[5] == true)
            _MenuIconModel(
              image: 'assets/icons/manager.png',
              gradientColors: _kTileGradient,
              size: 32,
              title: 'Manager',
              onTap: () {
                final userId =
                    state.userEntity?.id ?? MyDataModel.getInstance().id;
                final url =
                    'https://iamparty.linlive.fr/manager_dashboard/${userId ?? ''}';
                Methods.printLog(
                  '🔗 [Manager Dashboard] link ===> $url',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DashboardWebViewScreen(
                      url: url,
                      title: 'Manager Dashboard',
                    ),
                  ),
                );
              },
            ),
          // BD / Admin (BD Admin) / Super Admin dashboards. The app has
          // no existing field yet that marks an account as one of these
          // roles (confirmed — checked UserEntity, MyDataEntity,
          // StringManager.userType), so these three are shown to
          // EVERYONE for now rather than hidden entirely — the dashboard
          // website itself will enforce the real login/permission check
          // for whoever taps in without that role. Once the backend
          // gives the exact field/value for a user's role, wrap each of
          // these three in an `if (...)` the same way Agency/Manager are
          // above, so they only show to the right accounts.
          if (StringManager.userType[4] == true)
            _MenuIconModel(
              image: 'assets/icons/bd.png',
              // icon: Icons.badge,
              iconColor: const Color(0xFFF59E0B),
              gradientColors: _kTileGradient,
              size: 32,
              title: 'BD',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DashboardWebViewScreen(
                    url:
                    'https://iamparty.linlive.fr/bd_dashboard/${state.userEntity?.id ?? ''}',
                    title: 'BD Dashboard',
                  ),
                ),
              ),
            ),
          if (StringManager.userType[6] == true)
            _MenuIconModel(
              icon: Icons.shield,
              iconColor: const Color(0xFF9333EA),
              gradientColors: _kTileGradient,
              size: 32,
              title: 'Admin',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DashboardWebViewScreen(
                    url:
                    'https://iamparty.linlive.fr/bd_admin_dashboard/${state.userEntity?.id ?? ''}',
                    title: 'Admin Dashboard',
                  ),
                ),
              ),
            ),
          if (StringManager.userType[8] == true)
            _MenuIconModel(
              image: 'assets/icons/super.png',
              gradientColors: _kTileGradient,
              size: 32,
              title: 'Super Admin',
              onTap: () {
                final userId =
                    state.userEntity?.id ?? MyDataModel.getInstance().id;
                final url =
                    'https://iamparty.linlive.fr/super_admin_dashboard/${userId ?? ''}';
                // DEBUG (on request): print the exact URL this tile opens,
                // every time it's tapped -- check a terminal/logcat right
                // after tapping to see it.
                Methods.printLog('🔗 [Super Admin Dashboard] link ===> $url');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DashboardWebViewScreen(
                      url: url,
                      title: 'Super Admin Dashboard',
                    ),
                  ),
                );
              },
            ),
        ];

        // Everything else, as plain full-width rows underneath the grid —
        // same visual shape as the reference image's "Verify" / "Admin/Host
        // Room" rows.
        return ProfileCard(
          child: Column(
            children: [
              Padding(
                // Was horizontal: 10 — the outer three tiles sat well clear
                // of the card's edges. Tighter inset spreads the row wider,
                // pushing the first tile closer to the left edge and the
                // last tile closer to the right edge, per request.
                padding: context.paddingSymmetric(horizontal: 4, vertical: 20),
                child: _FixedIconGrid(items: gridItems),
              ),
              ListTileBody(
                image: AssetsManager.icMeCheckIn,
                title: StringManager.task.tr(),
                onTap: () => context.pushNamedRoute(Routes.taskPage),
              ),
              // Moved out of the grid above and placed right after Task,
              // per request.
              ListTileBody(
                image: AssetsManager.icMeAudioRoom,
                title: StringManager.myRoom.tr(),
                onTap: () => Methods.handleRoomEntry(
                  context,
                  di<FetchMyRoomDataBloc>().state.rooms?.audio,
                ),
              ),
              // New row, right after My Room, per request — opens the
              // existing Games lobby (Routes.gamesPage / GamesPage), the
              // same screen already reachable from the Home tab's
              // "Recommended Games" section.
              // ListTileBody(
              //   image: AssetsManager.icGame,
              //   title: StringManager.games.tr(),
              //   onTap: () => context.pushNamedRoute(Routes.gamesPage),
              // ),
              ListTileBody(
                image: AssetsManager.gift,
                title: StringManager.checkIn.tr(),
                onTap: () {
                  if (di<DailyPrizesBloc>()
                      .state
                      .requestStateGetPrize
                      .isLoaded) {
                    showDialog(
                      context: context,
                      builder: (_) => const Dialog(
                        backgroundColor: ColorManager.transparent,
                        insetPadding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 0),
                        child: DailyPrizeDialog(
                          isNeedCompleteInfoDialog: false,
                        ),
                      ),
                    );
                  } else {
                    di<DailyPrizesBloc>()
                        .add(GetDailyPrizesEvent(context: context));
                    Methods.showToast(context,
                        message: StringManager.noGift.tr());
                  }
                },
              ),
              if (StringManager.userType[3]! || StringManager.userType[6]!)
                ListTileBody(
                  image: AssetsManager.coin,
                  title: StringManager.chargeAgency.tr(),
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.chargeAgencyScreen),
                ),
              // The standalone "Withdraw" profile row was removed per
              // request -- Withdraw now lives as a tab directly inside the
              // Wallet screen's Diamond view (see diamond_view.dart), next
              // to the Exchange tab, so this separate entry point is no
              // longer needed here.
              ListTileBody(
                image: AssetsManager.chatWithUser,
                title: StringManager.feedBack.tr(),
                onTap: () =>
                    Navigator.pushNamed(context, Routes.problemReportsScreen),
              ),
              ListTileBody(
                image: AssetsManager.settings,
                title: StringManager.settings.tr(),
                onTap: () => Navigator.pushNamed(context, Routes.settingsScreen),
              ),
              5.hBox,
            ],
          ),
        );
      },
    );
  }
}

/// Lays [items] out as fixed rows of 4 equal-width columns — never a
/// width-dependent reflow — so the grid always reads as clean rows of 4,
/// same as other apps, regardless of how many items are visible (some are
/// conditional) or how wide the screen is. A short trailing row is padded
/// with blank slots rather than stretched or centered.
class _FixedIconGrid extends StatelessWidget {
  const _FixedIconGrid({required this.items});

  final List<_MenuIconModel> items;

  static const int _columns = 4;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int start = 0; start < items.length; start += _columns) {
      final rowItems = items.skip(start).take(_columns).toList();
      if (rows.isNotEmpty) rows.add(SizedBox(height: 22.h));
      rows.add(
        Row(
          children: [
            for (final item in rowItems)
              Expanded(child: _ThirdCardGridItem(item: item)),
            for (int pad = rowItems.length; pad < _columns; pad++)
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
    }
    return Column(children: rows);
  }
}

class _ThirdCardGridItem extends StatelessWidget {
  const _ThirdCardGridItem({required this.item});

  final _MenuIconModel item;

  @override
  Widget build(BuildContext context) {
    // No fixed width here on purpose — the parent _FixedIconGrid already
    // gives each tile an equal Expanded column, and Column's default
    // center alignment centers the icon+label inside whatever width that
    // column ends up being on this screen.
    return InkWell(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Every tile keeps the same light gradient square. Where a
          // dedicated PNG asset is available, the profile menu renders that
          // artwork directly; fallback Material icons are still supported.
          Container(
            height: 50.h,
            width: 50.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.gradientColors,
              ),
              borderRadius: 16.radius,
              border: Border.all(
                color: ColorManager.grey2.withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: item.image != null
                  ? ImageWidget(
                image: item.image!,
                height: item.size.h,
                width: item.size.w,
                boxFit: BoxFit.contain,
              )
                  : Icon(
                item.icon,
                color: item.iconColor ?? Colors.white,
                size: item.size.sp,
              ),
            ),
          ),
          6.hBox,
          Padding(
            padding: context.paddingSymmetric(horizontal: 4),
            child: FittedBox(
              child: TextWidget(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium
                    .size(12)
                    .colorExt(ColorManager.momentPostTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One grid tile's data. Every tile always has [gradientColors] for its
/// soft gradient square. On top of that square sits either [image] — the
/// item's own dedicated icon artwork — or, when an item has no artwork of
/// its own (only CP today), the generic Material [icon] in [iconColor]
/// (defaults to white, which only worked back when tiles were dark/bright;
/// CP now passes its own tint since the tile is light).
class _MenuIconModel extends Equatable {
  final String? image;
  final IconData? icon;
  final Color? iconColor;
  final List<Color> gradientColors;
  final String title;
  final VoidCallback onTap;

  /// Icon/image size in logical pixels (scaled via `.h`/`.w`/`.sp` at the
  /// render site). Defaults to the original 26 (Wallet/Invitation); items
  /// that asked for a bigger icon (My Level/Badge/Family/Agency
  /// Center/Mall/CP) pass 32.
  final double size;

  const _MenuIconModel({
    this.image,
    this.icon,
    this.iconColor,
    required this.gradientColors,
    required this.title,
    required this.onTap,
    this.size = 26,
  }) : assert(
  image != null || icon != null,
  'Provide either image or icon.',
  );

  @override
  List<Object?> get props =>
      [image, icon, iconColor, gradientColors, title, onTap, size];
}