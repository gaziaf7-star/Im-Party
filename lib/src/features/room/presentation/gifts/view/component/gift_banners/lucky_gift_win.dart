import 'package:general/src/core/index.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_event.dart';
import 'package:flutter_svga/flutter_svga.dart';

class LuckyGiftWin extends StatefulWidget {
  final int winTimes;
  const LuckyGiftWin({
    super.key,
    required this.winTimes,
  });

  @override
  State<LuckyGiftWin> createState() => _LuckyGiftWinState();
}

class _LuckyGiftWinState extends State<LuckyGiftWin>
    with SingleTickerProviderStateMixin {
  late SVGAAnimationController animationController;

  @override
  void initState() {
    animationController = SVGAAnimationController(vsync: this);
    _getAnimation();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _getAnimation() async {
    final bannerImage = getBannerImage();
    if (bannerImage.isEmpty) {
      di<LuckyGiftWinBloc>().add(const RemoveLuckyWinEvent());
      Future.delayed(
        const Duration(milliseconds: 50),
        () {
          di<LuckyGiftWinBloc>().add(const PlayNextLuckyWinEvent());
        },
      );
      return;
    }
    final videoItem = await SvgaMovieCache.instance.loadFromAsset(bannerImage);
    if (videoItem == null) return;
    if (!mounted) return;

    animationController.videoItem = videoItem;
    animationController.duration = const Duration(milliseconds: 2000);

    animationController.videoItem?.dynamicItem.setText(
        TextPainter(
            text: TextSpan(
          children: [
            TextSpan(
              text: StringManager.times.tr(),
              style: TextStyle(
                color: ColorManager.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )),
        "test-a");

    animationController.videoItem?.dynamicItem.setText(
        TextPainter(
            text: TextSpan(
          children: [
            TextSpan(
              text: StringManager.luckyGifts.tr(),
              style: TextStyle(
                color: ColorManager.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )),
        "test-b");

    animationController.forward().whenComplete(
      () {
        animationController.clear();
        di<LuckyGiftWinBloc>().add(const RemoveLuckyWinEvent());
        Future.delayed(
          const Duration(milliseconds: 50),
          () {
            di<LuckyGiftWinBloc>().add(const PlayNextLuckyWinEvent());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.w,
      height: 100.h,
      child: SVGAImage(
        animationController,
        fit: BoxFit.cover,
      ),
    );
  }

  String getBannerImage() {
    if (widget.winTimes == 5) {
      return AssetsManager.multiple5;
    } else if (widget.winTimes == 10) {
      return AssetsManager.multiple10;
    } else if (widget.winTimes == 20) {
      return AssetsManager.multiple20;
    } else if (widget.winTimes == 50) {
      return AssetsManager.multiple50;
    } else if (widget.winTimes == 100) {
      return AssetsManager.multiple100;
    } else if (widget.winTimes == 250) {
      return AssetsManager.multiple250;
    } else if (widget.winTimes == 500) {
      return AssetsManager.multiple500;
    } else if (widget.winTimes == 1000) {
      return AssetsManager.multiple1000;
    } else {
      return "";
    }
  }
}
