part of '../vip_screen.dart';

/// Colour accent of each SVIP tier (SVIP1, SVIP2, ...), cycled.
const List<List<Color>> _tierColors = [
  [Color(0xFFE6E9EF), Color(0xFF9AA3B2)], // 1 silver
  [Color(0xFFF1C9A4), Color(0xFFB8774A)], // 2 bronze
  [Color(0xFFFFE7A3), Color(0xFFD9A43A)], // 3 gold
  [Color(0xFFB8F5D4), Color(0xFF2FA872)], // 4 emerald
  [Color(0xFFBFD7FF), Color(0xFF3F6FD8)], // 5 sapphire
  [Color(0xFFE2C6FF), Color(0xFF8A4FD8)], // 6 amethyst
  [Color(0xFFFFC2CC), Color(0xFFD23A57)], // 7 ruby
  [Color(0xFFFFE48A), Color(0xFF7B2CFF)], // 8 imperial gold-violet
];

List<Color> _tierColor(int level) =>
    _tierColors[((level <= 0 ? 1 : level) - 1) % _tierColors.length];

/// SVIP centre: one page per SVIP level, swiped left/right. Each page has
/// the user's profile on the left, the level badge on a stone pedestal on
/// the right, the level progress, the level's privileges, and a top-up bar.
/// The "my SVIP" bag opens from the list icon at the top right.
class VipBody extends StatefulWidget {
  const VipBody({super.key, this.index, required this.length});

  final int? index;
  final int length;

  @override
  State<VipBody> createState() => _VipBodyState();
}

class _VipBodyState extends State<VipBody> {
  late final PageController _pager;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // Open on the requested level (1-based), else the user's own level.
    final myLevel = MyDataModel.getInstance().vip1?.level ?? 0;
    final start = ((widget.index ?? myLevel) - 1).clamp(0, widget.length - 1);
    _page = start < 0 ? 0 : start;
    _pager = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _openBag() => _showMyVipBag(context);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VipCenterBloc, VipStates>(
      bloc: di<VipCenterBloc>(),
      buildWhen: (prev, curr) => prev.vip != curr.vip,
      builder: (context, state) {
        final levels = state.vip;
        if (levels.isEmpty) return const SizedBox.shrink();
        final current = levels[_page.clamp(0, levels.length - 1)];
        return Scaffold(
          backgroundColor: const Color(0xFF0E0D10),
          body: Stack(
            children: [
              PageView.builder(
                controller: _pager,
                physics: const BouncingScrollPhysics(),
                itemCount: levels.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _SvipLevelPage(
                  entity: levels[i],
                  next: i + 1 < levels.length ? levels[i + 1] : null,
                  previous: i > 0 ? levels[i - 1] : null,
                ),
              ),
              // Fixed header over the pages.
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 52.h,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        'SVIP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _openBag,
                        icon: Icon(Icons.receipt_long_rounded,
                            color: Colors.white, size: 24.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: VipBottomBar(
            color: _tierColor(current.level ?? 1).last,
            vipBadge: current.img1 ?? '',
            expire: current.expire.toString(),
            id: current.id.toString(),
            price: current.price.toString(),
            name: current.name.toString(),
          ),
        );
      },
    );
  }
}

/// One SVIP level page.
class _SvipLevelPage extends StatelessWidget {
  const _SvipLevelPage({
    required this.entity,
    required this.next,
    required this.previous,
  });

  final VipCenterEntity entity;
  final VipCenterEntity? next;
  final VipCenterEntity? previous;

  @override
  Widget build(BuildContext context) {
    final level = entity.level ?? 1;
    final tier = _tierColor(level);
    final size = MediaQuery.sizeOf(context);
    final top = MediaQuery.paddingOf(context).top;
    final headerH = size.width * 1.12;
    return Stack(
      children: [
        // Painted backdrop (no image): dark hall, top light, corner beams,
        // faint pillars and hexagons, tinted with the tier colour.
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _SvipBackdropPainter(
                  tier: tier, headerH: headerH, level: level),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            children: [
              SizedBox(
                height: headerH,
                child: Stack(
                  children: [
                    // Profile, left.
                    Positioned(
                      left: 18.w,
                      top: top + 64.h,
                      width: size.width * 0.45,
                      child: _ProfileStatus(level: level, tier: tier),
                    ),
                    // Pedestal + badge, right.
                    Positioned(
                      right: size.width * 0.04,
                      top: top + 40.h,
                      width: size.width * 0.5,
                      child: _BadgeOnPedestal(entity: entity, tier: tier),
                    ),
                    // Level name + progress.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _LevelProgress(
                        entity: entity,
                        next: next,
                        previous: previous,
                        tier: tier,
                      ),
                    ),
                  ],
                ),
              ),
              22.hBox,
              _Privileges(entity: entity, tier: tier),
            ],
          ),
        ),
      ],
    );
  }
}

