import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/family/domain/entities/family_rank_entity.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/games/presentation/ranking/components/agency_rank/rank_agency_body.dart';

import 'widgets/rank_tab_bar.dart';

part 'components/center_shadow_body.dart';

part 'components/inner_tab_bar.dart';

part 'components/rank_body.dart';

part 'components/rank_container_widget.dart';

part 'widgets/item_rank_top_three.dart';

part 'widgets/top_three_widget.dart';

part 'widgets/user_info_rank_widget.dart';

class RankScreen extends StatefulWidget {
  final int? initialIndex;

  const RankScreen({this.initialIndex, super.key});

  @override
  State<RankScreen> createState() => RankScreenState();
}

class RankScreenState extends State<RankScreen> with TickerProviderStateMixin {
  late final TabController _rankController;
  late final TabController _charmController;
  late final TabController _roomController;
  late final TabController _wealthController;
  late final TabController _gameController;
  late final TabController _agencyController;
  late final TabController _luckyController;
  static late ValueNotifier<int> innerTabNotifier;

  // Debounce for tab changes
  int? _lastTabIndex;
  DateTime? _lastTabChange;
  static const Duration _tabDebounceDuration = Duration(milliseconds: 350);
  final List<VoidCallback> _controllerListeners = [];

  @override
  void initState() {
    super.initState();
    innerTabNotifier = ValueNotifier<int>(0);
    _rankController = TabController(
      length: 6,
      vsync: this,
      initialIndex: widget.initialIndex ?? 0,
    );
    _wealthController = TabController(length: 4, vsync: this);
    _charmController = TabController(length: 4, vsync: this);
    _roomController = TabController(length: 4, vsync: this);
    _gameController = TabController(length: 4, vsync: this);
    _agencyController = TabController(length: 4, vsync: this);
    _luckyController = TabController(length: 4, vsync: this);

    // First time: update images and fetch data for initialIndex
    _handleImagesSelection();
    _fetchIfNeeded(widget.initialIndex ?? 0);

    // Debounced tab change listener
    _rankController.addListener(() {
      if (!_rankController.indexIsChanging) {
        final now = DateTime.now();
        if (_lastTabIndex == _rankController.index &&
            _lastTabChange != null &&
            now.difference(_lastTabChange!) < _tabDebounceDuration) {
          return;
        }
        _lastTabIndex = _rankController.index;
        _lastTabChange = now;
        _handleImagesSelection();
        _fetchIfNeeded(_rankController.index);
        switch (_rankController.index) {
          case 0:
            innerTabNotifier.value = _roomController.index;
            break;
          case 1:
            innerTabNotifier.value = _wealthController.index;
            break;
          case 2:
            innerTabNotifier.value = _charmController.index;
            break;
          case 3:
            innerTabNotifier.value = _gameController.index;
            break;
          case 4:
            innerTabNotifier.value = _agencyController.index;
            break;
          case 5:
            innerTabNotifier.value = _luckyController.index;
            break;
        }
      }
    });

    attach(_wealthController);
    attach(_charmController);
    attach(_roomController);
    attach(_gameController);
    attach(_agencyController);
    attach(_luckyController);
  }

  void attach(TabController controller) {
    void listener() {
      if (!controller.indexIsChanging) {
        innerTabNotifier.value = controller.index;
      }
    }

    controller.addListener(listener);
    _controllerListeners.add(listener);
  }

  @override
  void dispose() {
    // _controllerListeners only tracks inner tab controllers (added via attach())
    final innerControllers = [
      _wealthController,
      _charmController,
      _roomController,
      _gameController,
      _agencyController,
      _luckyController,
    ];

    for (int i = 0; i < innerControllers.length; i++) {
      innerControllers[i].removeListener(_controllerListeners[i]);
    }

    _rankController.dispose();
    for (final c in innerControllers) {
      c.dispose();
    }

    innerTabNotifier.dispose();
    super.dispose();
  }

  void _handleImagesSelection() {
    di<RankingBloc>()
        .add(HandleInfoCurrentRankEvent(currentIndex: _rankController.index));
  }

