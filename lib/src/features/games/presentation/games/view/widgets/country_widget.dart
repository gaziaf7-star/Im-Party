import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class CountryWidget extends StatelessWidget {
  final CountryEntity? countryEntity;
  final bool isShowFlag;
  final bool isSelected;
  final VoidCallback onTap;

  /// Renders a globe instead of a flag, for the "no country filter" entry that
  /// leads the home row. A null [countryEntity] already meant "All" here, but
  /// only as the word -- the row needs something the eye reads as a place.
  final bool isGlobal;

  const CountryWidget({
    super.key,
    this.countryEntity,
    required this.onTap,
    this.isShowFlag = true,
    required this.isSelected,
    this.isGlobal = false,
    this.paletteIndex,
  });

  /// Position in the row; picks this pill's own gradient from [_gradients].
  /// Null falls back to a stable pick from the label.
  final int? paletteIndex;

  /// One gradient per pill (cycled), so every tab has its own colours.
  static const List<List<Color>> _gradients = [
    [Color(0xFFF8284D), Color(0xFF3A3BF0)],
    [Color(0xFFFF8A00), Color(0xFFFF2E93)],
    [Color(0xFF00C27A), Color(0xFF0091FF)],
    [Color(0xFFB144FF), Color(0xFFFF4FA3)],
    [Color(0xFF00B8D9), Color(0xFF5B5CFF)],
    [Color(0xFFFFB300), Color(0xFFFF5722)],
    [Color(0xFF7C4DFF), Color(0xFF00BFA5)],
  ];

  @override
  Widget build(BuildContext context) {
    // Flat pill, no border or shadow. Selected = this pill's own gradient
    // with white bold text; unselected = soft grey with grey text.
    final label = isGlobal ? StringManager.all.tr() : (countryEntity?.name ?? '');
    final gradient = _gradients[
        (paletteIndex ?? label.hashCode).abs() % _gradients.length];
    final fg = isSelected ? Colors.white : const Color(0xFF8E8E93);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 34.h,
        margin: context.paddingSymmetric(horizontal: 4),
        padding: context.paddingSymmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: 12.radius,
          color: isSelected ? null : const Color(0xFFF1F1F3),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: gradient,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isGlobal) ...[
              Icon(Icons.public_rounded, size: 14.h, color: fg),
              4.wBox,
            ],
            TextWidget(
              label,
              maxLines: 1,
              style: context.bodySmall
                  .copyWith(fontSize: 13)
                  .colorExt(fg)
                  .copyWith(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
