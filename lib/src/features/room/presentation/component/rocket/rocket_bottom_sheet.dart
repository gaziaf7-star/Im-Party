import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_svga/flutter_svga.dart';
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/GradientLoader.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/room.dart';

import 'rocket_realtime_controller.dart';

part 'rocket_sheet_ui.dart';

/// Keeps the last rocket data (and warms the images) per room so the sheet
/// opens instantly instead of showing a loader while the pictures download.
class _RocketCache {
  _RocketCache._();

  static final Map<String, Map<String, dynamic>> home = {};
  static final Map<String, List<Map<String, dynamic>>> ranking = {};
  static final Set<String> _warmed = {};
  static bool _svgaWarm = false;

  static const Set<String> _imageKeys = {
    'rocket_image',
    'rocket_image_url',
    'platform_image',
    'image',
    'show_image',
    'icon',
    'icon_url',
    'launch_animation',
  };

  static void _collect(dynamic node, Set<String> out) {
    if (node is Map) {
      node.forEach((k, v) {
        if (v is String && _imageKeys.contains(k) && v.trim().isNotEmpty) {
          if (!v.toLowerCase().endsWith('.svga')) out.add(v.trim());
        } else {
          _collect(v, out);
        }
      });
    } else if (node is List) {
      for (final e in node) {
        _collect(e, out);
      }
    }
  }

  /// Downloads every rocket / reward picture into the app's disk cache.
  static void warm(Map<String, dynamic> data) {
    RocketRealtimeController.instance.prepareFromRocket(data['rocket']);
    if (!_svgaWarm) {
      _svgaWarm = true;
      SvgaMovieCache.instance.loadFromAsset(AssetsManager.rocketLaunchpadSvga);
    }
    final urls = <String>{};
    _collect(data, urls);
    for (final raw in urls) {
      final u = RocketRealtimeController.mediaUrl(raw);
      if (_warmed.add(u)) {
        AssetCacheManager().getCachedAsset(u).catchError((_) => null);
      }
    }
  }
}

/// Phase 1 of the Rocket room-reward mini-game: the bottom sheet showing the
/// current rocket session (stage/progress/levels), contribution ranking, and
/// the reward table for the active level. Ported (structure + colour
/// language + panel/ribbon/card frame shapes) from the reference LinLive
/// app's audioRocketBottom.dart -- that file also drives a full-screen
/// launch animation + an app-wide banner over a dedicated realtime websocket
/// queue, which are deliberately NOT built yet (out of scope for this pass;
/// the user asked for the bottom sheet first).
///
/// Backend contract (confirmed directly by the user, Postman-tested):
///   GET /api/rocket/room/{roomId}            -- session/progress/levels
///   GET /api/rocket/room/{roomId}/ranking     -- contribution ranking
///   GET /api/rocket/room/{roomId}/launch-history
///   GET /api/rocket/my-rewards                 (auth)
/// There is no "contribute" endpoint -- contribution happens server-side
/// whenever a normal gift is sent in the room (per the reference app; this
/// app's backend is expected to work the same way).
/// Small carousel entry icon shown in the room's top icon strip (alongside
/// Room Support / Lucky Box). Unlike those static asset icons, this one
/// polls the room's actual current-level rocket image + live progress so
/// it always reflects the real running rocket, matching how Room Support's
/// slider icon shows real content instead of a placeholder.
class RocketCarouselIcon extends StatefulWidget {
  const RocketCarouselIcon({super.key});

  @override
  State<RocketCarouselIcon> createState() => _RocketCarouselIconState();
}

class _RocketCarouselIconState extends State<RocketCarouselIcon> {
  Timer? _poll;
  String _image = '';
  double _percent = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
    // REST poll stays as the baseline (covers missed/late realtime events),
    // but realtime progress/reset events (see RocketRealtimeController) now
    // update this icon instantly instead of waiting up to 20s.
    _poll = Timer.periodic(const Duration(seconds: 20), (_) => _fetch());
    RocketRealtimeController.instance.latestRocket.addListener(_onRealtimeRocket);
    RocketRealtimeController.instance.resetTick.addListener(_fetch);
  }

  @override
  void dispose() {
    _poll?.cancel();
    RocketRealtimeController.instance.latestRocket
        .removeListener(_onRealtimeRocket);
    RocketRealtimeController.instance.resetTick.removeListener(_fetch);
    super.dispose();
  }

  void _onRealtimeRocket() {
    final rocket = RocketRealtimeController.instance.latestRocket.value;
    if (rocket == null || !mounted) return;
    _applyRocket(rocket);
  }

  void _applyRocket(Map<String, dynamic> rocket) {
    final level =
    rocket['level'] is Map ? Map<String, dynamic>.from(rocket['level']) : null;
    final image = (level?['rocket_image'] ??
        level?['rocket_image_url'] ??
        level?['platform_image'] ??
        level?['image'] ??
        level?['show_image'] ??
        '')
        .toString();
    final targetRaw = rocket['target_coins'];
    final progressRaw = rocket['progress_coins'];
    final target = targetRaw is num
        ? targetRaw.toDouble()
        : double.tryParse('$targetRaw') ?? 0;
    final progress = progressRaw is num
        ? progressRaw.toDouble()
        : double.tryParse('$progressRaw') ?? 0;
    final percentRaw = rocket['progress_percent'];
    final percent = percentRaw != null
        ? (percentRaw is num
        ? percentRaw.toDouble()
        : double.tryParse('$percentRaw') ?? 0)
        : (target > 0 ? (progress / target * 100) : 0);
    setState(() {
      if (image.isNotEmpty) _image = image;
      _percent = percent.clamp(0, 100).toDouble();
    });
  }

  Future<void> _fetch() async {
    final roomId = RoomData.instance.room.id?.toString() ?? '';
    if (roomId.isEmpty) return;
    try {
      final res = await di<DioFactory>().get(EndPoints.rocketRoomInfo(roomId));
      final raw = res.data;
      final home = raw is Map
          ? Map<String, dynamic>.from(raw['data'] ?? raw)
          : <String, dynamic>{};
      final rocket =
      home['rocket'] is Map ? Map<String, dynamic>.from(home['rocket']) : null;
      if (home.isNotEmpty) {
        _RocketCache.home[roomId] = home;
        _RocketCache.warm(home);
      }
      if (!mounted || rocket == null) return;
      _applyRocket(rocket);
    } catch (_) {
      // Silent -- this is a passive background icon, not worth surfacing
      // a toast/log spam for every failed poll while the room is open.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Background removed, on request, matching the sibling OriVex Party
    // codebase -- now renders just the rocket image + progress bar, no
    // gradient card behind it.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _image.isNotEmpty
                ? ImageViewWidget(url: _image, boxFit: BoxFit.contain)
                : Icon(Icons.rocket_launch_rounded,
                color: const Color(0xFF58EDF1), size: 26.sp),
          ),
          2.hBox,
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: (_percent / 100).clamp(0, 1),
              minHeight: 3.h,
              backgroundColor: ColorManager.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF58EDF1)),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showRocketBottomSheet(BuildContext context) async {
  final screenHeight = MediaQuery.sizeOf(context).height;
  final sheetHeight = (screenHeight * .66).clamp(520.0, 1000.0).toDouble();
  await bottomDailog(
    context: context,
    height: sheetHeight,
    widget: const RocketBottomSheet(),
  );
}

