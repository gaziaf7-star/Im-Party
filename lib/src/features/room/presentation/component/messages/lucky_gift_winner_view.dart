import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/text_sanitizer.dart';

/// Big lucky gift win notification — celebratory golden message shown in the
/// room comment feed when a user wins a significant prize from lucky gifts.
/// Redesigned with a premium festive look: shimmering gold background with
/// sparkles, bold white text with gold shadow, and a glowing coin icon to
/// emphasize the exciting win moment (matches the coin sound played alongside).
class LuckyGiftWinnerView extends StatelessWidget {
  final Map<String, dynamic> data;
  final double fontSize;
  const LuckyGiftWinnerView({super.key, required this.data, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final winCoins = data['winCoins']?.toString() ?? '0';
    final senderName = (data['senderName'] ?? '').toString().sanitizedForDisplay;
    final giftName = data['giftName']?.toString() ?? '';
    final winTimes = data['winTimes']?.toString() ?? '';

    return Container(
      width: ScreenUtil().screenWidth,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/lucky_win_bg.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Coin icon (glowing)
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 28.sp,
            ),
          ),

          SizedBox(width: 12.w),

          // Win message
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '🎉 ${StringManager.congratulations.tr()} ',
                    style: TextStyle(
                      fontSize: (fontSize * 1.1).sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: senderName,
                    style: TextStyle(
                      fontSize: fontSize.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF8B4513), // Brown
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          offset: const Offset(0, 0),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: ' ${StringManager.send.tr()} ',
                    style: TextStyle(
                      fontSize: fontSize.sp,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: giftName,
                    style: TextStyle(
                      fontSize: fontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B4513),
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          offset: const Offset(0, 0),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: ' ${StringManager.got.tr()} ',
                    style: TextStyle(
                      fontSize: fontSize.sp,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: winTimes,
                    style: TextStyle(
                      fontSize: (fontSize * 1.15).sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF8B4513),
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          offset: const Offset(0, 0),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: ' ${StringManager.turn.tr()} ',
                    style: TextStyle(
                      fontSize: fontSize.sp,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: '💰 $winCoins ',
                    style: TextStyle(
                      fontSize: (fontSize * 1.2).sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFF6B00),
                          offset: const Offset(0, 0),
                          blurRadius: 8,
                        ),
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          offset: const Offset(2, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: StringManager.coins_.tr(),
                    style: TextStyle(
                      fontSize: fontSize.sp,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
