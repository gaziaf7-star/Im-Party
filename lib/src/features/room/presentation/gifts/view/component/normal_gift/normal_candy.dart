import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/view/component/normal_gift/gift_bottom_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';

class NormalCandy extends StatefulWidget {
  final void Function(int?) sendGift;
  final bool isMoment;
  final List<Color> gradientColors;
  const NormalCandy({
    required this.sendGift,
    this.isMoment = false,
    required this.gradientColors,
    super.key,
  });

  @override
  NormalCandyState createState() => NormalCandyState();
}

class NormalCandyState extends State<NormalCandy>
    with TickerProviderStateMixin {
  int compo = 1;
  late final AnimationController _progressController;
  Timer? timerDuration;
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    showWidget(isMoment: widget.isMoment);
  }

  @override
  void dispose() {
    _sendFinalGift();
    _progressController.dispose();
    timerDuration?.cancel();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (compo != 0)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Compo X  ',
                  style: context.bodyMedium.colorExt(ColorManager.textPrimary),
                ),
                TextSpan(
                  text: compo.toString(),
                  style: context.bodyMedium.colorExt(
                      widget.gradientColors.isNotEmpty
                          ? widget.gradientColors.first
                          : ColorManager.primary),
                ),
              ],
            ),
          ),
        SizedBox(width: 20.w),
        InkWell(
          onTap: () {
            timerDuration?.cancel();
            showWidget(isMoment: widget.isMoment);
            setState(() {
              compo++;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: animationController,
                child: Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(AssetsManager.coinsVip),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) {
                  final percent = _progressController.value;
                  return CircularPercentIndicator(
                    radius: 34.r,
                    lineWidth: 3,
                    animation: true,
                    curve: Curves.ease,
                    animateFromLastPercent: true,
                    addAutomaticKeepAlive: true,
                    percent: percent < 1 ? percent : 1,
                    backgroundColor: Colors.grey,
                    progressColor: widget.gradientColors.isNotEmpty
                        ? widget.gradientColors.first
                        : ColorManager.primary,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showWidget({required bool isMoment}) {
    _progressController
      ..stop()
      ..reset()
      ..forward();

    timerDuration = Timer(const Duration(milliseconds: 2500), () {
      _sendFinalGift();
      if (!isMoment &&
          mounted &&
          Navigator.canPop(context) &&
          NavObserver.currentRoute.value != Routes.roomScreen &&
          NavObserver.currentRoute.value != Routes.liveRoomScreen) {
        Navigator.pop(context);
      }
    });

    GiftBottomBar.typeCandy.value = TypeCandy.normalCandy;
  }

  void _sendFinalGift() {
    if (compo != 0) {
      widget.sendGift(compo);
      compo = 0;
      _progressController.reset();
      GiftBottomBar.typeCandy.value = TypeCandy.non;
    }
  }
}
