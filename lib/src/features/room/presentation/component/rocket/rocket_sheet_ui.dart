part of 'rocket_bottom_sheet.dart';

/// New Rocket sheet design: launch-pad scene (SVGA) with the active rocket, a
/// row of five rocket cards, the level bar and a framed Reward panel, all in
/// one scrolling page with a pinned header + countdown.

String _rocketShortNumber(num n) {
  if (n >= 1000000000) return '${_trimNum(n / 1000000000)}B';
  if (n >= 1000000) return '${_trimNum(n / 1000000)}M';
  if (n >= 1000) return '${_trimNum(n / 1000)}K';
  return n.toInt().toString();
}

String _trimNum(double v) {
  final s = v.toStringAsFixed(v >= 100 ? 0 : 1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

// ---------------------------------------------------------------- header
class _RocketHeader extends StatelessWidget {
  final VoidCallback onHelp;
  final VoidCallback onClose;

  const _RocketHeader({required this.onHelp, required this.onClose});

  Widget _round(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3B79F0), Color(0xFF14389A)],
          ),
          border: Border.all(color: const Color(0xFFBBD2FF), width: 1.6),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6)],
        ),
        child: Icon(icon, size: 22.sp, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 0),
      child: SizedBox(
        height: 58.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              AssetsManager.rocketLogo,
              height: 52.h,
              fit: BoxFit.contain,
            ),
            Positioned(
              left: 0,
              child: Row(
                children: [
                  _round(Icons.question_mark_rounded, onHelp),
                  6.wBox,
                  _round(Icons.close_rounded, onClose),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RocketCountdown extends StatefulWidget {
  final int seconds;
  const _RocketCountdown({required this.seconds});

  @override
  State<_RocketCountdown> createState() => _RocketCountdownState();
}

class _RocketCountdownState extends State<_RocketCountdown> {
  Timer? _t;
  late int _left;

  @override
  void initState() {
    super.initState();
    _left = widget.seconds;
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _left > 0) setState(() => _left--);
    });
  }

  @override
  void didUpdateWidget(covariant _RocketCountdown old) {
    super.didUpdateWidget(old);
    if (old.seconds != widget.seconds) _left = widget.seconds;
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  String _p(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final d = _left ~/ 86400;
    final h = (_left % 86400) ~/ 3600;
    final m = (_left % 3600) ~/ 60;
    final s = _left % 60;
    return Container(
      height: 30.h,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x0013307A), Color(0xCC13307A), Color(0x0013307A)],
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'countdown  ${_p(d)} : ${_p(h)} : ${_p(m)} : ${_p(s)}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- scene
/// Launch-pad scene: animated SVGA background, the active rocket in the
/// middle, the five rocket cards stacked on the LEFT and the vertical level
/// gauge on the RIGHT.
class _RocketScene extends StatefulWidget {
  final String rocketImage;
  final List<Map<String, dynamic>> levels;
  final int selectedIndex;
  final String Function(Map<String, dynamic>) imageOf;
  final int Function(Map<String, dynamic>) levelNoOf;
  final ValueChanged<int> onSelect;
  final int level;
  final int nextLevel;
  final double percent;
  final int remainingSeconds;

  const _RocketScene({
    required this.rocketImage,
    required this.levels,
    required this.selectedIndex,
    required this.imageOf,
    required this.levelNoOf,
    required this.onSelect,
    required this.level,
    required this.nextLevel,
    required this.percent,
    required this.remainingSeconds,
  });

  @override
  State<_RocketScene> createState() => _RocketSceneState();
}

class _RocketSceneState extends State<_RocketScene>
    with TickerProviderStateMixin {
  late final SVGAAnimationController _svga;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _svga = SVGAAnimationController(vsync: this);
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _load();
  }

  Future<void> _load() async {
    final movie = await SvgaMovieCache.instance
        .loadFromAsset(AssetsManager.rocketLaunchpadSvga);
    if (!mounted || movie == null) return;
    _svga.videoItem = movie;
    _svga.repeat();
  }

  @override
  void dispose() {
    _svga.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final sceneH = w * 1.0;
    final svgaH = w * 1280 / 720;
    // The launch pad sits at ~66 % of the 720x1280 artwork; keep it near the
    // bottom of the visible window.
    final padY = svgaH * 0.665;
    final top = -(padY - sceneH * 0.80);
    final rocketH = sceneH * 0.46;
    final vPad = 12.h;
    const slots = 5;
    final gap = 8.h;
    final cardW = ((sceneH - vPad * 2 - gap * (slots - 1)) / slots).clamp(40.0, 60.w);
    final items = widget.levels.take(slots).toList();
    final total = cardW * slots + gap * (slots - 1);
    final groupTop = (sceneH - total) / 2;

    return SizedBox(
      width: w,
      height: sceneH,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: 0,
            top: top,
            width: w,
            height: svgaH,
            // Fade the top edge so the room shows through behind the header.
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [Colors.transparent, Colors.white],
                stops: [
                  ((-top) / svgaH).clamp(0.0, 1.0),
                  (((-top) + sceneH * 0.18) / svgaH).clamp(0.0, 1.0),
                ],
              ).createShader(rect),
              child: SVGAImage(_svga, fit: BoxFit.fill),
            ),
          ),
          // Active rocket on the pad.
          Positioned(
            left: 0,
            right: 0,
            bottom: sceneH * 0.20,
            height: rocketH,
            child: AnimatedBuilder(
              animation: _float,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -8.h * Curves.easeInOut.transform(_float.value)),
                child: child,
              ),
              child: widget.rocketImage.isNotEmpty
                  ? ImageViewWidget(
                      url: widget.rocketImage,
                      boxFit: BoxFit.contain,
                    )
                  : Icon(
                      Icons.rocket_launch_rounded,
                      size: rocketH * 0.5,
                      color: const Color(0xFFBFE6FF),
                    ),
            ),
          ),
          // LEFT: the rockets, one under the other in order.
          Positioned(
            left: 3.w,
            top: groupTop,
            height: total,
            width: cardW,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slots; i++) ...[
                  if (i > 0) SizedBox(height: gap),
                  SizedBox(
                    width: cardW,
                    height: cardW,
                    child: i < items.length
                        ? _RocketCard(
                            image: widget.imageOf(items[i]),
                            number: widget.levelNoOf(items[i]) == 0
                                ? i + 1
                                : widget.levelNoOf(items[i]),
                            selected: i == widget.selectedIndex,
                            onTap: () => widget.onSelect(i),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
          // Countdown: level with the first rocket card, between the cards and the gauge.
          Positioned(
            left: cardW + 14.w,
            right: 52.w + 18.w,
            top: groupTop + (cardW - 30.h) / 2,
            height: 30.h,
            child: _RocketCountdown(seconds: widget.remainingSeconds),
          ),
          // RIGHT: tall level gauge.
          // Its bottom lines up with the bottom of the last rocket card.
          Positioned(
            right: 12.w,
            top: groupTop + 6.h,
            height: total - 6.h,
            width: 52.w,
            child: _RocketGauge(
              percent: widget.percent,
              nextLevel: widget.nextLevel,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- rocket card
class _RocketCard extends StatelessWidget {
  final String image;
  final int number;
  final bool selected;
  final VoidCallback onTap;

  const _RocketCard({
    required this.image,
    required this.number,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: selected
                ? const [Color(0xFFFFF0B0), Color(0xFFF2B338), Color(0xFFB87812)]
                : const [Color(0xFF3A6FE6), Color(0xFF1C48B8), Color(0xFF122E86)],
          ),
          border: Border.all(
            color: selected ? const Color(0xFFFFF4CF) : const Color(0xFF6FA0FF),
            width: selected ? 2.2 : 1.4,
          ),
          boxShadow: [
            if (selected)
              const BoxShadow(color: Color(0x99FFC93A), blurRadius: 12, spreadRadius: 1),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(5.w),
                child: image.isNotEmpty
                    ? ImageViewWidget(url: image, boxFit: BoxFit.contain)
                    : Icon(Icons.rocket_launch_rounded,
                        color: Colors.white70, size: 26.sp),
              ),
            ),
            Positioned(
              right: 3.w,
              bottom: 3.w,
              child: Container(
                width: 16.w,
                height: 16.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E2B8A),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: const Color(0xFF8FB4FF), width: 0.8),
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- vertical level gauge
/// Tall glass tube on the right of the scene. The fill is a liquid: two waves
/// roll across its surface and small bubbles rise through it.
class _RocketGauge extends StatefulWidget {
  final double percent;
  final int nextLevel;

  const _RocketGauge({required this.percent, required this.nextLevel});

  @override
  State<_RocketGauge> createState() => _RocketGaugeState();
}

class _RocketGaugeState extends State<_RocketGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.percent.clamp(0.0, 100.0);
    final done = p >= 100;
    final label = done
        ? 'Achieved'
        : '${p.toStringAsFixed(p % 1 == 0 ? 0 : 1)}%';
    // Even at 0 % keep a sliver of liquid so the wave / bubbles are visible.
    final visual = (p / 100).clamp(0.06, 1.0);

    return Column(
      children: [
        Text(
          'lv${widget.nextLevel}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
            shadows: const [Shadow(color: Color(0xAA000000), blurRadius: 4)],
          ),
        ),
        4.hBox,
        Expanded(
          child: Center(
            child: SizedBox(
              width: 38.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // glass tube
                  Positioned.fill(
                    top: 7.h,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19.r),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0x55FFFFFF), Color(0x22FFFFFF), Color(0x44FFFFFF)],
                        ),
                        border: Border.all(color: const Color(0x77FFFFFF), width: 1.4),
                        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 6)],
                      ),
                      padding: EdgeInsets.all(3.5.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: AnimatedBuilder(
                          animation: _anim,
                          builder: (context, _) => CustomPaint(
                            size: Size.infinite,
                            painter: _LiquidPainter(level: visual, t: _anim.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // metal cap
                  Positioned(
                    top: 0,
                    left: 7.w,
                    right: 7.w,
                    height: 12.h,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.r),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB9C2D4), Color(0xFF7C879E), Color(0xFFB9C2D4)],
                        ),
                        border: Border.all(color: const Color(0xFFE4EAF6), width: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        6.hBox,
        // percent bubble
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2F83FF), Color(0xFF1245CC)],
            ),
            border: Border.all(color: const Color(0xFFA8CAFF), width: 1),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// Liquid fill: back + front wave, a soft highlight and rising bubbles.
const List<Color> _bubbleColors = [
  Color(0xFFFFE15A), // yellow
  Color(0xFFFF7BD5), // pink
  Color(0xFF7DFFB0), // green
  Color(0xFFFFFFFF), // white
  Color(0xFFFF9A52), // orange
  Color(0xFFB88CFF), // violet
  Color(0xFF6CF3FF), // cyan
];

class _LiquidPainter extends CustomPainter {
  final double level; // 0..1
  final double t; // 0..1, loops

  const _LiquidPainter({required this.level, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final liquidH = h * level;
    final top = h - liquidH;
    final amp = math.min(3.6, liquidH / 2.5);
    const twoPi = 2 * math.pi;

    Path wave(double phase, double a, double freq) {
      final path = Path()..moveTo(0, h);
      path.lineTo(0, top + a * math.sin(twoPi * (phase)));
      for (double x = 0; x <= w; x += 1.5) {
        final y = top + a * math.sin(twoPi * (x / w * freq + phase));
        path.lineTo(x, y);
      }
      path.lineTo(w, h);
      path.close();
      return path;
    }

    // back wave (lighter, slower, opposite direction)
    canvas.drawPath(
      wave(-t * 0.8 + 0.3, amp * 0.9, 1.3),
      Paint()..color = const Color(0xAA7FDCFF),
    );
    // front wave with the main gradient
    final front = wave(t, amp, 1.0);
    canvas.drawPath(
      front,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8DEBFF), Color(0xFF2E9BFF), Color(0xFF1B56E0)],
        ).createShader(Rect.fromLTWH(0, top - amp, w, liquidH + amp * 2)),
    );
    // glossy highlight down the left side
    canvas.save();
    canvas.clipPath(front);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, top + 6, w * 0.14, math.max(0, liquidH - 12)),
        Radius.circular(w * 0.07),
      ),
      Paint()..color = const Color(0x55FFFFFF),
    );
    // bubbles rising through the liquid
    const bubbles = 12;
    for (var i = 0; i < bubbles; i++) {
      final speed = 0.8 + (i % 4) * 0.25;
      final phase = (t * speed + i / bubbles) % 1.0;
      final x = w * (0.18 + 0.64 * ((i * 0.37) % 1.0)) +
          math.sin(twoPi * (phase * 1.5 + i * 0.13)) * w * 0.06;
      final y = h - phase * liquidH;
      final r = 1.5 + (i % 3) * 0.9;
      final alpha = (math.sin(math.pi * phase)).clamp(0.0, 1.0) * 0.9;
      final c = _bubbleColors[i % _bubbleColors.length];
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = c.withValues(alpha: alpha * 0.55),
      );
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = c.withValues(alpha: alpha),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter old) =>
      old.t != t || old.level != level;
}

