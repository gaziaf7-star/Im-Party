import 'dart:ui' as ui;
import 'package:general/src/core/index.dart';

class SenderBalanceBanner extends StatefulWidget {
  final String giftPrice;
  const SenderBalanceBanner({super.key, required this.giftPrice});

  @override
  State<SenderBalanceBanner> createState() => _SenderBalanceBannerState();
}

class _SenderBalanceBannerState extends State<SenderBalanceBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value == 0) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: AlignmentDirectional.topEnd,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              padding: EdgeInsets.only(
                left: 10.w,
                right: 5.w,
                top: 5.h,
                bottom: 5.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.r),
                  bottomLeft: Radius.circular(40.r),
                ),
                gradient: LinearGradient(
                  colors: ColorManager.senderBallanceBannerColors,
                ),
              ),
              child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AssetsManager.coinIcon,
                      height: 20.h,
                      width: 20.h,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      _formatPrice(widget.giftPrice),
                      style: TextStyle(
                        color: ColorManager.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatPrice(String priceStr) {
    final price = double.tryParse(priceStr.replaceAll(',', '')) ?? 0;
    if (price < 100000) {
      return priceStr;
    } else if (price < 1000000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
    } else if (price < 1000000000) {
      return '${(price / 1000000).toStringAsFixed(price % 1000000 == 0 ? 0 : 1)}M';
    } else {
      return '${(price / 1000000000).toStringAsFixed(price % 1000000000 == 0 ? 0 : 1)}B';
    }
  }
}
