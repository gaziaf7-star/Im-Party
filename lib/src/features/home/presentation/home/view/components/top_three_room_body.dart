import 'package:general/src/core/widgets/country_icon.dart';
import 'package:general/src/core/widgets/reversible_auto_scroll_list_widget.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/lock_pk_icon.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/visitors_count.dart';
import '../../../../../../core/index.dart';
import '../../../../../../core/widgets/on_multiable_tab.dart';
import '../../../../domain/entities/room_entity.dart';

class TopThreeRoomBody extends StatelessWidget {
  const TopThreeRoomBody({super.key, required this.rooms});

  final List<RoomEntity> rooms;

  @override
  Widget build(BuildContext context) {
    // Cache ScreenUtil values to avoid repeated lookups
    final screenHeight = ScreenUtil().screenHeight;
    final screenWidth = ScreenUtil().screenWidth;

    // Early return if no rooms
    if (rooms.isEmpty) {
      return SizedBox(height: screenHeight * 0.320);
    }

    // Cache room references
    final room0 = rooms[0];
    final room1 = rooms.length > 1 ? rooms[1] : null;
    final room2 = rooms.length > 2 ? rooms[2] : null;

    return BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
      bloc: di<FetchUserDataBloc>(),
      buildWhen: (previous, current) => previous.reqState != current.reqState,
      builder: (context, state) {
        final isLoaded = state.reqState == RequestState.loaded;

        return Container(
          height: screenHeight * 0.320,
          padding: context.paddingSymmetric(horizontal: 5),
          child: Row(
            children: [
              Expanded(
                child: RepaintBoundary(
                  child: MultiTapCard(
                    onTap: () {
                      if (isLoaded) {
                        di<RoomStateManager>().navigateToRoom(
                          RoomEntryRequest(
                            context: context,
                            roomData: room0,
                            isLive: room0.streamType == "live",
                          ),
                        );
                      }
                    },
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        ImageViewWidget(
                          url: room0.cover ?? '',
                          boxFit: BoxFit.fill,
                          width: screenWidth * 0.570,
                          height: screenWidth * 0.580,
                          displayName: room0.name ?? '',
                          isRoomCover: true,
                        ),
                        Positioned(
                          bottom: 30.h,
                          left: 30.w,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 1.w,
                                  maxWidth: 100.w,
                                ),
                                child: TextWidget(
                                  room0.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.bodyLarge
                                      .colorExt(ColorManager.onDark),
                                ),
                              ),
                              5.hBox,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CountryIcon(
                                    borderRadius: 0.radius,
                                    country: room0.country?.flag ?? '',
                                    countryId:
                                        (room0.country?.id ?? '-1').toString(),
                                  ),
                                  5.wBox,
                                  if (room0.achievementImages?.isNotEmpty ==
                                      true)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: 1.0.w,
                                        maxHeight: 20.h,
                                        minHeight: 20.h,
                                        maxWidth: 180.w,
                                      ),
                                      child: ReversibleAutoScrollListWidget(
                                        items: room0.achievementImages ?? [],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        RepaintBoundary(
                          child: SizedBox(
                            height: screenWidth,
                            width: screenWidth,
                            child: ShowSVGA(
                              svgaAssetPath: AssetsManager.grid1,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 30.h,
                          right: 25.w,
                          child: VisitorsCount(
                            count: room0.visitorsCount.toString(),
                            isTop: true,
                          ),
                        ),
                        if (room0.roomLevelImage != "")
                          Positioned(
                            top: 50.h,
                            right: 25.w,
                            child: ImageViewWidget(
                              url: room0.roomLevelImage ?? '',
                              boxFit: BoxFit.contain,
                              width: 34.w,
                              height: 18.h,
                            ),
                          ),
                        Padding(
                          padding: context.paddingOnly(
                            top: 40,
                            end: 28,
                            start: 28,
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: LockAndPkIcon(
                              isPK: room0.isPK ?? false,
                              isPassword: room0.passwordStatus ?? false,
                              isHasLuckyBox: room0.hasLuckyBox ?? false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.300,
                width: screenWidth * 0.33,
                child: Column(
                  children: [
                    if (room1 != null)
                      Expanded(
                        child: RepaintBoundary(
                          child: MultiTapCard(
                            onTap: () {
                              if (isLoaded) {
                                di<RoomStateManager>().navigateToRoom(
                                  RoomEntryRequest(
                                    context: context,
                                    roomData: room1,
                                    isLive: room1.streamType == "live",
                                  ),
                                );
                              }
                            },
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                ImageViewWidget(
                                  url: room1.cover ?? '',
                                  boxFit: BoxFit.fill,
                                  width: screenWidth * 0.30,
                                  height: screenWidth * 0.28,
                                  displayName: room1.name ?? '',
                                  isRoomCover: true,
                                ),
                                Padding(
                                  padding: context.paddingOnly(
                                    top: 20,
                                    end: 17,
                                    start: 17,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: LockAndPkIcon(
                                      isPK: room1.isPK ?? false,
                                      isPassword: room1.passwordStatus ?? false,
                                      isHasLuckyBox: room1.hasLuckyBox ?? false,
                                    ),
                                  ),
                                ),
                                PositionedDirectional(
                                  bottom: 12.5.h,
                                  start: 20.w,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: 1.w,
                                          maxWidth: 100.w,
                                        ),
                                        child: TextWidget(
                                          room1.name ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.bodyLarge
                                              .size(12.5)
                                              .colorExt(
                                                  ColorManager.onDark),
                                        ),
                                      ),
                                      5.hBox,
                                      if (room1.achievementImages?.isNotEmpty ==
                                          true)
                                        Row(
                                          children: [
                                            CountryIcon(
                                              borderRadius: 0.radius,
                                              country:
                                                  room1.country?.flag ?? '',
                                              countryId:
                                                  (room1.country?.id ?? '-1')
                                                      .toString(),
                                            ),
                                            5.wBox,
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth: 1.0.w,
                                                maxHeight: 20.h,
                                                minHeight: 20.h,
                                                maxWidth: 70.w,
                                              ),
                                              child:
                                                  ReversibleAutoScrollListWidget(
                                                items:
                                                    room1.achievementImages ??
                                                        [],
                                              ),
                                            ),
                                          ],
                                        ),
                                      2.5.hBox,
                                    ],
                                  ),
                                ),
                                RepaintBoundary(
                                  child: SizedBox(
                                    height: screenWidth,
                                    width: screenWidth,
                                    child: ShowSVGA(
                                      svgaAssetPath: AssetsManager.grid2,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                PositionedDirectional(
                                  top: 15.h,
                                  end: 8.w,
                                  child: VisitorsCount(
                                    count: room1.visitorsCount.toString(),
                                    isTop: true,
                                  ),
                                ),
                                if (room1.roomLevelImage != "")
                                  PositionedDirectional(
                                    top: 30.h,
                                    end: 8.w,
                                    child: ImageViewWidget(
                                      url: room1.roomLevelImage ?? '',
                                      boxFit: BoxFit.contain,
                                      width: 34.w,
                                      height: 18.h,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    room2 != null
                        ? Expanded(
                            child: RepaintBoundary(
                              child: MultiTapCard(
                                onTap: () {
                                  if (isLoaded) {
                                    di<RoomStateManager>().navigateToRoom(
                                      RoomEntryRequest(
                                        context: context,
                                        roomData: room2,
                                        isLive: room2.streamType == "live",
                                      ),
                                    );
                                  }
                                },
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    ImageViewWidget(
                                      url: room2.cover ?? '',
                                      boxFit: BoxFit.fill,
                                      width: screenWidth * 0.30,
                                      height: screenWidth * 0.28,
                                      displayName: room2.name ?? '',
                                      isRoomCover: true,
                                    ),
                                    Padding(
                                      padding: context.paddingOnly(
                                        top: 20,
                                        end: 17,
                                        start: 17,
                                      ),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: LockAndPkIcon(
                                          isPK: room2.isPK ?? false,
                                          isPassword:
                                              room2.passwordStatus ?? false,
                                          isHasLuckyBox:
                                              room2.hasLuckyBox ?? false,
                                        ),
                                      ),
                                    ),
                                    PositionedDirectional(
                                      bottom: 12.h,
                                      start: 20.w,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minWidth: 1.w,
                                              maxWidth: 100.w,
                                            ),
                                            child: TextWidget(
                                              room2.name ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: context.bodyLarge
                                                  .size(12.5)
                                                  .colorExt(
                                                      ColorManager.onDark),
                                            ),
                                          ),
                                          5.hBox,
                                          if (room2.achievementImages
                                                  ?.isNotEmpty ==
                                              true)
                                            Row(
                                              children: [
                                                CountryIcon(
                                                  borderRadius: 0.radius,
                                                  country:
                                                      room2.country?.flag ?? '',
                                                  countryId:
                                                      (room2.country?.id ??
                                                              '-1')
                                                          .toString(),
                                                ),
                                                5.wBox,
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    minWidth: 1.0.w,
                                                    maxHeight: 20.h,
                                                    minHeight: 20.h,
                                                    maxWidth: 70.w,
                                                  ),
                                                  child:
                                                      ReversibleAutoScrollListWidget(
                                                    items: room2
                                                            .achievementImages ??
                                                        [],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          2.5.hBox,
                                        ],
                                      ),
                                    ),
                                    RepaintBoundary(
                                      child: SizedBox(
                                        height: screenWidth,
                                        width: screenWidth,
                                        child: ShowSVGA(
                                          svgaAssetPath: AssetsManager.grid3,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    PositionedDirectional(
                                      top: 15.h,
                                      end: 8.w,
                                      child: VisitorsCount(
                                        count: room2.visitorsCount.toString(),
                                        isTop: true,
                                      ),
                                    ),
                                    if (room2.roomLevelImage != "")
                                      PositionedDirectional(
                                        top: 30.h,
                                        end: 8.w,
                                        child: ImageViewWidget(
                                          url: room2.roomLevelImage ?? '',
                                          boxFit: BoxFit.contain,
                                          width: 34.w,
                                          height: 18.h,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : 120.hBox,
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
