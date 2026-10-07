import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/create_relation_widget.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/relation_level_widget.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/relation_recovery_widget.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';

class RelationRulesView extends StatelessWidget {
  const RelationRulesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 10),
      child: CpLegendBox(
        label: StringManager.cpTabRules.tr(),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreateRelationWidget(),
            RelationLevelWidget(),
            RelationRecoveryWidget(),
          ],
        ),
      ),
    );
  }
}
