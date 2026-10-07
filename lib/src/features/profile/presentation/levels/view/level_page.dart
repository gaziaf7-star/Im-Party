import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../domain/entities/level_badges_entity.dart';
import '../bloc/levels_bloc/levels_bloc.dart';
import '../bloc/levels_bloc/levels_event.dart';
import '../bloc/levels_bloc/levels_state.dart';
part 'components/level_tab_bar.dart';
part 'components/level_tab_bar_view.dart';
part 'components/level_view.dart';
part 'components/bottom_card.dart';
part 'components/level_body.dart';
part 'components/level_listtile.dart';
part 'components/charm_view.dart';
part 'components/charge_view.dart';
part 'components/room_view.dart';
part 'widgets/level_item.dart';
part 'components/level_card.dart';
part 'widgets/sender_level.dart';
part 'widgets/reciver_level.dart';

class LevelPage extends StatefulWidget {
  final int? index;
  const LevelPage({super.key, this.index});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> with TickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    _controller = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.index ?? 0,
    );
    di<LevelBloc>().add(const GetLevelsBadges(type: 1));
    di<LevelBloc>().add(GetUserLevels());

    Future.microtask(() {
      di<LevelBloc>().add(ChangeValueEvent(_controller.index == 0));
    });
    _controller.addListener(() {
      di<LevelBloc>().add(ChangeTabEvent(_controller.index));
      di<LevelBloc>().add(ChangeValueEvent(_controller.index == 0));
    });

    super.initState();
  }

  @override
  void dispose() {
    di<LevelBloc>().add(const ChangeTabEvent(0));
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalPage = BlocBuilder<LevelBloc, AllLevelsState>(
      bloc: di<LevelBloc>(),
      buildWhen: (prev, curr) =>
      prev.levelsBadgesRequest != curr.levelsBadgesRequest ||
          prev.levelsBadges != curr.levelsBadges,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorManager.white,
          appBar: AppBarWidget(
            title: StringManager.myLevel.tr(),
            iconColor: ColorManager.black,
            backgroundColor: ColorManager.white,
            titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
          ),
          body: Column(
            children: [
              LevelTabBar(controller: _controller),
              Flexible(
                child: HandlingDataWidget(
                  titleStyle:
                  context.bodyLarge.colorExt(ColorManager.black),
                  reqState: state.levelsBadgesRequest,
                  title: StringManager.noLevels.tr(),
                  subTitle: StringManager.noLevelsMsg.tr(),
                  onTap: () {
                    di<LevelBloc>().add(const GetLevelsBadges(type: 1));
                    di<LevelBloc>().add(GetUserLevels());
                  },
                  child: LevelTabBarView(
                    controller: _controller,
                    senderBadges: state.levelsBadges?.sender ?? [],
                    reciverBadges: state.levelsBadges?.reciver ?? [],
                    chargeBadges: state.levelsBadges?.charge ?? [],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
    return normalPage;
  }
}