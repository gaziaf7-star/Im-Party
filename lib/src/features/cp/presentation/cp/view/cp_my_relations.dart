import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/cp.dart';
import 'package:general/src/features/cp/presentation/cp/view/MY_relation_tap_views/myrelation_cp_view.dart';
import 'package:general/src/features/cp/presentation/cp/view/MY_relation_tap_views/myrelation_special_friends_view.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/myrelation_tap_bar_body.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';

class CpMyRelations extends StatefulWidget {
  const CpMyRelations({super.key});

  @override
  State<CpMyRelations> createState() => _CpMyRelationsState();
}

class _CpMyRelationsState extends State<CpMyRelations> with TickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    BlocProvider.of<CpProfileBloc>(context).add(GetCpProfileEvents(userId: MyDataModel.getInstance().id.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CpGlowBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 8.h, 16.w, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                        tooltip:
                            MaterialLocalizations.of(context).backButtonTooltip,
                      ),
                      Text(
                        StringManager.myRelations.tr(),
                        style: context.titleLarge.bold.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Push the tab bar down toward the middle of the screen,
                // matching the main CP page.
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.20),
                MyRelationTapBarBody(
                  controller: tabController!,
                ),
                12.hBox,
                SizedBox(
                  height: ScreenUtil().screenHeight * 2,
                  width: ScreenUtil().screenWidth,
                  child: TabBarView(
                    controller: tabController,
                    children: const [
                      MyRelationCpView(),
                      MyRelationSpecialFriendsView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
