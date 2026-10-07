import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/cache/cache_alpha_widget.dart';
import 'package:general/src/features/room/presentation/component/rocket/rocket_launch_banner.dart';
import 'package:general/src/features/room/presentation/component/rocket/rocket_launch_overlay.dart';
import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
import 'package:general/src/core/widgets/cache/cache_video_widget.dart';
import 'package:general/src/features/home/domain/entities/carousel_entity.dart';
import 'package:general/src/features/home/presentation/home/bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'package:general/src/features/home/presentation/home/view/components/carousel_page_view.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_events_sheet.dart';
import 'package:general/src/features/room/presentation/gifts/controller/lucky_gift_service.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/gifts/view/component/normal_gift/gift_bottom_bar.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/gift_bloc/gift_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/view/component/gift_banners/lucky_gift_win.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_state.dart';
import 'package:general/src/features/room/presentation/gifts/view/component/gift_banners/sender_balance_banner.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/show_normal_gift.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/lucky_box_icon.dart';
import 'package:general/src/features/room/presentation/music/view/component/music_widget.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_bloc.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_state.dart';
import 'package:general/src/features/room/room.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

/// The live (video) room's foreground overlay — its own copy, forked off the
/// audio `ForegroundWidget`. It renders the gift / lucky-gift / entry-effect /
/// super-boom overlays and the side action column, driven by the shared,
/// controller-agnostic gift blocs.
///
/// Differences from the audio overlay:
/// - Entry + RTM are driven by the LIVE controller's connection (the live room
///   never goes through `RoomHandlerBloc`), via [LiveRoomData].
/// - No CP seat grid, music widget, PK overlays, or seat-based gift animations
///   (those are audio-room/seat concepts).
class LiveForegroundWidget extends StatefulWidget {
  final String roomId;
  final String userId;
  final bool isHost;

  /// Opens the gift sheet (used by the lucky-box icon).
  final VoidCallback? giftButtonCallBack;

  const LiveForegroundWidget({
    super.key,
    required this.roomId,
    required this.userId,
    required this.isHost,
    this.giftButtonCallBack,
  });

  @override
  State<LiveForegroundWidget> createState() => _LiveForegroundWidgetState();
}

