import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/cp.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/tap_bar_body.dart';
import 'package:general/src/features/cp/presentation/cp/view/cp_my_relations.dart';
import 'package:general/src/features/cp/presentation/cp/view/relation_tap_views/relation_special_friends_view.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';

import 'relation_tap_views/relation_privileges_view.dart';
import 'relation_tap_views/relation_rules_view.dart';

class CpPage extends StatefulWidget {
  const CpPage({super.key});

  @override
  State<CpPage> createState() => _CpPageState();
}

class _CpPageState extends State<CpPage> with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CpGlowBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _CpTopBar(),
                // Push the tab bar down toward the middle of the screen,
                // leaving the background photo visible above it, on request.
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: TapBarBody(controller: tabController),
                ),
                Expanded(
                  // No box of its own here — each tab's own CpLegendBox is
                  // the only visible border/background, so it doesn't sit
                  // inside a second, redundant outer box.
                  child: TabBarView(
                    controller: tabController,
                    children: const [
                      _ScrollableCpTab(child: RelationRulesView()),
                      _ScrollableCpTab(child: RelationPrivilegesView()),
                      _ScrollableCpTab(
                        child: RelationSpecialFriendsView(),
                      ),
                    ],
                  ),
                ),
                _MyRelationsButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // CpMyRelations and its children read CpProfileBloc
                        // / CpRelationsLevelsBloc off the nearest ancestor
                        // BlocProvider (BlocProvider.of / bare BlocBuilder
                        // with no explicit `bloc:`), but no provider for
                        // either bloc exists anywhere above this route —
                        // confirmed by a live crash: "BlocProvider.of()
                        // called with a context that does not contain a
                        // CpProfileBloc". Provide both here, scoped to this
                        // route only.
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider<CpProfileBloc>(
                              create: (_) => di<CpProfileBloc>(),
                            ),
                            BlocProvider<CpRelationsLevelsBloc>.value(
                              value: di<CpRelationsLevelsBloc>(),
                            ),
                          ],
                          child: const CpMyRelations(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

/// Plain back button + title row — replaces the old gradient hero card that
/// used to sit above the tab bar, on request.
class _CpTopBar extends StatelessWidget {
  const _CpTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Text(
            StringManager.cP.tr(),
            style: context.titleLarge.bold.copyWith(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollableCpTab extends StatelessWidget {
  const _ScrollableCpTab({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      child: child,
    );
  }
}

/// Same floating gold-edged pill look as the tab bar (CpTabPill), on request
/// — was a big standalone gradient button before.
class _MyRelationsButton extends StatelessWidget {
  const _MyRelationsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      child: CpTabPill(
        text: StringManager.myRelations.tr(),
        selected: true,
        onTap: onTap,
      ),
    );
  }
}

