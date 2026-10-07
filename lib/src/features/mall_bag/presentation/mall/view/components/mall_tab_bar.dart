part of '../mall_page.dart';

class _MallTabBar extends StatelessWidget {
  final TabController controller;

  const _MallTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.scaffoldBg,
      child: TabBar(
        onTap: (index) {
          di<MallBloc>().add(ChangeAppBarUIMallEvent(index: controller.index));
        },
        controller: controller,
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        splashFactory: NoSplash.splashFactory,
        dividerHeight: 0,
        labelPadding: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        indicator: MDIndicator(
          radius: 20.r,
          indicatorSize: MDIndicatorSize.normal,
          indicatorHeight: 3,
          indicatorWidth: 35.w,
          indicatorColor: ColorManager.primary,
        ),
        labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 16.sp,
              color: ColorManager.primary,
              fontWeight: FontWeight.w500,
            ),
        unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 16.sp,
              color: ColorManager.greyTextColor,
              fontWeight: FontWeight.w500,
            ),
        tabs: [
          Padding(
            padding: context.paddingOnly(start: 8),
            child: Text(StringManager.bubble.tr()),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(StringManager.frames.tr()),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(StringManager.entries.tr()),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(StringManager.specialId.tr()),
          ),
          Padding(
            padding: context.paddingOnly(end: 8),
            child: Text(StringManager.profileFrame.tr()),
          ),
        ],
      ),
    );
  }
}
