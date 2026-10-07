part of '../vip_screen.dart';

/// A small gold "chevron/caret" mark under the selected SVIP tier tab,
/// instead of a straight underline bar — matching the reference image's
/// selection style exactly ("select style sm to sm"). Self-contained here
/// (not touching the shared MDIndicator widget, which other tab bars in
/// the app also use) so nothing else is affected.
class _ChevronIndicator extends Decoration {
  final Color color;
  final double width;
  final double strokeWidth;

  const _ChevronIndicator({
    required this.color,
    this.width = 16,
    this.strokeWidth = 2.4,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _ChevronPainter(this, onChanged);
}

class _ChevronPainter extends BoxPainter {
  final _ChevronIndicator decoration;

  _ChevronPainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size!;
    final w = decoration.width;
    final cx = offset.dx + size.width / 2;
    // With indicatorSize.label the painter's rect is the tab LABEL's own
    // tight bounding box, so drawing at "size.height - strokeWidth" (the
    // bottom edge of the text) made the chevron sit ON/overlapping the
    // text itself instead of below it. Draw it a few px BELOW the label
    // instead, fixing the overlap seen on the selected tier tab.
    final y = offset.dy + size.height + 6.h;
    final paint = Paint()
      ..color = decoration.color
      ..strokeWidth = decoration.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(cx - w / 2, y - w * 0.4)
      ..lineTo(cx, y)
      ..lineTo(cx + w / 2, y - w * 0.4);
    canvas.drawPath(path, paint);
  }
}

class TabBarBody extends StatelessWidget {
  const TabBarBody({
    super.key,
    required this.controller,
    required this.length,
    required this.vipCenterEntity,
  });
  final TabController controller;
  final List<VipCenterEntity> vipCenterEntity;
  final int length;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.label,
        dividerHeight: 0,
        tabAlignment: TabAlignment.start,
        // A small gold chevron/caret under the selected SVIP tier tab
        // instead of a bar, on request ("select style sm to sm") — the
        // index-0 ("VIP Center") tab keeps its original MDIndicator bar
        // untouched.
        indicator: controller.index == 0
            ? MDIndicator(
            indicatorColor: ColorManager.textPrimary,
            indicatorWidth: 17.w,
            indicatorHeight: 3.5.h,
            radius: 20)
            : _ChevronIndicator(
          color: ColorManager.defaultTextVip,
          width: 16.w,
          strokeWidth: 2.4.h,
        ),
        isScrollable: true,
        // Clear size + weight contrast between the selected and
        // unselected tier tabs, on request ("size sm to sm, font sm to
        // sm") -- the selected tab reads noticeably bigger & bolder,
        // matching the reference image.
        unselectedLabelStyle: TextStyle(
          fontSize: controller.index == 0 ? 13.sp : 13.sp,
          fontWeight: FontWeight.w500,
          color: controller.index == 0
              ? ColorManager.secondaryText
          // A muted grey for unselected tier tabs, on request —
          // matching the reference image (was dimmed white before).
              : const Color(0xFF8C8C8C),
        ),
        labelStyle: TextStyle(
          fontSize: controller.index == 0 ? 14.sp : 16.sp,
          fontWeight: FontWeight.w700,
          color: controller.index == 0
              ? ColorManager.textPrimary
          // Gold for the selected tier tab's text, on request,
          // matching the reference image exactly (was plain white
          // before).
              : ColorManager.defaultTextVip,
        ),
        tabs: List.generate(length + 1, (index) {
          if (index == 0) {
            return Text(
              StringManager.vipCenter.tr(),
            );
          }
          return Text(vipCenterEntity[index - 1].name ?? '');
        }),
      ),
    );
  }
}