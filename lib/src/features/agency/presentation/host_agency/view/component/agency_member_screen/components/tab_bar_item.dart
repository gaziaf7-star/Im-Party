import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/manager_information_agency/information_agency_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/widgets/agency_ui.dart';

/// Segmented pill tabs (Host Center / Public / Target): the selected tab
/// slides as a white pill over a light grey track.
class TabBarAgency extends StatelessWidget {
  const TabBarAgency({
    super.key,
    required this.controller,
    required this.isOwner,
  });

  final TabController? controller;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AgencyUI.surface,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        splashBorderRadius: BorderRadius.circular(20.r),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: ColorManager.primary,
        unselectedLabelColor: AgencyUI.muted,
        labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
        unselectedLabelStyle:
            TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
        tabs: [
          Tab(text: StringManager.hostCenter.tr().toUpperCase()),
          Tab(text: StringManager.public.tr().toUpperCase()),
          if (StringManager.userType[2]! ||
              (di<InformationAgencyBloc>().state.data?.userStates ?? 0) == 1)
            Tab(text: StringManager.target.tr().toUpperCase()),
        ],
      ),
    );
  }
}
