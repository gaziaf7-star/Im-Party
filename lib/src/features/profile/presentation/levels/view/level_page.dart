import 'dart:math' as math;

import 'package:flutter_animate/flutter_animate.dart';
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
part 'components/level_gallery.dart';
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
    return Scaffold(
      backgroundColor: _LevelGalleryColors.skyBottom,
      extendBodyBehindAppBar: true,
      appBar: AppBarWidget(
        title: StringManager.myLevel.tr(),
        iconColor: Colors.white,
        backgroundColor: Colors.transparent,
        shadow: Colors.transparent,
        titleStyle: context.bodyLarge.bold.size(18).colorExt(Colors.white),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _StarrySky()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(height: kToolbarHeight - 6.h),
                _LevelTypeTabs(controller: _controller),
                Expanded(
                  child: BlocBuilder<LevelBloc, AllLevelsState>(
                    bloc: di<LevelBloc>(),
                    buildWhen: (prev, curr) =>
                        prev.levelsBadgesRequest != curr.levelsBadgesRequest ||
                        prev.levelsBadges != curr.levelsBadges ||
                        prev.userLevels != curr.userLevels ||
                        prev.userLevelsRequest != curr.userLevelsRequest,
                    builder: (context, state) {
                      return HandlingDataWidget(
                        titleStyle: context.bodyLarge.colorExt(Colors.white),
                        reqState: state.levelsBadgesRequest,
                        title: StringManager.noLevels.tr(),
                        subTitle: StringManager.noLevelsMsg.tr(),
                        onTap: () {
                          di<LevelBloc>().add(const GetLevelsBadges(type: 1));
                          di<LevelBloc>().add(GetUserLevels());
                        },
                        child: TabBarView(
                          controller: _controller,
                          children: [
                            _tab(
                              state,
                              type: 'sender',
                              label: StringManager.wealth.tr(),
                              badges: state.levelsBadges?.sender ?? [],
                              title: StringManager.wealthDescription.tr(),
                              body: StringManager.wealthDescriptionBody.tr(),
                            ),
                            _tab(
                              state,
                              type: 'reciever',
                              label: StringManager.charm.tr(),
                              badges: state.levelsBadges?.reciver ?? [],
                              title: StringManager.charmDescription.tr(),
                              body: StringManager.charmDescriptionBody.tr(),
                            ),
                            _tab(
                              state,
                              type: 'charge',
                              label: StringManager.charge.tr(),
                              badges: state.levelsBadges?.charge ?? [],
                              title: StringManager.chargeDescription.tr(),
                              body: StringManager.chargeDescriptionBody.tr(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(
    AllLevelsState state, {
    required String type,
    required String label,
    required List<LevelBadgesEntity> badges,
    required String title,
    required String body,
  }) {
    final numbers = _LevelNumbers.of(type, state);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          18.hBox,
          _LevelHero(numbers: numbers, label: label)
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 380))
              .slideY(begin: .05, end: 0, curve: Curves.easeOutCubic),
          22.hBox,
          _LevelPanel(
            badges: badges,
            level: numbers.level,
            title: title,
            body: body,
          ),
        ],
      ),
    );
  }
}
