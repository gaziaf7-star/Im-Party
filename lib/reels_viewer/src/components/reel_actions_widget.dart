part of 'package:general/reels_viewer/src/reels_viewer.dart';

class _ReelActionsWidget extends StatelessWidget {
  const _ReelActionsWidget({
    required this.reelsEntity,
    required this.onLike,
    required this.onClickShare,
    required this.onClickComment,
    required this.onUserTap,
    required this.onTapFollow,
    this.onDelete,
  });

  final ReelsEntity reelsEntity;
  final void Function()? onLike;
  final void Function()? onClickShare;
  final void Function()? onClickComment;
  final void Function()? onUserTap;
  final void Function()? onTapFollow;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: true,
          label: StringManager.follow.tr(),
          child: Padding(
            padding: context.paddingOnly(end: 10),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GestureDetector(
                  onTap: onUserTap ?? () {},
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    margin: EdgeInsets.only(
                        bottom: reelsEntity.user?.isFollow == true ? 0 : 10.h),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: ColorManager.offWhite, width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: ImageViewWidget(
                        url: reelsEntity.user?.profileUrl ?? '',
                        displayName: reelsEntity.user?.userName ?? '',
                        boxFit: BoxFit.cover,
                        width: 44.w,
                        height: 44.w,
                      ),
                    ),
                  ),
                ),
                // TikTok-style: show + icon below avatar only when NOT following
                if (reelsEntity.user?.isFollow != true)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      (onTapFollow ?? () {})();
                    },
                    child: CircleAvatar(
                      backgroundColor: ColorManager.redIndicator,
                      radius: 9.w,
                      child:
                          Icon(Icons.add, color: ColorManager.white, size: 14.w),
                    ),
                  ),
              ],
            ),
          ),
        ),
        20.hBox,
        _ReelsActionWidget(
          onTap: onLike ?? () {},
          image: AssetsManager.reelsLiked,
          color: (reelsEntity.isLiked == true)
              ? ColorManager.redIndicator
              : ColorManager.offWhite,
          size: 28,
          isActive: reelsEntity.isLiked == true,
          enableHaptic: true,
          semanticLabel: StringManager.likes.tr(),
          semanticValue: Methods.formatCompactNumber(reelsEntity.likeCount ?? 0),
        ),
        _CountWidget(count: reelsEntity.likeCount ?? 0),
        10.hBox,
        _ReelsActionWidget(
          onTap: onClickComment ?? () {},
          image: AssetsManager.reelsChat,
          color: ColorManager.offWhite,
          size: 38,
          semanticLabel: StringManager.comment.tr(),
          semanticValue:
              Methods.formatCompactNumber(reelsEntity.commentCount ?? 0),
        ),
        _CountWidget(count: reelsEntity.commentCount ?? 0),
        10.hBox,
        _ReelsActionWidget(
          onTap: onClickShare ?? () {},
          image: AssetsManager.reelsSend,
          color: ColorManager.offWhite,
          size: 30,
          semanticLabel: StringManager.share.tr(),
          semanticValue: Methods.formatCompactNumber(reelsEntity.sendCount ?? 0),
        ),
        _CountWidget(count: reelsEntity.sendCount ?? 0),
        10.hBox,
        _MoreOptionsButton(reelsEntity: reelsEntity, onDelete: onDelete),
      ],
    );
  }
}

class _MoreOptionsButton extends StatelessWidget {
  const _MoreOptionsButton({required this.reelsEntity, this.onDelete});

  final ReelsEntity reelsEntity;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: StringManager.more.tr(),
      child: Padding(
        padding: context.paddingOnly(end: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () =>
                  showReelMoreOptionsSheet(context, reelsEntity, onDelete: onDelete),
              child: Container(
                color: ColorManager.transparent,
                child: Icon(
                  Icons.more_horiz,
                  color: ColorManager.offWhite,
                  size: 30.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