class RocketBottomSheet extends StatefulWidget {
  const RocketBottomSheet({super.key});

  @override
  State<RocketBottomSheet> createState() => _RocketBottomSheetState();
}

class _RocketBottomSheetState extends State<RocketBottomSheet> {
  bool _loading = true;
  Map<String, dynamic> _home = {};
  List<Map<String, dynamic>> _ranking = [];
  // null = follow the room's actual active level; set once the user taps a
  // level card in the rail so the Reward panel below switches with it too.
  int? _selectedLevelIndex;
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _scrollY = ValueNotifier<double>(0);
  final GlobalKey _rewardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients) _scrollY.value = _scroll.offset;
    });
    final cachedRoomId = RoomData.instance.room.id?.toString() ?? '';
    final cachedHome = _RocketCache.home[cachedRoomId];
    if (cachedHome != null) {
      _home = cachedHome;
      _ranking = _RocketCache.ranking[cachedRoomId] ?? [];
      _loading = false;
    }
    _fetch();
    // Keep the open sheet's progress bar/level in sync with realtime
    // broadcasts too, not just the initial REST fetch (on request -- "gift
    // korle rocket level barbe").
    RocketRealtimeController.instance.latestRocket.addListener(_onRealtimeRocket);
    RocketRealtimeController.instance.resetTick.addListener(_fetch);
  }

  @override
  void dispose() {
    RocketRealtimeController.instance.latestRocket
        .removeListener(_onRealtimeRocket);
    RocketRealtimeController.instance.resetTick.removeListener(_fetch);
    super.dispose();
  }

  void _onRealtimeRocket() {
    final rocket = RocketRealtimeController.instance.latestRocket.value;
    if (rocket == null || !mounted) return;
    setState(() {
      _home = {..._home, 'rocket': rocket};
    });
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  Map<String, dynamic>? _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : null;

  List<Map<String, dynamic>> _asMapList(dynamic v) => (v is List)
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : [];

  Future<void> _fetch() async {
    final roomId = RoomData.instance.room.id?.toString() ?? '';
    if (roomId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        di<DioFactory>().get(EndPoints.rocketRoomInfo(roomId)),
        di<DioFactory>().get(EndPoints.rocketRanking(roomId)),
      ]);
      final homeRaw = results[0].data;
      final rankingRaw = results[1].data;
      final home = homeRaw is Map
          ? Map<String, dynamic>.from(homeRaw['data'] ?? homeRaw)
          : <String, dynamic>{};
      final rankingBody = rankingRaw is Map
          ? Map<String, dynamic>.from(rankingRaw['data'] ?? rankingRaw)
          : <String, dynamic>{};
      final ranking = _asMapList(rankingBody['ranking'] ??
          rankingBody['data'] ??
          rankingBody['contributors'] ??
          rankingBody['items'] ??
          home['ranking']);
      _RocketCache.home[roomId] = home;
      _RocketCache.ranking[roomId] = ranking;
      _RocketCache.warm(home);
      _logRocketMedia(home);
      if (!mounted) return;
      setState(() {
        _home = home;
        _ranking = ranking;
        _loading = false;
      });
    } catch (e) {
      Methods.printLog('⚠️ [Rocket] failed to load rocket info: $e');
      if (e is DioException) {
        Methods.printLog(
            '⚠️ [Rocket] status=${e.response?.statusCode} body=${e.response?.data}');
      }
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Prints every picture / animation URL the rocket API returned, with the
  /// key it came under, so the rocket image and the launch animation can be
  /// told apart in the log.
  void _logRocketMedia(dynamic node, [String path = 'rocket']) {
    final mediaExt = RegExp(r'\.(png|jpe?g|webp|gif|svga|json|mp4|webm)(\?|$)',
        caseSensitive: false);
    if (node is Map) {
      node.forEach((k, v) => _logRocketMedia(v, '$path.$k'));
    } else if (node is List) {
      for (var i = 0; i < node.length; i++) {
        _logRocketMedia(node[i], '$path[$i]');
      }
    } else if (node is String && mediaExt.hasMatch(node)) {
      final fixed = RocketRealtimeController.mediaUrl(node);
      Methods.printLog(fixed == node
          ? '🚀 [Rocket] $path = $node'
          : '🚀 [Rocket] $path = $node -> $fixed');
    }
  }

  Map<String, dynamic>? get _rocket =>
      _asMap(_home['rocket']) ?? _asMap(_home['rocket_state']) ?? _asMap(_home['state']);

  List<Map<String, dynamic>> get _levels =>
      _asMapList(_rocket?['levels'] ?? _home['levels']);

  Map<String, dynamic>? get _activeLevel =>
      _asMap(_rocket?['level']) ??
          (_levels.isNotEmpty
              ? _levels.firstWhere(
                  (l) => _asInt(l['level_no'] ?? l['id']) ==
                  _asInt(_rocket?['level_no']),
              orElse: () => _levels.first)
              : null);

  int get _progressCoins => _asInt(_rocket?['progress_coins']);
  int get _targetCoins => _asInt(
    _rocket?['target_coins'] ?? _activeLevel?['required_coins'],
  );
  double get _progressPercent {
    final raw = _rocket?['progress_percent'];
    if (raw != null) return _asDouble(raw).clamp(0, 100);
    if (_targetCoins <= 0) return 0;
    return (_progressCoins / _targetCoins * 100).clamp(0, 100);
  }

  int get _remainingSeconds => _asInt(_rocket?['remaining_seconds']);

  String get _rocketImage => (_activeLevel?['rocket_image'] ??
      _activeLevel?['rocket_image_url'] ??
      _activeLevel?['platform_image'] ??
      _activeLevel?['image'] ??
      _activeLevel?['show_image'] ??
      _activeLevel?['icon'] ??
      '')
      .toString();

  int get _resolvedSelectedIndex {
    final levels = _levels;
    if (levels.isEmpty) return 0;
    if (_selectedLevelIndex != null) {
      return _selectedLevelIndex!.clamp(0, levels.length - 1);
    }
    final activeLevelNo = _activeLevel != null
        ? (_activeLevel!['level_no'] ?? _activeLevel!['id']).toString()
        : null;
    final idx = levels.indexWhere(
            (lv) => (lv['level_no'] ?? lv['id']).toString() == activeLevelNo);
    return idx >= 0 ? idx : 0;
  }

  Map<String, dynamic>? get _selectedLevel =>
      _levels.isNotEmpty ? _levels[_resolvedSelectedIndex] : _activeLevel;

  String _levelImageOf(Map<String, dynamic> lv) => (lv['rocket_image'] ??
          lv['rocket_image_url'] ??
          lv['platform_image'] ??
          lv['image'] ??
          lv['show_image'] ??
          lv['icon'] ??
          '')
      .toString();

  int _levelNoOf(Map<String, dynamic> lv) => _asInt(lv['level_no'] ?? lv['id']);

  void _openHelp() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B2365),
        title: const Text('Rocket', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Send gifts in this room to fill the rocket. When the rocket '
          'reaches the target it launches and the TOP contributors, the room '
          'owner and the launcher receive the rewards of that level.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levels = _levels;
    final sel = _resolvedSelectedIndex;
    final selLevel = _selectedLevel;
    final active = _activeLevel;
    final activeNo = active != null ? _levelNoOf(active) : (sel + 1);
    final stageImage = selLevel != null ? _levelImageOf(selLevel) : _rocketImage;
    final headerH = 66.h;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00111A46),
            Color(0x66122562),
            Color(0xEE102E78),
            Color(0xFF0B2365),
            Color(0xFF06143E),
          ],
          stops: [0.0, 0.18, 0.40, 0.70, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: _loading
                ? const Center(child: GradientLoader(size: 26))
                : SingleChildScrollView(
                    controller: _scroll,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Column(
                      children: [
                        SizedBox(height: headerH),
                        _RocketScene(
                          rocketImage: stageImage,
                          levels: levels,
                          selectedIndex: sel,
                          imageOf: _levelImageOf,
                          levelNoOf: _levelNoOf,
                          onSelect: (i) => setState(() => _selectedLevelIndex = i),
                          level: activeNo,
                          nextLevel: activeNo + 1,
                          percent: _progressPercent,
                          remainingSeconds: _remainingSeconds,
                        ),
                        10.hBox,
                        Padding(
                          key: _rewardKey,
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: _RocketRewardPanel(level: selLevel),
                        ),
                        10.hBox,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: _RocketWinners(level: selLevel, ranking: _ranking),
                        ),
                        24.hBox,
                      ],
                    ),
                  ),
          ),
          // Pinned header: transparent over the scene, solid once scrolled.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollY,
              builder: (context, y, child) {
                final t = (y / 140).clamp(0.0, 1.0);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.lerp(const Color(0x00102E78), const Color(0xFF0E2A75), t)!,
                        Color.lerp(const Color(0x00102E78), const Color(0xF20B2365), t)!,
                      ],
                    ),
                  ),
                  child: child,
                );
              },
              child: _RocketHeader(
                onHelp: _openHelp,
                onClose: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cut-corner ribbon label (matches the reference app's `_RibbonPainter`),
/// used as the floating "Reward" / "Ranking" headers on top of each panel.
class _SectionRibbon extends StatelessWidget {
  final String title;

  const _SectionRibbon({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: CustomPaint(
        painter: const _RibbonPainter(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: TextWidget(
              title,
              style: context.bodyMedium.w900.colorExt(ColorManager.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cut-corner tech panel background (matches the reference app's
/// `_TechPanelPainter`), used behind the Reward and Ranking sections.
class _TechPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _TechPanel({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 12),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: CustomPaint(
              painter: const _TechPanelPainter(),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageTab extends StatefulWidget {
  final List<Map<String, dynamic>> levels;
  final Map<String, dynamic>? activeLevel;
  final String rocketImage;
  final int progressCoins;
  final int targetCoins;
  final double progressPercent;
  final int remainingSeconds;
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;

  const _StageTab({
    required this.levels,
    required this.activeLevel,
    required this.rocketImage,
    required this.progressCoins,
    required this.targetCoins,
    required this.progressPercent,
    required this.remainingSeconds,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  State<_StageTab> createState() => _StageTabState();
}

class _StageTabState extends State<_StageTab> {
  Timer? _ticker;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _seconds = widget.remainingSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds > 0) setState(() => _seconds--);
    });
  }

  @override
  void didUpdateWidget(covariant _StageTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingSeconds != widget.remainingSeconds) {
      _seconds = widget.remainingSeconds;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _levelImage(Map<String, dynamic> lv) => (lv['rocket_image'] ??
      lv['rocket_image_url'] ??
      lv['platform_image'] ??
      lv['image'] ??
      lv['show_image'] ??
      lv['icon'] ??
      '')
      .toString();

  int _levelNo(Map<String, dynamic> lv) {
    final raw = lv['level_no'] ?? lv['id'] ?? 0;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString()) ?? 0;
  }

  String get _hours => (_seconds ~/ 3600).toString().padLeft(2, '0');
  String get _minutes => ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  String get _secondsText => (_seconds % 60).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final activeLevelNo = widget.activeLevel != null
        ? (widget.activeLevel!['level_no'] ?? widget.activeLevel!['id'])
        .toString()
        : null;

    final selectedIndex = widget.selectedIndex
        .clamp(0, widget.levels.isEmpty ? 0 : widget.levels.length - 1);
    final selectedLevel =
    widget.levels.isNotEmpty ? widget.levels[selectedIndex] : null;
    final displayedImage =
    selectedLevel != null ? _levelImage(selectedLevel) : widget.rocketImage;
    final selectedLevelNo = selectedLevel != null
        ? (selectedLevel['level_no'] ?? selectedLevel['id']).toString()
        : (activeLevelNo ?? '');

    // Reference screenshot shows the highest level at the top of the rail.
    // Keep the real array index so selecting a displayed item still switches
    // the correct reward setup.
    final displayLevels = widget.levels.asMap().entries.toList()
      ..sort((a, b) => _levelNo(b.value).compareTo(_levelNo(a.value)));

    return Padding(
      padding: context.paddingSymmetric(horizontal: 10).copyWith(top: 10),
      child: Column(
        children: [
          SizedBox(
            height: 310.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LEFT LEVEL RAIL — close to the reference screenshot:
                // narrow dark-blue column, big rocket thumbnail and bright
                // LV label bar, with gold glow for active/selected level.
                SizedBox(
                  width: 66.w,
                  child: Column(
                    children: [
                      Container(
                        height: 28.h,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF279BFF), Color(0xFF0758D7)],
                          ),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: const Color(0xFFB6F6FF),
                            width: .7,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1ACBFF)
                                  .withValues(alpha: .28),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: TextWidget(
                          'Record >',
                          maxLines: 1,
                          style: context.bodySmall
                              .size(9)
                              .w900
                              .colorExt(ColorManager.white),
                        ),
                      ),
                      5.hBox,
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.r),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xE90B3D92),
                                Color(0xE9072672),
                                Color(0xF205164B),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFF1B83F5)
                                  .withValues(alpha: .75),
                              width: .8,
                            ),
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            itemCount: displayLevels.length,
                            separatorBuilder: (_, __) => 4.hBox,
                            itemBuilder: (context, displayIndex) {
                              final entry = displayLevels[displayIndex];
                              final originalIndex = entry.key;
                              final lv = entry.value;
                              final lvNo =
                              (lv['level_no'] ?? lv['id']).toString();
                              final active = lvNo == activeLevelNo;
                              final selected = originalIndex == selectedIndex;
                              final image = _levelImage(lv);

                              return GestureDetector(
                                onTap: () => widget.onSelectIndex(originalIndex),
                                child: Container(
                                  height: 59.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF174AA9),
                                        Color(0xFF0A246E),
                                        Color(0xFF071947),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: (selected || active)
                                          ? const Color(0xFFFFD64A)
                                          : const Color(0xFF4BC9FF)
                                          .withValues(alpha: .72),
                                      width: (selected || active) ? 1.5 : .8,
                                    ),
                                    boxShadow: [
                                      if (selected || active)
                                        BoxShadow(
                                          color: const Color(0xFFFFC928)
                                              .withValues(alpha: .26),
                                          blurRadius: 8,
                                          spreadRadius: .5,
                                        ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        bottom: 17.h,
                                        child: Padding(
                                          padding: EdgeInsets.all(2.w),
                                          child: image.isNotEmpty
                                              ? ImageViewWidget(
                                            url: image,
                                            boxFit: BoxFit.contain,
                                          )
                                              : Icon(
                                            Icons.rocket_launch_rounded,
                                            size: 24.sp,
                                            color:
                                            const Color(0xFF85ECFF),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 1,
                                        right: 1,
                                        bottom: 1,
                                        height: 17.h,
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(4.r),
                                              bottomRight: Radius.circular(4.r),
                                            ),
                                            gradient: (selected || active)
                                                ? const LinearGradient(
                                              colors: [
                                                Color(0xFFFFE066),
                                                Color(0xFFF09B00),
                                              ],
                                            )
                                                : const LinearGradient(
                                              colors: [
                                                Color(0xFF2A9BFF),
                                                Color(0xFF174ED2),
                                              ],
                                            ),
                                          ),
                                          child: TextWidget(
                                            'LV.$lvNo',
                                            style: context.bodySmall
                                                .size(9)
                                                .w900
                                                .colorExt((selected || active)
                                                ? const Color(0xFF4D2C00)
                                                : ColorManager.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                7.wBox,

                // CENTER ROCKET STAGE — dark sci-fi chamber, cyan hologram
                // base, radial glow and the real backend rocket image.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.r),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x44142F75),
                              Color(0x66123083),
                              Color(0xAA071A50),
                              Color(0xDD041138),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF257BDF)
                                .withValues(alpha: .45),
                            width: .8,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: 10.h,
                              left: 10.w,
                              right: 10.w,
                              child: Container(
                                height: 155.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF58CFFF)
                                          .withValues(alpha: .20),
                                      const Color(0xFF1478FF)
                                          .withValues(alpha: .08),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 22.h,
                              child: Container(
                                width: box.maxWidth * .78,
                                height: 18.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.r),
                                  border: Border.all(
                                    color: const Color(0xFF58E7FF),
                                    width: 1.4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF22C8FF)
                                          .withValues(alpha: .78),
                                      blurRadius: 24,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -7.h,
                              child: Image.asset(
                                AssetsManager.rocketPathImage,
                                width: box.maxWidth * .98,
                                height: 112.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 260),
                                  child: displayedImage.isNotEmpty
                                      ? ImageViewWidget(
                                    key: ValueKey(displayedImage),
                                    url: displayedImage,
                                    height: 275.h,
                                    width: box.maxWidth * .94,
                                    boxFit: BoxFit.contain,
                                  )
                                      : Icon(
                                    Icons.rocket_launch_rounded,
                                    size: 130.sp,
                                    color: const Color(0xFF58EDF1),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                7.wBox,

                // RIGHT ENERGY TUBE — silver glass body, neon cyan fill,
                // floating percentage badge and lightning energy cell.
                SizedBox(
                  width: 43.w,
                  height: 288.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 8.h,
                        child: Container(
                          width: 35.w,
                          height: 236.h,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF55616A),
                                Color(0xFFC9D3D9),
                                Color(0xFFF0F5F6),
                                Color(0xFF8A969F),
                                Color(0xFF4A545C),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFFE6FBFF),
                              width: .9,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.r),
                              color: const Color(0x33001B42),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: math.max(
                                  .035,
                                  (widget.progressPercent / 100)
                                      .clamp(0.0, 1.0),
                                ).toDouble(),
                                widthFactor: .88,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.r),
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color(0xFF057AFF),
                                        Color(0xFF18C9FF),
                                        Color(0xFF74FFFF),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF36E7FF)
                                            .withValues(alpha: .65),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 123.h,
                        child: Container(
                          constraints: BoxConstraints(minWidth: 42.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 4.h,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0EAFFF), Color(0xFF0753D1)],
                            ),
                            borderRadius: BorderRadius.circular(3.r),
                            border: Border.all(
                              color: const Color(0xFFB8F8FF),
                              width: .9,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF19D7FF)
                                    .withValues(alpha: .35),
                                blurRadius: 7,
                              ),
                            ],
                          ),
                          child: TextWidget(
                            '${widget.progressPercent.toStringAsFixed(0)}%',
                            maxLines: 1,
                            style: context.bodySmall
                                .size(9)
                                .w900
                                .colorExt(ColorManager.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2.h,
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFFF1FFFF),
                                Color(0xFF4BE8FF),
                                Color(0xFF167FFF),
                                Color(0xFF3944C8),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFF8AFFFF),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF35DFFF)
                                    .withValues(alpha: .55),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.bolt_rounded,
                            color: ColorManager.white,
                            size: 25.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          7.hBox,

          // Countdown row placed directly under the launch pad, like the
          // reference image. Progress details stay underneath in a thin bar.
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xCC071840), Color(0xDD09245E)],
              ),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFF3DBBFF).withValues(alpha: .5),
                width: .8,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TextWidget(
                        'Reset countdown',
                        maxLines: 1,
                        style: context.bodyMedium
                            .w800
                            .colorExt(ColorManager.white),
                      ),
                    ),
                    8.wBox,
                    _TimeBox(text: _hours),
                    3.wBox,
                    _TimeSeparator(),
                    3.wBox,
                    _TimeBox(text: _minutes),
                    3.wBox,
                    _TimeSeparator(),
                    3.wBox,
                    _TimeBox(text: _secondsText),
                  ],
                ),
                7.hBox,
                Row(
                  children: [
                    TextWidget(
                      'LV.$selectedLevelNo',
                      style: context.bodySmall
                          .size(10)
                          .w900
                          .colorExt(const Color(0xFF7FEAFF)),
                    ),
                    8.wBox,
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: LinearProgressIndicator(
                          value: (widget.progressPercent / 100).clamp(0, 1),
                          minHeight: 7.h,
                          backgroundColor:
                          ColorManager.white.withValues(alpha: .12),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF28D9F2),
                          ),
                        ),
                      ),
                    ),
                    8.wBox,
                    TextWidget(
                      '${widget.progressCoins}/${widget.targetCoins}',
                      style: context.bodySmall
                          .size(9)
                          .w700
                          .colorExt(ColorManager.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String text;

  const _TimeBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31.w,
      height: 27.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF041429), Color(0xFF08244A)],
        ),
        borderRadius: BorderRadius.circular(3.r),
        border: Border.all(
          color: const Color(0xFF25DDF6).withValues(alpha: .65),
          width: .6,
        ),
      ),
      child: TextWidget(
        text,
        style: context.bodyMedium
            .size(13)
            .w900
            .colorExt(const Color(0xFF67F5FF)),
      ),
    );
  }
}

