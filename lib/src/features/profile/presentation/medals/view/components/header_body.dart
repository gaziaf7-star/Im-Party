part of '../medals_page.dart';

class _HeaderBody extends StatelessWidget {
  const _HeaderBody({required this.index, required this.pageController});

  final int index;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Was a fixed height (237.h, then 320.h) sized for the old, shorter
      // content -- the new "My medal" 10-slot card is taller and overflowed
      // it ("BOTTOM OVERFLOWED"). Nothing downstream needs a fixed header
      // height, so let the Column size itself to its actual content instead.
      // Was a solid ColorManager.scaffoldBgSpecial fill -- now transparent so
      // the page's own dark SVIP background image (with its top lighting
      // effect) shows through instead of being hidden behind this header.
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBarWidget(
            backgroundColor: ColorManager.transparent,
            title: index == 1
                ? StringManager.myRoomBadge.tr()
                : StringManager.myBadge.tr(),
            // Fixed white (was the mutable textPrimary token) -- this now
            // sits on the dark SVIP background image, same reason the VIP
            // page fixes its own title/back-icon colour to white there.
            titleStyle: context.bodyLarge.bold.colorExt(Colors.white),
            iconColor: ColorManager.white,
          ),
          SizedBox(height: 10,),
          _BadgesBody(
            index: index,
          ),

          SizedBox(height: 10,),
          // Padding(
          //   padding: context.paddingOnly(
          //     start: 15,
          //     bottom: 20,
          //     top: 10,
          //   ),
          //   child: SmoothPageIndicator(
          //     controller: pageController,
          //     count: 2,
          //     effect: WormEffect(
          //         dotHeight: 10.h,
          //         dotWidth: 10.w,
          //         activeDotColor: ColorManager.headerColor,
          //         dotColor: ColorManager.timeColor.withValues(alpha: (0.5))),
          //   ),
          // ),
        ],
      ),
    );
  }
}
