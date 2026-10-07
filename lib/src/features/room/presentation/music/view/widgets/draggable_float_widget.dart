part of '../component/music_widget.dart';

class CustmDraggableFloatWidget extends StatelessWidget {
  /// The spin animation, owned by the parent [_MusicWidgetState].
  final Animation<double> turns;

  const CustmDraggableFloatWidget({required this.turns, super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableFloatWidget(
      config: DraggableFloatWidgetBaseConfig(
        initPositionYInTop: false,
        initPositionYMarginBorder: ScreenUtil().screenHeight - 300,
        borderTopContainTopBar: true,
        borderBottom: 30,
      ),
      onTap: () {
        // Tapping the floating widget opens the control dialog. The DJ sees
        // enabled controls; everyone else sees a read-only "now playing" view.
        bottomDailog(
          context: context,
          widget: const MusicDialog(),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ConstantsManager.isVariantBuildA
                ? Container(
                    height: 60.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: (0.5)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IgnorePointer(
                        child: ShowSVGA(
                          svgaAssetPath: AssetsManager.musicFloatIcon,
                          height: 25.h,
                          width: 25.w,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 70.h,
                    width: 70.w,
                    child: ClipRRect(
                      borderRadius: 30.radius,
                      child: RippleAnimation(
                        repeat: true,
                        color: ColorManager.gold,
                        minRadius: 30,
                        ripplesCount: 6,
                        size: Size(60.w, 60.h),
                        child: RotationTransition(
                          turns: turns,
                          child: Container(
                            height: 70.h,
                            width: 70.w,
                            decoration: BoxDecoration(
                              color: ColorManager.transparent,
                              borderRadius: 70.radius,
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: AssetImage(
                                  AssetsManager.music,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          // Only the active DJ can stop the shared music for everyone.
          if (canControlMusic())
            GestureDetector(
              onTap: () {
                di<MusicRoomBloc>().add(const DestroyMusicRoomListEvent());
              },
              child: Container(
                decoration: BoxDecoration(
                    color: ColorManager.black.withValues(alpha: (0.5)),
                    borderRadius: 20.radius),
                padding: context.paddingAll(4),
                child: Icon(
                  CupertinoIcons.clear,
                  color: Colors.white,
                  size: 14.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
