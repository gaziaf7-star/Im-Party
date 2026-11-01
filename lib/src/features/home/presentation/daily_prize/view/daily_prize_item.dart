import 'package:general/src/core/index.dart';

/// One day of the weekly sign-in: soft cream card with the reward artwork,
/// "Day N" underneath, a purple glow on today and a check badge once taken.
class DailyPrizeItem extends StatelessWidget {
  const DailyPrizeItem({
    super.key,
    this.day,
    this.image,
    this.takenPrize,
    this.isLastDay,
    this.isThisDay,
    this.size,
    this.height,
    this.scale,
  });

  final String? image;
  final bool? takenPrize;
  final bool? isLastDay;
  final bool? isThisDay;
  final int? day;
  final double? size;

  /// Card height; defaults to 100.h.
  final double? height;

  /// Width the text/icon sizes are derived from (the dialog width).
  final double? scale;

  static const _cream = Color(0xFFFFF4EA);
  static const _creamBorder = Color(0xFFF6DEC8);
  static const _purple = Color(0xFF9B5CF6);
  static const _text = Color(0xFF5B4A66);

  @override
  Widget build(BuildContext context) {
    final h = height ?? 100.h;
    final s = scale ?? ScreenUtil().screenWidth;
    final today = isThisDay == true;
    final taken = takenPrize == true;
    final img = (size ?? h * 0.5);

    return Container(
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s * 0.03),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: today
              ? const [Color(0xFFF7EEFF), Color(0xFFEBDDFF)]
              : const [Colors.white, _cream],
        ),
        border: Border.all(
          color: today ? _purple : _creamBorder,
          width: today ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: today
                ? _purple.withValues(alpha: .35)
                : Colors.black.withValues(alpha: .05),
            blurRadius: today ? 10 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: taken && !today ? .55 : 1,
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  SizedBox(
                    width: img,
                    height: img,
                    child: _reward(img),
                  ),
                  const Spacer(),
                  Text(
                    'Day $day',
                    style: TextStyle(
                      color: today ? _purple : _text,
                      fontSize: s * 0.032,
                      fontWeight: today ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: h * 0.07),
                ],
              ),
            ),
          ),
          if (taken)
            Positioned(
              top: h * 0.05,
              right: h * 0.05,
              child: Container(
                padding: EdgeInsets.all(s * 0.006),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFB57BFF), Color(0xFF7C3AED)],
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: s * 0.03,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _reward(double box) {
    final url = image ?? '';
    if (url.isEmpty) {
      return Icon(Icons.card_giftcard_rounded,
          size: box * .8, color: const Color(0xFFFF7AA8));
    }
    if (url.contains('.svga') || url.contains('.zz')) {
      return CacheSvgaWidget(
        isStopErrorAndLoadingFrame: false,
        url: url,
        width: box,
        height: box,
        boxFit: BoxFit.contain,
      );
    }
    return ImageViewWidget(
      url: url,
      height: box,
      width: box,
      boxFit: BoxFit.contain,
    );
  }
}
