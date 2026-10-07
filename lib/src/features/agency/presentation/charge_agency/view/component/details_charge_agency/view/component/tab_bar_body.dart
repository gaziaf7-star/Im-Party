
part of 'package:general/src/features/agency/presentation/charge_agency/view/component/details_charge_agency/view/details_charge_agency_screen.dart';
class _TabBarBody extends StatelessWidget {
  const _TabBarBody({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
          padding: context.paddingSymmetric(horizontal: 10),
          width: ScreenUtil().screenWidth,
          color: ColorManager.white,
      child: TabBar(
        controller: controller,
        isScrollable: false,
        padding: context.paddingZero(),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 1.0,
        indicator: MDIndicator(
          radius: 20.r,
          indicatorSize: MDIndicatorSize.normal,
          indicatorHeight: 3,
          indicatorWidth: 35.w,
          indicatorColor: ColorManager.primary,
        ),
        indicatorColor: ColorManager.primary,
        unselectedLabelStyle: context.bodyMedium.colorExt(ColorManager.secondaryText,).w500.size(17).copyWith(fontFamily: "AppFont",),
        labelStyle: context.bodyMedium.bold.size(17).copyWith(fontFamily: "AppFont",),
        dividerHeight: 0,
        tabs: [
          Text(StringManager.send.tr()),
          Text(StringManager.received.tr()),
        ],
      ),
    );
  }
}
