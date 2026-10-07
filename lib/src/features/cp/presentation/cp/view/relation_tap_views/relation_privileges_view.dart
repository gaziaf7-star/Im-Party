import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';

class RelationPrivilegesView extends StatelessWidget {
  const RelationPrivilegesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 10),
      child: const Column(
        children: [
          CreatePrivilegesWidget(),
        ],
      ),
    );
  }
}

class CreatePrivilegesWidget extends StatefulWidget {
  const CreatePrivilegesWidget({super.key});

  @override
  State<CreatePrivilegesWidget> createState() => _CreatePrivilegesWidgetState();
}

class _CreatePrivilegesWidgetState extends State<CreatePrivilegesWidget> {
  static const _levels = [1, 2, 3, 4, 6, 7, 8];

  late int _selectedLevel = _levels.first;

  String _titleFor(int level) {
    switch (level) {
      case 1:
        return StringManager.relationPrivilegesL1.tr();
      case 2:
        return StringManager.relationPrivilegesL2.tr();
      case 3:
        return StringManager.relationPrivilegesL3.tr();
      case 4:
        return StringManager.relationPrivilegesL4.tr();
      case 6:
        return StringManager.relationPrivilegesL6.tr();
      case 7:
        return StringManager.relationPrivilegesL7.tr();
      default:
        return StringManager.relationPrivilegesL8.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CpLegendBox(
      label: StringManager.cpTabPrivileges.tr(),
      backgroundGradient: const [Color(0xFF6A3FD1), Color(0xFF4B2A9E)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CpLevelRow(
            levels: _levels,
            activeLevel: _selectedLevel,
            onSelect: (level) => setState(() => _selectedLevel = level),
          ),
          16.hBox,
          // Only the tapped level's privilege shows below, on request —
          // was every level listed at once.
          RichText(
            text: TextSpan(
              style: context.bodySmall.colorExt(Colors.white70),
              children: [
                TextSpan(
                  text: 'Lv.$_selectedLevel  ',
                  style: context.bodySmall.bold.colorExt(const Color(0xFFFFD98A)),
                ),
                TextSpan(text: _titleFor(_selectedLevel)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