// ---------------------------------------------------------------- reward panel
class _RocketRewardPanel extends StatefulWidget {
  final Map<String, dynamic>? level;
  const _RocketRewardPanel({required this.level});

  @override
  State<_RocketRewardPanel> createState() => _RocketRewardPanelState();
}

class _RocketRewardPanelState extends State<_RocketRewardPanel> {
  static const List<(String, List<String>)> _tabs = [
    ('TOP 1', ['top1']),
    ('TOP 2', ['top2']),
    ('TOP 3', ['top3']),
    ('In Room', ['in_room', 'room_owner', 'owner', 'host']),
  ];

  int _tab = 0;
  ui.Image? _frame;

  @override
  void initState() {
    super.initState();
    _loadFrame();
  }

  Future<void> _loadFrame() async {
    final data = await rootBundle.load(AssetsManager.rocketRewardFrame);
    final img = await decodeImageFromList(data.buffer.asUint8List());
    if (mounted) setState(() => _frame = img);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width - 28.w;
    final s = w / 493.0;
    final items = _rocketRewardItems(widget.level, _tabs[_tab].$2);

    return CustomPaint(
      painter: _RewardPanelPainter(_frame),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20 * s, 44 * s, 20 * s, 42 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 14.w),
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _tab = i),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tabs[i].$1,
                              maxLines: 1,
                              style: TextStyle(
                                color: i == _tab ? Colors.white : Colors.white70,
                                fontSize: 15.sp,
                                fontWeight: i == _tab ? FontWeight.w700 : FontWeight.w400,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            4.hBox,
                            Container(
                              width: 22.w,
                              height: 3.h,
                              decoration: BoxDecoration(
                                color: i == _tab ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            22.hBox,
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Center(
                  child: Text(
                    StringManager.noDataYet.tr(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 14 * s),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.78,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => _RocketRewardCard(item: items[i]),
              ),
          ],
        ),
      ),
    );
  }
}

