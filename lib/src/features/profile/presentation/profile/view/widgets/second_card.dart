part of 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

/// SVIP as a single full-width hero banner.
///
/// Was the app's own purple `me_svip.webp` artwork, locked to that artwork's
/// aspect ratio (so height could only ever change by cropping it). Per
/// request — a shorter banner AND a gold/premium colour instead of purple,
/// "like other apps" — this is now a built widget instead of a fixed image:
/// a warm gold-to-bronze gradient card with "SVIP" and a tagline on the
/// left, the app's own crown artwork on the right. A fixed, compact height
/// rather than an aspect ratio, so it can never read as an oversized block
/// again regardless of screen width.
class SecondCard extends StatelessWidget {
  const SecondCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Inset from the screen edges. The card sat flush against both sides
    // because _ProfileBody adds no horizontal padding around this block —
    // the grouped list below is full-bleed on purpose, this card is not.
    return Padding(
      padding: context.paddingSymmetric(horizontal: 12),
      child: Semantics(
        button: true,
        label: StringManager.svip.tr(),
        child: GestureDetector(
          onTap: () => context.pushNamedRoute(Routes.vipScreen),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 78.h,
            width: double.infinity,
            padding: context.paddingSymmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7A5230), Color(0xFF412D19)],
              ),
              borderRadius: 16.radius,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWidget(
                        StringManager.svip.tr(),
                        style: context.bodyLarge.w800
                            .size(20)
                            .colorExt(const Color(0xFFF4D998)),
                      ),
                      3.hBox,
                      TextWidget(
                        StringManager.vipHeaderText.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyMedium
                            .size(11.5)
                            .colorExt(const Color(0xFFE0C9A6)),
                      ),
                    ],
                  ),
                ),
                10.wBox,
                ImageWidget(
                  image: AssetsManager.crown,
                  height: 46.h,
                  width: 46.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}