/// "SVIP  1" -> "SVIP1".
String _levelName(VipCenterEntity e) {
  final n = (e.name ?? '').replaceAll(RegExp(r'\s+'), '');
  return n.isNotEmpty ? n : 'SVIP${e.level ?? 1}';
}

bool _isSvga(String path) {
  final p = path.toLowerCase();
  return p.endsWith('.svga') || p.endsWith('.zz') || p.endsWith('.zzz');
}

/// Plays an animated (svga) item full size; tap anywhere to close.
void _playAnimated(BuildContext context, String path, String title) {
  final url = EndPoints.getImage(path);
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (_) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300.w,
                height: 300.w,
                child: _isSvga(path)
                    ? CacheSvgaWidget(url: url, boxFit: BoxFit.contain)
                    : ImageViewWidget(url: url, boxFit: BoxFit.contain),
              ),
              12.hBox,
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Avatar, name and SVIP status.
class _ProfileStatus extends StatelessWidget {
  const _ProfileStatus({required this.level, required this.tier});

  final int level;
  final List<Color> tier;

  @override
  Widget build(BuildContext context) {
    final me = MyDataModel.getInstance();
    final myLevel = me.vip1?.level ?? 0;
    final active = myLevel > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: tier),
          ),
          child: UserImage(
            image: me.profile?.image ?? '',
            displayName: me.name ?? '',
            imageSize: 64.w,
          ),
        ),
        10.hBox,
        Text(
          me.name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        4.hBox,
        if (active)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              gradient: LinearGradient(colors: _tierColor(myLevel)),
            ),
            child: Text(
              'SVIP$myLevel  Active',
              style: TextStyle(
                color: const Color(0xFF2A1A0A),
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          Text(
            'You are not an SVIP yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13.sp,
            ),
          ),
      ],
    );
  }
}

/// The level badge floating gently above a marble pedestal ("khuti").
/// Shows the still badge picture; tapping it plays the animated badge.
class _BadgeOnPedestal extends StatefulWidget {
  const _BadgeOnPedestal({required this.entity, required this.tier});

  final VipCenterEntity entity;
  final List<Color> tier;

  @override
  State<_BadgeOnPedestal> createState() => _BadgeOnPedestalState();
}

