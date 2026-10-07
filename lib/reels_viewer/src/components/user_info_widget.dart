part of 'package:general/reels_viewer/src/reels_viewer.dart';

class _ReelUserInfo extends StatefulWidget {
  const _ReelUserInfo({
    required this.reelsEntity,
    required this.onUserTap,
    required this.onTapFollow,
    required this.height,
    required this.readMore,
  });

  final ReelsEntity reelsEntity;
  final double height;
  final bool readMore;
  final void Function()? onUserTap;
  final void Function()? onTapFollow;

  @override
  State<_ReelUserInfo> createState() => _ReelUserInfoState();
}

class _ReelUserInfoState extends State<_ReelUserInfo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _discController;

  bool get _hasMusic =>
      widget.reelsEntity.musicName != null &&
      widget.reelsEntity.musicName!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (_hasMusic) {
      _discController.repeat();
    }
  }

  @override
  void didUpdateWidget(_ReelUserInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasMusic) {
      if (!_discController.isAnimating) _discController.repeat();
    } else {
      if (_discController.isAnimating) _discController.stop();
    }
  }

  @override
  void dispose() {
    _discController.dispose();
    super.dispose();
  }

  void _onMusicTap() {
    HapticFeedback.lightImpact();
    Methods.showToast(
      context,
      message: widget.reelsEntity.musicName?.isNotEmpty == true
          ? widget.reelsEntity.musicName!
          : StringManager.music.tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reelsEntity = widget.reelsEntity;
    if (reelsEntity.user == null) return const SizedBox();

    return GestureDetector(
      onTap: () {
        di<GetReelsBloc>().add(const ToggleReadMoreEvent());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: context.paddingOnly(start: 10),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onUserTap?.call();
              },
              child: SizedBox(
                width: 250.w,
                child: AutoScrollText(
                  text: '@${reelsEntity.user?.userName ?? ""}',
                  style: context.bodyMedium
                      .size(15)
                      .bold
                      .colorExt(ColorManager.white),
                ),
              ),
            ),
          ),
          8.hBox,
          _ReelDescription(
            height: widget.height,
            readMore: widget.readMore,
            reelsEntity: reelsEntity,
          ),
          if (_hasMusic) ...[
            10.hBox,
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onMusicTap,
              child: Tooltip(
                message: StringManager.music.tr(),
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: ColorManager.black.withAlpha(120),
                  ),
                  padding: context.paddingSymmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: _discController,
                        child: Icon(
                          Icons.album_rounded,
                          color: ColorManager.textPrimary,
                          size: 16.w,
                        ),
                      ),
                      6.wBox,
                      SizedBox(
                        width: 150.w,
                        child: AutoScrollText(
                          text: reelsEntity.musicName!,
                          style: context.bodyMedium
                              .size(12)
                              .colorExt(ColorManager.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
