import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/profile/data/model/badges_model.dart';
import 'package:general/src/features/profile/domain/entities/get_user_badges_entity.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/badge_bloc/badges_bloc.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/pick_badge_bloc/pick_my_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/pick_badge_bloc/pick_my_badges_event.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/pick_badge_bloc/pick_my_badges_state.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/select_badge_bloc/select_badge_bloc.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/select_badge_bloc/select_badge_event.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/select_badge_bloc/select_badge_state.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';

part 'components/badges_body.dart';

part 'components/badge_manage_page.dart';

part 'components/badges_body_bottom_dialog.dart';

part 'components/dialog_medal_pick_personal.dart';

part 'components/dialog_medal_pick_room.dart';

part 'components/header_body.dart';

part 'components/medals_tab_bar.dart';

part 'components/personal_tab_view_body.dart';

part 'components/room_tab_view_body.dart';

part 'components/tab_bar_dialog.dart';

part 'components/tab_bar_view.dart';

part 'widgets/badge_container_body.dart';

part 'widgets/badge_items.dart';

part 'widgets/container_item_pick.dart';

class MedalsPage extends StatefulWidget {
  const MedalsPage({super.key});

  @override
  State<MedalsPage> createState() => _MedalsPageState();
}

class _MedalsPageState extends State<MedalsPage> with TickerProviderStateMixin {
  final GetBadgesBloc _badgesBloc = di<GetBadgesBloc>();
  late final TabController _firstDownController, _secondDownController;
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    di<GetBadgesBloc>().add(const ChangeMyMedalsAppBarUIEvent(index: 0));

    pageController = PageController(initialPage: 0);
    _firstDownController = TabController(length: 2, vsync: this);
    _secondDownController = TabController(length: 2, vsync: this);

    if (!di<GetBadgesBloc>().state.myAllBadgeState.isLoaded) {
      di<GetBadgesBloc>()
          .add(GetMyAllBadges(id: MyDataModel.getInstance().id.toString()));
    }
    if (!di<UserBadgesBloc>().state.myStates.isLoaded) {
      context.read<UserBadgesBloc>().add(const GetMyBadges());
    }
    if (_badgesBloc.state.roomBadgeRequest != RequestState.loaded) {
      _badgesBloc.add(const RoomEvent());
    }

    _firstDownController.addListener(_firstDownListener);
  }

  void _firstDownListener() {
    if (_badgesBloc.state.activityBadgeRequest != RequestState.loaded) {
      _badgesBloc.add(const GiftEvent());
    }
  }

  @override
  void dispose() {
    _firstDownController.removeListener(_firstDownListener);
    _firstDownController.dispose();
    _secondDownController.dispose();
    super.dispose();
  }

  // first --> honor , activity
  // second --> achievement , empty
  @override
  Widget build(BuildContext context) {
    final normalPage = DefaultTabController(
      length: 4,
      child: BlocListener<PickMyBadgesBloc, BasePickMyBadgesState>(
        bloc: di<PickMyBadgesBloc>(),
        listener: (context, state) {
          if (state is PickMyBadgesSucssesState) {
            context.read<UserBadgesBloc>().add(
                  const GetMyBadges(),
                );
          }
        },
        child: Scaffold(
          // Dark gold/brown gradient background, matching the "Medal of
          // Honor" reference. The animated sparkle SVGA layer that used to
          // sit here was removed on request -- a moving background was
          // distracting; a plain (static) gradient colour is what's wanted.
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF241605), Color(0xFF0D0904)],
                    ),
                  ),
                ),
              ),
              BlocBuilder<GetBadgesBloc, GetBadgesStates>(
            bloc: _badgesBloc,
            buildWhen: (prev, curr) =>
                prev.myMedalsTabBarIndex != curr.myMedalsTabBarIndex ||
                prev.rechargeBadgeRequest != curr.rechargeBadgeRequest ||
                prev.roomBadgeRequest != curr.roomBadgeRequest ||
                prev.activityBadgeRequest != curr.activityBadgeRequest ||
                prev.giftBadgeRequest != curr.giftBadgeRequest ||
                prev.myAllBadgeState != curr.myAllBadgeState,
            builder: (context, state) {
              return Column(
                children: [
                  _HeaderBody(
                    index: state.myMedalsTabBarIndex,
                    pageController: pageController,
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        if (notification is OverscrollNotification) {
                          if ((notification.dragDetails?.delta.dx ?? 0) < 0 &&
                              pageController.page != 1.0) {
                            di<GetBadgesBloc>()
                                .add(const ChangeMyMedalsAppBarUIEvent(
                              index: 1,
                            ));
                            pageController.animateToPage(1,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeIn);
                          } else if ((notification.dragDetails?.delta.dx ?? 0) >
                                  0 &&
                              pageController.page != 0.0) {
                            di<GetBadgesBloc>()
                                .add(const ChangeMyMedalsAppBarUIEvent(
                              index: 0,
                            ));
                            pageController.animateToPage(0,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeIn);
                          }
                        }
                        return true;
                      },
                      child: PageView(
                        controller: pageController,
                        children: [
                          Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: Container(
                              width: ScreenUtil().screenWidth,
                              decoration: BoxDecoration(
                                color: ColorManager.scaffoldBg,
                                borderRadius: 25.radius,
                              ),
                              child: _PersonalTabViewBody(
                                controller: _firstDownController,
                                state: state,
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: Container(
                              width: ScreenUtil().screenHeight,
                              decoration: BoxDecoration(
                                color: ColorManager.scaffoldBg,
                                borderRadius: 25.radius,
                              ),
                              child: _RoomTabViewBody(
                                controller: _secondDownController,
                                state: state,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
            ],
          ),
        ),
      ),
    );

    return normalPage;
  }
}
