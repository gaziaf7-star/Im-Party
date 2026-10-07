import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/room/presentation/yallow_banner/controller/controller.dart';
import 'package:general/src/features/room/room.dart';
import 'dart:ui' as ui;

class ShowYallowBannerWidget extends StatefulWidget {
  final UserEntity? senderYallowBanner;

  const ShowYallowBannerWidget({
    super.key,
    this.senderYallowBanner,
  });

  @override
  State<ShowYallowBannerWidget> createState() => _ShowYallowBannerWidgetState();
}

class _ShowYallowBannerWidgetState extends State<ShowYallowBannerWidget>
    with TickerProviderStateMixin {
  AnimationController? yellowBannerController;
  Animation<Offset>? offsetAnimationYellowBanner;

  @override
  void initState() {
    super.initState();

    yellowBannerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    offsetAnimationYellowBanner = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: yellowBannerController!,
      curve: Curves.easeOut,
    ));

    // Run slide-in
    yellowBannerController?.forward();
  }

  void _closeBanner() {
    if (mounted) {
      yellowBannerController?.reverse().then((_) {
        YallowBannerController().closeBanner();
      });
    }
  }

  @override
  void dispose() {
    yellowBannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: SlideTransition(
        position: offsetAnimationYellowBanner!,
        child: MultiTapCard(
          onTap: () async {
            final navContext = SafeNavigator.context;
            if (navContext == null) return;
            if (di<RoomStateManager>().isInRoom &&
                YallowBannerController().roomData?.id ==
                    RoomData.instance.room.id) {
              final utdCtrl = RoomData.instance.utdController;
              if (utdCtrl != null && utdCtrl.minimize.isMinimizing) {
                utdCtrl.minimize.restoreWithNavigator();
                return;
              }
              // Check if live room is minimized - navigate to it
              if (di<RoomStateManager>().currentState ==
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
              return; // Already in same room
            }

            final bannerRoom =
                YallowBannerController().roomData ?? const RoomEntity();
            // Payload carries room_type ('audio' | 'live') in roomType;
            // streamType is kept as a secondary signal for older payloads.
            final isLive = (bannerRoom.roomType ?? '').contains('live') ||
                bannerRoom.streamType == "live";

            await showBannerDestinationDialog(
              context: navContext,
              destinationName: bannerRoom.name,
              isLive: isLive,
              onConfirm: () {
                if (di<RoomStateManager>().isInRoom &&
                    di<RoomStateManager>().currentState !=
                        RoomStateType.videoMinimized) {
                  SafeNavigator.context?.popRoute();
                }

                final tapContext = SafeNavigator.context;
                if (tapContext == null) return;
                di<RoomStateManager>().navigateToRoom(
                  RoomEntryRequest(
                    context: tapContext,
                    roomData: bannerRoom,
                    isLive: isLive,
                  ),
                );
              },
            );
          },
          child: SizedBox(
            height: 45.h,
            child: Stack(
              children: [
                ShowSVGA(
                  svgaAssetPath: AssetsManager.yallowBanner,
                  fit: BoxFit.cover,
                  width: ScreenUtil().screenWidth,
                ),
                Row(
                  children: [
                    // User Image
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorManager.white,
                            width: 1,
                          ),
                        ),
                        child: UserImage(
                          frameSize: 0,
                          imageSize: 30,
                          borderRadius: BorderRadius.circular(20.r),
                          displayName:
                              YallowBannerController().senderData?.name ?? '',
                          image: YallowBannerController()
                                  .senderData
                                  ?.profile
                                  ?.image ??
                              "",
                        ),
                      ),
                    ),

                    // Sender name
                    Text(
                      "${YallowBannerController().senderData?.name ?? ''}: ",
                      style: context.bodyMedium
                          .size(14)
                          .w600
                          .colorExt(ColorManager.textPrimary)
                          .copyWith(
                            decoration: TextDecoration.none,
                          ),
                    ),

                    // Message text -- was TextScroll (a scrolling marquee),
                    // swapped for a plain Text: the text_scroll package
                    // throws a null-check error from inside its own
                    // post-frame callback (_initScroller ->
                    // ScrollPosition.viewportDimension) on some show/hide
                    // sequences, which was preventing the banner from
                    // ever rendering.
                    Expanded(
                      child: Text(
                        YallowBannerController().message,
                        textDirection: ui.TextDirection.ltr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyMedium
                            .size(15)
                            .w600
                            .colorExt(ColorManager.textPrimary)
                            .copyWith(
                              decoration: TextDecoration.none,
                            ),
                      ),
                    ),

                    // Close Button
                    IconButton.outlined(
                      onPressed: _closeBanner,
                      style: IconButton.styleFrom(
                          padding: context.paddingZero(),
                          minimumSize: Size(27.5.w, 27.5.h),
                          side: const BorderSide(color: ColorManager.white)),
                      icon: const Icon(Icons.close,
                          color: ColorManager.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
