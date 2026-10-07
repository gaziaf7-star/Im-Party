import '../../../../../../core/index.dart';
import 'cp_design.dart';

class RelationLevelWidget extends StatelessWidget {
  const RelationLevelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CpRuleSection(
      emoji: '🎁',
      title: StringManager.relationLevel.tr(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(StringManager.relationLevelTitle.tr()),
          4.hBox,
          Text('1. ${StringManager.relationLevelRule1.tr()}'),
          4.hBox,
          Text('2. ${StringManager.relationLevelRule2.tr()}'),
          4.hBox,
          Text(StringManager.relationLevelNote.tr()),
        ],
      ),
    );
  }
}