/// Draws the gold-framed "Reward" panel: the title ribbon keeps its aspect
/// ratio, the blue interior stretches to whatever height the content needs.
class _RewardPanelPainter extends CustomPainter {
  final ui.Image? image;
  const _RewardPanelPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final img = image;
    if (img == null) {
      final r = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14));
      canvas.drawRRect(r, Paint()..color = const Color(0xFF0A2A8A));
      return;
    }
    const topH = 112.0, botH = 35.0;
    final iw = img.width.toDouble(), ih = img.height.toDouble();
    final s = size.width / iw;
    final paint = Paint()..filterQuality = FilterQuality.high;
    final topDst = Rect.fromLTWH(0, 0, size.width, topH * s);
    final botDst = Rect.fromLTWH(0, size.height - botH * s, size.width, botH * s);
    final midDst = Rect.fromLTRB(0, topDst.bottom - 0.5, size.width, botDst.top + 0.5);
    canvas.drawImageRect(img, Rect.fromLTWH(0, topH, iw, ih - topH - botH), midDst, paint);
    canvas.drawImageRect(img, Rect.fromLTWH(0, 0, iw, topH), topDst, paint);
    canvas.drawImageRect(img, Rect.fromLTWH(0, ih - botH, iw, botH), botDst, paint);
  }

  @override
  bool shouldRepaint(covariant _RewardPanelPainter old) => old.image != image;
}

