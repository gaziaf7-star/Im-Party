part of '../level_page.dart';

/// "Gallery" look for My Level, modelled on the starry gift-gallery screen:
/// night-sky header with the user's avatar, name, a glowing horizon arc and
/// the level, then a dark panel with All / Lit / Unlit filters and a grid of
/// bevelled silver cards (one per badge tier, lit once the user reaches it).
class _LevelGalleryColors {
  static const Color skyTop = Color(0xFF0A1236);
  static const Color skyBottom = Color(0xFF05060D);
  static const Color gold = Color(0xFFF5D58A);
  static const Color goldDeep = Color(0xFFE2B55C);
  static const Color idle = Color(0xFF8C8FA0);
  static const Color panelTop = Color(0xFF1E2130);
  static const Color panelBottom = Color(0xFF0E0F16);
}

/// The numbers the header shows for one level type.
class _LevelNumbers {
  const _LevelNumbers({
    required this.level,
    required this.next,
    required this.percent,
    required this.exp,
    required this.remaining,
  });

  final int level;
  final String next;
  final double percent;
  final String exp;
  final String remaining;

  /// [type] is 'sender' (Wealth), 'reciever' (Charm) or 'charge'.
  factory _LevelNumbers.of(String type, AllLevelsState s) {
    final l = s.userLevels?.level;
    final c = s.userLevels?.chargeLevel;
    int asInt(Object? v) => int.tryParse('${v ?? ''}') ?? 0;
    switch (type) {
      case 'reciever':
        return _LevelNumbers(
          level: asInt(l?.reciverLevel),
          next: '${l?.nextReciverLevel ?? ''}',
          percent: ((l?.reciverPer?.toDouble() ?? 0) / 100).clamp(0.0, 1.0),
          exp: '${l?.reciverNum ?? 0}',
          remaining: '${l?.remReceiverLevel ?? 0}',
        );
      case 'charge':
        return _LevelNumbers(
          level: asInt(c?.currentLevel),
          next: '${c?.nextLevel ?? ''}',
          percent: (c?.progress?.toDouble() ?? 0).clamp(0.0, 1.0),
          exp: '${c?.currentExp ?? 0}',
          remaining: '${c?.remaining ?? 0}',
        );
      default:
        return _LevelNumbers(
          level: asInt(l?.senderLevel),
          next: '${l?.nextSenderLevel ?? ''}',
          percent: ((l?.senderPer?.toDouble() ?? 0) / 100).clamp(0.0, 1.0),
          exp: '${l?.senderNum ?? 0}',
          remaining: '${l?.remSenderLevel ?? 0}',
        );
    }
  }
}

/// Starry night backdrop for the whole page.
class _StarrySky extends StatelessWidget {
  const _StarrySky();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _LevelGalleryColors.skyTop,
            Color(0xFF0B0F24),
            _LevelGalleryColors.skyBottom,
          ],
          stops: [0, .35, .7],
        ),
      ),
      child: CustomPaint(painter: _StarsPainter(), size: Size.infinite),
    );
  }
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Fixed seed: the same sky every frame (no flicker on rebuild).
    final rnd = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < 140; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * .45;
      final r = rnd.nextDouble() * 1.1 + .2;
      paint.color = Colors.white.withValues(alpha: rnd.nextDouble() * .6 + .15);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wealth / Charm / Charge at the top: the selected one is bold white on a
