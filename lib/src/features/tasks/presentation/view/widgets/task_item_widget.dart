import 'package:general/src/features/tasks/tasks.dart';

import '../../../../../core/index.dart';

/// One task row: what to do, how far along, and the claim button.
class TaskItemWidget extends StatelessWidget {
  const TaskItemWidget({
    super.key,
    required this.task,
    required this.isCollecting,
    required this.onCollect,
  });

  final DailyTaskModel task;

  /// This row's claim is in flight.
  final bool isCollecting;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.paddingOnly(bottom: 10),
      padding: context.paddingSymmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        // Explicit white + a subtle border/shadow instead of the dynamic
        // `surfaceCardColor` (a remote-brandable token that can render
        // differently per white-label deployment) -- guarantees a clean,
        // consistent white card here, on request.
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _TaskIcon(type: task.type),
          10.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWidget(
                  task.title,
                  maxLines: 2,
                  // Admin-authored copy, already localised server-side by the
                  // title_en/title_ar pair — running it through .tr() would
                  // look up a key that cannot exist.
                  isTranslate: false,
                  // Explicit black on request, instead of the dynamic
                  // `textPrimary` token.
                  style: context.bodyMedium.w600.colorExt(ColorManager.black),
                ),
                4.hBox,
                Row(
                  children: [
                    TextWidget(
                      '+${task.totalPoints} ${StringManager.taskPoints.tr()}',
                      style: context.bodySmall.colorExt(ColorManager.gold),
                    ),
                    8.wBox,
                    TextWidget(
                      '${task.progress}/${task.count}',
                      // Explicit, fixed grey instead of the dynamic
                      // `secondaryText` token, so this stays clearly
                      // readable against the white card regardless of
                      // remote branding config.
                      style: context.bodySmall
                          .colorExt(ColorManager.black.withValues(alpha: 0.55)),
                    ),
                  ],
                ),
                6.hBox,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: task.ratio,
                    minHeight: 5.h,
                    backgroundColor: ColorManager.divider,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(ColorManager.primary),
                  ),
                ),
              ],
            ),
          ),
          10.wBox,
          SizedBox(
            width: 86.w,
            child: ButtonWidget(
              title: task.isClaimed
                  ? StringManager.taskCollected.tr()
                  : StringManager.taskCollect.tr(),
              height: 34.h,
              radius: 17.r,
              fontSize: 12.sp,
              isLoading: isCollecting,
              // A finished-but-unclaimed task is the only actionable state.
              // Anything else keeps the button visible (so rows stay the same
              // width) but inert.
              backgroundColor: task.isClaimable
                  ? ColorManager.primary
                  : ColorManager.divider,
              // Explicit black / fixed grey instead of the dynamic
              // `buttonTextColor` / `secondaryText` tokens, so the button
              // label stays clearly readable in both states regardless of
              // remote branding config.
              titleColor: task.isClaimable
                  ? ColorManager.black
                  : ColorManager.black.withValues(alpha: 0.45),
              onPressed: task.isClaimable ? onCollect : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskIcon extends StatelessWidget {
  const _TaskIcon({required this.type});

  final String type;

  /// Task types are set by an admin, so an unrecognised one must still draw
  /// something rather than crash on a missing asset.
  String get _asset {
    switch (type) {
      case 'up_mic':
        return AssetsManager.micOnIcon;
      case 'live_minutes':
      case 'enter_room':
        return AssetsManager.icMeAudioRoom;
      case 'images':
      default:
        return AssetsManager.icMeCheckIn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: ColorManager.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: ImageWidget(
          image: _asset,
          width: 22.w,
          height: 22.h,
        ),
      ),
    );
  }
}