class _TimeSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextWidget(
      ':',
      style: context.bodyMedium.w900.colorExt(ColorManager.white),
    );
  }
}

// Not shown in the sheet for now (the trophy button was removed), kept for later.
// ignore: unused_element
class _RankingTab extends StatelessWidget {
  final List<Map<String, dynamic>> ranking;

  const _RankingTab({required this.ranking});

  @override
  Widget build(BuildContext context) {
    final topThree = ranking.take(3).toList();

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        _TechPanel(
          padding: context.paddingOnly(
            start: 10,
            end: 10,
            top: 18,
            bottom: 12,
          ),
          child: topThree.isEmpty
              ? Padding(
            padding: context.paddingSymmetric(vertical: 20),
            child: Center(
              child: TextWidget(
                StringManager.noDataYet.tr(),
                style: context.bodySmall.colorExt(
                  ColorManager.white.withValues(alpha: .70),
                ),
              ),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topThree.length,
            separatorBuilder: (_, __) => 7.hBox,
            itemBuilder: (context, i) => _RankRow(
              row: topThree[i],
              rank: i + 1,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: MediaQuery.sizeOf(context).width * .25,
          right: MediaQuery.sizeOf(context).width * .25,
          child: const _SectionRibbon(title: 'Ranking'),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  final Map<String, dynamic> row;
  final int rank;

  const _RankRow({required this.row, required this.rank});

  Map<String, dynamic>? _user() {
    final u = row['user'] ?? row['sender'] ?? row['contributor'] ?? row['member'];
    return u is Map ? Map<String, dynamic>.from(u) : null;
  }

  @override
  Widget build(BuildContext context) {
    final u = _user();
    final name = (u?['name'] ?? u?['username'] ?? '-').toString();
    final coins = (row['contribution_coins'] ??
        row['total_contribution'] ??
        row['total_coins'] ??
        row['coins'] ??
        0)
        .toString();
    final percentRaw = row['percentage'] ??
        row['percent'] ??
        row['contribution_percent'] ??
        row['sending_percent'];
    final percent = percentRaw == null ? '' : percentRaw.toString();

    final badgeColors = rank == 1
        ? const [Color(0xFFFFF297), Color(0xFFFFAA00)]
        : rank == 2
        ? const [Color(0xFFE8F8FF), Color(0xFF7BBFFF)]
        : rank == 3
        ? const [Color(0xFFFFD6C2), Color(0xFFDF8753)]
        : const [Color(0xFF4CE9FF), Color(0xFF1F74F1)];

    return Container(
      constraints: BoxConstraints(minHeight: 54.h),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.r),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0B2E7B), Color(0xFF08225D), Color(0xFF071A4A)],
        ),
        border: Border.all(
          color: const Color(0xFF2E8DF2).withValues(alpha: .72),
          width: .8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: badgeColors),
              border: Border.all(color: ColorManager.white, width: .7),
              boxShadow: [
                BoxShadow(
                  color: badgeColors.last.withValues(alpha: .35),
                  blurRadius: 7,
                ),
              ],
            ),
            child: TextWidget(
              '$rank',
              style: context.bodySmall
                  .size(11)
                  .w900
                  .colorExt(const Color(0xFF4A2B00)),
            ),
          ),
          8.wBox,
          UserImage(
            image: RocketRealtimeController.profileUrl(
                u?['profile_image'] ?? u?['avatar'] ?? u?['image'],
                log: false),
            displayName: name,
            imageSize: 38.w,
            uniquId: '${u?['id'] ?? rank}',
          ),
          9.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWidget(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMedium
                      .size(12)
                      .w800
                      .colorExt(ColorManager.white),
                ),
                2.hBox,
                TextWidget(
                  percent.isEmpty ? 'Sending' : 'Sending $percent%',
                  maxLines: 1,
                  style: context.bodySmall
                      .size(9)
                      .w700
                      .colorExt(const Color(0xFFFFD54A)),
                ),
              ],
            ),
          ),
          Icon(
            Icons.monetization_on_rounded,
            color: const Color(0xFFFFD34E),
            size: 16.sp,
          ),
          4.wBox,
          TextWidget(
            coins,
            style: context.bodySmall
                .size(11)
                .w900
                .colorExt(ColorManager.white),
          ),
        ],
      ),
    );
  }
}


