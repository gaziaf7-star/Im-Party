import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';

class CreateRelationWidget extends StatelessWidget {
  const CreateRelationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CpRuleSection(
      emoji: '💗',
      title: StringManager.createRelation.tr(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. ${StringManager.createRelationRule1.tr()}'),
          4.hBox,
          Text('2. ${StringManager.createRelationRule2.tr()}'),
          4.hBox,
          Text('3. ${StringManager.createRelationRule3.tr()}'),
        ],
      ),
    );
  }
}
