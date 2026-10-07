import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// Shown to the host once their broadcast has ended.
///
/// Identical for a party room and a live stream — the backend computes the same
/// summary for both, so the host sees the same card whichever they were running.
class SessionSummaryDialog extends StatelessWidget {
  const SessionSummaryDialog({super.key, required this.summary});

  final RoomSessionSummaryModel summary;

  /// Never throws and never blocks: a summary that cannot be shown must not
  /// stop the host from leaving a room they have already left.
  static Future<void> show(
    BuildContext context,
    RoomSessionSummaryModel summary,
  ) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SessionSummaryDialog(summary: summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManager.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: context.paddingSymmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          // Fixed white card / black text on request -- was following the
          // shared dark-theme surface/text colors, which read fine in dark
          // mode but not what was asked for here specifically.
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              StringManager.sessionEnded.tr(),
              style: context.bodyLarge.w600.colorExt(ColorManager.black),
            ),
            6.hBox,
            TextWidget(
              summary.formattedDuration,
              isTranslate: false,
              style: context.titleLarge.w600.colorExt(ColorManager.red),
            ),
            TextWidget(
              StringManager.sessionDuration.tr(),
              style: context.bodySmall.colorExt(ColorManager.black),
            ),
            20.hBox,
            Row(
              children: [
                _Stat(
                  value: summary.viewers,
                  label: StringManager.sessionViewers,
                ),
                _Stat(
                  value: summary.coinsReceived,
                  label: StringManager.sessionCoins,
                ),
                _Stat(
                  value: summary.newFollowers,
                  label: StringManager.sessionFollowers,
                ),
              ],
            ),
            if (summary.topGifters.isNotEmpty) ...[
              20.hBox,
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextWidget(
                  StringManager.sessionTopGifters.tr(),
                  style: context.bodyMedium.w600
                      .colorExt(ColorManager.black),
                ),
              ),
              8.hBox,
              ...summary.topGifters.map((gifter) => _GifterRow(gifter: gifter)),
            ],
            20.hBox,
            SizedBox(
              width: double.infinity,
              child: ButtonWidget(
                title: StringManager.ok.tr(),
                height: 44.h,
                radius: 22.r,
                // Brand gradient instead of flat primary, on request.
                backgroundColors: ColorManager.brandGradientColors,
                titleColor: ColorManager.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWidget(
            '$value',
            isTranslate: false,
            style: context.bodyLarge.w600.colorExt(ColorManager.black),
          ),
          4.hBox,
          TextWidget(
            label.tr(),
            textAlign: TextAlign.center,
            style: context.bodySmall.colorExt(ColorManager.black),
          ),
        ],
      ),
    );
  }
}

class _GifterRow extends StatelessWidget {
  const _GifterRow({required this.gifter});

  final SessionGifterModel gifter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingOnly(bottom: 8),
      child: Row(
        children: [
          UserImage(
            image: gifter.image,
            imageSize: 32,
          ),
          10.wBox,
          Expanded(
            child: TextWidget(
              gifter.name,
              maxLines: 1,
              isTranslate: false,
              overflow: TextOverflow.ellipsis,
              style: context.bodyMedium.colorExt(ColorManager.black),
            ),
          ),
          TextWidget(
            '${gifter.coins}',
            isTranslate: false,
            style: context.bodyMedium.w600.colorExt(ColorManager.gold),
          ),
        ],
      ),
    );
  }
}
