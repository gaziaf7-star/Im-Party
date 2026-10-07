import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/md_indicator.dart';
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
      appBar: AppBarWidget(
        title: StringManager.agencySetting.tr(),
        backgroundColor: ColorManager.scaffoldBg,
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
          Padding(
            padding: context.paddingSymmetric(horizontal: 10),
            child: TabBar(
              controller: _tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              labelStyle:
                  context.bodyMedium.size(12).colorExt(ColorManager.textPrimary),
              unselectedLabelStyle: context.bodyMedium
                  .size(11)
                  .colorExt(ColorManager.textPrimary.withValues(alpha: (0.5))),
              indicatorPadding: context.paddingSymmetric(horizontal: 10),
              indicator: MDIndicator(
                  indicatorColor: ColorManager.lightBlack,
                  indicatorWidth: 17.w,
                  indicatorHeight: 4.h,
                  radius: 20),
              labelPadding: context.paddingSymmetric(horizontal: 20),
              indicatorSize: TabBarIndicatorSize.label,
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
