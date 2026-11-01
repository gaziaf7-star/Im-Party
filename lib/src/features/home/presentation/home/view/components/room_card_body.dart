import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/lock_pk_icon.dart';
import '../../../../../../core/index.dart';
import '../../../../../../core/widgets/on_multiable_tab.dart';
import '../../../../domain/entities/room_entity.dart';
import '../widgets/visitors_count.dart';

// NEW THEME (was _RoomCardBody, a home_page.dart part-file private class —
// made public so it can be reused outside the home feed, e.g. the Live tab).
class RoomCardBody extends StatelessWidget {
  const RoomCardBody({
    super.key,
    required this.data,
    this.isLoading = false,
    this.isShowSVGA = false,
    this.isLive = false,
    this.rank,
  });

  final RoomEntity data;
  final bool isLoading;
  final bool isShowSVGA;

  /// Whether tapping this card should enter the room as a live broadcast
  /// (RoomEntryRequest.isLive). Defaults false, matching every existing
  /// call site's behavior; the Live tab passes true.
  final bool isLive;

  /// 1-based position of this room in the currently displayed list. Only
  /// 1, 2 and 3 get a rank frame badge (AssetsManager.frameHomeTopOne/Two/
  /// Three — the same assets already used for the home rank slider); any
  /// other value is ignored.
  final int? rank;

  String? get _rankFrame {
    switch (rank) {
      case 1:
        return AssetsManager.frameHomeTopOne;
      case 2:
        return AssetsManager.frameHomeTopTwo;
      case 3:
        return AssetsManager.frameHomeTopThree;
      default:
        return null;
    }
  }

  /// Animated TOP1/2/3 frame for this card, or null (not ranked 1-3).
  String? get _topFrame =>
      isShowSVGA && rank != null && rank! >= 1 && rank! <= 3
          ? AssetsManager.roomCardTopFrames[rank! - 1]
          : null;

  static const _gradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0x66000000), Colors.transparent],
      begin: AlignmentDirectional.bottomCenter,
      end: AlignmentDirectional.topCenter,
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Cache dimension calculations
    final topPosition = isShowSVGA ? 20.h : 5.h;
    final sidePosition = isShowSVGA ? 12.w : 5.w;
    final containerHeight = isShowSVGA ? 60.h : 50.h;
    final startPadding = isShowSVGA ? 12.5 : 7.5;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        MultiTapCard(
          onTap: () {
            if (isLoading) {
              di<RoomStateManager>().navigateToRoom(
                RoomEntryRequest(
                  context: context,
                  roomData: data,
                  isLive: isLive,
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: 8.radius,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ImageViewWidget(
                    url: data.cover ?? "",
                    boxFit: BoxFit.cover,
                    displayName: data.name ?? '',
                    isRoomCover: true,
                  ),
                ),
                PositionedDirectional(
                  top: topPosition,
                  end: 5.w,
                  child: LockAndPkIcon(
                    isPK: data.isPK ?? false,
                    isPassword: data.passwordStatus ?? false,
                    isHasLuckyBox: data.hasLuckyBox ?? false,
                  ),
                ),
                if (data.roomLevelImage != null &&
                    data.roomLevelImage!.isNotEmpty)
                  Positioned(
                    top: isShowSVGA ? 20.h : 10.h,
                    left: sidePosition,
                    right: sidePosition,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ImageViewWidget(
                          url: data.roomLevelImage!,
                          boxFit: BoxFit.contain,
                          width: 34.w,
                          height: 18.h,
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Container(
                    width: ScreenUtil().screenWidth,
                    height: containerHeight,
                    padding: context.paddingOnly(
                      start: startPadding,
                      end: 3.5,
                    ),
                    decoration: _gradientDecoration,
                    child: SizedBox.shrink(
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ImageViewWidget(
                                  url: data.country?.flag ?? "",
                                  height: 25,
                                  width: 25,
                                ),
                                5.0.wBox,
                                Expanded(
                                  child: TextWidget(
                                    Methods.capitalizeFirstLetter(
                                        data.name ?? ""),
                                    style: context.bodyMedium
                                        .colorExt(ColorManager.onDark),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                5.0.wBox,
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxWidth: 120.w),
                                    child: Text(
                                      data.roomIntro ?? '',
                                      style: context.bodySmall
                                          .colorExt(ColorManager.onDark),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                5.wBox,
                                VisitorsCount(
                                  count: (data.visitorsCount ?? 0).toString(),
                                  fontSize: 12,
                                  color: ColorManager.onDark,
                                  fontWeight: FontWeight.w500,
                                  icon: AssetsManager.icHomeItemAudio,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Top 1/2/3 get their own animated frame; other cards none.
        if (_topFrame != null)
          Positioned(
            top: -15.h,
            right: -10.w,
            left: -10.w,
            bottom: -15.h,
            child: RepaintBoundary(
              child: SizedBox(
                height: ScreenUtil().screenWidth,
                width: ScreenUtil().screenWidth,
                child: ShowSVGA(
                  svgaAssetPath: _topFrame,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        // The small TOP badge is drawn into the new frames themselves.
        if (_rankFrame != null && _topFrame == null)
          PositionedDirectional(
            top: 4.h,
            start: 4.w,
            child: Image.asset(
              _rankFrame!,
              height: 32.h,
              width: 32.w,
              fit: BoxFit.contain,
            ),
          ),
      ],
    );
  }
}
