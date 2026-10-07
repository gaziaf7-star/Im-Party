import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/room/presentation/room_ticker.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_theme_bloc/get_super_bombs_theme_bloc.dart';
import 'package:general/src/features/room/presentation/super_bomb/view/super_boom_controller.dart';

class SuperBoomBanner extends StatefulWidget {
  final Map<String, dynamic> bomb;
  const SuperBoomBanner({super.key, required this.bomb});

  @override
  State<SuperBoomBanner> createState() => _SuperBoomBannerState();
}

class _SuperBoomBannerState extends State<SuperBoomBanner>
    with TickerProviderStateMixin {
  static const int startSeconds = 30;
  late int _seconds;
  StreamSubscription<int>? _tickerSubscription;
  late AnimationController _controller;

  Animation<Offset>? animationControllerPng;
  AnimationController? controllerEntroPng;

  @override
  void initState() {
    super.initState();
    _seconds = startSeconds;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: startSeconds),
    )..forward();

    startTimer();

    controllerEntroPng = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    animationControllerPng = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1.5,
      ),
      TweenSequenceItem(
        tween: ConstantTween(const Offset(0.0, 0.0)), // Pause in center
        weight: 2.0,
      ),
      TweenSequenceItem(
        tween:
            Tween(begin: const Offset(0.0, 0.0), end: const Offset(-1.0, 0.0))
                .chain(CurveTween(curve: Curves.easeIn)),
        weight: 2.5,
      ),
    ]).animate(controllerEntroPng ?? AnimationController(vsync: this));
    controllerEntroPng?.forward().then((_) {
      SuperBoomController.removeCurrentBomb();
    });
  }

  void startTimer() {
    _tickerSubscription = RoomTicker.instance.subscribe((_) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        RoomTicker.instance.unsubscribe(_tickerSubscription);
        _tickerSubscription = null;
      }
    });
  }

  @override
  void dispose() {
    RoomTicker.instance.unsubscribe(_tickerSubscription);
    _controller.dispose();
    controllerEntroPng?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SlideTransition(
        position: animationControllerPng!,
        child: SizedBox(
          height: 65.h,
          width: MediaQuery.sizeOf(context).width - 20,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 60.h,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsManager.superBoomBanner),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ImageViewWidget(
                        url: widget.bomb["user_image"] ?? "",
                        boxFit: BoxFit.fill,
                        width: 45.w,
                        height: 45.h,
                        shape: BoxShape.circle,
                      ),
                      10.wBox,
                      Text(
                        "Open The Super Bomb",
                        style: context.bodyMedium.copyWith(
                          color: ColorManager.white,
                          fontSize: 15.sp,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 30.w,
                        height: 30.h,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return CircularProgressIndicator(
                                  value: 1.0 - _controller.value,
                                  strokeWidth: 3,
                                  backgroundColor: ColorManager.orange
                                      .withValues(alpha: 0.3),
                                  valueColor: const AlwaysStoppedAnimation(
                                      ColorManager.white),
                                );
                              },
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: ColorManager.orange,
                                shape: BoxShape.circle,
                              ),
                              width: 25.w,
                              height: 25.h,
                              child: Center(
                                child: Text(
                                  "$_seconds",
                                  style: context.bodyMedium.copyWith(
                                    color: ColorManager.white,
                                    decoration: TextDecoration.none,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      60.wBox,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -10,
                right: 0,
                child: Builder(builder: (context) {
                  final themeState = di<GetSuperBombsThemeBloc>().state;
                  final cachedLevelFile = themeState.getCachedLevelBoomFile(
                      SuperBoomController.roomBoomLevel.value);
                  final cachedFullFile =
                      themeState.getCachedProgressAnimationFile(100);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ShowSVGA(
                        fileCacheSvga: cachedLevelFile,
                        height: 70.h,
                        width: 70.w,
                      ),
                      ShowSVGA(
                        fileCacheSvga: cachedFullFile,
                        height: 70.h,
                        width: 70.w,
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