class _LiveForegroundWidgetState extends State<LiveForegroundWidget>
    with TickerProviderStateMixin {
  bool _enteredHandled = false;
  VoidCallback? _connListener;
  live.UTDRoomController? _attached;

  @override
  void initState() {
    super.initState();
    LiveRoomData.instance.liveControllerNotifier.addListener(
      _onControllerChanged,
    );
    _attach(LiveRoomData.instance.liveController);

    // Re-entering an already-connected room (restored from minimize): the entry
    // sequence already ran, so don't replay it — just make sure RTM is wired.
    if (LiveRoomData.instance.liveController?.isConnected ?? false) {
      _enteredHandled = true;
      _startRtm();
    } else {
      _handleConnection();
    }
  }

  void _onControllerChanged() {
    _attach(LiveRoomData.instance.liveController);
    _handleConnection();
  }

  void _attach(live.UTDRoomController? c) {
    if (c == null || _connListener != null) return;
    _connListener = _handleConnection;
    _attached = c;
    c.connectionState.addListener(_connListener!);
  }

  void _handleConnection() {
    final c = LiveRoomData.instance.liveController;
    if (c == null || !c.isConnected || _enteredHandled) return;
    // Race guard (Crashlytics: "Null check operator used on a null value" in
    // onEnterLiveRoomSuccess): the engine can finish connecting BEFORE the
    // enter_room HTTP response has been applied to LiveRoomData.room.
    // onEnterLiveRoomSuccess reads `room` (id/gift price), so running it now
    // would crash AND permanently skip loadSecondaryData + the joinRoom
    // announcement (because _enteredHandled would already be true). Defer the
    // whole entry sequence; the EnterRoomSuccesMessageState listener below
    // re-invokes this method right after it assigns the room, at which point
    // both conditions (connected + room set) hold and it runs exactly once.
    if (LiveRoomData.instance.roomOrNull == null) return;
    _enteredHandled = true;
    _startRtm();
    LiveRoomData.instance.onEnterLiveRoomSuccess();
    if (_connListener != null) {
      c.connectionState.removeListener(_connListener!);
      _connListener = null;
    }
  }

  void _startRtm() {
    LiveRoomData.instance.initRtm(
      roomId: widget.roomId,
      userModelId: widget.userId,
      isHost: widget.isHost,
      tickerProvider: this,
    );
  }

  @override
  void dispose() {
    LiveRoomData.instance.liveControllerNotifier.removeListener(
      _onControllerChanged,
    );
    if (_connListener != null) {
      _attached?.connectionState.removeListener(_connListener!);
      _connListener = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Once entry-time category warm-up completes, warm the first visible
        // grid as well. FetchGiftBloc retains both categories and per-category
        // lists, exactly like the audio sheet, so subsequent opens are instant.
        BlocListener<FetchGiftBloc, FetchGiftsStates>(
          bloc: di<FetchGiftBloc>(),
          listenWhen:
              (previous, current) =>
                  previous.reqStateGiftCategory !=
                      current.reqStateGiftCategory &&
                  current.reqStateGiftCategory.isLoaded,
          listener: (_, state) {
            if (state.giftCategory.isEmpty) return;
            final first = state.giftCategory.first;
            if (state.getReqStateById(first.id) != RequestState.loaded) {
              di<FetchGiftBloc>().add(
                FetchGiftsByCategoryEvent(
                  categoryId: first.id,
                  typeId: first.id,
                ),
              );
            }
          },
        ),
        // A rejected special-message (yallow banner) send used to fail 100%
        // silently — surface the backend's error to the sender. The live room
        // has no BackgroundWidget (the audio room's listener host), so the
        // foreground overlay hosts it here.
        BlocListener<OnRoomBloc, OnRoomStates>(
          bloc: di<OnRoomBloc>(),
          listener: (context, state) {
            if (state is SendYallowBannerErrorState) {
              Methods.showToast(context, isError: true, message: state.message);
            }
          },
        ),
        BlocListener<RoomHandlerBloc, RoomHandlerStates>(
          bloc: di<RoomHandlerBloc>(),
          listener: (context, state) {
            if (state is EnterRoomSuccesMessageState) {
              di<GiftBloc>().add(
                UpdateRoomGiftsPriceEvent(price: '${state.room.giftPrice}'),
              );
              Methods.setDataRooms(
                data: {
                  "name": state.room.roomName ?? "",
                  "ownerId": state.room.ownerId,
                  "id": state.room.id,
                  "cover": state.room.roomCover,
                  "roomIntro": state.room.roomIntro,
                  "roomRule": state.room.roomRule,
                  "background": state.room.roomBackground,
                  "mode": state.room.mode,
                  "uuid": state.room.uuidOwnerRoom,
                  "giftPrice": state.room.giftPrice,
                  "ownerSpecialId": state.room.ownerSpecialId,
                  'ownerIdColors': state.room.ownerImageColor?.color,
                },
                id: state.room.id.toString(),
              );

              LockRoomDialog.roomIsLoked = state.room.roomPassStatus ?? false;
              RoomData.instance.isRoomLocked.value =
                  state.room.roomPassStatus ?? false;
              LiveRoomData.instance.room = state.room;
              // The engine may have connected while enter_room was in flight —
              // _handleConnection deferred the entry sequence until the room
              // was assigned. Run it now (no-op if already handled or still
              // disconnected).
              _handleConnection();
            }
          },
        ),
      ],
      child: Stack(
        children: [
          // Rocket room-reward mini-game launch sequence (Phase 2,
          // realtime-driven) -- same overlay as the audio room, purely
          // reactive to RocketRealtimeController.
          const RocketLaunchOverlay(),
          const RocketLaunchBanner(),
          _buildSideColumn(context),
          const _GiftDisplayStack(),
          _buildLuckyGiftSenderBanner(),
          _buildLuckyGiftReceiverBanner(),
          _buildLuckyGiftAnimation(),
          _buildEntro(),
          // Room bomb video overlay intentionally absent — the bomb is an
          // AUDIO-room exclusive feature (owner, 2026-06-11).
          const _LuckyGiftWinOverlay(),
          // Same floating synced-music player as the audio room (opened from
          // the more-sheet's music tool).
          if (di<RoomStateManager>().isInVideoRoom)
            MusicWidget(room: RoomData.instance.room),
        ],
      ),
    );
  }

  // ── Side action column (super boom, games, events carousel, lucky box) ──
  Widget _buildSideColumn(BuildContext context) {
    return Positioned(
      bottom: 65.h,
      right: Directionality.of(context) == TextDirection.rtl ? null : 5.w,
      left: Directionality.of(context) == TextDirection.rtl ? 5.w : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Room bomb (super boom) is an AUDIO-room exclusive feature — it
          // must not show in the live stream (owner, 2026-06-11).
          if (GamesAccess.canPlay &&
              (ConstantsManager.isVariantBuildA || ConstantsManager.isTheme2))
            GestureDetector(
              onTap: () {
                if (!GamesAccess.canPlay) {
                  Methods.showToast(
                    context,
                    message: StringManager.gamesNotAvailableForYou.tr(),
                    isError: true,
                  );
                  return;
                }
                if (HomePage.isConnectToInternet == true) {
                  bottomDailog(
                    context: navKey.currentState!.context,
                    widget: GamesView(roomId: widget.roomId),
                  );
                } else {
                  Methods.showToast(
                    context,
                    message: StringManager.pleaseCheckInternet.tr(),
                    isError: true,
                  );
                }
              },
              child: CircleAvatar(
                backgroundColor: ColorManager.blue,
                radius: 20.w,
                child: Image.asset(
                  AssetsManager.gameIconHome,
                  color: ColorManager.onDark,
                  width: 30.w,
                ),
              ),
            ),
          15.hBox,
          _buildEventsCarousel(context),
          15.hBox,
          ValueListenableBuilder(
            valueListenable: LuckyBoxVariables.notifierLuckyBox,
            builder: (context, _, child) {
              if (LuckyBoxVariables.luckyBoxMap['luckyBoxes'] != [] &&
                  LuckyBoxVariables.luckyBoxMap['luckyBoxes'] != null) {
                return LuckyBoxIcon(
                  giftButtonCallBack: widget.giftButtonCallBack,
                  roomId: widget.roomId,
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsCarousel(BuildContext context) {
    return BlocBuilder<GetCarouselBloc, GetCarouselState>(
      bloc: di<GetCarouselBloc>(),
      buildWhen: (prev, curr) => prev.homeTopCarousels != curr.homeTopCarousels,
      builder: (context, state) {
        final List<CarouselEntity> sliders =
            state.homeTopCarousels.where((c) => c.type == 'event').toList();
        return SizedBox(
          height: 75,
          width: 75,
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: 5.radius,
              child: Stack(
                children: [
                  CarouselSlider(
                    items: List.generate(
                      sliders.length,
                      (index) => Padding(
                        padding: context.paddingSymmetric(horizontal: 0),
                        child: GestureDetector(
                          onTap: () => _onSliderTap(context, sliders[index]),
                          child:
                              sliders[index].type == 'event'
                                  ? EventSliderItem(
                                    image: sliders[index].img,
                                    avatar: sliders[index].avatar,
                                    avatar2: sliders[index].cpAvatar2,
                                    name: sliders[index].cpName,
                                    name2: sliders[index].cpName2,
                                    eventType: sliders[index].eventType,
                                  )
                                  : ImageViewWidget(
                                    url: sliders[index].img,
                                    boxFit: BoxFit.fill,
                                    width: ScreenUtil().screenWidth,
                                  ),
                        ),
                      ),
                    ),
                    options: CarouselOptions(
                      initialPage: 0,
                      reverse: false,
                      autoPlay: true,
                      viewportFraction: 1,
                      enableInfiniteScroll: true,
                      height: 110.h,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 600,
                      ),
                      autoPlayCurve: Curves.easeInOut,
                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        di<GetCarouselBloc>().add(
                          ChangeCarsouleIndex(index: index, type: 'homeTop'),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 15,
                    bottom: 2,
                    child: Padding(
                      padding: context.paddingSymmetric(vertical: 8),
                      child: BlocBuilder<GetCarouselBloc, GetCarouselState>(
                        bloc: di<GetCarouselBloc>(),
                        buildWhen:
                            (prev, curr) =>
                                prev.topHomeIndex != curr.topHomeIndex,
                        builder: (context, state) {
                          int currentIndex = state.topHomeIndex;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(sliders.length, (index) {
                              bool isActive = index == currentIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: isActive ? 6 : 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.white : Colors.grey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSliderTap(BuildContext context, CarouselEntity slider) async {
    switch (slider.type) {
      case 'normal':
        break;
      case 'room':
        di<RoomStateManager>().navigateToRoom(
          RoomEntryRequest(
            context: context,
            roomData: RoomEntity(
              passwordStatus: slider.myRoomData?.passwordStatus,
              ownerId: slider.ownerId,
              id: slider.myRoomData?.id ?? 0,
              name: slider.myRoomData?.name ?? "",
              cover: slider.myRoomData?.cover ?? "",
              roomBackground: slider.myRoomData?.background ?? "",
              mode: slider.myRoomData?.toString() ?? '',
              uuidOwnerRoom: slider.myRoomData?.ownerUuid ?? "",
              giftPrice: slider.myRoomData?.giftPrice ?? "",
            ),
            isLive: false,
          ),
        );
        break;
      case 'link':
        final url = slider.url ?? "";
        if (url.contains("wa.me") || url.contains("whatsapp.com")) {
          Methods().whatsAppLink(context, url);
        } else if (context.mounted) {
          Navigator.pushNamed(
            context,
            Routes.webViewEvents,
            arguments: {'url': url, 'type': 'events'},
          );
        }
        break;
      case 'event':
        if (!context.mounted || (slider.url ?? '').isEmpty) return;
        // In-live events browser (#21): a 2/3-screen sheet with one tab per
        // running event so the stream stays visible — not the full-screen
        // events route.
        final events =
            di<GetCarouselBloc>().state.homeTopCarousels
                .where((c) => c.type == 'event' && (c.url ?? '').isNotEmpty)
                .toList();
        final tappedIndex = events.indexWhere((c) => c.url == slider.url);
        LiveEventsSheet.show(
          context,
          events: events,
          initialIndex: tappedIndex < 0 ? 0 : tappedIndex,
        );
    }
  }

  // ── Lucky gift banners ──
  Widget _buildLuckyGiftSenderBanner() {
    return BlocConsumer<LuckyGiftBannerBloc, LuckyGiftBannerState>(
      bloc: di<LuckyGiftBannerBloc>(),
      buildWhen: (previous, current) {
        if (current is SendLuckyGiftLoadingState) return false;
        return true;
      },
      listener: (context, state) {
        if (state is SendLuckyGiftSucssesState) {
          LiveRoomData.instance.myCoins.value = state.data.userCoins ?? "";
          di<GiftBloc>().add(
            UpdateRoomGiftsPriceEvent(price: state.data.giftPrice.toString()),
          );
          // The SENDER already animated optimistically per-tap (lucky_candy
          // ._showOptimisticTapAnimation). The response is no longer the trigger
          // for the sender's own animation — it only carries the authoritative
          // win data other clients need, so forward it over RTM without touching
          // local seats (was: tempLuckyGiftData.add → batched burst).
          final data = state.data;
          di<LuckyGiftAnaimationManagerBloc>().add(
            RebroadcastLuckyGiftEvent(
              giftPrice: data.giftPrice,
              index: data.position ?? const <int>[],
              ids: data.receiversId ?? const <String>[],
              image: data.giftImage ?? "",
              reciverName: data.receiverName ?? "",
              senderName: data.senderName ?? "",
              senderImage: data.senderImg ?? "",
              giftNum: data.giftNum ?? 0,
              giftPriceT: data.giftPriceT ?? 0,
              totalWin: data.totalWin ?? 0,
              totalPk: data.totalPk ?? 0,
            ),
          );

          // Per-stage guest counter (المسّات) — lucky sender side.
          LiveRoomData.instance.addGuestStageTouches(
            state.data.receiversId ?? const <String>[],
            state.data.giftPriceT ?? 0,
          );

          // Lucky-gift line in the live comments — the backend already builds
          // the canonical text ("N x ارسل هدية حظ قيمتها P الى Name") inside
          // each combo hit's win data; the chat views localize/parse it like
          // the audio room does. One line per send (first hit carries it).
          final comment =
              state.data.combo
                  ?.map((c) => c.data?.commentMessage)
                  .firstWhere(
                    (m) => m != null && m.isNotEmpty,
                    orElse: () => null,
                  ) ??
              '';
          if (comment.isNotEmpty) {
            final me = MyDataModel.getInstance();
            LiveRoomData.instance.chatController?.sendMessage(
              comment,
              userData: {
                "img": me.profile?.image ?? "",
                "bu": me.bubble ?? "",
                "buId": me.bubbleId.toString(),
                "sL": me.level?.senderImage ?? "",
                "rL": me.level?.receiverImage ?? "",
                "v": me.vip1?.img1 ?? "",
                "c": me.vip1?.colorName ?? "",
                "giftImage": state.data.giftImage ?? "",
                "giftName": state.data.giftName ?? "",
                'type': 'message',
              },
            );
          }
        } else if (state is SendLuckyGiftErrorStateState) {
          Methods.showToast(context, message: state.error, isError: true);
        }
      },
      builder: (context, state) {
        if (state is SendLuckyGiftSucssesState) {
          return Stack(
            children: [
              Positioned(
                top: 450.h,
                left: 20.w,
                child: LuckGiftBannerWidget(
                  reciverName: state.data.receiverName ?? "",
                  giftNum: state.giftNum,
                  giftImage: state.data.giftImage ?? "",
                  totalWin: state.totalWin,
                  onHideComplete: () {
                    LuckyGiftController.instance.tempLuckyGiftData.clear();
                    if (GiftBottomBar.typeCandy.value != TypeCandy.luckyCandy) {
                      LuckyGiftService.instance.endAllLuckyGift();
                    }
                  },
                ),
              ),
              Positioned(
                top: 450.h + 60.h,
                right: 0,
                child: SenderBalanceBanner(
                  giftPrice: state.data.userCoins ?? "",
                ),
              ),
            ],
          );
        } else if (state is SendLuckyGiftLoadingState) {
          if (state.data == null) return const SizedBox();
          return Stack(
            children: [
              Positioned(
                top: 450.h,
                left: 20.w,
                child: LuckGiftBannerWidget(
                  reciverName: state.data?.receiverName ?? "",
                  giftNum: state.giftNum ?? 0,
                  giftImage: state.data?.giftImage ?? "",
                  totalWin: state.totalWin ?? 0,
                  onHideComplete: () {
                    LuckyGiftController.instance.tempLuckyGiftData.clear();
                    if (GiftBottomBar.typeCandy.value != TypeCandy.luckyCandy) {
                      LuckyGiftService.instance.endAllLuckyGift();
                    }
                  },
                ),
              ),
              Positioned(
                top: 450.h + 60.h,
                right: 0,
                child: SenderBalanceBanner(
                  giftPrice: state.data?.userCoins ?? "",
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildLuckyGiftReceiverBanner() {
    return BlocBuilder<
      LuckyGiftBannerForReciverBloc,
      LuckyGiftBannerForReciverState
    >(
      bloc: di<LuckyGiftBannerForReciverBloc>(),
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LuckyGiftBannerForReciverSucssesState) {
          return Positioned(
            top: 510.h,
            left: 20,
            child: LuckGiftBannerWidget(
              senderImg: state.senderImg,
              senderName: state.senderName,
              reciverName: state.receiverName,
              giftNum: state.giftNum,
              giftImage: state.giftImage,
              totalWin: state.totalWin,
              onHideComplete: () {
                di<LuckyGiftBannerForReciverBloc>().add(
                  const EndLuckyGiftBannerForReciverEvent(),
                );
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildLuckyGiftAnimation() {
    return BlocBuilder<
      LuckyGiftAnaimationManagerBloc,
      LuckyGiftAnaimationManagerState
    >(
      bloc: di<LuckyGiftAnaimationManagerBloc>(),
      buildWhen:
          (prev, curr) =>
              prev.runtimeType != curr.runtimeType ||
              (prev is LuckyGiftAnimationSucssesState &&
                  curr is LuckyGiftAnimationSucssesState &&
                  prev.data != curr.data),
      builder: (context, state) {
        if (state is LuckyGiftAnimationSucssesState) {
          return RepaintBoundary(child: Stack(children: [...state.data!]));
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEntro() {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: ShowEntroWidget.showEntro,
      builder: (context, data, _) {
        if (data != null &&
            data['wappelImage'] != null &&
            data['wappelImage'] != "") {
          return Positioned(
            bottom: 300.h,
            child: RepaintBoundary(child: ShowEntroWidget(userIntroData: data)),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _GiftDisplayStack extends StatelessWidget {
  const _GiftDisplayStack();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: BlocBuilder<GiftBloc, GiftState>(
            bloc: di<GiftBloc>(),
            buildWhen:
                (prev, curr) =>
                    prev.isShowGift != curr.isShowGift ||
                    prev.giftType != curr.giftType,
            builder: (context, state) {
              if (state.isShowGift && state.giftType == ShowGiftType.image) {
                return RepaintBoundary(child: ShowNormalGift(state: state));
              }
              return const SizedBox();
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BlocBuilder<GiftBloc, GiftState>(
            bloc: di<GiftBloc>(),
            buildWhen:
                (prev, curr) =>
                    prev.isShowGift != curr.isShowGift ||
                    prev.giftType != curr.giftType ||
                    prev.isFamousGift != curr.isFamousGift ||
                    prev.gift != curr.gift,
            builder: (context, state) {
              if (state.isShowGift && state.giftType == ShowGiftType.mp4) {
                return RepaintBoundary(
                  child:
                      state.isFamousGift == true
                          ? _FamousGiftMinimizeToggle(
                            child:
                                (isMinimize) => IgnorePointer(
                                  child: CacheVideoWidget(
                                    height:
                                        isMinimize
                                            ? (ScreenUtil().screenWidth / 1.15)
                                                .h
                                            : ScreenUtil().screenHeight,
                                    width:
                                        isMinimize
                                            ? (ScreenUtil().screenWidth / 1.15)
                                                .w
                                            : ScreenUtil().screenWidth,
                                    videoUrl: EndPoints.getImage(state.gift),
                                    isShowGift: true,
                                  ),
                                ),
                          )
                          : Stack(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.105,
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.730,
                                  width: MediaQuery.of(context).size.width,
                                  child: CacheVideoWidget(
                                    videoUrl: EndPoints.getImage(state.gift),
                                    isShowGift: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BlocBuilder<AlphaGiftManagerBloc, AlphaGiftManagerState>(
            bloc: di<AlphaGiftManagerBloc>(),
            buildWhen:
                (prev, curr) =>
                    prev.runtimeType != curr.runtimeType ||
                    (prev is AlphaGiftManagerShowGift &&
                        curr is AlphaGiftManagerShowGift &&
                        (prev.isFamousGift != curr.isFamousGift ||
                            prev.giftPath != curr.giftPath)),
            builder: (context, state) {
              if (state is AlphaGiftManagerShowGift) {
                return RepaintBoundary(
                  child:
                      state.isFamousGift == true
                          ? _FamousGiftMinimizeToggle(
                            child:
                                (isMinimize) => CacheAlphaWidget(
                                  height:
                                      isMinimize
                                          ? (ScreenUtil().screenWidth / 1.15).h
                                          : ScreenUtil().screenHeight,
                                  width:
                                      isMinimize
                                          ? (ScreenUtil().screenWidth / 1.15).w
                                          : ScreenUtil().screenWidth,
                                  url: EndPoints.getImage(state.giftPath),
                                ),
                          )
                          : Stack(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.105,
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: CacheAlphaWidget(
                                  url: EndPoints.getImage(state.giftPath),
                                ),
                              ),
                            ],
                          ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BlocBuilder<GiftBloc, GiftState>(
            bloc: di<GiftBloc>(),
            buildWhen:
                (prev, curr) =>
                    prev.isShowGift != curr.isShowGift ||
                    prev.giftType != curr.giftType ||
                    prev.isFamousGift != curr.isFamousGift ||
                    prev.gift != curr.gift,
            builder: (context, state) {
              if (state.isShowGift == true &&
                  state.giftType == ShowGiftType.svga) {
                return RepaintBoundary(
                  child:
                      state.isFamousGift == true
                          ? _FamousGiftMinimizeToggle(
                            child:
                                (isMinimize) => CacheSvgaWidget(
                                  url: EndPoints.getImage(state.gift),
                                  height:
                                      isMinimize
                                          ? (ScreenUtil().screenWidth / 1.15).h
                                          : ScreenUtil().screenHeight,
                                  width:
                                      isMinimize
                                          ? (ScreenUtil().screenWidth / 1.15).w
                                          : ScreenUtil().screenWidth,
                                  isShowGift: true,
                                ),
                          )
                          : CacheSvgaWidget(
                            url: EndPoints.getImage(state.gift),
                            isShowGift: true,
                          ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        BlocBuilder<GiftBloc, GiftState>(
          bloc: di<GiftBloc>(),
          buildWhen:
              (prev, curr) =>
                  prev.isShowGift != curr.isShowGift ||
                  prev.gift != curr.gift ||
                  prev.giftType != curr.giftType ||
                  prev.isFamousGift != curr.isFamousGift ||
                  prev.isShowIntroFullScreen != curr.isShowIntroFullScreen,
          builder: (context, state) {
            if (state.isShowGift == true &&
                state.gift != "" &&
                state.giftType == ShowGiftType.vap) {
              return RepaintBoundary(
                child:
                    state.isFamousGift == true
                        ? _FamousGiftMinimizeToggle(
                          child:
                              (isMinimize) => IgnorePointer(
                                child: CachedVapWidget(
                                  url: EndPoints.getImage(state.gift),
                                  height:
                                      isMinimize
                                          ? (ScreenUtil().screenWidth / 1.15).h
                                          : ScreenUtil().screenHeight,
                                  width:
                                      isMinimize
                                          ? (ScreenUtil().screenWidth / 1.15).w
                                          : ScreenUtil().screenWidth,
                                ),
                              ),
                        )
                        : IgnorePointer(
                          child: Stack(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.105,
                              ),
                              SizedBox(
                                height:
                                    state.isShowIntroFullScreen
                                        ? MediaQuery.of(context).size.height
                                        : MediaQuery.of(context).size.height *
                                            0.730,
                                width: MediaQuery.of(context).size.width,
                                child: CachedVapWidget(
                                  url: EndPoints.getImage(state.gift),
                                  height: ScreenUtil().screenHeight,
                                  width: ScreenUtil().screenWidth,
                                ),
                              ),
                            ],
                          ),
                        ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }
}

class _FamousGiftMinimizeToggle extends StatelessWidget {
  final Widget Function(bool isMinimize) child;
  const _FamousGiftMinimizeToggle({required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LiveRoomData.instance.minimizeGiftFamous,
      builder: (context, isMinimize, _) {
        return Stack(
          children: [
            child(isMinimize),
            Positioned(
              top: 50.h,
              right: 20.h,
              child: InkWell(
                onTap: () async {
                  bool newValue =
                      !LiveRoomData.instance.minimizeGiftFamous.value;
                  await HiveManager().saveData<bool>(
                    KeysManager.ROOMS_BOX,
                    KeysManager.MINIMIZE_GIFT_KEY,
                    newValue,
                  );
                  LiveRoomData.instance.minimizeGiftFamous.value = newValue;
                },
                child: Icon(
                  isMinimize
                      ? CupertinoIcons.fullscreen
                      : CupertinoIcons.fullscreen_exit,
                  color: Colors.white,
                  size: 30.h,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LuckyGiftWinOverlay extends StatelessWidget {
  const _LuckyGiftWinOverlay();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LuckyGiftWinBloc, LuckyGiftWinState>(
      bloc: di<LuckyGiftWinBloc>(),
      buildWhen:
          (prev, curr) =>
              prev.runtimeType != curr.runtimeType ||
              (prev is LuckyGiftWinQueueUpdated &&
                  curr is LuckyGiftWinQueueUpdated &&
                  prev.queue != curr.queue),
      builder: (context, state) {
        if (state is LuckyGiftWinQueueUpdated && state.queue.isNotEmpty) {
          final item = state.queue.first;
          return Positioned(
            top: 300.h,
            left: 110.w,
            right: 110.w,
            child: LuckyGiftWin(winTimes: item['winTimes']),
          );
        }
        return const SizedBox();
      },
    );
  }
}