  void _fetchIfNeeded(int index) {
    final bloc = di<RankingBloc>();
    // Only fetch if not already loading or loaded recently (simple cache)
    switch (index) {
      case 0: // Rooms
        if (bloc.state.rDState != RequestState.loaded &&
            bloc.state.rDState != RequestState.loading) {
          bloc.add(const FetchRoomsDayEvent());
        }
        if (bloc.state.rWState != RequestState.loaded &&
            bloc.state.rWState != RequestState.loading) {
          bloc.add(const FetchRoomWeeklyEvent());
        }
        if (bloc.state.rMState != RequestState.loaded &&
            bloc.state.rMState != RequestState.loading) {
          bloc.add(const FetchRoomMonthlyEvent());
        }
        if (bloc.state.rhState != RequestState.loaded &&
            bloc.state.rhState != RequestState.loading) {
          bloc.add(const FetchRoomHourEvent());
        }
        break;
      case 1: // Coins (Wealth)
        if (bloc.state.cDState != RequestState.loaded &&
            bloc.state.cDState != RequestState.loading) {
          bloc.add(const FetchCoinsDayEvent());
        }
        if (bloc.state.cWState != RequestState.loaded &&
            bloc.state.cWState != RequestState.loading) {
          bloc.add(const FetchCoinsWeeklyEvent());
        }
        if (bloc.state.cMState != RequestState.loaded &&
            bloc.state.cMState != RequestState.loading) {
          bloc.add(const FetchCoinsMonthlyEvent());
        }
        if (bloc.state.chState != RequestState.loaded &&
            bloc.state.chState != RequestState.loading) {
          bloc.add(const FetchCoinsHourEvent());
        }
        break;
      case 2: // Diamonds (Charm)
        if (bloc.state.dDState != RequestState.loaded &&
            bloc.state.dDState != RequestState.loading) {
          bloc.add(const FetchDiamondsDayEvent());
        }
        if (bloc.state.dWState != RequestState.loaded &&
            bloc.state.dWState != RequestState.loading) {
          bloc.add(const FetchDiamondsWeeklyEvent());
        }
        if (bloc.state.dMState != RequestState.loaded &&
            bloc.state.dMState != RequestState.loading) {
          bloc.add(const FetchDiamondsMonthlyEvent());
        }
        if (bloc.state.dhState != RequestState.loaded &&
            bloc.state.dhState != RequestState.loading) {
          bloc.add(const FetchDiamondsHourEvent());
        }
        break;
      case 3: // Gamers
        if (bloc.state.gDState != RequestState.loaded &&
            bloc.state.gDState != RequestState.loading) {
          bloc.add(const FetchGamersDayEvent());
        }
        if (bloc.state.gWState != RequestState.loaded &&
            bloc.state.gWState != RequestState.loading) {
          bloc.add(const FetchGamersWeeklyEvent());
        }
        if (bloc.state.gMState != RequestState.loaded &&
            bloc.state.gMState != RequestState.loading) {
          bloc.add(const FetchGamersMonthlyEvent());
        }
        if (bloc.state.ghState != RequestState.loaded &&
            bloc.state.ghState != RequestState.loading) {
          bloc.add(const FetchGamersHourEvent());
        }
        break;
      case 4: // Agency
        if (bloc.state.agencyDState != RequestState.loaded &&
            bloc.state.agencyDState != RequestState.loading) {
          bloc.add(const FetchAgencyDayEvent());
        }
        if (bloc.state.agencyWState != RequestState.loaded &&
            bloc.state.agencyWState != RequestState.loading) {
          bloc.add(const FetchAgencyWeeklyEvent());
        }
        if (bloc.state.agencyMState != RequestState.loaded &&
            bloc.state.agencyMState != RequestState.loading) {
          bloc.add(const FetchAgencyMonthlyEvent());
        }
        if (bloc.state.agencyHState != RequestState.loaded &&
            bloc.state.agencyHState != RequestState.loading) {
          bloc.add(const FetchAgencyHourEvent());
        }
        break;
      case 5: // Lucky Gift
        if (bloc.state.lDState != RequestState.loaded &&
            bloc.state.lDState != RequestState.loading) {
          bloc.add(const FetchLuckyDayEvent());
        }
        if (bloc.state.lWState != RequestState.loaded &&
            bloc.state.lWState != RequestState.loading) {
          bloc.add(const FetchLuckyWeeklyEvent());
        }
        if (bloc.state.lMState != RequestState.loaded &&
            bloc.state.lMState != RequestState.loading) {
          bloc.add(const FetchLuckyMonthlyEvent());
        }
        if (bloc.state.lhState != RequestState.loaded &&
            bloc.state.lhState != RequestState.loading) {
          bloc.add(const FetchLuckyHourEvent());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RankingBloc, RankingStates>(
      bloc: di<RankingBloc>(),
      buildWhen: (prev, curr) =>
          prev.index != curr.index ||
          prev.rhState != curr.rhState ||
          prev.rDState != curr.rDState ||
          prev.rWState != curr.rWState ||
          prev.rMState != curr.rMState ||
          prev.chState != curr.chState ||
          prev.cDState != curr.cDState ||
          prev.cWState != curr.cWState ||
          prev.cMState != curr.cMState ||
          prev.dhState != curr.dhState ||
          prev.dDState != curr.dDState ||
          prev.dWState != curr.dWState ||
          prev.dMState != curr.dMState ||
          prev.ghState != curr.ghState ||
          prev.gDState != curr.gDState ||
          prev.gWState != curr.gWState ||
          prev.gMState != curr.gMState ||
          prev.agencyHState != curr.agencyHState ||
          prev.agencyDState != curr.agencyDState ||
          prev.agencyWState != curr.agencyWState ||
          prev.agencyMState != curr.agencyMState ||
          prev.lhState != curr.lhState ||
          prev.lDState != curr.lDState ||
          prev.lWState != curr.lWState ||
          prev.lMState != curr.lMState,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorManager.transparent,
          body: Stack(
            children: [
              Image.asset(
                state.imageBackground,
                fit: BoxFit.fill,
                height: ScreenUtil().screenHeight,
                width: ScreenUtil().screenWidth,
                filterQuality: FilterQuality.low,
              ),
              Column(
                children: [
                  AppBarWidget(
                    title: StringManager.ranking.tr(),
                    backgroundColor: ColorManager.transparent,
                    titleStyle: context.titleLarge.bold
                        .colorExt(ColorManager.white),
                    iconColor: ColorManager.white,
                  ),
                  TopTabBar(controller: _rankController, fromRoom: false),
                  Expanded(
                    child: TabBarView(
                      controller: _rankController,
                      children: [
                        // 0) ROOMS
                        RankBody(
                          rankController: _rankController,
                          controller: _roomController,
                          reqStateHour: state.rhState,
                          reqStateDay: state.rDState,
                          reqStateWeak: state.rWState,
                          reqStateMonth: state.rMState,
                          usersRankHour: state.usersRankRh,
                          usersRankDay: state.usersRankRD,
                          usersRankWeak: state.usersRankRW,
                          usersRankMonth: state.usersRankRM,
                          index: 0,
                          imageRank: state.imageRank,
                          color: state.backgroundColor,
                          onTapHour: () =>
                              di<RankingBloc>().add(const FetchRoomHourEvent()),
                          onTapDay: () =>
                              di<RankingBloc>().add(const FetchRoomsDayEvent()),
                          onTapWeek: () => di<RankingBloc>()
                              .add(const FetchRoomWeeklyEvent()),
                          onTapMonthly: () => di<RankingBloc>()
                              .add(const FetchRoomMonthlyEvent()),
                          isPhoto: _rankController.index != 0,
                        ),

                        // 1) COINS (Wealth)
                        RankBody(
                          rankController: _rankController,
                          controller: _wealthController,
                          reqStateHour: state.chState,
                          reqStateDay: state.cDState,
                          reqStateWeak: state.cWState,
                          reqStateMonth: state.cMState,
                          usersRankHour: state.usersRankCh,
                          usersRankDay: state.usersRankCD,
                          usersRankWeak: state.usersRankCW,
                          usersRankMonth: state.usersRankCM,
                          index: 1,
                          imageRank: state.imageRank,
                          color: state.backgroundColor,
                          onTapHour: () =>
                              di<RankingBloc>().add(const FetchCoinsHourEvent()),
                          onTapDay: () =>
                              di<RankingBloc>().add(const FetchCoinsDayEvent()),
                          onTapWeek: () => di<RankingBloc>()
                              .add(const FetchCoinsWeeklyEvent()),
                          onTapMonthly: () => di<RankingBloc>()
                              .add(const FetchCoinsMonthlyEvent()),
                          isPhoto: _rankController.index != 1,
                        ),

                        // 2) DIAMONDS (Charm)
                        RankBody(
                          rankController: _rankController,
                          controller: _charmController,
                          reqStateHour: state.dhState,
                          reqStateDay: state.dDState,
                          reqStateWeak: state.dWState,
                          reqStateMonth: state.dMState,
                          usersRankHour: state.usersRankDh,
                          usersRankDay: state.usersRankDD,
                          usersRankWeak: state.usersRankDW,
                          usersRankMonth: state.usersRankDM,
                          index: 2,
                          imageRank: state.imageRank,
                          color: state.backgroundColor,
                          onTapHour: () => di<RankingBloc>()
                              .add(const FetchDiamondsHourEvent()),
                          onTapDay: () => di<RankingBloc>()
                              .add(const FetchDiamondsDayEvent()),
                          onTapWeek: () => di<RankingBloc>()
                              .add(const FetchDiamondsWeeklyEvent()),
                          onTapMonthly: () => di<RankingBloc>()
                              .add(const FetchDiamondsMonthlyEvent()),
                          isPhoto: _rankController.index != 2,
                        ),

                        // 3) GAMERS
                        RankBody(
                          rankController: _rankController,
                          controller: _gameController,
                          reqStateHour: state.ghState,
                          reqStateDay: state.gDState,
                          reqStateWeak: state.gWState,
                          reqStateMonth: state.gMState,
                          usersRankHour: state.usersRankGh,
                          usersRankDay: state.usersRankGD,
                          usersRankWeak: state.usersRankGW,
                          usersRankMonth: state.usersRankGM,
                          index: 3,
                          imageRank: state.imageRank,
                          color: state.backgroundColor,
                          onTapHour: () => di<RankingBloc>()
                              .add(const FetchGamersHourEvent()),
                          onTapDay: () => di<RankingBloc>()
                              .add(const FetchGamersDayEvent()),
                          onTapWeek: () => di<RankingBloc>()
                              .add(const FetchGamersWeeklyEvent()),
                          onTapMonthly: () => di<RankingBloc>()
                              .add(const FetchGamersMonthlyEvent()),
                          isPhoto: _rankController.index != 3,
                        ),

                        // 4) AGENCY
                        RankAgencyBody(
                          controller: _agencyController,
                          rankController: _rankController,
                          reqStateHour: state.agencyHState,
                          reqStateDay: state.agencyDState,
                          reqStateWeak: state.agencyWState,
                          reqStateMonth: state.agencyMState,
                          usersAgencyRankHour: state.usersRankAgencyH,
                          usersAgencyRankDay: state.usersRankAgencyD,
                          usersAgencyRankWeek: state.usersRankAgencyW,
                          usersAgencyRankMonth: state.usersRankAgencyM,
                          index: 4,
                          imageRank: state.imageRank,
                          color: state.backgroundColor,
                          onTapHour: () => di<RankingBloc>()
                              .add(const FetchAgencyHourEvent()),
                          onTapDay: () => di<RankingBloc>()
                              .add(const FetchAgencyDayEvent()),
                          onTapWeek: () => di<RankingBloc>()
                              .add(const FetchAgencyWeeklyEvent()),
                          onTapMonthly: () => di<RankingBloc>()
                              .add(const FetchAgencyMonthlyEvent()),
                          isPhoto: _rankController.index != 4,
                        ),

                        // 5) LUCKY GIFT
                        RankBody(
                          rankController: _rankController,
                          controller: _luckyController,
                          reqStateHour: state.lhState,
                          reqStateDay: state.lDState,
                          reqStateWeak: state.lWState,
                          reqStateMonth: state.lMState,
                          usersRankHour: state.usersRankLh,
                          usersRankDay: state.usersRankLD,
                          usersRankWeak: state.usersRankLW,
                          usersRankMonth: state.usersRankLM,
                          index: 5,
                          imageRank: state.imageRank,
                          color: state.backgroundColor,
                          onTapHour: () =>
                              di<RankingBloc>().add(const FetchLuckyHourEvent()),
                          onTapDay: () =>
                              di<RankingBloc>().add(const FetchLuckyDayEvent()),
                          onTapWeek: () => di<RankingBloc>()
                              .add(const FetchLuckyWeeklyEvent()),
                          onTapMonthly: () => di<RankingBloc>()
                              .add(const FetchLuckyMonthlyEvent()),
                          isPhoto: _rankController.index != 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
