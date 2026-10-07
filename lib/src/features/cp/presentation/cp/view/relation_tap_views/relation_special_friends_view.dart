import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';

class RelationSpecialFriendsView extends StatelessWidget {
  const RelationSpecialFriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 10),
      child: const Column(
        children: [
          SpecialFriendWidget(),
        ],
      ),
    );
  }
}

class SpecialFriendWidget extends StatefulWidget {
  const SpecialFriendWidget({super.key});

  @override
  State<SpecialFriendWidget> createState() => _SpecialFriendWidgetState();
}

class _SpecialFriendWidgetState extends State<SpecialFriendWidget> {
  static const _levels = [1, 2];

  late int _selectedLevel = _levels.first;

  @override
  Widget build(BuildContext context) {
    return CpLegendBox(
      label: StringManager.cpTabFriend.tr(),
      backgroundGradient: const [Color(0xFF1F7A6B), Color(0xFF11423B)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CpLevelRow(
            levels: _levels,
            activeLevel: _selectedLevel,
            onSelect: (level) => setState(() => _selectedLevel = level),
          ),
          16.hBox,
          RichText(
            text: TextSpan(
              style: context.bodySmall.colorExt(Colors.white70),
              children: [
                TextSpan(
                  text: 'Lv.$_selectedLevel  ',
                  style: context.bodySmall.bold.colorExt(const Color(0xFFFFD98A)),
                ),
                TextSpan(text: StringManager.specialMicSeatEffect.tr()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
