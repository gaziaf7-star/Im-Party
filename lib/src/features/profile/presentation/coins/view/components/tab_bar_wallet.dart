part of '../coins_page.dart';

class TabBarRechargeWidget extends StatelessWidget {
  final TabController controller;
  const TabBarRechargeWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.h,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: 50.radius,
          color: ColorManager.surfaceCardColor,
        ),
        child: TabBar(
          dividerHeight: 0,
          indicatorSize: TabBarIndicatorSize.tab,

          padding: context.paddingSymmetric(
            horizontal: 5,
            vertical: 4,
          ),
          controller: controller,
          labelColor: ColorManager.buttonTextColor,
          unselectedLabelColor: ColorManager.secondaryText,
          unselectedLabelStyle: context.bodyLarge.w400,
          labelStyle: context.bodyLarge.w400,
          indicator: BoxDecoration(
            borderRadius: 50.radius,
            color: ColorManager.primary,
          ),
          tabs: [
            Padding(
              padding:context.paddingSymmetric(horizontal: 20),
              child: Text(StringManager.gold.tr()),
            ),
            Padding(
              padding:context.paddingSymmetric(horizontal: 20),
              child: Text(StringManager.diamond.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