class _RewardTab extends StatefulWidget {
  final Map<String, dynamic>? level;

  const _RewardTab({required this.level});

  @override
  State<_RewardTab> createState() => _RewardTabState();
}

class _RewardTabState extends State<_RewardTab> {
  int _groupIndex = 0;

  static const List<String> _groups = ['top1', 'top3', 'top2', 'in_room'];
  static const List<String> _labels = ['TOP1', 'TOP3', 'TOP2', 'IN ROOM'];

  List<Map<String, dynamic>> _itemsFor(String group) {
    final rewards = widget.level?['rewards'] ??
        widget.level?['reward_setup'] ??
        widget.level?['reward_groups'] ??
        widget.level?['reward'];
    if (rewards is! Map) return [];
    final raw = rewards[group] ??
        rewards[group.replaceAll('_', '')] ??
        (group == 'in_room' ? rewards['inRoom'] ?? rewards['room'] : null);
    if (raw is! List) return [];
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _itemsFor(_groups[_groupIndex]);
    final isTop1 = _groupIndex == 0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        _TechPanel(
          padding: context.paddingOnly(start: 8, end: 8, top: 34, bottom: 10),
          child: widget.level == null
              ? Padding(
            padding: context.paddingSymmetric(vertical: 20),
            child: Center(
              child: TextWidget(
                StringManager.noDataYet.tr(),
                style: context.bodySmall.colorExt(
                  ColorManager.white.withValues(alpha: .70),
                ),
              ),
            ),
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: List.generate(_groups.length, (i) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _groupIndex = i),
                      child: _RewardGroupTab(
                        title: _labels[i],
                        selected: i == _groupIndex,
                      ),
                    ),
                  );
                }),
              ),
              6.hBox,
              SizedBox(
                height: 124.h,
                child: items.isEmpty
                    ? Center(
                  child: TextWidget(
                    StringManager.noDataYet.tr(),
                    style: context.bodySmall.colorExt(
                      ColorManager.white.withValues(alpha: .7),
                    ),
                  ),
                )
                    : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => 8.wBox,
                  itemBuilder: (context, i) => SizedBox(
                    width: 88.w,
                    child: _RewardCard(
                      item: items[i],
                      featured: isTop1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: MediaQuery.sizeOf(context).width * .25,
          right: MediaQuery.sizeOf(context).width * .25,
          child: const _SectionRibbon(title: 'Reward'),
        ),
      ],
    );
  }
}

