import 'package:flutter/cupertino.dart';
import 'package:general/src/features/cp/presentation/cp_rank/bloc/cp_bloc.dart';
import 'package:general/src/features/cp/presentation/cp_rank/view/components/list_cp_body.dart';
import '../../../../../core/index.dart';

part 'components/inner_tab_bar.dart';

class CpRank extends StatefulWidget {
  const CpRank({super.key});

  @override
  State<CpRank> createState() => _CpRankState();
}

class _CpRankState extends State<CpRank> with TickerProviderStateMixin {
  late final TabController _cpLoveController;

  @override
  void initState() {
    _cpLoveController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0,
    );

    if (di<CpBloc>().state.cpLoveDState != RequestState.loaded) {
      di<CpBloc>().add(const FetchLoveCpDayEvent());
    }
    _cpLoveController.addListener(() {
      if (di<CpBloc>().state.cpLoveWState != RequestState.loaded &&
          _cpLoveController.index == 1) {
        di<CpBloc>().add(const FetchLoveCpWeeklyEvent());
      }
      if (di<CpBloc>().state.cpLoveMState != RequestState.loaded &&
          _cpLoveController.index == 2) {
        di<CpBloc>().add(const FetchLoveCpMonthlyEvent());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _cpLoveController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CpBloc, CpStates>(
      bloc: di<CpBloc>(),
      buildWhen: (prev, curr) => prev.cpLoveDState != curr.cpLoveDState || prev.cpLoveWState != curr.cpLoveWState || prev.cpLoveMState != curr.cpLoveMState || prev.usersRankLoveCpD != curr.usersRankLoveCpD || prev.usersRankLoveCpW != curr.usersRankLoveCpW || prev.usersRankLoveCpM != curr.usersRankLoveCpM,
      builder: (context, state) {
        return Container(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                AssetsManager.cpBackgroundRank,
              ),
            ),
          ),
          child: Scaffold(
            backgroundColor: ColorManager.transparent,
            appBar: AppBarWidget(
              title: StringManager.cpRank.tr(),
              iconColor: Colors.white,
              titleStyle:
                  context.bodyLarge.colorExt(ColorManager.textPrimary).w600,
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AnimatedDialog(
                          width: 30.w,
                          height: 55.h,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          titleDivider: false,
                          description: StringManager.rulesCpRank.tr(),
                          title: StringManager.rule.tr(),
                          conText: StringManager.know.tr(),
                          color: ColorManager.primary,
                          isUpdateDialog: false,
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    CupertinoIcons.question_circle,
                    color: Colors.white,
                  ),
                ),
              ],
              backgroundColor: ColorManager.transparent,
            ),
            body: Column(
              children: [
                InnerTabBar(
                  tabController: _cpLoveController,
                  color: Colors.white,
                ),
                7.5.hBox,
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      return true;
                    },
                    child: TabBarView(
                      controller: _cpLoveController,
                      children: [
                        HandlingDataWidget(
                          reqState: state.cpLoveDState,
                          title: StringManager.noUsersToday.tr(),
                          subTitle: StringManager.noUsersTodayMsg.tr(),
                          onTap: () {},
                          child: ListBodyCp(
                            topUsers: state.usersRankLoveCpD?.firstThree ?? [],
                            otherUsers: state.usersRankLoveCpD?.others ?? [],
                            usersRankCp: state.usersRankLoveCpD?.user,
                          ),
                        ),
                        HandlingDataWidget(
                          reqState: state.cpLoveWState,
                          title: StringManager.noUsersWeekly.tr(),
                          subTitle: StringManager.noUsersWeeklyMsg.tr(),
                          onTap: () {},
                          child: ListBodyCp(
                            topUsers: state.usersRankLoveCpW?.firstThree ?? [],
                            otherUsers: state.usersRankLoveCpW?.others ?? [],
                            usersRankCp: state.usersRankLoveCpW?.user,
                          ),
                        ),
                        HandlingDataWidget(
                          reqState: state.cpLoveMState,
                          title: StringManager.noUsersMonthly.tr(),
                          subTitle: StringManager.noUsersMonthlyMsg.tr(),
                          onTap: () {},
                          child: ListBodyCp(
                            topUsers: state.usersRankLoveCpM?.firstThree ?? [],
                            otherUsers: state.usersRankLoveCpM?.others ?? [],
                            usersRankCp: state.usersRankLoveCpM?.user,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
