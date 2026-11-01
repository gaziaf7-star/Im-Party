import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/presentation/cp_store/view/component/all_friends_view.dart';
import 'package:general/src/features/cp/presentation/intimate_space/intimate_space_data.dart';

/// Source size of the hero artwork (all kinds share the same layout).
const double _kBgW = 941, _kBgH = 1672;

const List<Color> _kGoldGradient = [Color(0xFFFFE9A6), Color(0xFFF2B33D)];

/// Artwork and colours of one relationship kind: blue for CP / Best Friend,
/// pink for Sister, gold for Brother.
class _KindTheme {
  final String bg;
  final String frame;
  final double frameW;

  /// Nine-slice of [frame] (source pixels): the ornate corners stay intact.
  final Rect frameSlice;
  final String card;
  final double cardW, cardH;
  final Color page;
  final Color deep;
  final Color light;
  final List<Color> tabs;
  final List<Color> button;

  /// CP uses its own layout below the hero (Rewards / Level privileges
  /// frames) instead of the single level frame.
  final bool cpStyle;

  /// Hero positions in source pixels of [bg] (941 x 1672).
  final double avatarLeftX, avatarRightX, avatarY;

  /// Centre of the beating heart; null when the art already has one.
  final double? heartY;
  final double ribbonTop, ribbonX0, ribbonX1, buttonTop;

  const _KindTheme({
    required this.bg,
    required this.frame,
    required this.frameW,
    required this.frameSlice,
    required this.card,
    required this.cardW,
    required this.cardH,
    required this.page,
    required this.deep,
    required this.light,
    required this.tabs,
    required this.button,
    this.cpStyle = false,
    this.avatarLeftX = 318,
    this.avatarRightX = 623,
    this.avatarY = 840,
    this.heartY = 842,
    this.ribbonTop = 965,
    this.ribbonX0 = 175,
    this.ribbonX1 = 766,
    this.buttonTop = 1052,
  });

  static const _cp = _KindTheme(
    bg: 'assets/icons/ui_icons/Cpbgmage.png',
    frame: 'assets/icons/ui_icons/levelprivilage.png',
    frameW: 577,
    frameSlice: Rect.fromLTRB(60, 120, 517, 310),
    card: 'assets/icons/ui_icons/sisterreword.png',
    cardW: 500,
    cardH: 500,
    page: Color(0xFF8B2FF0),
    deep: Color(0xFFB0127F),
    light: Color(0xFFFFD1F1),
    tabs: [Color(0xFFFF6FD8), Color(0xFFE01CB0)],
    button: [Color(0xFFFF8BE0), Color(0xFFE21CAE), Color(0xFFA80C82)],
    cpStyle: true,
    avatarLeftX: 322,
    avatarRightX: 618,
    avatarY: 862,
    heartY: null,
    ribbonTop: 990,
    ribbonX0: 182,
    ribbonX1: 758,
    buttonTop: 1095,
  );

  static const _blue = _KindTheme(
    bg: 'assets/icons/ui_icons/sisterbg image.png',
    frame: 'assets/icons/ui_icons/sisterlevelframe.png',
    frameW: 371,
    frameSlice: Rect.fromLTRB(40, 80, 331, 560),
    card: 'assets/icons/ui_icons/reword card.png',
    cardW: 500,
    cardH: 472,
    page: Color(0xFF26B2FD),
    deep: Color(0xFF0B4FB3),
    light: Color(0xFFBFE6FF),
    tabs: [Color(0xFF45B6FF), Color(0xFF1366E0)],
    button: [Color(0xFF6FD0FF), Color(0xFF1F7BEA), Color(0xFF0C55C4)],
  );

  static const _pink = _KindTheme(
    bg: 'assets/icons/ui_icons/sisterbgimage.png',
    frame: 'assets/icons/ui_icons/sisterlevelimage.png',
    frameW: 379,
    frameSlice: Rect.fromLTRB(45, 80, 334, 545),
    card: 'assets/icons/ui_icons/sisterreword.png',
    cardW: 500,
    cardH: 500,
    page: Color(0xFFFC35CD),
    deep: Color(0xFF9C0F78),
    light: Color(0xFFFFD1F1),
    tabs: [Color(0xFFFF6FD8), Color(0xFFC2189A)],
    button: [Color(0xFFFF8BE0), Color(0xFFE21CAE), Color(0xFFA80C82)],
  );

  static const _gold = _KindTheme(
    bg: 'assets/icons/ui_icons/brotherbg.png',
    frame: 'assets/icons/ui_icons/bratherlevelframe.png',
    frameW: 387,
    frameSlice: Rect.fromLTRB(48, 95, 339, 565),
    card: 'assets/icons/ui_icons/brotherrewordframe.png',
    cardW: 500,
    cardH: 500,
    page: Color(0xFFD4761E),
    deep: Color(0xFF8A4300),
    light: Color(0xFFFFE3B8),
    tabs: [Color(0xFFFFB547), Color(0xFFD9780F)],
    button: [Color(0xFFFFC765), Color(0xFFEE8F1A), Color(0xFFB65E05)],
  );

