part of 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

/// The wealth and charm level badges under the name in the Mine header.
///
/// The panel art for these ladders is ALREADY a complete badge — a pill carrying
/// its own emblem and its own `Lv.N` text, one design per band of ten levels. So
/// when artwork exists it is drawn on its own and nothing is added around it.
/// Wrapping it in a second pill squeezed a 3:1 image into a 22px circle where the
/// number was unreadable, and printing our own number beside it showed a
/// different value again, because the count and the artwork come from different
/// fields in the response.
///
/// The composed pill below is only the FALLBACK, for an account that has not
/// reached level 1 on a ladder and therefore has no artwork to show.
///
/// Lives here rather than in the shared [UserInfoRow]: that widget renders other
/// people's profiles, room sheets and search results, and these belong to the
/// owner's own header.
class LevelCharmPills extends StatelessWidget {
  const LevelCharmPills({required this.level, super.key});

  final LevelEntity? level;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Sized per ladder, because the two are not the same shape and the thing
        // that has to stay readable is the PILL, not the whole artwork. The
        // wealth badge's emblem rises well above its pill (art is ~1.85:1, pill
        // about half the height), so it needs more height to give the number the
        // same size as charm, whose artwork is almost all pill (~3.5:1).
        _LadderBadge(
          image: level?.senderImage ?? '',
          value: level?.senderLevel ?? 0,
          artHeight: 40,
          artAspect: 1.85,
          gradient: const [Color(0xFF3A4450), Color(0xFF8D97A3)],
          fallbackAsset: AssetsManager.icLevelBadge,
        ),
        6.wBox,
        _LadderBadge(
          image: level?.receiverImage ?? '',
          value: (level?.reciverLevel ?? 0).toInt(),
          artHeight: 24,
          artAspect: 3.5,
          gradient: const [Color(0xFF4B4BD6), Color(0xFF8E8EF0)],
          fallbackAsset: AssetsManager.icCharmBadge,
        ),
      ],
    );
  }
}

class _LadderBadge extends StatelessWidget {
  const _LadderBadge({
    required this.image,
    required this.value,
    required this.artHeight,
    required this.artAspect,
    required this.gradient,
    required this.fallbackAsset,
  });

  final String image;
  final int value;

  /// Height of the artwork, chosen so this ladder's pill matches the other's.
  final double artHeight;

  /// Width-to-height of this ladder's artwork.
  final double artAspect;

  /// Only used by the fallback pill.
  final List<Color> gradient;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    if (image.trim().isNotEmpty) {
      // Both dimensions are required. The underlying cache widget only resolves
      // an intrinsic size when height AND width are null; give it just a height
      // and it lays out at zero width and vanishes.
      final h = artHeight.h;
      return ImageViewWidget(
        url: image,
        height: h,
        width: h * artAspect,
        boxFit: BoxFit.contain,
      );
    }

    // No tier reached yet: a neutral pill with the bundled glyph and the count,
    // so the ladder is still visible as something to climb.
    return Container(
      height: 20.h,
      padding: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 22.h,
            width: 22.h,
            child: ImageWidget(
              image: fallbackAsset,
              height: 22.h,
              width: 22.h,
              boxFit: BoxFit.contain,
            ),
          ),
          2.wBox,
          TextWidget(
            '$value',
            style: context.bodySmall.w700.size(11).colorExt(ColorManager.white),
          ),
        ],
      ),
    );
  }
}
