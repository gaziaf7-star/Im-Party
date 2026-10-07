import 'package:general/src/core/index.dart';

/// Rounded selectable chip for the Lucky Bag sheet redesign -- solid red
/// fill + white text when selected, tan fill + dark text otherwise. Kept
/// separate from [CpTabPill] (cp_design.dart) since that one's pink/blue
/// gradient look is specific to the CP tab bar, not this sheet.
class LuckyPill extends StatelessWidget {
  const LuckyPill({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  static const Color _unselectedFill = Color(0xFFF3DFA6);
  static const Color _unselectedText = Color(0xFF6B4A1E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ColorManager.redAccount : _unselectedFill,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w700).colorExt(
                selected ? ColorManager.white : _unselectedText,
              ),
        ),
      ),
    );
  }
}