/// Reward entries of [level] for one group (top1 / top2 / top3 / in_room ...).
List<Map<String, dynamic>> _rocketRewardItems(
    Map<String, dynamic>? level, List<String> keys) {
  final rewards = level?['rewards'] ??
      level?['reward_setup'] ??
      level?['reward_groups'] ??
      level?['reward'];
  if (rewards is! Map) return [];
  for (final k in keys) {
    final raw = rewards[k] ?? rewards[k.replaceAll('_', '')];
    if (raw is List && raw.isNotEmpty) {
      return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }
  return [];
}

String _rewardImage(Map<String, dynamic> item, {bool log = false}) {
  final ref = item['reference'] is Map ? Map<String, dynamic>.from(item['reference']) : const <String, dynamic>{};
  String pick(dynamic v) {
    final t = v?.toString().trim() ?? '';
    return t.toLowerCase() == 'null' ? '' : t;
  }

  final raw = [
    item['image'],
    item['show_image'],
    ref['show_image'],
    ref['asset'],
    ref['image'],
  ].map(pick).firstWhere((e) => e.isNotEmpty, orElse: () => '');
  if (raw.isEmpty) {
    // Coin rewards carry no picture: use the app's coin icon.
    final type = '${item['reward_type'] ?? item['type'] ?? ''}'.toLowerCase();
    if (log) {
      Methods.printLog('🚀 [Rocket] reward image (${_rewardName(item)}, type=$type): none');
    }
    return type == 'coin' ? AssetsManager.coinsIcon : '';
  }
  return RocketRealtimeController.mediaUrl(raw,
      label: log ? 'reward image (${_rewardName(item)})' : 'reward', log: log);
}

String _rewardName(Map<String, dynamic> item) {
  final ref = item['reference'] is Map ? Map<String, dynamic>.from(item['reference']) : const <String, dynamic>{};
  return (item['name'] ?? item['title'] ?? ref['name'] ?? item['type'] ?? '').toString();
}

String _rewardAmount(Map<String, dynamic> item) {
  final raw = item['amount'] ?? item['quantity'] ?? item['coin'] ?? item['coins'] ?? item['exp'] ?? '';
  final n = num.tryParse('$raw');
  if (n != null && n > 0) return 'x${_rocketShortNumber(n)}';
  return raw.toString();
}

// ---------------------------------------------------------------- reward card
/// Item picture; a failed / empty load shows nothing (just the pedestal)
/// instead of the grey "person" placeholder.
class _RewardImage extends StatefulWidget {
  final String url;
  const _RewardImage({required this.url});

  @override
  State<_RewardImage> createState() => _RewardImageState();
}

class _RewardImageState extends State<_RewardImage> {
  bool _failed = false;

  @override
  void didUpdateWidget(covariant _RewardImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _failed = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty || _failed) {
      return const SizedBox.shrink();
    }
    if (widget.url.startsWith('assets/')) {
      return Image.asset(widget.url, fit: BoxFit.contain);
    }
    return ImageViewWidget(
      url: widget.url,
      boxFit: BoxFit.contain,
      detectError: () {
        if (!mounted || _failed) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _failed = true);
        });
      },
    );
  }
}