  static _KindTheme forKind(RelationKind kind) => switch (kind) {
    RelationKind.sister => _pink,
    RelationKind.brother => _gold,
    RelationKind.cp => _cp,
    RelationKind.bestFriend => _blue,
  };

  static _KindTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ThemeScope>()?.theme ?? _blue;
}

class _ThemeScope extends InheritedWidget {
  final _KindTheme theme;

  const _ThemeScope({required this.theme, required super.child});

  @override
  bool updateShouldNotify(_ThemeScope old) => old.theme != theme;
}

class IntimateSpaceArgs {
  final String userId;
  final String name;
  final String image;
  final String uuid;
  final bool isMine;
  final RelationKind initial;

  const IntimateSpaceArgs({
    required this.userId,
    required this.name,
    required this.image,
    required this.uuid,
    required this.isMine,
    this.initial = RelationKind.cp,
  });
}

/// "Intimate Space": CP, Best Friend, Sister and Brother. Each tab shows the
/// pair on the star, a Bind Now button to add one, and the level ladder with
/// each level's rewards. Gifts between the pair raise the level (server side).
class IntimateSpacePage extends StatefulWidget {
  final IntimateSpaceArgs args;

  const IntimateSpacePage({super.key, required this.args});

  static Future<void> open(BuildContext context, IntimateSpaceArgs args) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => IntimateSpacePage(args: args)));
  }

  @override
  State<IntimateSpacePage> createState() => _IntimateSpacePageState();
}

