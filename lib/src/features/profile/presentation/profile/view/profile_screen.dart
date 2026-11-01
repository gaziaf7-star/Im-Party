import 'package:general/src/core/index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:general/src/core/widgets/country_icon.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/get_setting_manager/get_setting_bloc.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/home/presentation/daily_prize/bloc/daily_prizes_bloc.dart';
import 'package:general/src/features/home/presentation/daily_prize/view/daily_prize_dialog.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_state.dart';
import 'package:general/src/features/profile/presentation/profile/view/widgets/f_f_f_body.dart';
import 'package:general/src/features/profile/presentation/profile/view/widgets/third_card_body.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_bloc.dart' show VipCenterBloc;
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_event.dart' show GetVipCenterEvent;
// Role tags (BD / Agent / Seller / Host) shared with the in-room profile,
// so both read the same `user_types` and cannot disagree.

part 'components/colum_info_body.dart';
part 'components/fifth_card.dart';
part 'components/icon_and_title_body.dart';
part 'components/list_tile_body.dart';
part 'components/profile_body.dart';
part 'components/profile_card.dart';
part 'widgets/coins_or_agency_widget.dart';
part 'widgets/second_card.dart';
part 'widgets/level_charm_pills.dart';
part 'widgets/mine_header.dart';
part 'widgets/second_card_body.dart';
part 'widgets/user_info_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Warm the slow SVIP list so the SVIP page opens instantly.
    final vipBloc = di<VipCenterBloc>();
    if (vipBloc.state.vip.isEmpty &&
        !vipBloc.state.requestState.isLoading) {
      vipBloc.add(const GetVipCenterEvent(isLoading: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImgWidget(
      // Home page's exact gradient band (was the panel-driven body theme/
      // scaffoldBg) — requested to match the Home page background.
      backgroundGradient: ColorManager.homeBackgroundGradient,
      // The admin image is drawn inside the scroll content (_ScrollHeader) so
      // the whole page, image included, scrolls together.
      paintHeaderImage: false,
      child: Scaffold(
        // Fixed transparent in both themes so the gradient above shows
        // through (was ColorManager.background — an opaque near-black that
        // would have hidden it in theme1).
        backgroundColor: ColorManager.transparent,
        // No top SafeArea: the header image starts under the status bar;
        // _ScrollHeader pads the content below it instead.
        body: SafeArea(
          top: false,
          child: BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
            bloc: di<FetchUserDataBloc>(),
            buildWhen: (prev, curr) =>
            prev.reqState != curr.reqState ||
                prev.userEntity != curr.userEntity,
            builder: (context, state) {
              return RefreshIndicatorWidget(
                onRefresh: () async {
                  di<FetchUserDataBloc>().add(
                    const FetchMyDataEvent(isLoading: false),
                  );
                  di<GetSettingBloc>().add(const GetSettingsEvent());
                  di<MyStoreBloc>().add(const GetMyStoreEvent());
                },
                // Was a Stack with a ShowSVGA(AssetsManager.bgMine, height:
                // 400.h, ...) painted behind the content — that SVGA is its
                // own separate background artwork/animation, sitting on top
                // of (and hiding) the shared BackgroundImgWidget gradient
                // above, which is exactly why this page's top region looked
                // different from Home's (Home paints nothing here — it lets
                // that one shared gradient fade show through untouched).
                // Dropped so both themes now share the exact same visual:
                // just the Home-matching gradient behind plain content.
                child: body(state),
              );
            },
          ),
        ),
      ),
    );
  }

  HandlingDataWidget body(FetchUserDataState state) => HandlingDataWidget(
    reqState: state.reqState,
    title: "",
    subTitle: "",
    onTap: () => di<FetchUserDataBloc>()
        .add(const FetchMyDataEvent(isLoading: false)),
    child: ConstantsManager.isTheme1 == true
        ? _NewProfileBody(data: state.userEntity ?? const MyDataEntity())
        : SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: _ScrollHeader(
        child: _ProfileBody(
            data: state.userEntity ?? const MyDataEntity()),
      ),
    ),
  );
}

/// Where the admin header image ends on the profile: the vertical middle of
/// the follow/fans card, measured inside [_ScrollHeader]'s content.
final ValueNotifier<double?> _profileHeaderHeight = ValueNotifier(null);

/// Key of [_ScrollHeader]'s stack; [_FollowCard] measures against it.
final GlobalKey _profileContentKey = GlobalKey();

