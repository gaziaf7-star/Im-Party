
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/country_icon.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/md_indicator.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/games/domain/entities/ranking_entity.dart';
import 'package:general/src/features/games/domain/entities/user_top_entity.dart';
import 'package:general/src/features/family/domain/entities/family_rank_entity.dart';
import 'package:general/src/features/room/presentation/manager/manager_top_inroom/topin_room_states.dart';
import 'package:general/src/features/room/room.dart';

part 'components/header_tab_bar_body.dart';

part 'components/rank_room_body.dart';

part 'components/tab_bar_body.dart';

part 'components/user_profile_body.dart';

part 'components/users_body.dart';
part 'components/item_rank_top_three.dart';
part 'components/top_three_widget.dart';
part 'components/user_info_rank_widget.dart';
part 'components/rank_container_widget.dart';

class RankRoomPage extends StatefulWidget {
  final EnterRoomModel roomEntity;

  const RankRoomPage({required this.roomEntity, super.key});

  @override
  RankRoomPageState createState() => RankRoomPageState();
}

class RankRoomPageState extends State<RankRoomPage>
    with TickerProviderStateMixin {
  final bloc = di<RankingRoomBloc>();
  late final TabController _outerTabController,
      _firstTabController,
      _secondTabController;

  @override
  void initState() {
    _outerTabController =
        TabController(length: 2, vsync: this, initialIndex: 0);
    _firstTabController =
        TabController(length: 3, vsync: this, initialIndex: 0);
    _secondTabController =
        TabController(length: 3, vsync: this, initialIndex: 0);

    bloc.add(
      GetCoinsTopDayEvent(roomId: '${widget.roomEntity.id}'),
    );

    bloc.add(
      const ChangeColorEvent(color: Color(0xffDCB483)),
    );
    _firstTabController.addListener(_listenerFirstTab);
    _secondTabController.addListener(_listenerSecondTab);
    _outerTabController.addListener(_listenerChangeBgImage);
    super.initState();
  }

  void _listenerFirstTab() {
    final Map<int, Map<int, Function>> eventMap = {
      0: {
        1: () {
          bloc.add(
              GetCoinsTopWeeklyEvent(roomId: '${widget.roomEntity.id}'));
        },
        2: () {
          bloc.add(
            GetCoinsTopMonthlyEvent(roomId: '${widget.roomEntity.id}'),
          );
        },
      },
    };

    eventMap[0]?[_firstTabController.index]?.call();
  }

  void _listenerSecondTab() {
    final Map<int, Map<int, Function>> eventMap = {
      1: {
        1: () {
          di<RankingRoomBloc>().add(GetDiamondsTopWeeklyEvent(
              roomId: '${widget.roomEntity.id}'));
        },
        2: () {
          di<RankingRoomBloc>().add(GetDiamondsTopMonthlyEvent(
              roomId: '${widget.roomEntity.id}'));
        },
      },
    };

    eventMap[1]?[_secondTabController.index]?.call();
  }

  void _listenerChangeBgImage() {
    if (_outerTabController.index == 1) {
      di<RankingRoomBloc>()
          .add(GetDiamondsTopDayEvent(roomId: '${widget.roomEntity.id}'));
    }
    di<RankingRoomBloc>().add(
      ChangeColorEvent(
        color: _outerTabController.index == 0
            ? const Color(0xffDCB483)
            : const Color(0xffE0D6FF),
      ),
    );
  }

  @override
  void dispose() {
    _firstTabController.removeListener(_listenerFirstTab);
    _firstTabController.removeListener(_listenerSecondTab);
    _outerTabController.removeListener(_listenerChangeBgImage);
    _firstTabController.dispose();
    _secondTabController.dispose();
    _outerTabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RankingRoomBloc, RankingRoomState>(
      bloc: di<RankingRoomBloc>(),
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        return Container(
          height: MediaQuery.sizeOf(context).height / 1.25,
          width: ScreenUtil().screenWidth,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: ColorManager.followButtonGrident,
            ),
            borderRadius: BorderRadius.only(
              topLeft: 13.radiusCircular,
              topRight: 13.radiusCircular,
            ),
            color: ColorManager.white,
          ),
          child: Column(
            children: [
              10.hBox,
              _HeaderTabBarBody(controller: _outerTabController),
              Expanded(
                child: TabBarView(
                  controller: _outerTabController,
                  children: [
                    _RankingRoomBody(
                      headerTabController: _firstTabController,
                      outerTabController: _outerTabController,
                      roomData: widget.roomEntity,
                      dayState: state.dayCoinState,
                      dayUsersRank: state.dayCoinUsersRank,
                      weekState: state.weekCoinState,
                      weekUsersRank: state.weekCoinUsersRank,
                      monthState: state.monthCoinState,
                      monthUsersRank: state.monthCoinUsersRank,
                      index: 1,
                    ),
                    _RankingRoomBody(
                      headerTabController: _secondTabController,
                      roomData: widget.roomEntity,
                      dayState: state.dayDiamondState,
                      dayUsersRank: state.dayDiamondUsersRank,
                      weekState: state.weekDiamondState,
                      weekUsersRank: state.weekDiamondUsersRank,
                      monthState: state.monthDiamondState,
                      monthUsersRank: state.monthDiamondUsersRank,
                      outerTabController: _outerTabController,
                      index: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
