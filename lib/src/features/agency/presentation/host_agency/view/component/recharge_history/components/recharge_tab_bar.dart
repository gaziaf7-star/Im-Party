part of 'package:general/src/features/agency/presentation/host_agency/view/component/recharge_history/recharge_history_page.dart';
class RechargeTabBar extends StatelessWidget {
  final TabController rechargeHistoryController;

  const RechargeTabBar({required this.rechargeHistoryController, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 410.w,
      height: 50.h,
      child: TabBar(
          controller: rechargeHistoryController,
          labelPadding: const EdgeInsets.only(bottom: 0.0),
          isScrollable: false,
          dividerHeight: 0,
          indicatorColor: ColorManager.primary,
          unselectedLabelStyle: context.bodyMedium.size(16).w400.colorExt( ColorManager.secondaryText),
          labelStyle: context.bodyMedium.size(16).w600.colorExt( ColorManager.primary),
          indicatorPadding: context.paddingOnly(top: 0,start: 2,end: 2),
          tabs:  [
            TextWidget(StringManager.received.tr()),
            TextWidget(StringManager.google.tr()),

          ]),
    );
  }
}