class _BadgeOnPedestalState extends State<_BadgeOnPedestal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Widget _still(double w, double h) {
    final e = widget.entity;
    final still = e.oldImage ?? '';
    if (still.isNotEmpty) {
      return ImageViewWidget(
        url: EndPoints.getImage(still),
        width: w,
        height: h,
        boxFit: BoxFit.contain,
      );
    }
    // No still picture uploaded: first frame of the animation.
    return CacheSvgaWidget(
      url: EndPoints.getImage(e.img1 ?? ''),
      width: w,
      height: h,
      boxFit: BoxFit.contain,
      autoPlay: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = widget.tier;
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return SizedBox(
        height: w * 1.2,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Pedestal, fading into the dark at the bottom.
            Positioned(
              top: w * 0.6,
              width: w * 0.62,
              height: w * 0.62,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white, Colors.transparent],
                  stops: [0, 0.45, 1],
                ).createShader(r),
                child: CustomPaint(painter: _PedestalPainter(tier: tier)),
              ),
            ),
            // Soft tier-coloured glow behind the badge.
            Positioned(
              top: w * 0.02,
              child: IgnorePointer(
                child: Container(
                  width: w * 0.85,
                  height: w * 0.72,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(colors: [
                      tier.first.withValues(alpha: 0.32),
                      tier.first.withValues(alpha: 0),
                    ]),
                  ),
                ),
              ),
            ),
            // Badge: still picture, floating; tap to animate.
            Positioned(
              top: w * 0.04,
              child: AnimatedBuilder(
                animation: _float,
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                      0, -5 * Curves.easeInOut.transform(_float.value)),
                  child: child,
                ),
                child: GestureDetector(
                  onTap: () => _playAnimated(
                    context,
                    widget.entity.img1 ?? '',
                    _levelName(widget.entity),
                  ),
                  child: RepaintBoundary(child: _still(w * 0.74, w * 0.66)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Big level name, the curved level track, and the top-up requirement.
class _LevelProgress extends StatelessWidget {
  const _LevelProgress({
    required this.entity,
    required this.next,
    required this.previous,
    required this.tier,
  });

  final VipCenterEntity entity;
  final VipCenterEntity? next;
  final VipCenterEntity? previous;
  final List<Color> tier;

  @override
  Widget build(BuildContext context) {
    final myLevel = MyDataModel.getInstance().vip1?.level ?? 0;
    final level = entity.level ?? 1;
    final unlocked = myLevel >= level || entity.isBuy == true;
    final label = TextStyle(
      color: Colors.white.withValues(alpha: 0.65),
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
    );
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (r) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, tier.first, tier.last],
          ).createShader(r),
          child: Text(
            _levelName(entity),
            style: TextStyle(
              color: Colors.white,
              fontSize: 40.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
              letterSpacing: 1,
              shadows: const [
                Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
          ),
        ),
        4.hBox,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SizedBox(
            height: 54.h,
            child: CustomPaint(
              painter: _TrackPainter(tier: tier),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Text(previous == null ? '0' : _levelName(previous!),
                        style: label),
                    const Spacer(),
                    if (next != null) ...[
                      Text(_levelName(next!), style: label),
                      4.wBox,
                      Icon(Icons.info_outline_rounded,
                          size: 14.sp,
                          color: Colors.white.withValues(alpha: 0.55)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        10.hBox,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6.w,
            runSpacing: 4.h,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: unlocked
                      ? tier.last.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  unlocked ? 'Unlocked' : 'Locked',
                  style: TextStyle(color: Colors.white, fontSize: 11.sp),
                ),
              ),
              Text(
                'Top up',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13.sp),
              ),
              ImageWidget(
                  image: AssetsManager.coinsVip, height: 14.h, width: 14.w),
              Text(
                '${entity.price ?? 0} within ${entity.expire ?? 0} days to upgrade',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "SVIPn Exclusive Privileges" and a two-column grid of ONLY this level's
/// own rewards (the API marks them `active`; other levels' are hidden).
class _Privileges extends StatelessWidget {
  const _Privileges({required this.entity, required this.tier});

  final VipCenterEntity entity;
  final List<Color> tier;

  @override
  Widget build(BuildContext context) {
    final items = (entity.privilgesData ?? const <PrivilegsEntity>[])
        .where((p) => p.active)
        .toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '${_levelName(entity)} ',
                      style: TextStyle(
                        color: tier.first,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(
                      text: 'Exclusive Privileges',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ]),
                  style: TextStyle(fontSize: 18.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${items.length}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          14.hBox,
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, i) =>
                _PrivilegeCard(item: items[i], tier: tier),
          ),
        ],
      ),
    );
  }
}

/// One reward: still picture, name and kind. Tap plays it animated.
class _PrivilegeCard extends StatelessWidget {
  const _PrivilegeCard({required this.item, required this.tier});

  final PrivilegsEntity item;
  final List<Color> tier;

  /// The still picture: whichever of img2 / img1 is not an animation.
  String? get _still {
    for (final p in [item.img2, item.img1]) {
      if (p.isNotEmpty && !_isSvga(p)) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final still = _still;
    final kind = item.privileg?.name ?? '';
    return GestureDetector(
      onTap: () => _playAnimated(context, item.img1, item.name),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF26282F), Color(0xFF131418)],
          ),
          border: Border.all(
            color: tier.first.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Light line along the top edge.
            Positioned(
              top: 0,
              left: 24.w,
              right: 24.w,
              height: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    tier.first.withValues(alpha: 0),
                    tier.first.withValues(alpha: 0.9),
                    tier.first.withValues(alpha: 0),
                  ]),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 62.h,
                      width: 90.w,
                      child: still != null
                          ? ImageViewWidget(
                              url: EndPoints.getImage(still),
                              height: 62.h,
                              width: 90.w,
                              boxFit: BoxFit.contain,
                            )
                          : CacheSvgaWidget(
                              url: EndPoints.getImage(item.img1),
                              height: 62.h,
                              width: 90.w,
                              boxFit: BoxFit.contain,
                              autoPlay: false,
                            ),
                    ),
                    10.hBox,
                    Text(
                      item.name,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (kind.isNotEmpty && kind != 'Unknown Type') ...[
                      3.hBox,
                      Text(
                        kind,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The whole page background, painted (no image): a dark hall lit from the
/// top, beams from both top corners, faint gothic pillars, hexagons and the
/// tier colour. It gets richer with each level: SVIP1 is a calm silver
/// glow, SVIP8 has a wide fan of coloured rays, an aurora band, many
/// sparkles and a halo behind the badge.
class _SvipBackdropPainter extends CustomPainter {
  _SvipBackdropPainter({
    required this.tier,
    required this.headerH,
    required this.level,
  });

  final List<Color> tier;
  final double headerH;
  final int level;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    final split = (headerH / h).clamp(0.3, 0.8);
    // 0 for SVIP1 .. 1 for SVIP8.
    final t = ((level - 1) / 7).clamp(0.0, 1.0);
    final light = Color.lerp(Colors.white, tier.first, 0.35 + 0.3 * t)!;

    // Base: tinted stone at the top, near-black where the rewards sit.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF4E4F56), tier.last, 0.12 + 0.30 * t)!,
            Color.lerp(const Color(0xFF26262B), tier.last, 0.08 + 0.20 * t)!,
            Color.lerp(const Color(0xFF111114), tier.last, 0.04 * t)!,
            const Color(0xFF0C0C0E),
          ],
          stops: [0, split * 0.7, split, 1],
        ).createShader(rect),
    );

    // Aurora band along the top (SVIP5+).
    if (level >= 5) {
      final band = Rect.fromLTWH(0, 0, w, headerH * 0.3);
      canvas.drawRect(
        band,
        Paint()
          ..shader = LinearGradient(colors: [
            tier.last.withValues(alpha: 0.10 + 0.18 * t),
            tier.first.withValues(alpha: 0.18 + 0.20 * t),
            tier.last.withValues(alpha: 0.10 + 0.18 * t),
          ]).createShader(band)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
      );
    }

    // Faint pillars with pointed arches, left and right.
    final pillar = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          light.withValues(alpha: 0.07),
          light.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, headerH));
    for (final x in [w * 0.02, w * 0.14, w * 0.80, w * 0.92]) {
      final pw = w * 0.06;
      final path = Path()
        ..moveTo(x, headerH * 0.7)
        ..lineTo(x, headerH * 0.12)
        ..quadraticBezierTo(x, headerH * 0.04, x + pw / 2, 0)
        ..quadraticBezierTo(x + pw, headerH * 0.04, x + pw, headerH * 0.12)
        ..lineTo(x + pw, headerH * 0.7)
        ..close();
      canvas.drawPath(path, pillar);
    }

    // Hexagon lattice, top right, fading out.
    final hexR = w * 0.035;
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 6; col++) {
        final cx = w * 0.62 + col * hexR * 1.75 + (row.isOdd ? hexR * 0.87 : 0);
        final cy = row * hexR * 1.5;
        final fade = (1 - row / 5) * (col / 6 + 0.2);
        final hex = Path();
        for (int k = 0; k < 6; k++) {
          final a = (math.pi / 3) * k + math.pi / 6;
          final p = Offset(cx + hexR * math.cos(a), cy + hexR * math.sin(a));
          k == 0 ? hex.moveTo(p.dx, p.dy) : hex.lineTo(p.dx, p.dy);
        }
        hex.close();
        canvas.drawPath(
          hex,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = light.withValues(alpha: (0.10 + 0.06 * t) * fade),
        );
      }
    }

    // Fan of light rays from the top centre: more and wider each level.
    final origin = Offset(w * 0.55, -headerH * 0.05);
    final rays = 3 + level;
    final spread = 0.45 + 0.35 * t;
    final rayLen = headerH * (0.85 + 0.3 * t);
    for (int i = 0; i < rays; i++) {
      final a = math.pi / 2 - spread + (2 * spread) * (i + 0.5) / rays;
      final half = 0.025 + 0.01 * t;
      final p1 = origin +
          Offset(math.cos(a - half), math.sin(a - half)) * rayLen;
      final p2 = origin +
          Offset(math.cos(a + half), math.sin(a + half)) * rayLen;
      canvas.drawPath(
        Path()
          ..moveTo(origin.dx, origin.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close(),
        Paint()
          ..shader = RadialGradient(
            center: Alignment(
                (origin.dx / w) * 2 - 1, (origin.dy / headerH) * 2 - 1),
            radius: 1.0,
            colors: [
              light.withValues(alpha: 0.10 + 0.08 * t),
              light.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, w, headerH)),
      );
    }

    // Main light pouring in from the top.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.1, -1.05),
          radius: 0.9 + 0.3 * t,
          colors: [
            Colors.white.withValues(alpha: 0.34 + 0.10 * t),
            light.withValues(alpha: 0.12 + 0.12 * t),
            light.withValues(alpha: 0),
          ],
          stops: const [0, 0.4, 1],
        ).createShader(Rect.fromLTWH(0, 0, w, headerH)),
    );

    // Beams from both top corners.
    for (final fromLeft in [true, false]) {
      final beam = Path()
        ..moveTo(fromLeft ? 0 : w, 0)
        ..lineTo(fromLeft ? w * 0.42 : w * 0.58, 0)
        ..lineTo(fromLeft ? w * 0.70 : w * 0.30, headerH * 0.75)
        ..lineTo(fromLeft ? w * 0.18 : w * 0.82, headerH * 0.75)
        ..close();
      canvas.drawPath(
        beam,
        Paint()
          ..shader = LinearGradient(
            begin: fromLeft ? Alignment.topLeft : Alignment.topRight,
            end: Alignment.bottomCenter,
            colors: [
              light.withValues(alpha: 0.14 + 0.10 * t),
              light.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, w, headerH * 0.75)),
      );
    }

    // Tier-coloured glow around the badge, stronger each level.
    final badge = Offset(w * 0.72, headerH * 0.3);
    final glowR = w * (0.40 + 0.12 * t);
    canvas.drawCircle(
      badge,
      glowR,
      Paint()
        ..shader = RadialGradient(colors: [
          tier.first.withValues(alpha: 0.14 + 0.20 * t),
          tier.first.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: badge, radius: glowR)),
    );

    // Halo rings behind the badge (SVIP6+).
    if (level >= 6) {
      for (int r = 0; r < level - 5; r++) {
        canvas.drawCircle(
          badge,
          w * (0.24 + 0.05 * r),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = tier.first.withValues(alpha: 0.28 - 0.06 * r)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }

    // Sparkles: a few at SVIP1, a sky full at SVIP8; four-point stars from
    // SVIP4.
    final rnd = math.Random(level * 97);
    final dot = Paint();
    final count = 6 + level * 6;
    for (int i = 0; i < count; i++) {
      final p = Offset(rnd.nextDouble() * w, rnd.nextDouble() * headerH * 0.9);
      final r = 0.6 + rnd.nextDouble() * (1.0 + t);
      final a = 0.25 + rnd.nextDouble() * 0.6;
      dot.color = Color.lerp(Colors.white, tier.first, rnd.nextDouble())!
          .withValues(alpha: a);
      canvas.drawCircle(p, r, dot);
      if (level >= 4 && i % 4 == 0) {
        final s = r * (3 + 2 * t);
        final star = Paint()
          ..color = dot.color
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p - Offset(s, 0), p + Offset(s, 0), star);
        canvas.drawLine(p - Offset(0, s), p + Offset(0, s), star);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SvipBackdropPainter old) =>
      old.tier != tier || old.headerH != headerH || old.level != level;
}

/// Marble pedestal: bright top face, light front, darker side, faint veins.
/// Neutral stone with only a hint of the tier colour.
class _PedestalPainter extends CustomPainter {
  _PedestalPainter({required this.tier});

  final List<Color> tier;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final topH = h * 0.12;
    final frontW = w * 0.7;
    Color stone(Color c) => Color.lerp(c, tier.first, 0.08)!;

    final top = Path()
      ..moveTo(0, topH * 0.55)
      ..lineTo(frontW * 0.45, 0)
      ..lineTo(w, topH * 0.3)
      ..lineTo(frontW, topH)
      ..close();
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(colors: [
          stone(const Color(0xFFF7F7F8)),
          stone(const Color(0xFFD6D7DB)),
        ]).createShader(Rect.fromLTWH(0, 0, w, topH)),
    );

    final front = Path()
      ..moveTo(0, topH * 0.55)
      ..lineTo(frontW, topH)
      ..lineTo(frontW, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stone(const Color(0xFFE6E7EA)),
            stone(const Color(0xFFB9BBC1)),
            stone(const Color(0xFF8C8E95)),
          ],
        ).createShader(Rect.fromLTWH(0, 0, frontW, h)),
    );

    final side = Path()
      ..moveTo(frontW, topH)
      ..lineTo(w, topH * 0.3)
      ..lineTo(w, h)
      ..lineTo(frontW, h)
      ..close();
    canvas.drawPath(
      side,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            stone(const Color(0xFFA4A6AD)),
            stone(const Color(0xFF55575D)),
          ],
        ).createShader(Rect.fromLTWH(frontW, 0, w - frontW, h)),
    );

    // Bright edge where the top meets the front.
    canvas.drawLine(
      Offset(0, topH * 0.55),
      Offset(frontW, topH),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 1.2,
    );

    // Marble veins.
    final vein = Paint()
      ..color = Colors.black.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(
      Path()
        ..moveTo(frontW * 0.12, h * 0.25)
        ..quadraticBezierTo(frontW * 0.38, h * 0.42, frontW * 0.26, h * 0.8),
      vein,
    );
    canvas.drawPath(
      Path()
        ..moveTo(frontW * 0.58, h * 0.18)
        ..quadraticBezierTo(frontW * 0.74, h * 0.5, frontW * 0.62, h * 0.95),
      vein,
    );
  }

  @override
  bool shouldRepaint(covariant _PedestalPainter old) => old.tier != tier;
}

