part of 'package:general/reels_viewer/src/reels_viewer.dart';

/// TikTok-style "more options" sheet for a reel.
///
/// Items (per owner spec):
/// - Save video: downloads the reel video to the device gallery.
/// - Report: reports the reel.
void showReelMoreOptionsSheet(
  BuildContext context,
  ReelsEntity reel, {
  void Function()? onDelete,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ColorManager.transparent,
    barrierColor: ColorManager.black.withValues(alpha: 0.45),
    isScrollControlled: true,
    builder: (sheetContext) =>
        _ReelMoreOptionsSheet(reel: reel, onDelete: onDelete),
  );
}

class _ReelMoreOptionsSheet extends StatelessWidget {
  const _ReelMoreOptionsSheet({required this.reel, this.onDelete});

  final ReelsEntity reel;
  final void Function()? onDelete;

  Future<void> _saveVideo(BuildContext context) async {
    Navigator.of(context).pop();
    final url = reel.url;
    final startCtx = navKey.currentContext;
    if (url == null || url.isEmpty) {
      if (startCtx != null) {
        Methods.showToast(startCtx,
            message: StringManager.someThingWentWrong.tr(), isError: true);
      }
      return;
    }
    if (startCtx != null) {
      Methods.showToast(startCtx,
          message: StringManager.reelPreparingVideo.tr());
    }
    try {
      // Materialize the reel into a proper .mp4 temp file (reusing the cached
      // download when available), then hand it to the OS share/save sheet so
      // the user can "Save Video" / "Save to Files". Uses share_plus (already
      // a dependency) — avoids a native gallery plugin and its build conflicts.
      final dir = await getTemporaryDirectory();
      final tmpPath =
          '${dir.path}/theme2_reel_${reel.id ?? 'video'}.mp4';
      final cached = await ReelsCacheManager().getCachedFileOrNull(url);
      if (cached != null) {
        await cached.copy(tmpPath);
      } else {
        await Dio().download(url, tmpPath);
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tmpPath, mimeType: 'video/mp4')],
        ),
      );
    } catch (_) {
      final ctx = navKey.currentContext;
      if (ctx == null) return;
      Methods.showToast(ctx,
          message: StringManager.reelSaveFailed.tr(), isError: true);
    }
  }

  void _report(BuildContext context) {
    Navigator.of(context).pop();
    Methods.showToast(context, message: StringManager.comingSoon.tr());
  }

  void _delete(BuildContext context) {
    Navigator.of(context).pop();
    onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isOwnReel = reel.user?.id != null &&
        reel.user?.id == MyDataModel.getInstance().id;
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: ColorManager.surfaceCardColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 6.h),
              decoration: BoxDecoration(
                color: ColorManager.grayMouce.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            _ReelMoreOptionRow(
              icon: Icons.download_rounded,
              label: StringManager.reelSaveVideo.tr(),
              onTap: () => _saveVideo(context),
            ),
            _ReelMoreOptionsDivider(),
            _ReelMoreOptionRow(
              icon: Icons.flag_outlined,
              label: StringManager.report.tr(),
              iconColor: ColorManager.redIndicator,
              onTap: () => _report(context),
            ),
            if (isOwnReel && onDelete != null) ...[
              _ReelMoreOptionsDivider(),
              _ReelMoreOptionRow(
                icon: Icons.delete_outline,
                label: StringManager.delete.tr(),
                iconColor: ColorManager.redIndicator,
                onTap: () => _delete(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReelMoreOptionRow extends StatelessWidget {
  const _ReelMoreOptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Row(
            children: [
              Icon(icon,
                  color: iconColor ?? ColorManager.iconColor, size: 25.sp),
              16.wBox,
              Expanded(
                child: TextWidget(
                  label,
                  style: context.bodyMedium
                      .size(16)
                      .colorExt(iconColor ?? ColorManager.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReelMoreOptionsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: ColorManager.grayMouce.withValues(alpha: 0.25),
      indent: 20.w,
      endIndent: 20.w,
    );
  }
}