class _RocketRewardCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _RocketRewardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final image = _rewardImage(item);
    final name = _rewardName(item);
    final amount = _rewardAmount(item);
    final days = item['days'] ?? item['duration'] ?? item['expire_days'];
    final dayNum = int.tryParse('$days');

    return Container(
      // Soft, see-through card so the panel's blue shows through.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x2E4F86FF), Color(0x14102A86)],
        ),
        border: Border.all(color: const Color(0x334F86FF), width: 1),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      left: 5.w,
                      right: 5.w,
                      bottom: 2.h,
                      height: 34.h,
                      child: const Opacity(
                        opacity: 0.55,
                        child: CustomPaint(painter: _PedestalPainter()),
                      ),
                    ),
                    Positioned(
                      left: 10.w,
                      right: 10.w,
                      top: 12.h,
                      bottom: 14.h,
                      child: _RewardImage(url: image),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 8.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (name.isNotEmpty)
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 10.sp, decoration: TextDecoration.none),
                      ),
                    if (amount.isNotEmpty)
                      Text(
                        amount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (dayNum != null && dayNum > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.r),
                    bottomLeft: Radius.circular(10.r),
                  ),
                  gradient: const LinearGradient(colors: [Color(0xFFFFE08A), Color(0xFFE5A21E)]),
                ),
                child: Text(
                  '${dayNum}d',
                  style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700, decoration: TextDecoration.none),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Blue hexagonal display stand under every reward.
