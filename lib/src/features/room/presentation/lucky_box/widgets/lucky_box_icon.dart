import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/dialog_lucky_box.dart';
import 'package:general/src/features/room/room.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LuckyBoxIcon extends StatefulWidget {
  final VoidCallback? giftButtonCallBack;
  final String roomId;

  const LuckyBoxIcon({
    super.key,
    required this.giftButtonCallBack,
    required this.roomId,
  });

  @override
  State<LuckyBoxIcon> createState() => _LuckyBoxIconState();
}

class _LuckyBoxIconState extends State<LuckyBoxIcon> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final boxes =
          LuckyBoxVariables.luckyBoxMap['luckyBoxes'] as List<LuckyBoxData>;
      if (boxes.isEmpty) return;

      _currentIndex = (_currentIndex + 1) % boxes.length;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<LuckyBoxData> luckyBoxes =
        (LuckyBoxVariables.luckyBoxMap['luckyBoxes'] as List<LuckyBoxData>);
    Methods.printLog(
      '[LuckyBoxDebug] LuckyBoxIcon.build() luckyBoxes.length=${luckyBoxes.length}',
    );

    if (luckyBoxes.isEmpty) return const SizedBox.shrink();
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      width: 75.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 75.w,
            height: 75.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: luckyBoxes.length,
              onPageChanged: (index) {
                _currentIndex = index;
              },
              itemBuilder: (context, index) {
                final LuckyBoxData box = luckyBoxes[index];
                return GestureDetector(
                  onTap: () {
                    bottomDailog(
                      context: context,
                      widget: DialogLuckyBox(
                        coins: box.coins,
                        luckyBoxId: box.boxId,
                        ownerBoxName: box.ownerName,
                        typeLuckyBox: box.typeLuckyBox,
                        ownerImage: box.ownerImage,
                        uid: box.uId,
                        usersNumber: box.usersNumber,
                        giftButtonCallBack: widget.giftButtonCallBack,
                        roomId: widget.roomId,
                        remTime: box.endTime,
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Positioned(
                        bottom: 0,
                        right: isRtl ? null : 0.w,
                        left: isRtl ? 0.w : null,
                        child: Image.asset(
                          AssetsManager.luckyBox,
                          width: 60.h,
                          height: 60.h,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: isRtl ? null : 0.w,
                        left: isRtl ? 0.w : null,
                        child: UserImage(
                          image: box.ownerImage,
                          displayName: box.ownerName,
                          imageSize: 20.h,
                          border: Border.all(
                            color: const Color(0xFFffd947),
                            width: 1.w,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: isRtl ? null : 0.w,
                        right: isRtl ? 0.w : null,
                        child: Text(
                          box.typeLuckyBox == TypeLuckyBox.normalBox
                              ? "Normal"
                              : "Super",
                          style: TextStyle(
                            color: const Color(0xFFffd947),
                            fontWeight: FontWeight.w900,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 5.h),
          SmoothPageIndicator(
            controller: _pageController,
            count: luckyBoxes.length,
            effect: luckyBoxes.length <= 6
                ? WormEffect(
                    dotHeight: 8.h,
                    dotWidth: 8.h,
                    spacing: 6.w,
                    activeDotColor: const Color(0xFFffd947),
                    dotColor: ColorManager.grayLight,
                  )
                : ScrollingDotsEffect(
                    activeDotColor: const Color(0xFFffd947),
                    dotColor: ColorManager.grayLight,
                    dotHeight: 8.h,
                    dotWidth: 8.h,
                    spacing: 6.w,
                    maxVisibleDots: 5,
                  ),
          ),
        ],
      ),
    );
  }
}
