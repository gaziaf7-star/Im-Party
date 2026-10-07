import 'dart:ui' as ui;
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/scale_animation_for_text.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LuckGiftBannerWidget extends StatefulWidget {
  final String giftImage;
  final int giftNum;
  final String reciverName;
  final String? senderName;
  final String? senderImg;
  final int? totalWin;
  final VoidCallback? onHideComplete;

  /// How long the combo bar stays open with no new gift before it counts down
  /// to zero and closes. Each new gift restarts this window. Kept in step with
  /// the sender's combo inactivity window in [LuckyCandy] so the visible
  /// countdown reaches zero exactly as the session closes.
  final Duration sessionDuration;

  const LuckGiftBannerWidget({
    super.key,
    required this.giftImage,
    required this.giftNum,
    required this.reciverName,
    required this.totalWin,
    this.senderName,
    this.senderImg,
    this.onHideComplete,
    this.sessionDuration = const Duration(seconds: 3),
  });

  @override
  State<LuckGiftBannerWidget> createState() => _LuckGiftBannerWidgetState();
}

class _LuckGiftBannerWidgetState extends State<LuckGiftBannerWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  /// Drives the combo window. Runs FORWARD 0.0 → 1.0 over [sessionDuration]
  /// (0 = just refilled, 1 = elapsed). The visible ring shows the REMAINING
  /// fraction (1 - value), so it drains full → empty; on completion the banner
  /// closes.
  late AnimationController _countdownController;

  int? _lastGiftNum;
  bool _closing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation = Tween(
      begin: const Offset(-650, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _countdownController = AnimationController(
      vsync: this,
      duration: widget.sessionDuration,
    )..addStatusListener((status) {
        // Countdown elapsed with no new gift → close the bar.
        if (status == AnimationStatus.completed) _close();
      });

    _lastGiftNum = widget.giftNum;

    _controller.forward();

    _restartCountdown();
  }

  @override
  void didUpdateWidget(covariant LuckGiftBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A new gift arrived → bump the counter and restart the countdown window so
    // an active combo keeps the bar open and the timer visibly refills.
    if (widget.giftNum != oldWidget.giftNum) {
      _lastGiftNum = widget.giftNum;
      _restartCountdown();
    }
  }

  /// Refills the countdown ring to full and restarts the window. Running forward
  /// from 0.0 makes the displayed remaining fraction (1 - value) drain over
  /// [sessionDuration]; reaching 1.0 fires [AnimationStatus.completed] → close.
  void _restartCountdown() {
    if (_closing) return;
    _countdownController.forward(from: 0.0);
  }

  void _close() {
    if (_closing) return;
    // Guard against a stale gift count from an in-flight rebuild.
    if (widget.giftNum != _lastGiftNum) {
      _restartCountdown();
      return;
    }
    _closing = true;
    if (_controller.isAnimating || _controller.isCompleted) {
      _controller.reverse().then((_) {
        if (mounted) widget.onHideComplete?.call();
      });
    } else {
      widget.onHideComplete?.call();
    }
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _offsetAnimation.value,
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.r),
                bottomLeft: Radius.circular(40.r),
              ),
              gradient: LinearGradient(
                colors: ColorManager.luckyGiftBannerColors,
              ),
            ),
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Row(
                children: [
                  SizedBox(width: 4.w),

                  /// sender image
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
                      displayName: widget.senderName ??
                          MyDataModel.getInstance().name ??
                          "",
                      image: widget.senderImg ??
                          MyDataModel.getInstance().profile?.image ??
                          "",
                    ),
                  ),

                  SizedBox(width: 5.w),

                  /// sender → receiver
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.senderName ??
                            MyDataModel.getInstance().name ??
                            "",
                        style: TextStyle(
                          color: ColorManager.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          const TextWidget("➡️"),
                          SizedBox(width: 5.w),
                          Text(
                            widget.reciverName == "الغرفة"
                                ? StringManager.allSeats.tr()
                                : widget.reciverName,
                            style: TextStyle(
                              color: ColorManager.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                    ],
                  ),

                  SizedBox(width: 5.w),

                  /// Gift Image
                  UserImage(
                    image: widget.giftImage,
                    boxFit: BoxFit.fill,
                    imageSize: 40.sp,
                  ),

                  SizedBox(width: 30.w),

                  /// xN (wrapped in the combo countdown ring) + total win
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _countdownController,
                        builder: (context, child) {
                          return CircularPercentIndicator(
                            radius: 18.r,
                            lineWidth: 3,
                            // Remaining fraction (1 - elapsed): the ring drains
                            // full → empty as the combo timer runs out, then the
                            // bar closes.
                            percent: (1.0 - _countdownController.value)
                                .clamp(0.0, 1.0)
                                .toDouble(),
                            backgroundColor:
                                ColorManager.white.withValues(alpha: 0.25),
                            progressColor: ColorManager.white,
                            center: child,
                          );
                        },
                        // The countdown circle constrains its center child's width,
                        // which clipped/wrapped a large combo count (e.g. x31968).
                        // OverflowBox lets the count render full-width on one line,
                        // overflowing the circle instead of wrapping.
                        child: OverflowBox(
                          minWidth: 0,
                          maxWidth: double.infinity,
                          alignment: Alignment.center,
                          child: TextScaleAnimation(
                            text: "x${widget.giftNum}",
                          ),
                        ),
                      ),
                      if (widget.totalWin != null && widget.totalWin! > 0)
                        SizedBox(height: 5.h),
                      if (widget.totalWin != null && widget.totalWin! > 0)
                        Text(
                          "+${widget.totalWin}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: "BungeeSpice",
                          ),
                        ),
                    ],
                  ),

                  SizedBox(width: 20.w),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