/// Level track: a line that bows gently down toward the centre and dips
/// into a V notch under the big centre diamond, small diamonds at each end.
class _TrackPainter extends CustomPainter {
  _TrackPainter({required this.tier});

  final List<Color> tier;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final y = size.height * 0.3;
    final cx = w / 2;

    final track = Path()
      ..moveTo(8, y)
      ..quadraticBezierTo(w * 0.25, y + 7, cx - 18, y + 9)
      ..lineTo(cx, y + 22)
      ..lineTo(cx + 18, y + 9)
      ..quadraticBezierTo(w * 0.75, y + 7, w - 8, y);
    final shader = LinearGradient(colors: [
      Colors.white.withValues(alpha: 0.25),
      tier.first.withValues(alpha: 0.85),
      Colors.white.withValues(alpha: 0.25),
    ]).createShader(Rect.fromLTWH(0, y - 2, w, 26));

    // Soft glow under the line, then the line itself.
    canvas.drawPath(
      track,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      track,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );

    void diamond(Offset c, double r, Paint fill) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - r)
          ..lineTo(c.dx + r, c.dy)
          ..lineTo(c.dx, c.dy + r)
          ..lineTo(c.dx - r, c.dy)
          ..close(),
        fill,
      );
    }

    final small = Paint()..color = Colors.white.withValues(alpha: 0.9);
    diamond(Offset(8, y), 5, small);
    diamond(Offset(w - 8, y), 5, small);

    final c = Offset(cx, y - 2);
    canvas.drawCircle(
      c,
      18,
      Paint()
        ..color = tier.first.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    diamond(
      c,
      12,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, tier.first, tier.last],
        ).createShader(Rect.fromCircle(center: c, radius: 12)),
    );
    diamond(
      c,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant _TrackPainter old) => old.tier != tier;
}

