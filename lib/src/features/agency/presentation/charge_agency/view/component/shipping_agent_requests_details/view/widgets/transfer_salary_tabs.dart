part of'package:general/src/features/agency/presentation/charge_agency/view/component/shipping_agent_requests_details/view/shipping_agent_requests_details.dart';
class TransferSalaryTabs extends StatelessWidget {
  final TabController controller;

  const TransferSalaryTabs({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      overlayColor: WidgetStateColor.transparent,
      labelPadding: context.paddingSymmetric(vertical: 5, horizontal: 8),
      indicatorSize: TabBarIndicatorSize.label,
      physics: const AlwaysScrollableScrollPhysics(),
      controller: controller,
      indicatorWeight: 5,
      indicator: MDIndicator(
          indicatorColor: ColorManager.lightBlack,
          indicatorWidth: 17.w,
          indicatorHeight: 4.h,
          radius: 20
      ),
      indicatorPadding: EdgeInsets.zero,
      tabAlignment: TabAlignment.start,
      padding: EdgeInsets.zero,
      labelStyle: context.bodyMedium.size(18).colorExt(ColorManager.textPrimary),
      unselectedLabelStyle: context.bodyMedium
          .size(14)
          .colorExt(ColorManager.textPrimary.withValues(alpha: (0.5 ))),
      dividerHeight: 0,
      tabs: [
        Text(StringManager.waitingTab.tr()),
        Text(StringManager.acceptedTab.tr()),
        Text(StringManager.transferedTab.tr()),
        Text(StringManager.completeTab.tr()),
        Text(StringManager.rejectedTab.tr()),
      ],
    );
  }
}
