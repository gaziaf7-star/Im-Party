part of '../problem_reports_screen.dart';
class SupportTabBar extends StatelessWidget {
  final TabController controller;

  const SupportTabBar({super.key,required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 393.w,
       height: 46.h,
      child: TabBar(
        tabAlignment:  TabAlignment.start,
        onTap: (index) {
          di<MakeProblemReportBloc>().add(ChangeContactDetails(index: index, type: '',));
        },
        isScrollable: true,
        splashFactory: NoSplash.splashFactory,
        dividerHeight: 0,
        controller: controller,
        padding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: ColorManager.lightDarkText,
        indicatorWeight: 2,

        labelPadding: context.paddingSymmetric(horizontal: 10),
        tabs: [
          Tab(
            child: TextWidget(
              StringManager.faqSupport.tr(),
              style: di<MakeProblemReportBloc>().state.indexDetails == 0? context.bodyMedium.size(12).bold.colorExt(ColorManager.textPrimary): context.bodyMedium.size(12).bold.colorExt(ColorManager.textPrimary.withValues(alpha: (0.35 ))),
            ),
          ),
          Tab(
            child: TextWidget(
              StringManager.emailSupport.tr(),
              style: di<MakeProblemReportBloc>().state.indexDetails == 1? context.bodyMedium.size(12).bold.colorExt(ColorManager.textPrimary): context.bodyMedium.size(12).bold.colorExt(ColorManager.textPrimary.withValues(alpha: (0.35 ))),

            ),
          ),
          Tab(
            child: TextWidget(
              StringManager.chatSupport.tr(),
              style: di<MakeProblemReportBloc>().state.indexDetails == 2? context.bodyMedium.size(12).bold.colorExt(ColorManager.textPrimary): context.bodyMedium.size(12).bold.colorExt(ColorManager.textPrimary.withValues(alpha: (0.35 ))),

            ),
          ),
        ],
      ),
    );
  }
}