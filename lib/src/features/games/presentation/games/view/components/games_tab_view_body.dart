part of 'package:general/src/features/games/presentation/games/view/games_page.dart';

class _GamesTabViewBody extends StatefulWidget {
  const _GamesTabViewBody({
    required this.bloc,
    required this.onRefresh,
  });

  final ExploreBloc bloc;
  final Future<void> Function() onRefresh;

  @override
  State<_GamesTabViewBody> createState() => _GamesTabViewBodyState();
}

class _GamesTabViewBodyState extends State<_GamesTabViewBody> {
  late final VideoPlayerController controller;
  final Random _random = Random();
  int? _lastIndex;

  void _pickRandomRoom(BuildContext context) async {
    final List<RoomEntity> result = di<HomeBloc>()
        .state
        .popular
        .where((room) => !(room.passwordStatus ?? false))
        .toList();

    if (result.isEmpty) return;

    int newIndex;
    do {
      newIndex = _random.nextInt(result.length);
    } while (newIndex == _lastIndex && result.length > 1);

    _lastIndex = newIndex;
  }

  @override
  void initState() {
    di<ExploreBloc>().add(const ScrollGameEvent(isScrolled: false));
    _pickRandomRoom(context);
    controller = VideoPlayerController.asset(AssetsManager.gamesBackground);
    if (!widget.bloc.state.reqStateGamers.isLoaded) {
      widget.bloc.add(const FetchGamersEvent());
    }
    controller.initialize();
    controller.play();
    controller.setLooping(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicatorWidget(
      onRefresh: widget.onRefresh,
      child: BackgroundImgWidget(
        child: Stack(
          children: [
            Container(
              height: ScreenUtil().screenHeight,
              width: ScreenUtil().screenWidth,
              color: ColorManager.white,
              child: VideoPlayer(controller),
            ),
            Container(
              height: ScreenUtil().screenHeight,
              width: ScreenUtil().screenWidth,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [
                    ColorManager.transparent,
                    ColorManager.transparent,
                    ColorManager.offWhite,
                    ColorManager.offWhite,
                    ColorManager.offWhite,
                  ],
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: context.paddingOnly(start: 20, end: 7),
                      child: Row(
                        children: [
                          if (Navigator.canPop(context))
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: ColorManager.white,
                              ),
                            ),
                          ImageViewWidget(
                            url: MyDataModel.getInstance().profile?.image ?? '',
                            displayName: MyDataModel.getInstance().name ?? '',
                            height: 40.h,
                            width: 40.w,
                            shape: BoxShape.circle,
                            border: Border.all(color: ColorManager.white),
                          ),
                          5.wBox,
                          Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: [
                              Container(
                                height: 20.h,
                                padding: context
                                    .paddingSymmetric(
                                        vertical: 3, horizontal: 5)
                                    .copyWith(start: 22),
                                decoration: BoxDecoration(
                                    color: ColorManager.black.withValues(
                                      alpha: (0.4),
                                    ),
                                    borderRadius: 15.radius),
                                child: TextWidget(
                                  di<MyStoreBloc>()
                                          .state
                                          .myStore
                                          ?.coins
                                          .toString() ??
                                      '',
                                  style: context.bodySmall.bold
                                      .colorExt(ColorManager.lightOrange),
                                ),
                              ),
                              Image.asset(
                                AssetsManager.coinPayment,
                                height: 22.h,
                                width: 22.w,
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => context.pushNamedRoute(
                                Routes.rankScreen,
                                arguments: 3),
                            icon: Image.asset(
                              AssetsManager.reward,
                              height: 30.h,
                              width: 30.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                    170.hBox,
                    SizedBox(
                      height: 410.h,
                      child: Stack(
                        children: [
                          Container(
                            height: 375.h,
                            padding: context.paddingOnly(
                                top: 10, start: 10, end: 10, bottom: 1),
                            margin: context.paddingSymmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: ColorManager.white,
                              borderRadius: 15.radius,
                              boxShadow: [
                                BoxShadow(
                                  color: ColorManager.grey
                                      .withValues(alpha: (0.25)),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2.5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  StringManager.recommendedGames.tr(),
                                  padding:
                                      context.paddingSymmetric(horizontal: 10),
                                  style: context.bodyMedium.bold.size(15),
                                ),
                                8.hBox,
                                SizedBox(
                                  height: 330.h,
                                  child: HandlingDataWidget(
                                    reqState:
                                        widget.bloc.state.outerReqStateGames,
                                    title: StringManager.noGamesRoom.tr(),
                                    subTitle: StringManager.noGamesRoomMsg.tr(),
                                    onTap: () => widget.bloc.add(
                                      const FetchGamesEvent(
                                          isGamesLoading: false, type: 'outer'),
                                    ),
                                    child: NotificationListener<
                                        ScrollNotification>(
                                      onNotification:
                                          (ScrollNotification notification) {
                                        if (notification
                                            is OverscrollNotification) {
                                          if ((notification
                                                      .dragDetails?.delta.dy ??
                                                  0) <
                                              0) {
                                            di<ExploreBloc>().add(
                                              const ScrollGameEvent(
                                                isScrolled: true,
                                              ),
                                            );
                                          }
                                          if ((notification
                                                      .dragDetails?.delta.dy ??
                                                  0) >
                                              0) {
                                            di<ExploreBloc>().add(
                                              const ScrollGameEvent(
                                                isScrolled: false,
                                              ),
                                            );
                                          }
                                        }
                                        return true;
                                      },
                                      child: GamesGridWidget(
                                        bloc: widget.bloc,
                                        shrinkWrap: true,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        maxItems:
                                            widget.bloc.state.isScrolled == true
                                                ? null
                                                : 9,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 20,
                            child: InkWell(
                              onTap: () async {
                                if (MyDataModel.getInstance().hasRoom ??
                                    false) {
                                  di<RoomStateManager>().navigateToRoom(
                                    RoomEntryRequest(
                                      context: context,
                                      isLive: false,
                                      roomData: RoomEntity(
                                        ownerId: MyDataModel.getInstance().id,
                                        id: MyDataModel.getInstance()
                                                .myRoomData
                                                ?.id ??
                                            0,
                                        name: MyDataModel.getInstance()
                                                .myRoomData
                                                ?.name ??
                                            "",
                                        cover: MyDataModel.getInstance()
                                                .myRoomData
                                                ?.cover ??
                                            "",
                                        roomBackground:
                                            MyDataModel.getInstance()
                                                    .myRoomData
                                                    ?.background ??
                                                "",
                                        mode: MyDataModel.getInstance()
                                                .myRoomData
                                                ?.mode
                                                .toString() ??
                                            '',
                                        uuidOwnerRoom:
                                            MyDataModel.getInstance().uuid ??
                                                "",
                                        giftPrice: MyDataModel.getInstance()
                                                .myRoomData
                                                ?.giftPrice ??
                                            "",
                                      ),
                                      isGame: true,
                                    ),
                                  );
                                } else {
                                  if (di<HomeBloc>().state.popular.isNotEmpty) {
                                    final popularRoom = di<HomeBloc>()
                                        .state
                                        .popular[_lastIndex ?? 0];
                                    di<RoomStateManager>().navigateToRoom(
                                      RoomEntryRequest(
                                        context: context,
                                        roomData: popularRoom,
                                        isLive:
                                            popularRoom.streamType == "live",
                                        isGame: true,
                                      ),
                                    );
                                  } else {
                                    context
                                        .pushNamedRoute(Routes.createRoomPage);
                                  }
                                }
                              },
                              child: Stack(
                                alignment: AlignmentDirectional.centerStart,
                                children: [
                                  Container(
                                    height: 20.h,
                                    padding: context
                                        .paddingSymmetric(
                                            vertical: 3, horizontal: 5)
                                        .copyWith(start: 43),
                                    decoration: BoxDecoration(
                                        color: ColorManager.white,
                                        borderRadius: 15.radius),
                                    child: TextWidget(
                                      StringManager.quickGame.tr(),
                                      style: context.bodySmall
                                          .colorExt(ColorManager.lightOrange)
                                          .size(10)
                                          .copyWith(letterSpacing: 0.2),
                                    ),
                                  ),
                                  Image.asset(
                                    AssetsManager.quickGames,
                                    height: 40.h,
                                    width: 40.w,
                                    fit: BoxFit.fill,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    10.hBox,
                    TextWidget(
                      StringManager.activeGamer.tr(),
                      padding: context.paddingSymmetric(horizontal: 15),
                      style: context.bodyMedium.bold.size(15),
                    ),
                    5.hBox,
                    AutoScrollGamers(bloc: widget.bloc),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AutoScrollGamers extends StatefulWidget {
  final ExploreBloc bloc;

  const AutoScrollGamers({super.key, required this.bloc});

  @override
  State<AutoScrollGamers> createState() => _AutoScrollGamersState();
}

class _AutoScrollGamersState extends State<AutoScrollGamers> {
  final ScrollController _scrollController = ScrollController();
  late double itemWidth;
  late Timer _autoScrollTimer;
  bool _isAnimating = false;

  int currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    itemWidth = 65.w + (8.w * 2);
  }

  @override
  void initState() {
    super.initState();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (!_isAnimating) _scrollToNextItem();
    });
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToNextItem() async {
    final gamers = widget.bloc.state.gamers;
    if (gamers.isEmpty || !_scrollController.hasClients) return;

    final nextIndex = currentIndex + 1;
    if (nextIndex >= gamers.length) {
      // either stop auto-scroll or loop back to 0 if you prefer
      _autoScrollTimer.cancel();
      return;
    }

    final double targetOffset = nextIndex * itemWidth;

    // Guard to avoid overlapping animate calls
    _isAnimating = true;
    try {
      await _scrollController.animateTo(
        targetOffset.clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      // animateTo can throw if controller disposed while animating
    } finally {
      _isAnimating = false;
    }

    // update index AFTER animation finished
    currentIndex = nextIndex;

    // trigger pagination load if nearing the end
    if (nextIndex >= gamers.length - 2) {
      widget.bloc.add(const FetchMoreGamersEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return HandlingDataWidget(
      reqState: widget.bloc.state.reqStateGamers,
      title: '',
      subTitle: '',
      onTap: () => widget.bloc.add(const FetchGamersEvent()),
      child: SizedBox(
        height: 90.h,
        width: ScreenUtil().screenWidth,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          // use a non-snapping physics — this avoids conflicts with animateTo
          physics: const BouncingScrollPhysics(),
          itemCount: widget.bloc.state.gamers.length,
          itemExtent: itemWidth,
          itemBuilder: (context, index) {
            final gamer = widget.bloc.state.gamers[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: GestureDetector(
                onTap: () {
                  Methods().userProfileNavigator(
                    context: context,
                    userId: gamer.id.toString(),
                    // user_: gamer,
                  );
                },
                // ensure avatar width uses .w so it's consistent with itemWidth
                child: UserImage(
                  image: gamer.profile?.image ?? '',
                  displayName: gamer.name ?? '',
                  imageSize: 65.w,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
