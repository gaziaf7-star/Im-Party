import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/family/presentation/family_rank/view/components/top_user_item.dart';
import 'package:general/src/features/family/presentation/family_rank/view/widgets/family_card.dart';
import '../../../../../core/widgets/md_indicator.dart';
import '../../../../../core/widgets/vip_container.dart';
import '../../../../games/domain/entities/user_top_entity.dart';
import '../bloc/get_all_family/get_all_family_bloc.dart';

part 'components/family_rank_body.dart';
part 'components/family_rank_tab_bar_view.dart';
part 'components/family_tab_bar.dart';
part 'components/header_body.dart';
part 'components/top_three_body.dart';
part 'components/view_body.dart';
part 'widgets/family_rank_row_item.dart';
part 'widgets/top_three_families_item.dart';
part 'components/familes_tab_bar_view.dart';
part 'components/rank_tab_bar.dart';

class FamilyRankPage extends StatefulWidget {
  const FamilyRankPage({super.key});

  @override
  State<FamilyRankPage> createState() => FamilyRankPageState();
}

class FamilyRankPageState extends State<FamilyRankPage>
    with TickerProviderStateMixin {
  final GetFamilyRankingBloc _getFamilyRankingBloc = di<GetFamilyRankingBloc>();
  late TabController controller;
  late TabController mainController;

  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    mainController = TabController(length: 2, vsync: this);
    di<GetAllFamilyBloc>().add(const GetFamilyEvent());
    if (!_getFamilyRankingBloc.state.dailyRequestState.isLoaded &&
        controller.index == 0) {
      _getFamilyRankingBloc.add(const GetDailyFamilyRankingEvent());
    }
    controller.addListener(_addListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _addListener() {
    di<GetFamilyRankingBloc>()
        .add(TopUsersViewEvent(tabBarIndex: controller.index));
    if (!_getFamilyRankingBloc.state.dailyRequestState.isLoaded &&
        controller.index == 0) {
      _getFamilyRankingBloc.add(const GetDailyFamilyRankingEvent());
    }
    if (!_getFamilyRankingBloc.state.weeklyRequestState.isLoaded &&
        controller.index == 1) {
      _getFamilyRankingBloc.add(const GetWeeklyFamilyRankingEvent());
    }
    if (!_getFamilyRankingBloc.state.monthlyRequestState.isLoaded &&
        controller.index == 2) {
      _getFamilyRankingBloc.add(const GetMonthlyFamilyRankingEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalPage = Scaffold(
      body: Stack(
        children: [
          Image.asset(
            AssetsManager.rankBackground,
            fit: BoxFit.fill,
            height: ScreenUtil().screenHeight,
            width: ScreenUtil().screenWidth,
          ),
          SafeArea(
            child: Column(
              children: [
                AppBarWidget(
                  title: StringManager.family.tr(),
                  titleStyle: context.titleLarge.bold
                      .size(18)
                      .colorExt(ColorManager.onDark),
                  iconLasted: Padding(
                    padding: context.paddingOnly(end: 10),
                    child: BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
                        bloc: di<FetchUserDataBloc>(),
                        buildWhen: (prev, curr) => false,
                        builder: (context, state) {
                          return TextButtonWidget(
                            onTap: () {
                              if (MyDataModel.getInstance().familyId != 0) {
                                Navigator.pushNamed(
                                    context, Routes.familyScreen,
                                    arguments: MyDataModel.getInstance()
                                        .familyId
                                        .toString());
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  Routes.createFamilyIntro,
                                );
                              }
                            },
                            content: MyDataModel.getInstance().familyId != 0
                                ? StringManager.myFamily.tr()
                                : StringManager.createFamily.tr(),
                            fontColor: ColorManager.white,
                          );
                        }),
                  ),
                  iconColor: ColorManager.white,
                  backgroundColor: ColorManager.transparent,
                ),
                RankTabBar(controller: mainController),
                Expanded(
                  child: TabBarView(
                    controller: mainController,
                    children: [
                      Column(children: [
                        15.hBox,
                        _FamilyTabBar(controller: controller),
                        10.hBox,
                        Expanded(
                          child: BlocBuilder<GetFamilyRankingBloc,
                              GetFamilyRankingState>(
                            bloc: _getFamilyRankingBloc,
                            buildWhen: (prev, curr) =>
                                prev.dailyOtherFamilies !=
                                    curr.dailyOtherFamilies ||
                                prev.dailyRequestState !=
                                    curr.dailyRequestState ||
                                prev.weeklyOtherFamilies !=
                                    curr.weeklyOtherFamilies ||
                                prev.weeklyRequestState !=
                                    curr.weeklyRequestState ||
                                prev.monthlyOtherFamilies !=
                                    curr.monthlyOtherFamilies ||
                                prev.monthlyRequestState !=
                                    curr.monthlyRequestState,
                            builder: (context, state) {
                              return TabBarView(
                                controller: controller,
                                physics: const ClampingScrollPhysics(),
                                children: [
                                  _FamilyRankTabBarView(
                                    otherFamilyRankList:
                                        state.dailyOtherFamilies ?? [],
                                    requestState: state.dailyRequestState,
                                    rankingType: RankingType.daily,
                                  ),
                                  _FamilyRankTabBarView(
                                    otherFamilyRankList:
                                        state.weeklyOtherFamilies ?? [],
                                    requestState: state.weeklyRequestState,
                                    rankingType: RankingType.weekly,
                                  ),
                                  _FamilyRankTabBarView(
                                    otherFamilyRankList:
                                        state.monthlyOtherFamilies ?? [],
                                    requestState: state.monthlyRequestState,
                                    rankingType: RankingType.monthly,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ]),
                      const FamilesTabBarView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return normalPage;
  }
}
