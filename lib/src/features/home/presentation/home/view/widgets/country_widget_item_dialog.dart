import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

/// One row in the full-page country list (`CountryFilterPage`).
///
/// Was a 2-column grid card with a flag emoji/photo AND up to 3 supporter
/// avatars per country. On request this is now a single-column list row
/// matching the reference image exactly, pixel for pixel: the country's
/// name in plain black text (same colour whether selected or not — the
/// image never recolours the label itself), and on the right a plain
/// selection circle — grey-outlined when unselected, filled solid blue with
/// a white checkmark when selected. No flag, nothing else.
class CountryWidgetItemDialog extends StatelessWidget {
  final CountryEntity? countryEntity;
  final bool isSelected;
  final VoidCallback onTap;

  /// When set, the item renders this plain label instead of a country row
  /// (e.g. the leading "Recommended" entry that clears the country filter).
  final String? label;

  const CountryWidgetItemDialog({
    super.key,
    this.countryEntity,
    required this.onTap,
    required this.isSelected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final name = label ?? countryEntity?.name ?? '';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: TextWidget(
                name,
                // Same colour selected or not, matching the reference image
                // — only the circle on the right changes on selection.
                style: context.bodyMedium.w600.colorExt(
                  ColorManager.momentPostTextColor,
                ),
              ),
            ),
            _SelectionCircle(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _SelectionCircle extends StatelessWidget {
  const _SelectionCircle({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.h,
      width: 24.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Was the app's own pink->purple brand gradient — on request this
        // now matches the reference image exactly: a plain solid blue fill
        // (ColorManager.blue, a fixed constant — not the mutable/panel
        // driven tokens elsewhere), not a gradient.
        color: isSelected ? ColorManager.blue : null,
        border: isSelected
            ? null
            : Border.all(
          color: ColorManager.momentPostTextColor.withValues(
            alpha: 0.25,
          ),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check, size: 15.h, color: Colors.white)
          : null,
    );
  }
}