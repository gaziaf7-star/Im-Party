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
  });

  @override
  Widget build(BuildContext context) {
    // A colourful gold-edged pill, matching the CP profile's own
    // Personal/Moment/Gift tab-bar look exactly (same colours/border as
    // CpTabPill): selected = pink->purple gradient + bold gold ring,
    // unselected = a filled blue gradient + a lighter gold ring -- not a
    // plain white/bordered chip. Shows the country's NAME as text, not the
    // flag photo, on request.
    final label = isGlobal ? StringManager.all.tr() : (countryEntity?.name ?? '');
    return Container(
      height: 34.h,
      margin: context.paddingSymmetric(horizontal: 4),
      padding: context.paddingSymmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: 12.radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSelected
              ? const [Color(0xFFFF8AC2), Color(0xFFAC55E7)]
              : const [Color(0xFF4FC3FF), Color(0xFF3556E8)],
        ),
        border: Border.all(
          color: isSelected
              ? const Color(0xE6FFD98A)
              : const Color(0x99FFD98A),
          width: isSelected ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0x66FF5EA8)
                : const Color(0x66000000),
            blurRadius: isSelected ? 10 : 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: 12.radius,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isGlobal) ...[
              Icon(Icons.public_rounded, size: 14.h, color: Colors.white),
              4.wBox,
            ],
            TextWidget(
              label,
              maxLines: 1,
              style: context.bodySmall
                  .copyWith(fontSize: 12)
                  .colorExt(Colors.white)
                  .copyWith(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}