class _RewardGroupTab extends StatelessWidget {
  final String title;
  final bool selected;

  const _RewardGroupTab({required this.title, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(
            title,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: context.bodyMedium
                .size(10.5)
                .w900
                .colorExt(ColorManager.white),
          ),
          4.hBox,
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 24.w : 18.w,
            height: 2.4.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              gradient: LinearGradient(
                colors: selected
                    ? const [Color(0xFFFFDF61), Color(0xFF65EDFF)]
                    : const [Color(0xFF54DFFF), Color(0xFF2B68FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (selected
                      ? const Color(0xFFFFD84D)
                      : const Color(0xFF44DFFF))
                      .withValues(alpha: .18),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          if (selected)
            SizedBox(
              width: 12.w,
              height: 5.h,
              child: CustomPaint(
                painter: const _TopIndicatorPainter(),
              ),
            )
          else
            5.hBox,
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool featured;

  const _RewardCard({required this.item, required this.featured});

  bool _isDayAmount(String value) => value.toUpperCase().contains('DAY');

  bool _showCoinIcon(String value) {
    final upper = value.toUpperCase();
    return value.isNotEmpty &&
        !_isDayAmount(value) &&
        !upper.contains('EXP') &&
        !upper.contains('POINT');
  }

  @override
  Widget build(BuildContext context) {
    final image = (item['image'] ??
        item['show_image'] ??
        (item['reference'] is Map ? item['reference']['show_image'] : null) ??
        '')
        .toString();
    final amount = (item['amount'] ??
        item['quantity'] ??
        item['coin'] ??
        item['coins'] ??
        item['exp'] ??
        item['days'] ??
        '')
        .toString();
    final probability =
        item['probability'] ?? item['chance'] ?? item['win_probability'];

    return CustomPaint(
      painter: _RewardCardFramePainter(featured: featured),
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (probability != null)
              Align(
                alignment: Alignment.centerLeft,
                child: _ProbabilityTag(text: '$probability% Possib'),
              )
            else
              SizedBox(height: 18.h),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 2.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: featured
                        ? const [
                      Color(0xFFB12AFF),
                      Color(0xFF8B23F0),
                      Color(0xFF6117D8),
                    ]
                        : const [
                      Color(0xFF1236CE),
                      Color(0xFF0E29A9),
                      Color(0xFF0A1D7C),
                    ],
                  ),
                  border: Border.all(
                    color: featured
                        ? const Color(0xFFFA84FF).withValues(alpha: .85)
                        : const Color(0xFF66E6FF).withValues(alpha: .80),
                    width: .8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (featured
                          ? const Color(0xFFD740FF)
                          : const Color(0xFF2FDFFF))
                          .withValues(alpha: .16),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                  child: image.isEmpty
                      ? Icon(
                    Icons.card_giftcard_rounded,
                    color: featured
                        ? const Color(0xFFFFE867)
                        : const Color(0xFF90F3FF),
                    size: 30.sp,
                  )
                      : ImageViewWidget(
                    url: image,
                    boxFit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (!featured && _isDayAmount(amount))
              Padding(
                padding: EdgeInsets.only(top: 2.h, bottom: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: Icon(
                        Icons.star_rounded,
                        color: const Color(0xFFFFD84D),
                        size: 8.sp,
                      ),
                    ),
                  ),
                ),
              )
            else
              4.hBox,
            Container(
              height: 21.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: featured
                    ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFF63F4),
                    Color(0xFFD72BED),
                    Color(0xFF9F27D4),
                  ],
                )
                    : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3AE1FF),
                    Color(0xFF1B7DFF),
                    Color(0xFF1747DC),
                  ],
                ),
                borderRadius: BorderRadius.circular(3.r),
                border: Border.all(
                  color: ColorManager.white.withValues(alpha: .28),
                  width: .7,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showCoinIcon(amount)) ...[
                    Icon(
                      Icons.monetization_on_rounded,
                      color: const Color(0xFFFFD84D),
                      size: 11.sp,
                    ),
                    2.wBox,
                  ],
                  Flexible(
                    child: TextWidget(
                      _isDayAmount(amount) ? 'X $amount' : amount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodySmall
                          .size(9.5)
                          .w900
                          .colorExt(ColorManager.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProbabilityTag extends StatelessWidget {
  final String text;

  const _ProbabilityTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _ProbabilityTagPainter(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.5.h),
        constraints: BoxConstraints(minWidth: 52.w),
        child: TextWidget(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.bodySmall
              .size(8.5)
              .w900
              .colorExt(ColorManager.white),
        ),
      ),
    );
  }
}

/// Ported from the reference app's `_RibbonPainter`.
class _RibbonPainter extends CustomPainter {
  const _RibbonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(10, 2)
      ..lineTo(size.width - 10, 2)
      ..lineTo(size.width - 2, 11)
      ..lineTo(size.width - 12, size.height - 5)
      ..lineTo(size.width * .65, size.height - 5)
      ..lineTo(size.width * .60, size.height - 1)
      ..lineTo(size.width * .40, size.height - 1)
      ..lineTo(size.width * .35, size.height - 5)
      ..lineTo(12, size.height - 5)
      ..lineTo(2, 11)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF245DE0), Color(0xFF123BA4), Color(0xFF0A236A)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFF55F4FF), Color(0xFF3D8CFF), Color(0xFFFFD84D)]).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TechPanelPainter extends CustomPainter {
  const _TechPanelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const cut = 14.0;
    final path = Path()
      ..moveTo(cut, 0)
      ..lineTo(w - cut, 0)
      ..lineTo(w, cut)
      ..lineTo(w, h - cut)
      ..lineTo(w - cut, h)
      ..lineTo(cut, h)
      ..lineTo(0, h - cut)
      ..lineTo(0, cut)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A53DF),
            Color(0xFF173BB4),
            Color(0xFF1732A1),
            Color(0xFF2027A0),
            Color(0xFF15206D),
          ],
          stops: [.0, .26, .58, .82, 1.0],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * .66, 0)
        ..lineTo(w, 0)
        ..lineTo(w, h * .46)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x553A6BFF), Color(0x00000000)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(w * .34, 0)
        ..lineTo(0, h * .55)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x2225C7FF), Color(0x00000000)],
        ).createShader(Offset.zero & size),
    );

    _drawHatch(canvas, path, size);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(0xFF0A2C86),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0xFF63E7FF),
    );

    final gold = Paint()..color = const Color(0xFFFFD548);
    canvas.drawPath(
      Path()
        ..moveTo(w - cut, 0)
        ..lineTo(w, cut)
        ..lineTo(w - cut, cut)
        ..close(),
      gold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h - cut)
        ..lineTo(cut, h)
        ..lineTo(cut, h - cut)
        ..close(),
      gold,
    );

    _drawCornerBrackets(canvas, size, len: 12, inset: 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _drawHatch(Canvas canvas, Path clipPath, Size size) {
  canvas.save();
  canvas.clipPath(clipPath);
  final paint = Paint()
    ..color = Colors.white.withValues(alpha: 0.05)
    ..strokeWidth = 1;
  const gap = 10.0;
  for (double x = -size.height; x < size.width; x += gap) {
    canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
  }
  canvas.restore();
}

void _drawCornerBrackets(Canvas canvas, Size size,
    {double len = 9, double inset = 3}) {
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.3
    ..color = const Color(0xFFBFF3FF).withValues(alpha: 0.90);
  canvas.drawPath(
    Path()
      ..moveTo(inset, inset + len)
      ..lineTo(inset, inset)
      ..lineTo(inset + len, inset),
    paint,
  );
  canvas.drawPath(
    Path()
      ..moveTo(size.width - inset - len, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, inset + len),
    paint,
  );
  canvas.drawPath(
    Path()
      ..moveTo(inset, size.height - inset - len)
      ..lineTo(inset, size.height - inset)
      ..lineTo(inset + len, size.height - inset),
    paint,
  );
  canvas.drawPath(
    Path()
      ..moveTo(size.width - inset - len, size.height - inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(size.width - inset, size.height - inset - len),
    paint,
  );
}


class _RewardCardFramePainter extends CustomPainter {
  const _RewardCardFramePainter({this.featured = false});

  final bool featured;

  @override
  void paint(Canvas canvas, Size size) {
    const cut = 6.0;
    final path = Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, cut)
      ..lineTo(size.width, size.height - 4)
      ..lineTo(size.width - 4, size.height)
      ..lineTo(4, size.height)
      ..lineTo(0, size.height - 4)
      ..lineTo(0, cut)
      ..close();

    final outerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = (featured
          ? const Color(0xFFFF63FF)
          : const Color(0xFF40E7FF))
          .withValues(alpha: .18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, outerGlow);

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: featured
              ? const [
            Color(0xFFCB37FF),
            Color(0xFF9C28F2),
            Color(0xFF5A1CCA),
            Color(0xFF37138C),
          ]
              : const [
            Color(0xFF1750E5),
            Color(0xFF1438BC),
            Color(0xFF0F2D8F),
            Color(0xFF0A1C5A),
          ],
        ).createShader(Offset.zero & size),
    );
    _drawHatch(canvas, path, size);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = featured
            ? const Color(0xFFFF87FF)
            : const Color(0xFF7AEDFF),
    );

    final inner = Path()
      ..moveTo(cut + 3, 3)
      ..lineTo(size.width - cut - 3, 3)
      ..lineTo(size.width - 3, cut + 3)
      ..lineTo(size.width - 3, size.height - 7)
      ..lineTo(size.width - 7, size.height - 3)
      ..lineTo(7, size.height - 3)
      ..lineTo(3, size.height - 7)
      ..lineTo(3, cut + 3)
      ..close();

    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..color = ColorManager.white.withValues(alpha: .38),
    );

    canvas.drawPath(
      Path()
        ..moveTo(7, 7)
        ..lineTo(17, 7)
        ..moveTo(10, 4)
        ..lineTo(20, 4),
      Paint()
        ..color = const Color(0xFF55E8FF)
        ..strokeWidth = 1.2,
    );

    _drawCornerBrackets(canvas, size, len: 5.5, inset: 2.2);
  }

  @override
  bool shouldRepaint(covariant _RewardCardFramePainter oldDelegate) =>
      oldDelegate.featured != featured;
}

class _ProbabilityTagPainter extends CustomPainter {
  const _ProbabilityTagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - 8, 0)
      ..lineTo(size.width, size.height * .22)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF7A1D), Color(0xFFFFB13A)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9
        ..color = const Color(0xFFFFD38B),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopIndicatorPainter extends CustomPainter {
  const _TopIndicatorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFED79), Color(0xFF6BEFFF)],
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * .4, 0)
      ..lineTo(size.width * .5, size.height)
      ..lineTo(size.width * .6, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
