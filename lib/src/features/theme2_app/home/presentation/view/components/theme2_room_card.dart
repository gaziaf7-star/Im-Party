import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/home/domain/entities/room_entity.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/lock_pk_icon.dart';

class Theme2RoomCard extends StatelessWidget {
  final RoomEntity roomEntity;

  /// Overrides the default tap behaviour. When null, falls back to the
  /// audio-only default (ignores live rooms, enters audio rooms). The Live tab
  /// passes its own handler here to enter the live room.
  final VoidCallback? onTap;

  const Theme2RoomCard({
    required this.roomEntity,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 2-col grid: 10.w padding each side + 10.w crossAxisSpacing between columns.
    // Logical tile width drives the cover's ResizeImage decode target so the
    // cover decodes at ~tile size instead of full network resolution.
    final coverDecodeWidth = (ScreenUtil().screenWidth - 30.w) / 2;
    return MultiTapCard(
      onTap: () {
        if (onTap != null) {
          onTap!();
          return;
        }
        // Video live is removed: live rooms are not enterable. Ignore the tap.
        if (roomEntity.streamType == "live") return;
        if (di<FetchUserDataBloc>().state.reqState.isLoaded) {
          di<RoomStateManager>().navigateToRoom(
            RoomEntryRequest(
              context: context,
              roomData: roomEntity,
              isLive: false,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Room Cover Image
          Expanded(
            child: ClipRRect(
              borderRadius: 10.radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover — falls back to the host's avatar when the room has
                  // no cover (most lives: the broadcast row never had one set),
                  // and to name initials as the last resort. Never the black
                  // app-logo placeholder (owner report 2026-06-11).
                  ImageViewWidget(
                    url: (roomEntity.cover ?? '').isNotEmpty
                        ? roomEntity.cover!
                        : roomEntity.ownerImage ?? '',
                    boxFit: BoxFit.cover,
                    width: coverDecodeWidth,
                    displayName: roomEntity.name ?? '',
                  ),

                  // Top-right: Visitors + Signal bars
                  PositionedDirectional(
                    top: 8.h,
                    end: 8.w,
                    child: Container(
                      padding:
                          context.paddingSymmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ColorManager.black.withValues(alpha: 0.45),
                        borderRadius: 12.radius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${roomEntity.visitorsCount ?? 0}',
                            // Sits on a FIXED dark cover overlay — stays light so
                            // it never turns invisible under a light panel text
                            // palette (onDark is intentionally not admin-driven).
                            style: TextStyle(
                              color: ColorManager.onDark,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          3.wBox,
                          // Signal bars icon
                          Icon(
                            Icons.signal_cellular_alt,
                            color: ColorManager.theme2SignalBars,
                            size: 14.sp,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-left: Room level image
                  if (roomEntity.roomLevelImage != null &&
                      roomEntity.roomLevelImage!.isNotEmpty)
                    PositionedDirectional(
                      top: 8.h,
                      start: 8.w,
                      child: ImageViewWidget(
                        url: roomEntity.roomLevelImage!,
                        boxFit: BoxFit.contain,
                        width: 34.w,
                        height: 18.h,
                      ),
                    ),

                  // Lock/PK icons
                  PositionedDirectional(
                    top: 35.h,
                    end: 8.w,
                    child: LockAndPkIcon(
                      isPK: roomEntity.isPK ?? false,
                      isPassword: roomEntity.passwordStatus ?? false,
                      isHasLuckyBox: roomEntity.hasLuckyBox ?? false,
                    ),
                  ),

                  // Bottom-right: Party badge
                  PositionedDirectional(
                    bottom: 8.h,
                    end: 8.w,
                    child: _PartyBadge(
                      streamType: roomEntity.streamType,
                    ),
                  ),

                  // Bottom gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.r),
                          bottomRight: Radius.circular(10.r),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            ColorManager.black.withValues(alpha: 0.5),
                            ColorManager.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          6.hBox,

          // Room name + country flag
          Padding(
            padding: context.paddingSymmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    roomEntity.name ?? '',
                    style: TextStyle(
                      color: ColorManager.theme2TextPrimary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                if (roomEntity.country?.flag != null &&
                    roomEntity.country!.flag.isNotEmpty) ...[
                  4.wBox,
                  ImageViewWidget(
                    url: roomEntity.country?.flag ?? '',
                    height: 18,
                    width: 18,
                  ),
                ],
              ],
            ),
          ),

          // Room intro / description
          if (roomEntity.roomIntro != null && roomEntity.roomIntro!.isNotEmpty)
            Padding(
              padding: context.paddingSymmetric(horizontal: 2),
              child: Text(
                roomEntity.roomIntro!,
                style: TextStyle(
                  color: ColorManager.theme2TextSecondary,
                  fontSize: 10.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                textDirection: TextDirection.rtl,
              ),
            ),
        ],
      ),
    );
  }
}

class _PartyBadge extends StatelessWidget {
  final String? streamType;

  const _PartyBadge({this.streamType});

  @override
  Widget build(BuildContext context) {
    final isLive = streamType == "live";
    final label = isLive ? StringManager.live.tr() : StringManager.party.tr();

    return Container(
      padding: context.paddingSymmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ColorManager.theme2PartyBadge,
        borderRadius: 12.radius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🎉',
            style: TextStyle(fontSize: 10.sp),
          ),
          3.wBox,
          Text(
            label,
            // Label on a FIXED colored party/live badge — stays light for
            // contrast regardless of the admin text palette.
            style: TextStyle(
              color: ColorManager.onDark,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