class _PedestalPainter extends CustomPainter {
  const _PedestalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    Path hex(double inset, double top, double bottom) => Path()
      ..moveTo(inset + w * 0.12, top)
      ..lineTo(w - inset - w * 0.12, top)
      ..lineTo(w - inset, (top + bottom) / 2)
      ..lineTo(w - inset - w * 0.12, bottom)
      ..lineTo(inset + w * 0.12, bottom)
      ..lineTo(inset, (top + bottom) / 2)
      ..close();

    final base = hex(0, h * 0.34, h);
    canvas.drawPath(
      base,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B63E6), Color(0xFF0E2C8E)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      base,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF7FB0FF),
    );
    final top = hex(w * 0.10, h * 0.2, h * 0.62);
    canvas.drawPath(
      top,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5E92FF), Color(0xFF2C5BD8)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFBBD6FF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ---------------------------------------------------------------- winners list
/// "Winners": who gets the rewards of the selected level (TOP 1 / 2 / 3 by
/// contribution), with their picture, name, contributed coins and the rewards.
class _RocketWinners extends StatelessWidget {
  final Map<String, dynamic>? level;
  final List<Map<String, dynamic>> ranking;

  const _RocketWinners({required this.level, required this.ranking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 4.h, 0, 10.h),
          child: Text(
            'Winners',
            style: TextStyle(
              color: const Color(0xFFFFE08A),
              fontSize: 22.sp,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
              shadows: const [Shadow(color: Color(0xAA000000), blurRadius: 4)],
            ),
          ),
        ),
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) 10.hBox,
          _WinnerRow(
            rank: i + 1,
            row: i < ranking.length ? ranking[i] : null,
            rewards: _rocketRewardItems(level, ['top${i + 1}']),
          ),
        ],
      ],
    );
  }
}

class _WinnerRow extends StatelessWidget {
  final int rank;
  final Map<String, dynamic>? row;
  final List<Map<String, dynamic>> rewards;

  /// Shown instead of "Waiting" when the row is not a ranked user (e.g. the
  /// "everyone in the room" reward).
  final String? label;

  const _WinnerRow({
    required this.rank,
    required this.row,
    required this.rewards,
    this.label,
  });