class _IntimateSpacePageState extends State<IntimateSpacePage>
    with SingleTickerProviderStateMixin {
  final IntimateSpaceRepo _repo = IntimateSpaceRepo.instance;
  late final TabController _tabs = TabController(
    length: RelationKind.values.length,
    vsync: this,
    initialIndex: widget.args.initial.index,
  );

  Map<RelationKind, List<IntimateBond>>? _bonds;
  Object? _bondsError;

  /// Which bond is shown per kind when there are several.
  final Map<RelationKind, int> _shownBond = {};

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging && mounted) setState(() {});
    });
    _loadBonds();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadBonds() async {
    setState(() => _bondsError = null);
    try {
      final b = await _repo.bonds(widget.args.userId);
      if (mounted) setState(() => _bonds = b);
    } catch (e) {
      if (mounted) setState(() => _bondsError = e);
    }
  }

  RelationKind get _kind => RelationKind.values[_tabs.index];

  IntimateBond? _bondFor(RelationKind kind) {
    final list = _bonds?[kind] ?? const <IntimateBond>[];
    if (list.isEmpty) return null;
    final i = (_shownBond[kind] ?? 0).clamp(0, list.length - 1);
    return list[i];
  }

  Future<void> _bind(RelationKind kind) async {
    if (!widget.args.isMine) return;
    Map<RelationKind, RelationOffer> offers;
    try {
      offers = await _repo.offers();
    } catch (_) {
      if (mounted) {
        Methods.showToast(
          context,
          message: StringManager.someThingWentWrong.tr(),
          isError: true,
        );
      }
      return;
    }
    final offer = offers[kind];
    if (!mounted) return;
    if (offer == null || offer.id <= 0) {
      Methods.showToast(
        context,
        message: '${kind.label} is not available yet',
        isError: true,
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AllFriendsView(relationId: offer.id.toString()),
    );
    // The partner has to accept first; refresh in case they already did.
    if (mounted) _loadBonds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _KindTheme.forKind(_kind).page,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Intimate Space',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          return Stack(
            children: [
              Positioned.fill(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    for (final kind in RelationKind.values)
                      _ThemeScope(
                        theme: _KindTheme.forKind(kind),
                        child: ColoredBox(
                          color: _KindTheme.forKind(kind).page,
                          child: _KindView(
                            key: PageStorageKey(kind),
                            kind: kind,
                            width: w,
                            args: widget.args,
                            bonds: _bonds?[kind],
                            bond: _bondFor(kind),
                            loading: _bonds == null && _bondsError == null,
                            error: _bondsError,
                            onRetry: _loadBonds,
                            onBind: () => _bind(kind),
                            onPickBond:
                                (i) => setState(() => _shownBond[kind] = i),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 10.h,
                left: 14.w,
                right: 14.w,
                child: _KindTabs(controller: _tabs, current: _kind),
              ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tab pill
// -----------------------------------------------------------------------------

class _KindTabs extends StatelessWidget {
  final TabController controller;
  final RelationKind current;

  const _KindTabs({required this.controller, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: _KindTheme.forKind(current).deep.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final kind in RelationKind.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.animateTo(kind.index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26.r),
                    gradient:
                        kind == current
                            ? LinearGradient(
                              colors: _KindTheme.forKind(current).tabs,
                            )
                            : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text(
                        kind.label,
                        maxLines: 1,
                        style: TextStyle(
                          color:
                              kind == current
                                  ? Colors.white
                                  : _KindTheme.forKind(current).deep,
                          fontSize: 14.sp,
                          fontWeight:
                              kind == current
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// One tab
// -----------------------------------------------------------------------------

class _KindView extends StatefulWidget {
  final RelationKind kind;
  final double width;
  final IntimateSpaceArgs args;
  final List<IntimateBond>? bonds;
  final IntimateBond? bond;
  final bool loading;
  final Object? error;
  final VoidCallback onRetry;
  final VoidCallback onBind;
  final ValueChanged<int> onPickBond;

  const _KindView({
    super.key,
    required this.kind,
    required this.width,
    required this.args,
    required this.bonds,
    required this.bond,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onBind,
    required this.onPickBond,
  });

  @override
  State<_KindView> createState() => _KindViewState();
}

class _KindViewState extends State<_KindView>
    with AutomaticKeepAliveClientMixin {
  List<IntimateLevel>? _levels;
  bool _levelsFailed = false;
  int _index = 0;
  bool _indexChosen = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    setState(() => _levelsFailed = false);
    final list = await IntimateSpaceRepo.instance.levels(widget.kind);
    if (!mounted) return;
    setState(() {
      _levels = list;
      _levelsFailed = list.isEmpty;
      _syncIndex();
    });
  }

  @override
  void didUpdateWidget(covariant _KindView old) {
    super.didUpdateWidget(old);
    if (old.bond?.level != widget.bond?.level) _syncIndex();
  }

  /// Opens on the level being worked towards (or the first one).
  void _syncIndex() {
    final levels = _levels;
    if (levels == null || levels.isEmpty || _indexChosen) return;
    final current = LevelStatus.reachedLevel(levels, widget.bond);
    final i = levels.indexWhere((l) => l.level > current);
    _index = i < 0 ? levels.length - 1 : i;
  }

  void _step(int delta) {
    final levels = _levels;
    if (levels == null || levels.isEmpty) return;
    setState(() {
      _indexChosen = true;
      _index = (_index + delta).clamp(0, levels.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final w = widget.width;
    final imgH = w * _kBgH / _kBgW;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final theme = _KindTheme.of(context);

    return SingleChildScrollView(
      // physics: const BouncingScrollPhysics(),
      child: Stack(
        // The level panel is narrower than the page: keep it centred.
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            width: w,
            height: imgH,
            child: Image.asset(_KindTheme.of(context).bg, fit: BoxFit.fill),
          ),
          Column(
            children: [
              if (theme.cpStyle) ...[
                SizedBox(height: imgH * 0.70),
                _CpLevelSection(
                  width: w,
                  bond: widget.bond,
                  levels: _levels,
                  failed: _levelsFailed,
                  index: _index,
                  onStep: _step,
                  onRetry: _loadLevels,
                ),
              ] else ...[
                SizedBox(height: imgH * 0.705),
                _LevelPanel(
                  width: w * 0.985,
                  kind: widget.kind,
                  bond: widget.bond,
                  levels: _levels,
                  failed: _levelsFailed,
                  index: _index,
                  onStep: _step,
                  onRetry: _loadLevels,
                ),
              ],
              SizedBox(height: 24.h + bottom),
            ],
          ),
          ..._heroOverlay(context, w, imgH),
        ],
      ),
    );
  }

  List<Widget> _heroOverlay(BuildContext context, double w, double imgH) {
    double x(double px) => w * px / _kBgW;
    double y(double px) => imgH * px / _kBgH;
    final avatar = w * 0.17;
    final theme = _KindTheme.of(context);
    final bond = widget.bond;
    final bonds = widget.bonds ?? const <IntimateBond>[];
    final args = widget.args;

    return [
      // Owner (left arm of the star).
      Positioned(
        left: x(theme.avatarLeftX) - avatar / 2,
        top: y(theme.avatarY) - avatar / 2,
        child: _Avatar(
          size: avatar,
          image: args.image,
          name: args.name,
          onTap: null,
        ),
      ),
      // Partner or "+" (right arm).
      Positioned(
        left: x(theme.avatarRightX) - avatar / 2,
        top: y(theme.avatarY) - avatar / 2,
        child:
            bond != null
                ? _Avatar(
                  size: avatar,
                  image: bond.partnerImage,
                  name: bond.partnerName,
                  onTap:
                      () => Methods().userProfileNavigator(
                        context: context,
                        userId: bond.partnerId,
                      ),
                )
                : _AddSlot(
                  size: avatar,
                  enabled: args.isMine,
                  onTap: widget.onBind,
                ),
      ),
      // Middle heart (the CP art has its own gem).
      if (theme.heartY != null)
        Positioned(
          left: x(470) - w * 0.05,
          top: y(theme.heartY!) - w * 0.05,
          child: _BeatingHeart(size: w * 0.1, linked: bond != null),
        ),
      // ID ribbon.
      Positioned(
        left: x(theme.ribbonX0),
        width: x(theme.ribbonX1) - x(theme.ribbonX0),
        top: y(theme.ribbonTop),
        child: _IdRibbon(
          left: args.uuid,
          right: bond?.partnerUuid ?? '?',
          height: w * 0.075,
        ),
      ),
      // Bind Now / level pill.
      Positioned(
        left: 0,
        right: 0,
        top: y(theme.buttonTop),
        child: Center(
          child:
              bond != null
                  ? _LevelPill(
                    bond: bond,
                    level: LevelStatus.reachedLevel(_levels ?? const [], bond),
                    width: w * 0.42,
                    height: w * 0.095,
                  )
                  : _BindButton(
                    width: w * 0.40,
                    height: w * 0.105,
                    enabled: args.isMine,
                    onTap: widget.onBind,
                  ),
        ),
      ),
      if (widget.loading)
        Positioned(
          top: y(560),
          left: 0,
          right: 0,
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            ),
          ),
        ),
      if (widget.error != null)
        Positioned(
          top: y(520),
          left: 0,
          right: 0,
          child: Center(
            child: _SmallPill(
              text: 'Could not load. Tap to retry',
              onTap: widget.onRetry,
            ),
          ),
        ),
      if (bonds.length > 1)
        Positioned(
          right: 0,
          top: 64.h,
          child: _SmallPill(
            text: 'Other ${widget.kind.label.toLowerCase()}s (${bonds.length})',
            onTap: () => _pickBond(context, bonds),
            rightFlush: true,
          ),
        ),
    ];
  }

  void _pickBond(BuildContext context, List<IntimateBond> bonds) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (sheet) => SafeArea(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              itemCount: bonds.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final b = bonds[i];
                return ListTile(
                  leading: UserImage(
                    image: EndPoints.getImage(b.partnerImage),
                    displayName: b.partnerName,
                    imageSize: 42.sp,
                  ),
                  title: Text(
                    b.partnerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('ID: ${b.partnerUuid} · Lv ${b.level}'),
                  onTap: () {
                    Navigator.pop(sheet);
                    widget.onPickBond(i);
                  },
                );
              },
            ),
          ),
    );
  }
}

// -----------------------------------------------------------------------------
// Hero pieces
// -----------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final double size;
  final String image;
  final String name;
  final VoidCallback? onTap;

  const _Avatar({
    required this.size,
    required this.image,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.04),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, _KindTheme.of(context).light],
          ),
          boxShadow: [
            BoxShadow(
              color: _KindTheme.of(context).deep.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: UserImage(
          image: EndPoints.getImage(image),
          displayName: name,
          imageSize: size * 0.92,
        ),
      ),
    );
  }
}

class _AddSlot extends StatelessWidget {
  final double size;
  final bool enabled;
  final VoidCallback onTap;

  const _AddSlot({
    required this.size,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 2,
          ),
        ),
        child: Icon(
          enabled ? Icons.add_rounded : Icons.question_mark_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _BeatingHeart extends StatefulWidget {
  final double size;
  final bool linked;

  const _BeatingHeart({required this.size, required this.linked});

  @override
  State<_BeatingHeart> createState() => _BeatingHeartState();
}

class _BeatingHeartState extends State<_BeatingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        // Lub-dub: two quick beats then a rest.
        final t = _c.value;
        final beat =
            t < 0.15
                ? t / 0.15
                : t < 0.3
                ? 1 - (t - 0.15) / 0.15
                : t < 0.42
                ? (t - 0.3) / 0.12 * 0.7
                : t < 0.55
                ? 0.7 - (t - 0.42) / 0.13 * 0.7
                : 0.0;
        final scale = 1 + (widget.linked ? 0.18 : 0.08) * beat;
        return Transform.scale(
          scale: scale,
          child: Icon(
            Icons.favorite_rounded,
            size: widget.size,
            color:
                widget.linked
                    ? const Color(0xFFFF4D8D)
                    : Colors.white.withValues(alpha: 0.85),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IdRibbon extends StatelessWidget {
  final String left;
  final String right;
  final double height;

  const _IdRibbon({
    required this.left,
    required this.right,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: height * 0.42,
      fontWeight: FontWeight.w700,
      shadows: const [Shadow(color: Colors.black26, blurRadius: 3)],
    );
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        gradient: LinearGradient(
          colors: [
            _KindTheme.of(context).deep.withValues(alpha: 0.0),
            _KindTheme.of(context).deep.withValues(alpha: 0.75),
            _KindTheme.of(context).deep.withValues(alpha: 0.75),
            _KindTheme.of(context).deep.withValues(alpha: 0.0),
          ],
          stops: const [0, 0.15, 0.85, 1],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          SizedBox(width: height),
          Expanded(
            child: Text(
              right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _BindButton extends StatelessWidget {
  final double width;
  final double height;
  final bool enabled;
  final VoidCallback onTap;

  const _BindButton({
    required this.width,
    required this.height,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.75,
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _KindTheme.of(context).button,
            ),
            border: Border.all(color: const Color(0xFFFFE7A3), width: 2),
            boxShadow: [
              BoxShadow(
                color: _KindTheme.of(context).deep.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            enabled ? 'Bind Now' : 'Not bound yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: height * 0.4,
              fontWeight: FontWeight.w800,
              shadows: const [Shadow(color: Colors.black38, blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  final IntimateBond bond;
  final double width;
  final double height;

  final int level;

  const _LevelPill({
    required this.bond,
    required this.level,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: height * 0.3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        gradient: const LinearGradient(colors: _kGoldGradient),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Lv $level  ·  ${_fmtInt(bond.points)} intimacy',
          style: TextStyle(
            color: const Color(0xFF6B3A00),
            fontSize: height * 0.36,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool rightFlush;

  const _SmallPill({
    required this.text,
    required this.onTap,
    this.rightFlush = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = Radius.circular(18.r);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: _KindTheme.of(context).tabs),
          borderRadius:
              rightFlush
                  ? BorderRadius.only(topLeft: r, bottomLeft: r)
                  : BorderRadius.all(r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Level panel
// -----------------------------------------------------------------------------

class _LevelPanel extends StatelessWidget {
  final double width;
  final RelationKind kind;
  final IntimateBond? bond;
  final List<IntimateLevel>? levels;
  final bool failed;
  final int index;
  final ValueChanged<int> onStep;
  final VoidCallback onRetry;

  const _LevelPanel({
    required this.width,
    required this.kind,
    required this.bond,
    required this.levels,
    required this.failed,
    required this.index,
    required this.onStep,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // The frame is drawn with a nine-slice so the ornate corners keep their
    // shape at any height; it is scaled to the panel width.
    final theme = _KindTheme.of(context);
    final scale = theme.frameW / width;
    final pad = width * 0.075;

    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: width * 1.15),
      padding: EdgeInsets.fromLTRB(pad, width * 0.16, pad, width * 0.14),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(theme.frame),
          centerSlice: theme.frameSlice,
          scale: scale,
        ),
      ),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final list = levels;
    if (list == null) {
      return SizedBox(
        height: width * 0.6,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.4,
          ),
        ),
      );
    }
    if (failed || list.isEmpty) {
      return SizedBox(
        height: width * 0.6,
        child: Center(
          child: _SmallPill(
            text: 'No levels yet. Tap to retry',
            onTap: onRetry,
          ),
        ),
      );
    }

    final level = list[index.clamp(0, list.length - 1)];
    final status = LevelStatus.of(list, index, bond);
    final unlocked = status.unlocked;
    final isNext = status.isNext;
    final progress = status.progress;
    final inner = width - width * 0.15;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Level badge with arrows.
        Row(
          children: [
            _ArrowButton(
              icon: Icons.chevron_left_rounded,
              enabled: index > 0,
              onTap: () => onStep(-1),
            ),
            Expanded(
              child: _LevelBadge(
                level: level,
                unlocked: unlocked,
                size: inner * 0.42,
              ),
            ),
            _ArrowButton(
              icon: Icons.chevron_right_rounded,
              enabled: index < list.length - 1,
              onTap: () => onStep(1),
            ),
          ],
        ),
        8.hBox,
        Text(
          level.title.isNotEmpty ? level.title : 'Level ${level.level}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        14.hBox,
        // Requirement + progress.
        Row(
          children: [
            Expanded(
              child: Text(
                'Lv${level.level} unlock requirements:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (unlocked)
              const _StatusChip(text: 'Unlocked', gold: true)
            else
              _StatusChip(text: isNext ? 'In progress' : 'Locked'),
          ],
        ),
        6.hBox,
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            _requirementText(kind, level),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        10.hBox,
        _ProgressBar(value: progress),
        6.hBox,
        _ProgressInfo(status: status, hasBond: bond != null, kind: kind),
        18.hBox,
        const _PrivilegesTitle(),
        12.hBox,
        if (level.rewards.isEmpty && level.privileges.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text(
              'No rewards for this level yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13.sp,
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, box) {
              final gap = box.maxWidth * 0.04;
              final cardW = (box.maxWidth - gap * 2) / 3;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final r in [...level.rewards, ...level.privileges])
                    _RewardCard(reward: r, width: cardW, locked: !unlocked),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _kGoldGradient,
            ),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF8A4B00), size: 26.sp),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final IntimateLevel level;
  final bool unlocked;
  final double size;

  const _LevelBadge({
    required this.level,
    required this.unlocked,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final image = level.image;
    Widget art =
        image.isNotEmpty
            ? ImageViewWidget(
              url: EndPoints.getImage(image),
              width: size,
              height: size,
              boxFit: BoxFit.contain,
            )
            : Icon(
              Icons.workspace_premium_rounded,
              size: size * 0.8,
              color: const Color(0xFFFFD36B),
            );
    if (!unlocked) {
      art = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.33, 0.33, 0.33, 0, 0, //
          0.33, 0.33, 0.33, 0, 0, //
          0.33, 0.33, 0.33, 0, 0, //
          0, 0, 0, 1, 0,
        ]),
        child: art,
      );
    }
    return SizedBox(
      height: size * 1.12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow + pedestal.
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.95,
              height: size * 0.16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.elliptical(size, size * 0.2),
                ),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF4C9), Color(0xFFE6A93A)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: unlocked ? 0.55 : 0.25),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: size * 0.04, child: art),
          if (!unlocked)
            Positioned(
              top: size * 0.32,
              child: Icon(
                Icons.lock_rounded,
                color: Colors.white,
                size: size * 0.3,
              ),
            ),
          Positioned(
            bottom: size * 0.07,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: _KindTheme.of(context).deep.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Lv ${level.level}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final bool gold;

  const _StatusChip({required this.text, this.gold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: gold ? const LinearGradient(colors: _kGoldGradient) : null,
        color: gold ? null : Colors.white.withValues(alpha: 0.22),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gold ? const Color(0xFF6B3A00) : Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;

  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.h,
      decoration: BoxDecoration(
        color: _KindTheme.of(context).deep.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder:
              (_, v, __) => FractionallySizedBox(
                widthFactor: v,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    gradient: const LinearGradient(colors: _kGoldGradient),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

class _PrivilegesTitle extends StatelessWidget {
  const _PrivilegesTitle();

  @override
  Widget build(BuildContext context) {
    Widget wing(bool flip) => Expanded(
      child: Container(
        height: 1.5,
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                flip
                    ? [Colors.white, Colors.white.withValues(alpha: 0)]
                    : [Colors.white.withValues(alpha: 0), Colors.white],
          ),
        ),
      ),
    );
    return Row(
      children: [
        wing(false),
        Icon(Icons.auto_awesome, color: Colors.white, size: 14.sp),
        6.wBox,
        Text(
          'Level privileges',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        6.wBox,
        Icon(Icons.auto_awesome, color: Colors.white, size: 14.sp),
        wing(true),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final IntimateReward reward;
  final double width;
  final bool locked;

  const _RewardCard({
    required this.reward,
    required this.width,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = _KindTheme.of(context);
    final cardH = width * theme.cardH / theme.cardW;
    final art = width * 0.58;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(
            width: width,
            height: cardH,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Image.asset(theme.card, fit: BoxFit.fill),
                ),
                Padding(
                  padding: EdgeInsets.only(top: cardH * 0.06),
                  child:
                      reward.image.isNotEmpty
                          ? ImageViewWidget(
                            url: EndPoints.getImage(reward.image),
                            width: art,
                            height: art,
                            boxFit: BoxFit.contain,
                          )
                          : Icon(
                            Icons.card_giftcard_rounded,
                            color: Colors.white,
                            size: art * 0.7,
                          ),
                ),
                if (locked)
                  Positioned(
                    right: width * 0.1,
                    top: cardH * 0.12,
                    child: Icon(
                      Icons.lock_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: width * 0.14,
                    ),
                  ),
              ],
            ),
          ),
          4.hBox,
          Text(
            reward.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CP layout: level art with arrows, banner, Rewards and Level privileges
// -----------------------------------------------------------------------------

/// Source sizes of the CP artwork.
const double _kCpBannerW = 866, _kCpBannerH = 288;
const double _kCpFrameW = 577, _kCpFrameH = 433;
const String _kCpBanner = 'assets/icons/ui_icons/Cptopframe.png';
const String _kCpRewardFrame = 'assets/icons/ui_icons/Cp Reword image.png';
const String _kCpPrivilegeFrame = 'assets/icons/ui_icons/levelprivilage.png';

class _CpLevelSection extends StatelessWidget {
  final double width;
  final IntimateBond? bond;
  final List<IntimateLevel>? levels;
  final bool failed;
  final int index;
  final ValueChanged<int> onStep;
  final VoidCallback onRetry;

  const _CpLevelSection({
    required this.width,
    required this.bond,
    required this.levels,
    required this.failed,
    required this.index,
    required this.onStep,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final frameW = width * 0.985;
    final list = levels;
    if (list == null || failed || list.isEmpty) {
      return Column(
        children: [
          SizedBox(
            height: width * 0.4,
            child: Center(
              child:
                  list == null
                      ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      )
                      : _SmallPill(
                        text: 'No levels yet. Tap to retry',
                        onTap: onRetry,
                      ),
            ),
          ),
          _CpBanner(width: width, text: 'Level'),
          16.hBox,
          _CpFrame(
            width: frameW,
            asset: _kCpPrivilegeFrame,
            child: _levelCards(null, false),
          ),
        ],
      );
    }

    final level = list[index.clamp(0, list.length - 1)];
    final status = LevelStatus.of(list, index, bond);
    final unlocked = status.unlocked;
    final isNext = status.isNext;
    final progress = status.progress;

    return Column(
      children: [
        // Level art with arrows (like the pet stage).
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Row(
            children: [
              _ArrowButton(
                icon: Icons.chevron_left_rounded,
                enabled: index > 0,
                onTap: () => onStep(-1),
              ),
              Expanded(
                child: _LevelBadge(
                  level: level,
                  unlocked: unlocked,
                  size: width * 0.36,
                ),
              ),
              _ArrowButton(
                icon: Icons.chevron_right_rounded,
                enabled: index < list.length - 1,
                onTap: () => onStep(1),
              ),
            ],
          ),
        ),
        _CpBanner(
          width: width,
          text:
              level.title.isNotEmpty
                  ? 'Lv${level.level} · ${level.title}'
                  : 'Level ${level.level}',
        ),
        12.hBox,
        // Requirement + progress.
        Container(
          width: frameW,
          padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lv${level.level} unlock requirements:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (unlocked)
                    const _StatusChip(text: 'Unlocked', gold: true)
                  else
                    _StatusChip(text: isNext ? 'In progress' : 'Locked'),
                ],
              ),
              6.hBox,
              Text(
                _requirementText(RelationKind.cp, level),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              10.hBox,
              _ProgressBar(value: progress),
              6.hBox,
              _ProgressInfo(
                status: status,
                hasBond: bond != null,
                kind: RelationKind.cp,
              ),
            ],
          ),
        ),
        18.hBox,
        _CpFrame(
          width: frameW,
          asset: _kCpRewardFrame,
          child: _rewards(frameW, level, unlocked),
        ),
        16.hBox,
        _CpFrame(
          width: frameW,
          asset: _kCpPrivilegeFrame,
          child: _levelCards(level, unlocked),
        ),
      ],
    );
  }

  Widget _rewards(double frameW, IntimateLevel level, bool unlocked) {
    final bubble = frameW * 0.2;
    if (level.rewards.isEmpty) {
      return SizedBox(
        height: bubble * 1.3,
        child: Center(
          child: Text(
            'No rewards for this level yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13.sp,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: bubble * 1.42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: level.rewards.length,
        separatorBuilder: (_, __) => SizedBox(width: frameW * 0.035),
        itemBuilder:
            (_, i) => _CpBubble(
              reward: level.rewards[i],
              size: bubble,
              locked: !unlocked,
            ),
      ),
    );
  }

  /// Cards inside the Level privileges frame: the level's rewards, each
  /// drawn small inside a reward card. Before any reward is set up, the CP
  /// privileges are shown the same way.
  Widget _levelCards(IntimateLevel? level, bool unlocked) {
    final privileges = level?.privileges ?? const <IntimateReward>[];
    final rewards =
        privileges.isNotEmpty
            ? privileges
            : (level?.rewards ?? const <IntimateReward>[]);
    final cards = <Widget>[
      if (rewards.isNotEmpty)
        for (final r in rewards)
          _CpCard(
            image: r.image,
            icon: Icons.card_giftcard_rounded,
            label: r.title,
            locked: !unlocked,
          )
      else
        for (final (icon, label) in const <(IconData, String)>[
          (Icons.favorite_rounded, 'CP Space'),
          (Icons.verified_rounded, 'CP Certification'),
          (Icons.mic_rounded, 'CP On Mic'),
          (Icons.shield_rounded, 'CP Badge'),
          (Icons.diamond_rounded, 'CP Headwear'),
        ])
          _CpCard(image: '', icon: icon, label: label, locked: !unlocked),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        // One row that fits the frame's inner area; scrolls when longer.
        final card = (box.maxHeight * 0.78).clamp(0.0, box.maxWidth / 3.2);
        return Center(
          child: SizedBox(
            height: card + 30.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: cards.length,
              separatorBuilder: (_, __) => SizedBox(width: card * 0.08),
              itemBuilder:
                  (_, i) => SizedBox(
                    width: card,
                    child: _CpCardScope(size: card, child: cards[i]),
                  ),
            ),
          ),
        );
      },
    );
  }
}

/// "Head to feeding" style banner; our own text is drawn over its plaque.
class _CpBanner extends StatelessWidget {
  final double width;
  final String text;

  const _CpBanner({required this.width, required this.text});

  @override
  Widget build(BuildContext context) {
    final h = width * _kCpBannerH / _kCpBannerW;
    // Plaque of the art, in source pixels: centre (433, 181), ~280 x 66.
    final plaqueW = width * 280 / _kCpBannerW;
    final plaqueH = h * 66 / _kCpBannerH;
    return SizedBox(
      width: width,
      height: h,
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset(_kCpBanner, fit: BoxFit.fill)),
          Positioned(
            left: width * 433 / _kCpBannerW - plaqueW / 2,
            top: h * 181 / _kCpBannerH - plaqueH / 2,
            width: plaqueW,
            height: plaqueH,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: plaqueH * 0.3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(plaqueH * 0.4),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF9BD9), Color(0xFFF468C6)],
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: plaqueH * 0.5,
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(color: Color(0x66A0005E), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rewards / Level privileges frame, drawn exactly like the artwork (no
/// stretching); the content sits in its inner pink area.
class _CpFrame extends StatelessWidget {
  final double width;
  final String asset;
  final Widget child;

  const _CpFrame({
    required this.width,
    required this.asset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final k = width / _kCpFrameW;
    return SizedBox(
      width: width,
      height: _kCpFrameH * k,
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset(asset, fit: BoxFit.fill)),
          Positioned(
            left: 42 * k,
            right: 42 * k,
            top: 112 * k,
            bottom: 100 * k,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CpBubble extends StatelessWidget {
  final IntimateReward reward;
  final double size;
  final bool locked;

  const _CpBubble({
    required this.reward,
    required this.size,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(size * 0.14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.55),
                ],
                stops: const [0.6, 1],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB0127F).withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                reward.image.isNotEmpty
                    ? ImageViewWidget(
                      url: EndPoints.getImage(reward.image),
                      width: size * 0.72,
                      height: size * 0.72,
                      boxFit: BoxFit.contain,
                    )
                    : Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: size * 0.45,
                    ),
                if (locked)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: size * 0.2,
                    ),
                  ),
              ],
            ),
          ),
          4.hBox,
          Text(
            reward.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gives a [_CpCard] its size.
class _CpCardScope extends InheritedWidget {
  final double size;

  const _CpCardScope({required this.size, required super.child});

  @override
  bool updateShouldNotify(_CpCardScope old) => old.size != size;
}

/// One reward (or privilege) shown small inside the reward card art.
class _CpCard extends StatelessWidget {
  final String image;
  final IconData icon;
  final String label;
  final bool locked;

  const _CpCard({
    required this.image,
    required this.icon,
    required this.label,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final size =
        context.dependOnInheritedWidgetOfExactType<_CpCardScope>()?.size ??
        80.0;
    final art = size * 0.46;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/icons/ui_icons/sisterreword.png',
                  fit: BoxFit.contain,
                ),
              ),
              image.isNotEmpty
                  ? ImageViewWidget(
                    url: EndPoints.getImage(image),
                    width: art,
                    height: art,
                    boxFit: BoxFit.contain,
                  )
                  : Icon(icon, color: Colors.white, size: art * 0.8),
              if (locked)
                Positioned(
                  right: size * 0.14,
                  top: size * 0.14,
                  child: Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: size * 0.15,
                  ),
                ),
            ],
          ),
        ),
        4.hBox,
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String _fmtInt(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// What a level asks for, from its `need_intimacy`.
String _requirementText(RelationKind kind, IntimateLevel level) =>
    level.needIntimacy <= 0
        ? kind.becomeText
        : 'Reach ${_fmtInt(level.needIntimacy)} intimacy by sending gifts '
            'to each other';

/// Numbers under the progress bar: where the pair is and what is left.
class _ProgressInfo extends StatelessWidget {
  final LevelStatus status;
  final bool hasBond;
  final RelationKind kind;

  const _ProgressInfo({
    required this.status,
    required this.hasBond,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    final String left;
    final String right;
    if (!hasBond) {
      left = kind.becomeText;
      right = status.need > 0 ? '0 / ${_fmtInt(status.need)}' : '';
    } else if (status.unlocked) {
      left = 'Level reached';
      right = '${_fmtInt(status.intimacy)} intimacy';
    } else {
      left = '${_fmtInt(status.remaining)} more intimacy needed';
      right = '${_fmtInt(status.intimacy)} / ${_fmtInt(status.need)}';
    }
    final style = TextStyle(
      color: Colors.white.withValues(alpha: 0.92),
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
    );
    return Row(
      children: [
        Expanded(child: Text(left, style: style)),
        if (right.isNotEmpty) Text(right, style: style),
      ],
    );
  }
}
