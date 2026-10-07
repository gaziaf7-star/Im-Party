import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_event.dart';
class LuckyGiftBanner extends StatefulWidget {
  final Map<String, dynamic> data;

  const LuckyGiftBanner({
    super.key,
    required this.data,
  });

  @override
  State<LuckyGiftBanner> createState() => _LuckyGiftBannerState();
}

class _LuckyGiftBannerState extends State<LuckyGiftBanner>
    with TickerProviderStateMixin {
  late AnimationController luckWinnerGiftBannerController;
  late Animation<Offset> offsetAnimationLuckyWinnerGiftBanner;

  @override
  void initState() {
    super.initState();

    if (widget.data['speed'] == "normal") {
      luckWinnerGiftBannerController = AnimationController(
        duration: const Duration(seconds: 4), // 2s in, 1s stay, 2s out
        vsync: this,
      );
    } else {
      luckWinnerGiftBannerController = AnimationController(
        duration: const Duration(seconds: 2), // 2s in, 1s stay, 2s out
        vsync: this,
      );
    }

    offsetAnimationLuckyWinnerGiftBanner = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(1.0, 0.0), // off-screen right
          end: const Offset(0.0, 0.0), // center
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(
          const Offset(0.0, 0.0), // pause at center
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: const Offset(-1.0, 0.0), // off-screen left
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
    ]).animate(luckWinnerGiftBannerController);

    luckWinnerGiftBannerController.forward().whenComplete(
      () {
        di<ShowBannersBloc>().add(const ShowBannerInAppEvent(bannerData: {}));
        if (GiftController().userBannerData.isNotEmpty) {
          GiftController().userBannerData.removeAt(0);
        }
        Future.delayed(
          const Duration(milliseconds: 300),
          () => GiftController().advanceQueue(),
        );
      },
    );
  }

  @override
  void dispose() {
    luckWinnerGiftBannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: luckWinnerGiftBannerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            offsetAnimationLuckyWinnerGiftBanner.value.dx *
                MediaQuery.of(context).size.width,
            offsetAnimationLuckyWinnerGiftBanner.value.dy,
          ),
          child: SizedBox(
            height: 70.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 50.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: ColorManager.luckyGiftBannerColors,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 60.w),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorManager.white,
                            width: 1.w,
                          ),
                        ),
                        child: UserImage(
                          imageSize: 35.sp,
                          boxFit: BoxFit.fill,
                          image: widget.data["uImg"] ?? "",
                          displayName: widget.data["uName"] ?? "",
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 100.w,
                                ),
                                child: Text(
                                  widget.data["uName"] ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.bodyMedium.copyWith(
                                    color: ColorManager.white,
                                    fontSize: 12.sp,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                " sends lucky gift ",
                                style: context.bodyMedium.copyWith(
                                  color: ColorManager.white,
                                  fontSize: 12.sp,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                widget.data["gNum"].toString(),
                                style: context.bodyMedium.copyWith(
                                  fontFamily: "BungeeSpice",
                                  fontSize: 13.sp,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Text(
                                " times returns ",
                                style: context.bodyMedium.copyWith(
                                  color: ColorManager.white,
                                  fontSize: 12.sp,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Text(
                                widget.data["per"].toString(),
                                style: context.bodyMedium.copyWith(
                                  fontFamily: "BungeeSpice",
                                  fontSize: 13.sp,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Text(
                                " coins",
                                style: context.bodyMedium.copyWith(
                                  color: ColorManager.white,
                                  fontSize: 12.sp,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: -5.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(50.r),
                        child: Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                ColorManager.primary,
                                ColorManager.primary.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            widget.data["gNum"].toString(),
                            style: context.bodyMedium.copyWith(
                              fontFamily: "BungeeSpice",
                              decoration: TextDecoration.none,
                              fontSize: 25.sp,
                            ),
                          ),
                          Image.asset(
                            AssetsManager.group,
                            width: 90.w,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