  Map<String, dynamic>? get _user {
    final u = row?['user'] ?? row?['sender'] ?? row?['contributor'] ?? row?['member'];
    return u is Map ? Map<String, dynamic>.from(u) : null;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width - 28.w;
    final h = w * 224 / 968;
    final u = _user;
    final name = u == null ? '' : (u['name'] ?? u['username'] ?? '').toString();
    final avatar = u == null
        ? ''
        : RocketRealtimeController.profileUrl(
            u['profile_image'] ?? u['avatar'] ?? u['image'],
            log: false);
    final coins = row == null
        ? ''
        : (row!['contribution_coins'] ?? row!['total_contribution'] ?? row!['total_coins'] ?? row!['coins'] ?? '').toString();
    final waiting = row == null || name.isEmpty;
    final ring = w * 0.118;
    final slot = w * 0.11;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(AssetsManager.rocketRankingCard, fit: BoxFit.fill),
          ),
          // avatar inside the gold ring
          Positioned(
            left: w * (122 / 968) - ring / 2,
            top: h / 2 - ring / 2,
            width: ring,
            height: ring,
            child: ClipOval(
              child: waiting
                  ? const SizedBox.shrink()
                  : UserImage(
                      image: avatar,
                      displayName: name,
                      imageSize: ring,
                      boxFit: BoxFit.cover,
                    ),
            ),
          ),
          // name + contributed coins
          Positioned(
            left: w * 0.215,
            top: 0,
            bottom: 0,
            width: w * 0.27,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  waiting ? (label ?? 'Waiting') : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
                if (!waiting && coins.isNotEmpty) ...[
                  3.hBox,
                  Row(
                    children: [
                      Image.asset(AssetsManager.coinsIcon, width: 14.w, height: 14.w),
                      4.wBox,
                      Flexible(
                        child: Text(
                          coins,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFFFFD34A),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // rewards: first one sits in the card's square, the rest follow to the right
          for (var k = 0; k < math.min(rewards.length, 4); k++)
            Positioned(
              left: w * (536 / 968) - slot / 2 + k * (slot + w * 0.035),
              top: h * (91 / 224) - slot / 2,
              width: slot,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: slot,
                    height: slot,
                    child: Padding(
                      padding: EdgeInsets.all(slot * 0.08),
                      child: _RewardImage(url: _rewardImage(rewards[k])),
                    ),
                  ),
                  SizedBox(
                    width: slot + 24.w,
                    child: Text(
                      _rewardAmount(rewards[k]).isNotEmpty ? _rewardAmount(rewards[k]) : _rewardName(rewards[k]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.sp,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (rewards.isEmpty)
            Positioned(
              left: w * (536 / 968) - slot / 2,
              top: h * (91 / 224) + slot / 2 + 2,
              width: slot,
              child: Text(
                'Waiting',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(color: Colors.white54, fontSize: 11.sp, decoration: TextDecoration.none),
              ),
            ),
        ],
      ),
    );
  }
}


// ---------------------------------------------------------------- reward dialog
/// Shown right after the launch animation: the winners (TOP 1 / 2 / 3) and the
/// room members' reward, on the same card as the sheet's Winners list. Closes
/// itself after a few seconds or on tap.
class RocketRewardDialog extends StatelessWidget {
  const RocketRewardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: RocketRealtimeController.instance.rewardEvent,
      builder: (context, data, _) {
        if (data == null) return const SizedBox.shrink();
        return Positioned.fill(
          child: _RocketRewardDialogBody(
            key: ValueKey('${data['event_id'] ?? data['launch_id']}'),
            data: data,
          ),
        );
      },
    );
  }
}

class _RocketRewardDialogBody extends StatefulWidget {
  final Map<String, dynamic> data;
  const _RocketRewardDialogBody({super.key, required this.data});

  @override
  State<_RocketRewardDialogBody> createState() => _RocketRewardDialogBodyState();
}

class _RocketRewardDialogBodyState extends State<_RocketRewardDialogBody>
    with SingleTickerProviderStateMixin {
  static const _visible = Duration(seconds: 8);

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_visible, _close);
    // Print every reward picture URL (raw -> fixed) for debugging.
    final lv = widget.data['level'];
    if (lv is Map) {
      final level = Map<String, dynamic>.from(lv);
      for (final g in ['top1', 'top2', 'top3', 'in_room']) {
        for (final item in _rocketRewardItems(level, [g])) {
          _rewardImage(item, log: true);
        }
      }
    }
  }

  void _close() {
    _timer?.cancel();
    if (!mounted) return;
    _anim.reverse().whenComplete(
        () => RocketRealtimeController.instance.dismissReward());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winnersRaw = widget.data['winners'];
    final winners = winnersRaw is List
        ? winnersRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];
    final levelRaw = widget.data['level'];
    final level = levelRaw is Map ? Map<String, dynamic>.from(levelRaw) : null;

    Map<String, dynamic>? byGroup(String g) {
      for (final w in winners) {
        if ('${w['winner_group']}'.toLowerCase() == g) return w;
      }
      return null;
    }

    final inRoom = _rocketRewardItems(level, ['in_room', 'inRoom', 'room']);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _close,
      child: FadeTransition(
        opacity: _anim,
        child: Container(
          color: Colors.black.withValues(alpha: 0.6),
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 0, 10.h),
                  child: Text(
                    'Rocket Rewards',
                    style: TextStyle(
                      color: const Color(0xFFFFE08A),
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                      shadows: const [Shadow(color: Color(0xAA000000), blurRadius: 4)],
                    ),
                  ),
                ),
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) 10.hBox,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: _WinnerRow(
                      rank: i + 1,
                      row: byGroup('top${i + 1}') ?? (i < winners.length ? winners[i] : null),
                      rewards: _rocketRewardItems(level, ['top${i + 1}']),
                    ),
                  ),
                ],
                if (inRoom.isNotEmpty) ...[
                  10.hBox,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: _WinnerRow(
                      rank: 4,
                      row: null,
                      rewards: inRoom,
                      label: 'Everyone in the room',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