/// Opens the user's own SVIP bag as a dark sheet styled like the level-up
/// panel: glowing top edge, gold title with a close button, a short note,
/// and cards matching the privilege cards.
void _showMyVipBag(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => SizedBox(
      height: ScreenUtil().screenHeight * 0.72,
      child: const _MyVipBag(),
    ),
  );
}

/// The user's own SVIP bag (use / un-use / send).
class _MyVipBag extends StatelessWidget {
  const _MyVipBag();

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF3D9A4);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B2E46), Color(0xFF1A1B26), Color(0xFF14151C)],
          stops: [0, 0.18, 1],
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF8E96D8).withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + close.
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 8.w, 0),
            child: Row(
              children: [
                SizedBox(width: 40.w),
                Expanded(
                  child: Text(
                    'My SVIP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: gold,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.9), size: 28.sp),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 14.h),
            child: Text(
              'Use an SVIP to show it everywhere, or send it to a friend. '
              'Only one SVIP can be in use at a time.',
              style: TextStyle(
                color: gold.withValues(alpha: 0.85),
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<VipCenterBloc, VipStates>(
              bloc: di<VipCenterBloc>(),
              buildWhen: (prev, curr) =>
                  prev.vipBag != curr.vipBag ||
                  prev.requestStateVipBag != curr.requestStateVipBag,
              builder: (context, state) {
                final bag = state.vipBag;
                if (bag.isEmpty) {
                  return Center(
                    child: Text(
                      state.requestStateVipBag.isLoaded
                          ? 'You have no SVIP yet'
                          : '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w,
                      20.h + MediaQuery.paddingOf(context).bottom),
                  itemCount: bag.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, i) => _BagCard(item: bag[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// One owned SVIP, styled like the privilege cards.
class _BagCard extends StatelessWidget {
  const _BagCard({required this.item});

  final VipBagItemEntity item;

  @override
  Widget build(BuildContext context) {
    final level = item.vip?.level ?? 1;
    final tier = _tierColor(level);
    final used = item.isUsed == true;
    final img = item.vip?.img ?? '';
    final name = (item.vip?.name ?? 'SVIP$level').replaceAll(RegExp(r'\s+'), '');
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF26282F), Color(0xFF131418)],
        ),
        border: Border.all(
          color: tier.first.withValues(alpha: used ? 0.9 : 0.45),
          width: used ? 1.5 : 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 24.w,
            right: 24.w,
            height: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  tier.first.withValues(alpha: 0),
                  tier.first.withValues(alpha: 0.9),
                  tier.first.withValues(alpha: 0),
                ]),
              ),
            ),
          ),
          if (used)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  gradient: LinearGradient(colors: tier),
                ),
                child: Text(
                  'In use',
                  style: TextStyle(
                    color: const Color(0xFF2A1A0A),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 14.h, 10.w, 10.h),
            child: Column(
              children: [
                // Still badge; tap plays it.
                GestureDetector(
                  onTap: () => _playAnimated(context, img, name),
                  child: SizedBox(
                    width: 80.w,
                    height: 70.h,
                    child: _isSvga(img)
                        ? CacheSvgaWidget(
                            url: EndPoints.getImage(img),
                            width: 80.w,
                            height: 70.h,
                            boxFit: BoxFit.contain,
                            autoPlay: false,
                          )
                        : ImageViewWidget(
                            url: EndPoints.getImage(img),
                            width: 80.w,
                            height: 70.h,
                            boxFit: BoxFit.contain,
                          ),
                  ),
                ),
                8.hBox,
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tier.first,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                3.hBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 13.sp,
                        color: Colors.white.withValues(alpha: 0.5)),
                    4.wBox,
                    Flexible(
                      child: Text(
                        item.remainingTime ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _BagButton(
                  label: used ? StringManager.unUse.tr() : StringManager.use.tr(),
                  filled: !used,
                  tier: tier,
                  onTap: () => di<VipCenterBloc>().add(
                    UseAndUnuseVipEvent(
                      type: used ? '0' : '1',
                      context: context,
                      targetId: item.targetId.toString(),
                    ),
                  ),
                ),
                if (item.using != true) ...[
                  6.hBox,
                  _BagButton(
                    label: StringManager.send.tr(),
                    filled: false,
                    tier: tier,
                    onTap: () => customModalBottomSheet(
                      context,
                      height: ScreenUtil().screenHeight,
                      child: SendVipBottomSheet(
                        vipId: item.targetId.toString(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill button in the tier colour (filled or outlined).
class _BagButton extends StatelessWidget {
  const _BagButton({
    required this.label,
    required this.filled,
    required this.tier,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final List<Color> tier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          gradient: filled ? LinearGradient(colors: tier) : null,
          border: filled
              ? null
              : Border.all(color: tier.first.withValues(alpha: 0.8)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? const Color(0xFF2A1A0A) : tier.first,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class CustomMasonryGrid extends StatelessWidget {
  final int columnCount;
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const CustomMasonryGrid({
    super.key,
    required this.columnCount,
    required this.children,
    this.spacing = 10,
    this.runSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    // split children into N columns
    final columns = List.generate(columnCount, (_) => <Widget>[]);

    for (int i = 0; i < children.length; i++) {
      columns[i % columnCount].add(
        Padding(
          padding: EdgeInsets.only(bottom: runSpacing),
          child: children[i],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(columnCount, (i) {
        return Expanded(
          child: Column(
            children: columns[i],
          ),
        );
      }).indexed.expand((entry) sync* {
        yield entry.$2;
        if (entry.$1 != columnCount - 1) yield SizedBox(width: spacing);
      }).toList(),
    );
  }
}
