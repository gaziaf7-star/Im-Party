import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/room/room.dart';
import 'show_lucky_banner_body_widget.dart';

class ShowLuckyBannerWidget extends StatefulWidget {
  final Map<String, dynamic> bannerLuckyBoxModel;
  const ShowLuckyBannerWidget({
    super.key,
    required this.bannerLuckyBoxModel,
  });

  @override
  State<ShowLuckyBannerWidget> createState() => _ShowLuckyBannerWidgetState();
}

class _ShowLuckyBannerWidgetState extends State<ShowLuckyBannerWidget>
    with TickerProviderStateMixin {
  Animation<Offset>? animationControllerPng;
  AnimationController? controllerEntroPng;

  @override
  void initState() {
    super.initState();

    controllerEntroPng = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    animationControllerPng = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1.5,
      ),
      TweenSequenceItem(
        tween: ConstantTween(const Offset(0.0, 0.0)), // Pause in center
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween:
            Tween(begin: const Offset(0.0, 0.0), end: const Offset(-1.0, 0.0))
                .chain(CurveTween(curve: Curves.easeIn)),
        weight: 2.5,
      ),
    ]).animate(controllerEntroPng ?? AnimationController(vsync: this));
    controllerEntroPng?.forward().then((_) {
      try {
        removeLuckyBoxBanner('${widget.bannerLuckyBoxModel['ownerBoxUId']}');
      } catch (error) {
        Methods.printLog("❌ Error removing banner: $error");
      }
    });
  }

  @override
  void dispose() {
    controllerEntroPng?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animationControllerPng!,
      child: MultiTapCard(
        onTap: () async {
          final navContext = SafeNavigator.context;
          if (navContext == null) return;
          final isLive =
              widget.bannerLuckyBoxModel["room"]["room_type"].toString() ==
                  "live";
          if (di<RoomStateManager>().isInRoom &&
              widget.bannerLuckyBoxModel["room"]['id'].toString() ==
                  RoomData.instance.room.id.toString()) {
            final utdCtrl = RoomData.instance.utdController;
            if (!isLive && utdCtrl != null && utdCtrl.minimize.isMinimizing) {
              utdCtrl.minimize.restoreWithNavigator();
              return;
            }
            // Check if live room is minimized - navigate to it
            if (isLive &&
                di<RoomStateManager>().currentState ==
                    RoomStateType.videoMinimized) {
              Navigator.pushNamed(
                navContext,
                Routes.liveRoomScreen,
                arguments: RoomParameter(
                  myDataModel: MyDataModel.getInstance(),
                  isLocked: true,
                  isHost: MyDataModel.getInstance().id.toString() ==
                      RoomData.instance.room.ownerId.toString(),
                  roomId: RoomData.instance.room.id.toString(),
                  ownerId: RoomData.instance.room.ownerId.toString(),
                ),
              );
            }
            // Already in the same room → do nothing
            return;
          }

          await showBannerDestinationDialog(
            context: navContext,
            destinationName:
                widget.bannerLuckyBoxModel["room"]['room_name']?.toString(),
            isLive: isLive,
            onConfirm: () {
              if (di<RoomStateManager>().currentState !=
                      RoomStateType.videoMinimized &&
                  di<RoomStateManager>().isInRoom) {
                SafeNavigator.pop();
              }

              final tapContext = SafeNavigator.context;
              if (tapContext == null) return;
              di<RoomStateManager>().navigateToRoom(
                RoomEntryRequest(
                  context: tapContext,
                  isLive: isLive,
                  roomData: RoomEntity(
                    passwordStatus: widget.bannerLuckyBoxModel["room"]
                            ['is_password'] ??
                        false,
                    giftPrice: widget.bannerLuckyBoxModel["room"]
                            ['room_session']
                        .toString(),
                    ownerId: widget.bannerLuckyBoxModel["room"]
                        ['room_owner_id'],
                    id: int.parse(
                        widget.bannerLuckyBoxModel["room"]['id'].toString()),
                    name: widget.bannerLuckyBoxModel["room"]['room_name'],
                    cover: widget.bannerLuckyBoxModel["room"]['room_cover'],
                    roomBackground: widget.bannerLuckyBoxModel["room"]
                        ['room_background'],
                    mode: widget.bannerLuckyBoxModel["room"]['room_mode']
                        .toString(),
                    uuidOwnerRoom: widget.bannerLuckyBoxModel["room"]['uuid']
                        .toString(),
                  ),
                ),
              );
            },
          );
        },
        child: ShowLuckyBannerBodyWidget(
          bannerLuckyBoxModel: widget.bannerLuckyBoxModel,
        ),
      ),
    );
  }
}
