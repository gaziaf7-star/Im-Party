part of '../medals_page.dart';

/// "My medal" strip + 10-slot medal card, matching the reference design's
/// dark gold-bordered card with locked "?" medal placeholders -- on request,
/// replacing the old small badge-row + Wear button.
class _BadgesBody extends StatelessWidget {
  const _BadgesBody({required this.index});

  final int index;

  static const int _slotCount = 10;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBadgesBloc, UserBadgesState>(
      buildWhen: (prev, curr) => prev.myBadge != curr.myBadge,
      builder: (context, state) {
        final earned = (state.myBadge ?? [])
            .where((badge) => index == 0 ? badge.type != '2' : badge.type == '2')
            .toList();
        void openPicker() {
          // Was a bottom sheet -- now a full page (BadgeManagePage), on
          // request, with the user's own profile avatar/name on top.
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BadgeManagePage(
                  index: 0,
                  pickedRoomIds: state.myBadge
                          ?.where((badge) => badge.type == 2)
                          .map((badge) => badge.id)
                          .toList() ??
                      [],
                  pickedAchievements: state.myBadge
                          ?.where((badge) => badge.type != 2)
                          .map((badge) => badge.id.toString())
                          .toList() ??
                      [],
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BadgeManagePage(
                  index: 1,
                  pickedRoomIds: state.myBadge
                          ?.where((badge) => badge.type != 2)
                          .map((badge) => badge.id)
                          .toList() ??
                      [],
                  pickedAchievements: state.myBadge
                          ?.where((badge) => badge.type == 2)
                          .map((badge) => badge.id.toString())
                          .toList() ??
                      [],
                ),
              ),
            );
          }
        }

        return Padding(
          padding: context.paddingSymmetric(horizontal: 15),
          child: Container(
            padding: context.paddingSymmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: 16.radius,
              // Gradient fill + a thicker gold border, on request (was a
              // flat translucent black with a thin 1px border).
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3A2408), Color(0xFF1C1004)],
              ),
              border: Border.all(color: const Color(0xCCFFD98A), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Faint repeating diamond pattern, on request ("cotocot
                // noksha" -- small texture), instead of a plain flat fill.
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.08,
                    child: CustomPaint(painter: _DiamondPatternPainter()),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        TextWidget(
                          StringManager.myBadge.tr(),
                          // Bigger font, on request.
                          style: context.bodyLarge.bold.size(17).colorExt(Colors.white),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: openPicker,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextWidget(
                                StringManager.more.tr(),
                                style: context.bodyMedium.colorExt(const Color(0xFFD9C9A8)),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: const Color(0xFFD9C9A8), size: 20.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Was 8.hBox then 2.hBox -- removed entirely, on
                    // request ("gap ta kom hoba" repeated).
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _slotCount,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        // Wider-than-tall cells so the two rows sit closer
                        // together vertically -- was square cells (default
                        // aspect ratio 1), which left visible extra gap.
                        childAspectRatio: 1.1,
                        mainAxisSpacing: 9,
                      ),
                      itemBuilder: (context, i) {
                        final badge = i < earned.length ? earned[i] : null;
                        return GestureDetector(
                          onTap: openPicker,
                          child: _MedalSlot(badge: badge),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Small repeating diamond grid, painted at low opacity for a subtle card
/// texture -- matching the reference card's faint background pattern.
class _DiamondPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 22.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path()
          ..moveTo(x, y - 6)
          ..lineTo(x + 6, y)
          ..lineTo(x, y + 6)
          ..lineTo(x - 6, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DiamondPatternPainter oldDelegate) => false;
}

class _MedalSlot extends StatelessWidget {
  const _MedalSlot({required this.badge});

  final ImageData? badge;

  @override
  Widget build(BuildContext context) {
    final size = 46.h;
    // Was showing ImageViewWidget's own broken-image fallback (a grey
    // square with a person icon) whenever an "earned" badge's image was
    // blank -- looked like two stray holes in the card, on request. Any
    // slot without a real image now falls back to the same gold "?" look
    // as a genuinely unearned slot.
    if (badge == null || badge!.image.isEmpty) {
      return Center(
        child: Container(
          height: size,
          width: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE9A8), Color(0xFFB8862F)],
            ),
            border: Border.all(color: const Color(0xFFFFE9A8), width: 1.5),
          ),
          child: Icon(Icons.question_mark_rounded,
              color: const Color(0xFF5A3B0E), size: 20.h),
        ),
      );
    }
    return Center(
      child: badge!.image.contains('.svga')
          ? CacheSvgaWidget(
              url: badge!.image,
              boxFit: BoxFit.contain,
              height: size,
              width: size,
            )
          : ImageViewWidget(
              url: badge!.image,
              boxFit: BoxFit.contain,
              height: size,
              width: size,
            ),
    );
  }
}