/// Profile scroll content with the admin body image behind its top, from the
/// very top of the screen (under the status bar) down to the middle of the
/// follow card. Part of the scroll content, so it scrolls with the page. The
/// content itself starts below the status bar.
class _ScrollHeader extends StatelessWidget {
  const _ScrollHeader({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final image = BackgroundImgWidget.panelBodyImage();
    final size = MediaQuery.sizeOf(context);
    return Stack(
      key: _profileContentKey,
      children: [
        if (image.isNotEmpty)
          ValueListenableBuilder<double?>(
            valueListenable: _profileHeaderHeight,
            builder: (context, height, _) {
              final h = height ?? size.height * 0.3;
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: h,
                child: ImageViewWidget(
                  url: image,
                  width: size.width,
                  height: h,
                  boxFit: BoxFit.cover,
                ),
              );
            },
          ),
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: child,
        ),
      ],
    );
  }
}

/// White card around the follow / fans / friends / visitors row. Reports the
/// card's vertical centre (unscrolled) to [_profileHeaderHeight] so the header
/// image ends exactly at its middle.
class _FollowCard extends StatefulWidget {
  const _FollowCard({required this.child});

  final Widget child;

  @override
  State<_FollowCard> createState() => _FollowCardState();
}

class _FollowCardState extends State<_FollowCard> {
  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    final content =
        _profileContentKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || content == null) return;
    // Card centre in the scroll content's own coordinates: independent of
    // how far the page is scrolled.
    final centre = box
        .localToGlobal(Offset(0, box.size.height / 2), ancestor: content)
        .dy;
    if (_profileHeaderHeight.value == null ||
        (_profileHeaderHeight.value! - centre).abs() > 1) {
      _profileHeaderHeight.value = centre;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    // Square white card; a thin violet-pink-blue line and a light, simple
    // ornament in each corner.
    return Container(
      width: double.infinity,
      margin: context.paddingSymmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: ColorManager.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E5CFF).withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: const _CornerOrnamentPainter(),
        child: Padding(
          // Extra room above the counts; sides clear the corner ornaments.
          padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 14.h),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Thin violet-pink-blue border and a light, simple ornament in each corner
/// (an L bracket, a small curl and a tiny diamond).
class _CornerOrnamentPainter extends CustomPainter {
  const _CornerOrnamentPainter();

  static const _colors = [Color(0xFF8E5CFF), Color(0xFFD67BF2), Color(0xFF6FA2FF)];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: _colors,
      stops: [0.0, 0.5, 1.0],
    ).createShader(rect);

    // Faint full border.
    canvas.drawRect(
      rect.deflate(0.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = shader
        ..color = Colors.white.withValues(alpha: 0.35),
    );

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..shader = shader;
    final s = (h * 0.32).clamp(14.0, 24.0);

    for (final (sx, sy) in const [(1.0, 1.0), (-1.0, 1.0), (1.0, -1.0), (-1.0, -1.0)]) {
      canvas.save();
      canvas.translate(sx > 0 ? 0 : w, sy > 0 ? 0 : h);
      canvas.scale(sx, sy);
      final o = 4.0; // inset from the edge
      // L bracket.
      canvas.drawPath(
        Path()
          ..moveTo(o, o + s)
          ..lineTo(o, o)
          ..lineTo(o + s, o),
        line,
      );
      // Small curl inside the bracket.
      canvas.drawPath(
        Path()
          ..moveTo(o + s * 0.95, o + s * 0.30)
          ..quadraticBezierTo(o + s * 0.30, o + s * 0.30, o + s * 0.30, o + s * 0.95),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..strokeCap = StrokeCap.round
          ..shader = shader,
      );
      // Tiny diamond at the corner.
      final c = Offset(o + s * 0.30, o + s * 0.30);
      final d = s * 0.14;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - d)
          ..lineTo(c.dx + d, c.dy)
          ..lineTo(c.dx, c.dy + d)
          ..lineTo(c.dx - d, c.dy)
          ..close(),
        Paint()..shader = shader,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NewProfileBody extends StatelessWidget {
  const _NewProfileBody({required this.data});
  final MyDataEntity data;

  List<IconModel> getFirstIcons() {
    final List<IconModel> icons = [
      IconModel(
        icon: AssetsManager.icMeInvitation,
        title: StringManager.invitation,
        onTap: () {
          navKey.currentContext?.pushNamedRoute(Routes.inviteScreen);
        },
      ),
      IconModel(
        icon: AssetsManager.icMeCheckIn,
        title: StringManager.checkIn,
        onTap: () {
          final context = SafeNavigator.context;
          if (context == null) return;
          if (di<DailyPrizesBloc>().state.requestStateGetPrize.isLoaded) {
            showDialog(
              context: context,
              builder: (_) => const Dialog(
                backgroundColor: ColorManager.transparent,
                insetPadding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 0,
                ),
                child: DailyPrizeDialog(isNeedCompleteInfoDialog: false),
              ),
            );
          } else {
            di<DailyPrizesBloc>().add(
              GetDailyPrizesEvent(context: context),
            );
            Methods.safeShowToast(
              message: StringManager.noGift.tr(),
            );
          }
        },
      ),
      IconModel(
        icon: AssetsManager.icMeAudioRoom,
        title: StringManager.family,
        onTap: () {
          navKey.currentContext?.pushNamedRoute(Routes.familyRankPage);
        },
      ),
    ];

    if (ConstantsManager.isHostAgencyVisible == true) {
      icons.add(
        IconModel(
          icon: AssetsManager.icMeAgency,
          title: StringManager.agency1,
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
      icons.add(
        IconModel(
          icon: AssetsManager.icMeAgency,
          title: StringManager.chargeAgency,
          onTap: () {
            navKey.currentContext?.pushNamedRoute(Routes.chargeAgencyScreen);
          },
        ),
      );
    }

    icons.addAll([
      IconModel(
        icon: AssetsManager.icMeShop,
        title: StringManager.mall,
        onTap: () {
          navKey.currentContext?.pushNamedRoute(Routes.mallScreen);
        },
      ),
      IconModel(
        icon: AssetsManager.icMeVip,
        title: StringManager.vip,
        onTap: () {
          navKey.currentContext?.pushNamedRoute(Routes.vipScreen);
        },
      ),
      IconModel(
        icon: AssetsManager.icMeLevel,
        title: StringManager.grade,
        onTap: () {
          navKey.currentContext?.pushNamedRoute(Routes.levelScreen);
        },
      ),
      IconModel(
        icon: AssetsManager.icMeMedal,
        title: StringManager.badge,
        onTap: () {
          navKey.currentContext?.pushNamedRoute(Routes.medalsScreen);
        },
      ),
    ]);

    return icons;
  }

  static final List<IconModel> _secondIcons = [
    IconModel(
      icon: AssetsManager.icMeBlack,
      title: StringManager.blockList,
      onTap: () {
        navKey.currentContext?.pushNamedRoute(Routes.blockListScreen);
      },
    ),
    IconModel(
      icon: AssetsManager.icMeFeedback,
      title: StringManager.feedBack,
      onTap: () {
        navKey.currentContext?.pushNamedRoute(Routes.problemReportsScreen);
      },
    ),
    IconModel(
      icon: AssetsManager.icMeSettings,
      title: StringManager.settings,
      onTap: () {
        navKey.currentContext?.pushNamedRoute(Routes.settingsScreen);
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = MyDataModel.getInstance().convertMyDataEntityToUserEntity(
      data,
    );
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: _ScrollHeader(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          80.hBox,
          InkWell(
            onTap: () => Methods().userProfileNavigator(
              context: context,
              user_: user,
              userId:
              user.id.toString() == MyDataModel.getInstance().id.toString()
                  ? null
                  : user.id.toString(),
            ),
            child: _UserProfileImage(
              key: const ValueKey("profile_image_new_theme"),
              user: user,
            ),
          ),
          _UserNameRow(key: const ValueKey("user_name_new_theme"), user: user),
          2.5.hBox,
          _UserIDRow(key: const ValueKey("id_new_theme"), user: user),
          20.hBox,
          _FollowCard(
            child: FFLFBody(
              isMyProfile: true,
              data: user,
              textColor: ColorManager.momentPostTextColor,
            ),
          ),
          20.hBox,
          _FirstCardOnNewProfile(firstIcons: getFirstIcons()),
          30.hBox,
          _SecondCardOnNewProfile(secondIcons: _secondIcons),
          10.hBox,
        ],
      ),
      ),
    );
  }
}

class _SecondCardOnNewProfile extends StatelessWidget {
  const _SecondCardOnNewProfile({required List<IconModel> secondIcons})
      : _secondIcons = secondIcons;

  final List<IconModel> _secondIcons;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth,
      margin: context.paddingSymmetric(horizontal: 17.5),
      padding: context.paddingSymmetric(horizontal: 10, vertical: 20),
      // Fixed white (was cardDecoration()'s panel-driven card gradient).
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: 15.radius,
      ),
      child: Wrap(
        spacing: 20.w,
        runSpacing: 25.h,
        alignment: WrapAlignment.spaceBetween,
        children: List.generate(_secondIcons.length, (index) {
          return InkWell(
            onTap: _secondIcons[index].onTap,
            child: SizedBox(
              width: 65.w,
              child: Column(
                children: [
                  ImageWidget(
                    height: 35.h,
                    width: 35.w,
                    image: _secondIcons[index].icon,
                  ),
                  5.hBox,
                  FittedBox(
                    child: TextWidget(
                      _secondIcons[index].title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium
                          .size(12)
                          .colorExt(ColorManager.momentPostTextColor),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FirstCardOnNewProfile extends StatelessWidget {
  const _FirstCardOnNewProfile({required List<IconModel> firstIcons})
      : _firstIcons = firstIcons;

  final List<IconModel> _firstIcons;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            height: 55.h,
            width: ScreenUtil().screenWidth,
            margin: context.paddingSymmetric(horizontal: 17.5),
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: ColorManager.surfaceCardColor,
              borderRadius: BorderRadius.only(
                topLeft: 15.radiusCircular,
                topRight: 15.radiusCircular,
              ),
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                image: AssetImage(AssetsManager.bgMineWallet1),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -20.h,
                  left: 10.w,
                  child: ImageWidget(
                    height: 110.h,
                    width: 110.w,
                    boxFit: BoxFit.cover,
                    image: AssetsManager.bgMineWallet2,
                  ),
                ),
                Positioned.fill(
                  left: ScreenUtil().screenWidth / 3.0,
                  right: 15.w,
                  child: Row(
                    children: [
                      TextWidget(
                        StringManager.myWallet,
                        style: context.bodyMedium
                            .colorExt(ColorManager.onDark)
                            .w600,
                        padding: context.paddingOnly(top: 10),
                      ),
                      const Spacer(),
                      Expanded(
                        child: ButtonWidget(
                          onPressed: () =>
                              context.pushNamedRoute(Routes.coinsPage),
                          title: StringManager.check,
                          height: 35,
                          fontSize: 13,
                          isFittedBox: false,
                          titleColor: ColorManager.orange,
                          backgroundColor: ColorManager.white,
                          paddingButton: context.paddingZero(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: ScreenUtil().screenWidth,
          margin: context.paddingSymmetric(horizontal: 17.5),
          padding: context.paddingSymmetric(horizontal: 10, vertical: 20),
          // Fixed white (was cardDecoration()'s panel-driven card gradient).
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.only(
              bottomLeft: 15.radiusCircular,
              bottomRight: 15.radiusCircular,
            ),
          ),
          child: BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
            bloc: di<FetchUserDataBloc>(),
            buildWhen: (prev, curr) =>
            prev.userEntity?.showInvitationCode !=
                curr.userEntity?.showInvitationCode,
            builder: (context, state) {
              final showInvite = state.userEntity?.showInvitationCode == true;

              final icons = [
                if (showInvite) _firstIcons[0],
                ..._firstIcons.skip(1),
              ];
              return Wrap(
                spacing: 15.w,
                runSpacing: 25.h,
                alignment: WrapAlignment.spaceBetween,
                children: List.generate(icons.length, (index) {
                  return InkWell(
                    onTap: icons[index].onTap,
                    child: SizedBox(
                      width: 65.w,
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ImageWidget(
                                height: 40.h,
                                width: index == 0 ? 35.w : 40.w,
                                image: icons[index].icon,
                              ),
                              if (icons[index].title.toLowerCase() == "vip")
                                if (MyDataModel.getInstance().vip1?.id == null)
                                  Positioned(
                                    left: 30.w,
                                    child: Container(
                                      padding: context.paddingSymmetric(
                                        horizontal: 5.5,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColorManager.bColor,
                                        borderRadius: 30.radius,
                                      ),
                                      child: TextWidget(
                                        StringManager.become,
                                        // Fixed white — this badge sits on a
                                        // solid red (bColor) chip, not the
                                        // page background.
                                        style: context.bodyMedium
                                            .colorExt(ColorManager.white)
                                            .size(10),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                          5.hBox,
                          FittedBox(
                            child: TextWidget(
                              icons[index].title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.bodyMedium.size(12).colorExt(
                                ColorManager.momentPostTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class IconModel extends Equatable {
  final String icon, title;
  final VoidCallback onTap;

  const IconModel({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  List<Object?> get props => [icon, title, onTap];
}