/// soft glow, the others grey.
class _LevelTypeTabs extends StatelessWidget {
  const _LevelTypeTabs({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final labels = [
      StringManager.wealth.tr(),
      StringManager.charm.tr(),
      StringManager.charge.tr(),
    ];
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => controller.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: controller.index == i
                      ? LinearGradient(colors: [
                          Colors.white.withValues(alpha: .16),
                          Colors.white.withValues(alpha: .04),
                        ])
                      : null,
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    color: controller.index == i
                        ? Colors.white
                        : _LevelGalleryColors.idle,
                    fontSize: controller.index == i ? 16.sp : 14.sp,
                    fontWeight:
                        controller.index == i ? FontWeight.w700 : FontWeight.w500,
                  ),
                  child: Text(labels[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Avatar, name, glowing horizon arc, level and progress.
class _LevelHero extends StatelessWidget {
  const _LevelHero({required this.numbers, required this.label});
  final _LevelNumbers numbers;
  final String label;

  @override
  Widget build(BuildContext context) {
    final me = MyDataModel.getInstance();
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: .25),
                blurRadius: 18,
              ),
            ],
          ),
          child: UserImage(
            image: me.profile?.image ?? '',
            displayName: me.name ?? '',
            borderRadius: 200.radius,
            imageSize: 76.w,
          ),
        ),
        10.hBox,
        Text(
          me.name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 34.h,
          width: double.infinity,
          child: CustomPaint(painter: _HorizonPainter()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: _LevelGalleryColors.gold, size: 14.sp),
            8.wBox,
            Text(
              '$label  Lv ${numbers.level}',
              style: TextStyle(
                color: _LevelGalleryColors.gold,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            8.wBox,
            Icon(Icons.auto_awesome, color: _LevelGalleryColors.gold, size: 14.sp),
          ],
        ),
        10.hBox,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: numbers.percent),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Stack(
                    children: [
                      Container(
                        height: 6.h,
                        color: Colors.white.withValues(alpha: .12),
                      ),
                      FractionallySizedBox(
                        widthFactor: v,
                        child: Container(
                          height: 6.h,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              _LevelGalleryColors.goldDeep,
                              _LevelGalleryColors.gold,
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              6.hBox,
              Row(
                children: [
                  Text(
                    '${StringManager.currentExperienceLevel.tr()}: ${numbers.exp}',
                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                  ),
                  const Spacer(),
                  Text(
                    numbers.next.isEmpty
                        ? ''
                        : '${StringManager.nextlevel.tr()}: ${numbers.remaining}',
                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Thin golden arc across the screen with a bright flare in the middle.
class _HorizonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, h * .25)
      ..quadraticBezierTo(w / 2, h * 1.05, w, h * .25);
    final shader = const LinearGradient(colors: [
      Color(0x00F5D58A),
      Color(0xFFF5D58A),
      Color(0xFFFFFFFF),
      Color(0xFFF5D58A),
      Color(0x00F5D58A),
    ], stops: [0, .3, .5, .7, 1]).createShader(Offset.zero & size);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = shader,
    );
    // Flare where the arc dips lowest.
    final c = Offset(w / 2, h * .64);
    canvas.drawCircle(
      c,
      14,
      Paint()
        ..color = const Color(0xFF9FD3FF).withValues(alpha: .55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(c, 2.4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dark rounded panel with a light glow along its top edge, the All / Lit /
/// Unlit filter, the badge grid and the level description.
class _LevelPanel extends StatefulWidget {
  const _LevelPanel({
    required this.badges,
    required this.level,
    required this.title,
    required this.body,
  });

  final List<LevelBadgesEntity> badges;
  final int level;
  final String title;
  final String body;

  @override
  State<_LevelPanel> createState() => _LevelPanelState();
}

class _LevelPanelState extends State<_LevelPanel> {
  int _filter = 0; // 0 all, 1 lit, 2 unlit

  bool _lit(LevelBadgesEntity b) => widget.level >= (b.minlevel ?? 0);

  @override
  Widget build(BuildContext context) {
    final shown = widget.badges.where((b) {
      if (_filter == 1) return _lit(b);
      if (_filter == 2) return !_lit(b);
      return true;
    }).toList();
    final litCount = widget.badges.where(_lit).length;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _LevelGalleryColors.panelTop,
            _LevelGalleryColors.panelBottom,
          ],
        ),
        border: const Border(
          top: BorderSide(color: Color(0xFF6C6F80), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: .10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          14.hBox,
          Text(
            '✦  Lit $litCount/${widget.badges.length}  ✦',
            style: TextStyle(
              color: _LevelGalleryColors.gold,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          10.hBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final (i, label) in const [(0, 'All'), (1, 'Lit'), (2, 'Unlit')])
                GestureDetector(
                  onTap: () => setState(() => _filter = i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: _filter == i
                                ? _LevelGalleryColors.gold
                                : _LevelGalleryColors.idle,
                            fontSize: 16.sp,
                            fontWeight:
                                _filter == i ? FontWeight.w600 : FontWeight.w400,
                          ),
                          child: Text(label),
                        ),
                        4.hBox,
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _filter == i ? 16.w : 0,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: _LevelGalleryColors.gold,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          12.hBox,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            itemCount: shown.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: .86,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
            ),
            itemBuilder: (context, i) {
              final b = shown[i];
              return _BadgeTierCard(badge: b, lit: _lit(b))
                  .animate(
                      key: ValueKey('tier_${_filter}_$i'),
                      delay: Duration(milliseconds: 40 * i.clamp(0, 12)))
                  .fadeIn(duration: const Duration(milliseconds: 280))
                  .slideY(begin: .08, end: 0, curve: Curves.easeOutCubic);
            },
          ),
          if (shown.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.h),
              child: Text(
                StringManager.noLevels.tr(),
                style: TextStyle(color: Colors.white54, fontSize: 13.sp),
              ),
            ),
          20.hBox,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                8.hBox,
                Text(
                  widget.body,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13.sp,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24.h),
        ],
      ),
    );
  }
}

/// One badge tier as a bevelled silver card: lit (full colour, gold edge)
/// once the user's level reaches it, otherwise grey.
class _BadgeTierCard extends StatelessWidget {
  const _BadgeTierCard({required this.badge, required this.lit});
  final LevelBadgesEntity badge;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final range = badge.minlevel == badge.maxlevel
        ? 'Lv ${badge.minlevel ?? 0}'
        : 'Lv ${badge.minlevel ?? 0}-${badge.maxlevel ?? 0}';
    final image = ImageViewWidget(
      url: badge.badge ?? '',
      width: 84.w,
      height: 46.h,
      boxFit: BoxFit.contain,
    );
    return CustomPaint(
      painter: _BevelCardPainter(lit: lit),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 14.h, 8.w, 10.h),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: lit
                    ? image
                    : ColorFiltered(
                        // Greyscale for tiers not reached yet.
                        colorFilter: const ColorFilter.matrix([
                          .33, .59, .11, 0, 0, //
                          .33, .59, .11, 0, 0, //
                          .33, .59, .11, 0, 0, //
                          0, 0, 0, .85, 0,
                        ]),
                        child: image,
                      ),
              ),
            ),
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  (lit ? _LevelGalleryColors.gold : Colors.white)
                      .withValues(alpha: .35),
                  Colors.transparent,
                ]),
              ),
            ),
            6.hBox,
            Text(
              range,
              style: TextStyle(
                color: lit ? _LevelGalleryColors.gold : const Color(0xFFB4B6C0),
                fontSize: 13.sp,
                fontWeight: lit ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card body: chamfered corners, metallic gradient, light from the top,
/// a double hairline edge and small diamonds top/bottom centre.
class _BevelCardPainter extends CustomPainter {
  _BevelCardPainter({required this.lit});
  final bool lit;

  Path _shape(Rect r, double cut) => Path()
    ..moveTo(r.left + cut, r.top)
    ..lineTo(r.right - cut, r.top)
    ..lineTo(r.right, r.top + cut)
    ..lineTo(r.right, r.bottom - cut)
    ..lineTo(r.right - cut, r.bottom)
    ..lineTo(r.left + cut, r.bottom)
    ..lineTo(r.left, r.bottom - cut)
    ..lineTo(r.left, r.top + cut)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final outer = _shape(rect.deflate(1), 10);

    // Metallic body, brighter at the top.
    canvas.drawPath(
      outer,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: lit
              ? const [Color(0xFF5A4A2E), Color(0xFF2A2318), Color(0xFF15120D)]
              : const [Color(0xFF55575F), Color(0xFF26272D), Color(0xFF141519)],
          stops: const [0, .5, 1],
        ).createShader(rect),
    );
    // Top lighting.
    canvas.save();
    canvas.clipPath(outer);
    canvas.drawCircle(
      Offset(size.width / 2, 0),
      size.width * .7,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: lit ? .22 : .18),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
            center: Offset(size.width / 2, 0), radius: size.width * .7)),
    );
    canvas.restore();

    // Double edge.
    final edge = lit
        ? const [Color(0xFFF7E3A8), Color(0xFFB08A45)]
        : const [Color(0xFFD7D9E0), Color(0xFF6E7079)];
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: edge,
      ).createShader(rect);
    canvas.drawPath(outer, stroke);
    canvas.drawPath(
      _shape(rect.deflate(5), 8),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..color = edge.first.withValues(alpha: .35),
    );

    // Diamonds on the top and bottom edges.
    void diamond(double y) {
      const d = 4.5;
      final x = size.width / 2;
      final p = Path()
        ..moveTo(x, y - d)
        ..lineTo(x + d, y)
        ..lineTo(x, y + d)
        ..lineTo(x - d, y)
        ..close();
      canvas.drawPath(p, Paint()..color = const Color(0xFF15161B));
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = edge.first,
      );
    }

    diamond(1);
    diamond(size.height - 1);
  }

  @override
  bool shouldRepaint(covariant _BevelCardPainter oldDelegate) =>
      oldDelegate.lit != lit;
}
