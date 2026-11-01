import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/widgets/agency_ui.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class AgencySettingScreen extends StatefulWidget {
  final int? initialIndex;

  const AgencySettingScreen({super.key, this.initialIndex});

  @override
  State<AgencySettingScreen> createState() => _AgencySettingScreenState();
}

class _AgencySettingScreenState extends State<AgencySettingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _tabLength;

  @override
  void initState() {
    super.initState();
    _tabLength = (StringManager.userType[2]!) ? 2 : 1;
    _tabController = TabController(
        length: _tabLength,
        vsync: this,
        initialIndex: widget.initialIndex ?? 0);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: StringManager.agencySetting.tr(),
        backgroundColor: Colors.white,
        iconLasted:
            _tabController.index == _tabLength - 1 // Last tab is Join Requests
                ? TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, Routes.agencyMembersHistoryScreen);
                    },
                    child: const TextWidget(StringManager.record),
                  )
                : null,
      ),
      body: Column(
        children: [
          Container(
            height: 42.h,
            margin: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AgencyUI.surface,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: ColorManager.primary,
              unselectedLabelColor: AgencyUI.muted,
              labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
              unselectedLabelStyle:
                  TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
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
              splashBorderRadius: BorderRadius.circular(20.r),
              labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              tabs: [
                if (StringManager.userType[2]!)
                  Text(StringManager.addAdmin.tr().toUpperCase()),
                Text(StringManager.joinRequests.tr().toUpperCase()),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                if (StringManager.userType[2]!) const IdentitySetting(),
                const JoinRequestsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
