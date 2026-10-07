import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';

class RelationRecoveryWidget extends StatelessWidget {
  const RelationRecoveryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CpRuleSection(
      emoji: '💔',
      title: StringManager.relationRecoveryTitleR1.tr(),
      isLast: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(StringManager.relationRecoveryR1.tr()),
          8.hBox,
          Text(
            StringManager.relationRecoveryTitleR2.tr(),
            style: context.bodyMedium.bold.colorExt(const Color(0xFFFFB3E0)),
          ),
          4.hBox,
          Text(StringManager.relationRecoveryR2.tr()),
        ],
      ),
    );
  }
}
