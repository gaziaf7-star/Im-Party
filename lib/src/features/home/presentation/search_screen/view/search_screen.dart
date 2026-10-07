import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/chats/presentation/friends/view/friends_page.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_states.dart';
import 'package:general/src/features/home/presentation/search_screen/components/search_user_row.dart';

import '../../../../../core/widgets/md_indicator.dart';
import '../../../../games/games.dart';
import '../bloc/search_manager/search_events.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  late final TabController _controller;
  final _bloc = di<SearchBloc>();

  @override
  void initState() {
    super.initState();
    _controller = TabController(
        length: ConstantsManager.isAudioRoomsEnabled ? 2 : 1, vsync: this);
    _controller.addListener(() {
      _bloc.add(ChangeCurrentIndexEvent(currentIndex: _controller.index));
    });
    _bloc.add(const SearchAddListenerEvent());
  }

  @override
  void dispose() {
    _bloc.add(const SearchRemoveListenerEvent());
    controller.dispose();
    _controller.dispose();
    super.dispose();
    _bloc.add(const SearchEvent(keyWord: ''));
  }

  @override
  Widget build(BuildContext context) {
    // Owner request: this page's background is now the same fixed
    // purple -> blue gradient as the home page
    // (ColorManager.homeBackgroundGradient), replacing the plain fixed
    // white from the previous pass. AppBarWidget moved off the Scaffold's
    // own `appBar:` slot and into the body's own Column instead — the
    // native appBar sits ABOVE body and would have painted its own solid
    // strip over the gradient rather than letting it show through, the
    // same restructuring already done for rank_categories_page.dart /
    // rank_screen.dart.
    return Scaffold(
      backgroundColor: ColorManager.transparent,
      body: Stack(
        children: [
          Container(
            height: ScreenUtil().screenHeight,
            width: ScreenUtil().screenWidth,
            decoration: const BoxDecoration(
              gradient: ColorManager.homeBackgroundGradient,
            ),
          ),
          Column(
            children: [
              AppBarWidget(
                height: 60.h,
                backgroundColor: ColorManager.transparent,
                // Owner request: back arrow black — reads clearly on the
                // new light gradient (was the AppBarWidget's own default).
                iconColor: Colors.black,
                title: CustomSearchBar(
                  onEditingComplete: () {},
                  controller: controller,
                  hintText: StringManager.search.tr(),
                  keyboardType: TextInputType.text,
                  // Owner request: search-bar text bigger still (14 default
                  // -> 16 -> now 18). Its colour is already CustomSearchBar's
                  // fixed ColorManager.momentPostTextColor (#100F0F,
                  // effectively black), so no colour change was needed there.
                  fontSize: 18.sp,
                  onSubmit: (str) {},
                  onChanged: (str) {
                    if ((str ?? '').isNotEmpty) {
                      di<SearchBloc>().add(SearchEvent(keyWord: str ?? ''));
                    } else {
                      _bloc.add(const SearchEvent(keyWord: ''));
                    }
                  },
                  onPress: () {},
                ),
                titleStyle: context.titleLarge.w600
                    .copyWith(fontFamily: StringManager.fontFamily),
              ),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchStates>(
                  bloc: di<SearchBloc>(),
                  buildWhen: (prev, curr) =>
                  prev.reqState != curr.reqState || prev.data != curr.data,
                  builder: (context, state) {
                    return DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            overlayColor: WidgetStateColor.transparent,
                            indicatorSize: TabBarIndicatorSize.label,
                            isScrollable: false,
                            tabAlignment: TabAlignment.fill,
                            dividerHeight: 0,
                            // Was ColorManager.headerColor throughout (a
                            // mutable, panel-driven near-black) — fixed to
                            // the app's own brand gradient, matching the
                            // Chats page tab-bar convention used elsewhere
                            // in the app.
                            indicator: MDIndicator(
                              indicatorColor:
                              ColorManager.brandGradientColors.last,
                              indicatorWidth: 17.0.w,
                              indicatorHeight: 4.h,
                              radius: 20,
                            ),
                            controller: _controller,
                            labelPadding: context.paddingOnly(end: 10),
                            unselectedLabelStyle: context.bodyLarge.w500
                                .colorExt(ColorManager.momentPostTextColor
                                .withValues(alpha: (0.5)))
                                .size(16),
                            labelStyle: context.bodyLarge.w600
                                .colorExt(ColorManager.brandGradientColors.last)
                                .size(16),
                            tabs: [
                              Text(StringManager.user.tr()),
                              if (ConstantsManager.isAudioRoomsEnabled)
                                Text(StringManager.room.tr()),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _controller,
                              children: [
                                HandlingDataWidget(
                                  reqState: state.reqState,
                                  title: '',
                                  subTitle: '',
                                  child: ListView.builder(
                                    controller: state.usersScrollCtrl,
                                    padding: context.paddingAll(10),
                                    itemCount: state.data?.users.length ?? 0,
                                    itemBuilder: (context, index) {
                                      if (state.data?.users != null) {
                                        if (state.data?.users.isNotEmpty ==
                                            true) {
                                          return SearchUserRow(
                                            user: state.data?.users[index] ??
                                                const UserEntity(),
                                            endIcon: Icon(
                                              Icons.arrow_forward_ios,
                                              color: ColorManager
                                                  .momentPostTextColor
                                                  .withValues(alpha: (0.5)),
                                              size: 15,
                                            ),
                                          );
                                        }
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                if (ConstantsManager.isAudioRoomsEnabled)
                                  HandlingDataWidget(
                                    reqState: state.reqState,
                                    subTitle: "",
                                    title: "",
                                    child: ListView.separated(
                                      controller: state.roomsScrollCtrl,
                                      separatorBuilder: (context, index) =>
                                          SizedBox(height: 10.h),
                                      padding: context.paddingAll(15),
                                      itemCount:
                                      state.data?.rooms?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        if (state.data?.rooms != null) {
                                          if (state.data?.rooms
                                              ?.isNotEmpty ==
                                              true) {
                                            return MultiTapCard(
                                              onTap: () {
                                                di<RoomStateManager>()
                                                    .navigateToRoom(
                                                  RoomEntryRequest(
                                                    context: context,
                                                    isLive: state
                                                        .data
                                                        ?.rooms?[index]
                                                        .roomType ==
                                                        "live",
                                                    roomData: state.data
                                                        ?.rooms?[index] ??
                                                        const RoomEntity(),
                                                  ),
                                                );
                                              },
                                              child: CardLiveWidget(
                                                index: index,
                                                isRoomSearch: true,
                                                roomEntity: state.data
                                                    ?.rooms?[index] ??
                                                    const RoomEntity(),
                                              ),
                                            );
                                          }
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}