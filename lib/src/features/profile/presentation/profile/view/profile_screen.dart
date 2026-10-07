import 'package:general/src/core/index.dart';
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
  Widget build(BuildContext context) {
    return BackgroundImgWidget(
      // Home page's exact gradient band (was the panel-driven body theme/
      // scaffoldBg) — requested to match the Home page background.
      backgroundGradient: ColorManager.homeBackgroundGradient,
      child: Scaffold(
        // Fixed transparent in both themes so the gradient above shows
        // through (was ColorManager.background — an opaque near-black that
        // would have hidden it in theme1).
        backgroundColor: ColorManager.transparent,
        body: SafeArea(
          top: !ConstantsManager.isTheme1,
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
      child: _ProfileBody(
          data: state.userEntity ?? const MyDataEntity()),
    ),
  );
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
          FFLFBody(
            isMyProfile: true,
            data: user,
            textColor: ColorManager.momentPostTextColor,
          ),
          20.hBox,
          _FirstCardOnNewProfile(firstIcons: getFirstIcons()),
          30.hBox,
          _SecondCardOnNewProfile(secondIcons: _secondIcons),
          10.hBox,
        ],
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