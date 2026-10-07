import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_state.dart';
import 'package:general/src/features/profile/data/model/top.dart';
import 'package:general/src/features/room/room.dart';

import 'room_support_realtime_controller.dart';

/// Small carousel entry icon shown in the room's top icon strip. Unlike the
/// plain static asset icon it replaces, this one polls the room's actual
/// current level + progress toward the next level's room-coin target so the
/// slide always reflects the real running week, matching how `RocketCarouselIcon`
/// shows real content instead of a placeholder. Also listens to
/// [RoomSupportRealtimeController] for instant updates instead of waiting
/// up to 20s for the next poll.
class RoomSupportCarouselIcon extends StatefulWidget {
  const RoomSupportCarouselIcon({super.key});

  @override
  State<RoomSupportCarouselIcon> createState() =>
      _RoomSupportCarouselIconState();
}

class _RoomSupportCarouselIconState extends State<RoomSupportCarouselIcon> {
  Timer? _poll;
  int _level = 0;
  double _percent = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
    _poll = Timer.periodic(const Duration(seconds: 20), (_) => _fetch());
    RoomSupportRealtimeController.instance.updateTick.addListener(_fetch);
  }

  @override
  void dispose() {
    _poll?.cancel();
    RoomSupportRealtimeController.instance.updateTick.removeListener(_fetch);
    super.dispose();
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Future<void> _fetch() async {
    final livestreamId = RoomData.instance.room.id?.toString() ?? '';
    if (livestreamId.isEmpty) return;
    final ownerId = RoomData.instance.room.ownerId?.toString() ?? '';
    try {
      final res = await di<DioFactory>().get(
        EndPoints.roomSupportInfo(livestreamId, ownerId: ownerId),
      );
      final raw = res.data;
      final data = raw is Map
          ? Map<String, dynamic>.from(raw['data'] ?? raw)
          : <String, dynamic>{};
      final current = data['current'] is Map
          ? Map<String, dynamic>.from(data['current'])
          : <String, dynamic>{};
      if (!mounted) return;

      final levelRaw = current['current_level'];
      final level = levelRaw is Map
          ? _asInt(levelRaw['level_no'])
          : _asInt(levelRaw);
      final roomCoins = _asInt(current['room_coins']);
      // Same client-side formula as `_RoomSupportTabState._targetLevels`:
      // coin target for level N is N * 1,000,000.
      final nextTarget = (level + 1) * 1000000;
      final percent =
          nextTarget > 0 ? (roomCoins / nextTarget * 100) : 0.0;

      setState(() {
        _level = level;
        _percent = percent.clamp(0, 100).toDouble();
      });
    } catch (_) {
      // Silent -- passive background icon, no toast/log spam per failed poll.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Background removed, on request, matching the rocket carousel icon's
    // own background removal -- now just the icon/level badge + progress
    // bar, no gradient card behind it.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  AssetsManager.roomSupportIcon,
                  fit: BoxFit.contain,
                ),
                if (_level > 0)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC24B),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: TextWidget(
                        'Lv.$_level',
                        style: context.bodySmall.size(9).w800
                            .colorExt(const Color(0xFF6B4E00)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          2.hBox,
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: (_percent / 100).clamp(0, 1),
              minHeight: 3.h,
              backgroundColor: ColorManager.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC24B)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Entry point -- opens the room-support bottom sheet with a fresh
/// [GetSupporterBloc] already fetching the room owner's ranking, same
/// pattern the "Room Support" carousel slide used before this became a
/// dedicated sheet instead of a full-screen push.
Future<void> showRoomSupportBottomSheet(BuildContext context) async {
  final ownerId = RoomData.instance.room.ownerId?.toString() ?? '';
  final supporterBloc = di<GetSupporterBloc>()
    ..add(GetUserSupporterEvent(userId: ownerId));

  await bottomDailog(
    context: context,
    height: MediaQuery.sizeOf(context).height * 0.68,
    widget: RoomSupportBottomSheet(supporterBloc: supporterBloc),
  );
}

class RoomSupportBottomSheet extends StatefulWidget {
  final GetSupporterBloc supporterBloc;

  const RoomSupportBottomSheet({required this.supporterBloc, super.key});

  @override
  State<RoomSupportBottomSheet> createState() =>
      _RoomSupportBottomSheetState();
}

class _RoomSupportBottomSheetState extends State<RoomSupportBottomSheet> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Full-height base -- covers the ENTIRE sheet from top to bottom, no
      // matter what. Every earlier version of this only painted the teal
      // behind a specific top/height window, and any mismatch between that
      // window and where the SVGA/content actually landed left a sliver
      // showing the real room screen behind the sheet. A full-height base
      // makes that class of gap impossible: whatever isn't covered by the
      // SVGA on top of it is already this same colour.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF007F73),
            Color(0xFF0B4C63),
            Color(0xFF083247),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative arch header, shown at its own natural width-fit size
          // (not stretched/cropped) and anchored to the very top. The SVGA
          // art has an opaque maroon backdrop + a black "night window" baked
          // in (not transparent) -- a ShaderMask fades its bottom edge to
          // transparent so it blends into the base colour above instead of
          // ending in a hard cut.
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            height: 200.h,
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorManager.white,
                    ColorManager.white,
                    ColorManager.transparent,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: ShowSVGA(
                  svgaAssetPath: AssetsManager.bgMine,
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          // "Room Support" title art, centered on the SVGA header box.
          Positioned(
            top: 45,
            left: 0,
            right: 0,
            height: 30.h,
            child: IgnorePointer(
              child: Center(
                child: Image.asset(
                  AssetsManager.roomSupportTextImage,
                  height: 60.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                75.hBox,

                12.hBox,
                _SegmentedTabs(
                  index: _tabIndex,
                  onChanged: (i) => setState(() => _tabIndex = i),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      _RoomSupportTab(),
                      _RankingTab(supporterBloc: widget.supporterBloc),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.paddingSymmetric(horizontal: 16),
      padding: context.paddingAll(4),
      decoration: BoxDecoration(
        color: ColorManager.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          _tabButton(context, 0, StringManager.roomSupport.tr()),
          _tabButton(context, 1, StringManager.ranking.tr()),
        ],
      ),
    );
  }

  Widget _tabButton(BuildContext context, int i, String label) {
    final selected = index == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: context.paddingSymmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? ColorManager.white
                : ColorManager.transparent,
            borderRadius: BorderRadius.circular(26.r),
          ),
          alignment: Alignment.center,
          child: TextWidget(
            label,
            style: context.bodyMedium.w600.size(13).colorExt(
                  selected ? const Color(0xFF0B4C63) : ColorManager.white,
                ),
          ),
        ),
      ),
    );
  }
}

class _RoomSupportTab extends StatefulWidget {
  @override
  State<_RoomSupportTab> createState() => _RoomSupportTabState();
}

class _RoomSupportTabState extends State<_RoomSupportTab> {
  // Ported from the reference LinLive app's RoomSupportController
  // (AndroidStudioProjects/linlive/lib/app/modules/livestream/controllers/
  // room_support_controller.dart) -- same field-name fallbacks, same
  // client-side-computed Target & Reward table, same fallback rules text.
  static const int _maxPartners = 10;
  static const _fallbackRules = [
    'Weekly Room Visitors and Weekly Room Coins are counted from Monday 00:00 to Sunday 23:59 (UTC +5:30).',
    'Reaching a Room Level requires meeting both the Room Visitors and Room Coins targets at the same time.',
    'Room Owners must add Room Partners from Monday 00:00 to Tuesday 24:00 (UTC +5:30); otherwise the reward expires.',
    'Rewards are calculated and sent every Monday.',
    'Each user can receive only 1 reward per week, based on the highest target reached as Owner or Partner.',
    'Cheating and violations are prohibited. Confirmed violations cancel all rewards.',
    'This activity is independent of Google and Apple Inc.',
  ];

  Timer? _ticker;
  int _countdownSeconds = 0;
  bool _loading = true;
  List<String> _rules = [];
  List<Map<String, dynamic>> _partners = [];
  bool _canManagePartners = false;
  bool _partnerWindowOpen = true;
  String _partnerWindowMessage = '';
  int _currentLevel = 0;
  int _currentVisitors = 0;
  int _currentRoomCoins = 0;
  int _totalReward = 0;

  // Backend-supplied levels table (replaces the old client-side-computed
  // formula, on request -- the backend now actually sends this).
  List<Map<String, dynamic>> _levels = [];
  double _roomPercent = 0;
  double _totalPercent = 0;
  String _nextLevelTitle = '';

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_countdownSeconds > 0) setState(() => _countdownSeconds--);
    });
    _fetchRoomSupportInfo();
    // Instant refresh on the backend's `room_support_updated` broadcast
    // (gift/level change) instead of only reflecting it on next sheet open.
    RoomSupportRealtimeController.instance.updateTick
        .addListener(_fetchRoomSupportInfo);
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }

  Future<void> _fetchRoomSupportInfo() async {
    final livestreamId = RoomData.instance.room.id?.toString() ?? '';
    final ownerIdParam = RoomData.instance.room.ownerId?.toString() ?? '';
    Methods.printLog(
        '🎯 [RoomSupport] fetching info for livestreamId="$livestreamId" ownerId="$ownerIdParam"');
    if (livestreamId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final url =
          EndPoints.roomSupportInfo(livestreamId, ownerId: ownerIdParam);
      Methods.printLog('🎯 [RoomSupport] GET $url');
      final response = await di<DioFactory>().get(url);
      Methods.printLog('🎯 [RoomSupport] response: ${response.data}');
      final data = response.data is Map
          ? Map<String, dynamic>.from(
              response.data['data'] ?? response.data)
          : <String, dynamic>{};

      final week = data['week'] is Map
          ? Map<String, dynamic>.from(data['week'])
          : <String, dynamic>{};
      final current = data['current'] is Map
          ? Map<String, dynamic>.from(data['current'])
          : <String, dynamic>{};
      final rulesRaw = data['rules'];
      final partnersRaw = data['partners'] ?? [];
      final levelsRaw = data['levels'];
      final progress = current['progress'] is Map
          ? Map<String, dynamic>.from(current['progress'])
          : <String, dynamic>{};
      final rewardPreview = current['reward_preview'] is Map
          ? Map<String, dynamic>.from(current['reward_preview'])
          : <String, dynamic>{};
      final nextLevel = current['next_level'] is Map
          ? Map<String, dynamic>.from(current['next_level'])
          : <String, dynamic>{};
      final partnerWindow = week['partner_add_window'] is Map
          ? Map<String, dynamic>.from(week['partner_add_window'])
          : <String, dynamic>{};

      final myId = MyDataModel.getInstance().id;
      final roomOwnerId = RoomData.instance.room.ownerId;
      final canManage = _asBool(current['can_manage_partners']) ||
          _asBool(current['is_owner']) ||
          _asBool(current['is_admin']) ||
          _asBool(current['is_guardian']) ||
          _asBool(current['room_admin']) ||
          _asBool(data['can_manage_partners']) ||
          (myId != null && roomOwnerId != null && myId == roomOwnerId) ||
          (myId != null &&
              _asInt(current['owner_id'] ?? current['host_id']) == myId);

      if (!mounted) return;
      setState(() {
        _countdownSeconds = _asInt(week['countdown_seconds']);
        _partnerWindowOpen =
            week.containsKey('can_add_partner') ? _asBool(week['can_add_partner']) : true;
        _partnerWindowMessage = (partnerWindow['message'] ?? '').toString();
        _canManagePartners = canManage;
        _currentLevel = _asInt(current['current_level'] ??
            (current['current_level'] is Map
                ? current['current_level']['level_no']
                : null));
        _currentVisitors =
            _asInt(current['room_visitors'] ?? current['visitors']);
        _currentRoomCoins = _asInt(current['room_coins']);
        _totalReward = _asInt(rewardPreview['total_reward'] ??
            rewardPreview['owner_reward']);
        _roomPercent = (progress['room_percent'] as num? ?? 0).toDouble();
        _totalPercent = (progress['total_percent'] as num? ?? 0).toDouble();
        _nextLevelTitle = (nextLevel['title'] ?? '').toString();
        _rules = (rulesRaw is List && rulesRaw.isNotEmpty)
            ? rulesRaw
                .map((e) => e is Map
                    ? (e['title'] ?? e['text'] ?? e['rule'] ?? '').toString()
                    : e.toString())
                .where((s) => s.isNotEmpty)
                .toList()
            : _fallbackRules;
        _partners = (partnersRaw is List)
            ? partnersRaw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : [];
        // Backend-supplied levels table (was a fixed client-side formula,
        // on request -- now reads the real per-room targets/rewards).
        _levels = (levelsRaw is List && levelsRaw.isNotEmpty)
            ? levelsRaw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : _levels;
        _loading = false;
      });
    } catch (e) {
      Methods.printLog('⚠️ [RoomSupport] failed to load room-support info: $e');
      if (e is DioException) {
        Methods.printLog(
            '⚠️ [RoomSupport] status=${e.response?.statusCode} body=${e.response?.data}');
      }
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic>? _partnerUser(Map<String, dynamic> p) {
    final u = p['partner'] ?? p['user'] ?? p['partner_user'] ?? p['profile'];
    return u is Map ? Map<String, dynamic>.from(u) : null;
  }

  String _partnerId(Map<String, dynamic> p) {
    final u = _partnerUser(p);
    return (p['partner_id'] ??
            p['user_id'] ??
            u?['id'] ??
            u?['user_id'] ??
            u?['unique_id'] ??
            u?['uid'])
        ?.toString() ??
        '';
  }

  String? _pivotId(Map<String, dynamic> p) => (p['support_partner_id'] ??
          p['room_support_partner_id'] ??
          p['pivot_id'])
      ?.toString();

  Future<void> _addPartner(int partnerId) async {
    final livestreamId = RoomData.instance.room.id;
    final body = {
      'action': 'add_partner',
      'livestream_id': livestreamId,
      'partner_id': partnerId,
    };
    Methods.printLog('🎯 [RoomSupport] POST ${EndPoints.roomSupportAction} $body');
    try {
      final response =
          await di<DioFactory>().post(EndPoints.roomSupportAction, data: body);
      Methods.printLog('🎯 [RoomSupport] add_partner response: ${response.data}');
      final resData = response.data is Map ? response.data : {};
      final ok = resData['success'] != false && resData['status'] != false;
      final ctx = context;
      if (ctx.mounted) {
        Methods.showToast(
          ctx,
          message: (resData['message'] ??
                  (ok ? StringManager.success.tr() : StringManager.someThingWentWrong.tr()))
              .toString(),
          isError: !ok,
        );
      }
      if (ok) _fetchRoomSupportInfo();
    } catch (e) {
      Methods.printLog('⚠️ [RoomSupport] add_partner failed: $e');
      String message = StringManager.someThingWentWrong.tr();
      if (e is DioException) {
        Methods.printLog(
            '⚠️ [RoomSupport] status=${e.response?.statusCode} body=${e.response?.data}');
        final body = e.response?.data;
        if (body is Map) {
          message = (body['message'] ??
                  (body['data'] is Map ? body['data']['message'] : null) ??
                  body['error'] ??
                  message)
              .toString();
        }
      }
      final ctx = context;
      if (ctx.mounted) {
        Methods.showToast(ctx, message: message, isError: true);
      }
    }
  }

  Future<void> _removePartner(Map<String, dynamic> partner) async {
    final livestreamId = RoomData.instance.room.id;
    final pivotId = _pivotId(partner);
    final body = pivotId != null
        ? {
            'action': 'remove_partner',
            'livestream_id': livestreamId,
            'support_partner_id': pivotId,
          }
        : {
            'action': 'remove_partner',
            'livestream_id': livestreamId,
            'owner_id': RoomData.instance.room.ownerId,
            'partner_id': _partnerId(partner),
          };
    Methods.printLog('🎯 [RoomSupport] POST ${EndPoints.roomSupportAction} $body');
    try {
      final response =
          await di<DioFactory>().post(EndPoints.roomSupportAction, data: body);
      Methods.printLog('🎯 [RoomSupport] remove_partner response: ${response.data}');
      final resData = response.data is Map ? response.data : {};
      final ok = resData['success'] != false && resData['status'] != false;
      final ctx = context;
      if (ctx.mounted) {
        Methods.showToast(
          ctx,
          message: (resData['message'] ??
                  (ok ? StringManager.success.tr() : StringManager.someThingWentWrong.tr()))
              .toString(),
          isError: !ok,
        );
      }
      if (ok) _fetchRoomSupportInfo();
    } catch (e) {
      Methods.printLog('⚠️ [RoomSupport] remove_partner failed: $e');
      final ctx = context;
      if (ctx.mounted) {
        Methods.showToast(ctx,
            message: StringManager.someThingWentWrong.tr(), isError: true);
      }
    }
  }

  bool get _canAddPartner =>
      _canManagePartners && _partnerWindowOpen && _partners.length < _maxPartners;

  /// Add-partner button is tappable even when the window is closed (on
  /// request, per the backend guide) so the owner can tap it and actually
  /// see why -- the window message, rather than it just doing nothing.
  void _onAddPartnerTapped() {
    if (!_canManagePartners || _partners.length >= _maxPartners) return;
    if (!_partnerWindowOpen) {
      if (_partnerWindowMessage.isNotEmpty) {
        Methods.showToast(context, message: _partnerWindowMessage);
      }
      return;
    }
    _openAddPartnerDialog();
  }

  Future<void> _openAddPartnerDialog() async {
    if (!_canAddPartner) return;
    final controller = TextEditingController();
    final id = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0B4C63),
        title: TextWidget(
          StringManager.addPartner.tr(),
          style: context.bodyMedium.w700.colorExt(ColorManager.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: context.bodyMedium.colorExt(ColorManager.white),
          decoration: InputDecoration(
            hintText: StringManager.partnerId.tr(),
            hintStyle: context.bodySmall
                .colorExt(ColorManager.white.withValues(alpha: 0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: ColorManager.white.withValues(alpha: 0.3)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: TextWidget(StringManager.cancel.tr(),
                style: context.bodySmall.colorExt(ColorManager.white)),
          ),
          TextButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              Navigator.pop(dialogContext, parsed);
            },
            child: TextWidget(StringManager.addPartner.tr(),
                style: context.bodySmall.w700
                    .colorExt(const Color(0xFFFFC24B))),
          ),
        ],
      ),
    );
    if (id != null) _addPartner(id);
  }

  Future<void> _confirmRemovePartner(Map<String, dynamic> partner, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0B4C63),
        title: TextWidget(StringManager.removePartner.tr(),
            style: context.bodyMedium.w700.colorExt(ColorManager.white)),
        content: TextWidget(
          '${StringManager.removePartner.tr()} $name?',
          style: context.bodySmall.colorExt(ColorManager.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: TextWidget(StringManager.cancel.tr(),
                style: context.bodySmall.colorExt(ColorManager.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: TextWidget(StringManager.removePartner.tr(),
                style: context.bodySmall.w700.colorExt(ColorManager.redIcons)),
          ),
        ],
      ),
    );
    if (confirmed == true) _removePartner(partner);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    RoomSupportRealtimeController.instance.updateTick
        .removeListener(_fetchRoomSupportInfo);
    super.dispose();
  }

  String get _countdownText {
    final d = Duration(seconds: _countdownSeconds);
    return '${d.inDays}${StringManager.day.tr()} '
        '${(d.inHours % 24).toString().padLeft(2, '0')}:'
        '${(d.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  int _asIntKey(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      if (m[k] != null) return _asInt(m[k]);
    }
    return 0;
  }

  /// Levels table. Prefers the real per-room levels the backend now sends
  /// (`data.levels[]`: room_target/total_target/owner_reward/partner_reward/
  /// partner_limit) -- falls back to the old client-side-computed formula
  /// only when the backend hasn't returned any (e.g. an older server
  /// response), so this never regresses to a blank table.
  List<Map<String, int>> get _targetLevels {
    if (_levels.isNotEmpty) {
      return _levels.map((row) {
        return {
          'level': _asIntKey(row, ['level_no', 'level']),
          'room_visitors': _asIntKey(row, ['room_target', 'room_visitors']),
          'room_coin_target':
              _asIntKey(row, ['total_target', 'room_coin_target']),
          'total_reward': _asIntKey(
              row, ['owner_reward', 'total_reward']) +
              _asIntKey(row, ['partner_reward', 'partner_pool']),
          'owner_reward': _asIntKey(row, ['owner_reward']),
          'partner_pool': _asIntKey(row, ['partner_reward', 'partner_pool']),
          'number_of_partners':
              _asIntKey(row, ['partner_limit', 'number_of_partners']),
          'reward_per_partner': _asIntKey(row, ['reward_per_partner']),
        };
      }).toList();
    }
    // Ported as-is from the reference app's formula (fallback only):
    // visitors=lv*20, coin target=lv*1,000,000, total reward=lv*150,000
    // (15%), owner reward=lv*100,000 (10%), partner pool=lv*50,000 (5%),
    // partners=lv, reward per partner=50,000 flat.
    return List.generate(10, (i) {
      final level = i + 1;
      return {
        'level': level,
        'room_visitors': level * 20,
        'room_coin_target': level * 1000000,
        'total_reward': level * 150000,
        'owner_reward': level * 100000,
        'partner_pool': level * 50000,
        'number_of_partners': level,
        'reward_per_partner': 50000,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.paddingSymmetric(horizontal: 20).copyWith(bottom: 20),
      child: Column(
        children: [
          14.hBox,
          _MyRoomCard(
            level: _currentLevel,
            visitors: _currentVisitors,
            roomCoins: _currentRoomCoins,
            rewardCoins: _totalReward,
          ),
          16.hBox,
          _RoomSupportProgressCard(
            roomPercent: _roomPercent,
            totalPercent: _totalPercent,
            nextLevelTitle: _nextLevelTitle,
          ),
          16.hBox,
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0B4C63),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: context.paddingSymmetric(vertical: 10, horizontal: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE9A8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_giftcard,
                          color: const Color(0xFF6B4E00), size: 16.sp),
                      6.wBox,
                      Flexible(
                        child: TextWidget(
                          '${StringManager.rewardSendTime.tr()}: ',
                          style: context.bodySmall.w600
                              .colorExt(const Color(0xFF6B4E00)),
                        ),
                      ),
                      TextWidget(
                        _countdownText,
                        style: context.bodySmall.w700
                            .colorExt(const Color(0xFFE8501C)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: context.paddingAll(14),
                  child: TextWidget(
                    StringManager.roomSupportInfo.tr(),
                    textAlign: TextAlign.center,
                    style: context.bodySmall.colorExt(ColorManager.white),
                  ),
                ),
              ],
            ),
          ),
          16.hBox,
          _PartnersCard(
            partners: _partners,
            canManage: _canManagePartners,
            canAdd: _canAddPartner,
            partnerUserOf: _partnerUser,
            onAdd: _onAddPartnerTapped,
            onRemove: _confirmRemovePartner,
          ),
          16.hBox,
          if (_loading)
            Padding(
              padding: context.paddingSymmetric(vertical: 20),
              // child:  GradientLoader(size: 26),
            )
          else ...[
            _TargetRewardCard(levels: _targetLevels),
            14.hBox,
          ],
          if (_rules.isNotEmpty) ...[
            14.hBox,
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0B4C63),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: context.paddingSymmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE9A8),
                    ),
                    child: TextWidget(
                      StringManager.rules.tr(),
                      textAlign: TextAlign.center,
                      style: context.bodyMedium.w700
                          .colorExt(const Color(0xFF6B4E00)),
                    ),
                  ),
                  Padding(
                    padding: context.paddingAll(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < _rules.length; i++)
                          Padding(
                            padding: context.paddingOnly(
                                bottom: i == _rules.length - 1 ? 0 : 12),
                            child: TextWidget(
                              '${i + 1}. ${_rules[i]}',
                              style: context.bodySmall
                                  .colorExt(ColorManager.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          10.hBox,
        ],
      ),
    );
  }
}

/// "Target & Reward" table -- client-side computed (levels 1-10), ported
/// from the reference app's fixed formula. Not sent by the backend.
class _TargetRewardCard extends StatelessWidget {
  final List<Map<String, int>> levels;

  const _TargetRewardCard({required this.levels});

  @override
  Widget build(BuildContext context) {
    final grandTotal = <String, int>{
      for (final key in [
        'room_visitors',
        'room_coin_target',
        'total_reward',
        'owner_reward',
        'partner_pool',
        'number_of_partners',
      ])
        key: levels.fold(0, (sum, row) => sum + (row[key] ?? 0)),
    };

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0B4C63),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: context.paddingSymmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE9A8),
            ),
            child: TextWidget(
              '${StringManager.targetAndReward.tr()} (Lv 1-10)',
              textAlign: TextAlign.center,
              style: context.bodyMedium.w700.colorExt(const Color(0xFF6B4E00)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: context.paddingSymmetric(vertical: 10, horizontal: 10),
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                TableRow(children: [
                  _cell(context, 'Lv', header: true),
                  _cell(context, StringManager.roomVisitors.tr(), header: true),
                  _cell(context, 'Room Coin Target', header: true),
                  _cell(context, 'Total Reward', header: true),
                  _cell(context, 'Owner Reward', header: true),
                  _cell(context, 'Partner Pool', header: true),
                  _cell(context, 'Partners', header: true),
                ]),
                for (final row in levels)
                  TableRow(children: [
                    _cell(context, '${row['level']}'),
                    _cell(context, '${row['room_visitors']}'),
                    _cell(context, '${row['room_coin_target']}'),
                    _cell(context, '${row['total_reward']}'),
                    _cell(context, '${row['owner_reward']}'),
                    _cell(context, '${row['partner_pool']}'),
                    _cell(context, '${row['number_of_partners']}'),
                  ]),
                TableRow(
                  decoration: BoxDecoration(
                    color: ColorManager.white.withValues(alpha: 0.08),
                  ),
                  children: [
                    _cell(context, 'Total', header: true),
                    _cell(context, '${grandTotal['room_visitors']}', header: true),
                    _cell(context, '${grandTotal['room_coin_target']}', header: true),
                    _cell(context, '${grandTotal['total_reward']}', header: true),
                    _cell(context, '${grandTotal['owner_reward']}', header: true),
                    _cell(context, '${grandTotal['partner_pool']}', header: true),
                    _cell(context, '${grandTotal['number_of_partners']}', header: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, String text, {bool header = false}) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 10, vertical: 8),
      child: TextWidget(
        text,
        textAlign: TextAlign.center,
        style: header
            ? context.bodySmall.size(11).w600
                .colorExt(ColorManager.white.withValues(alpha: 0.9))
            : context.bodySmall.size(11).colorExt(ColorManager.white),
      ),
    );
  }
}

/// Room Support partners list (add/remove), matching the reference app's
/// flow: owner types a raw numeric user id to add, taps a remove badge
/// (with confirm dialog) to remove.
class _PartnersCard extends StatelessWidget {
  final List<Map<String, dynamic>> partners;
  final bool canManage;
  final bool canAdd;
  final Map<String, dynamic>? Function(Map<String, dynamic>) partnerUserOf;
  final VoidCallback onAdd;
  final void Function(Map<String, dynamic> partner, String name) onRemove;

  const _PartnersCard({
    required this.partners,
    required this.canManage,
    required this.canAdd,
    required this.partnerUserOf,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF0B4C63)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: context.paddingSymmetric(vertical: 10),
            decoration: const BoxDecoration(color: Color(0xFFFFE9A8)),
            child: TextWidget(
              '${StringManager.managePartners.tr()} (${partners.length}/10)',
              textAlign: TextAlign.center,
              style: context.bodyMedium.w700.colorExt(const Color(0xFF6B4E00)),
            ),
          ),
          Padding(
            padding: context.paddingAll(14),
            child: Column(
              children: [
                if (partners.isEmpty)
                  TextWidget(
                    StringManager.noDataYet.tr(),
                    style: context.bodySmall
                        .colorExt(ColorManager.white.withValues(alpha: 0.7)),
                  )
                else
                  for (final p in partners) _partnerRow(context, p),
                if (canManage) ...[
                  10.hBox,
                  GestureDetector(
                    // Still tappable when the window is closed (unlike the
                    // old `canAdd ? onAdd : null`) so the owner sees WHY,
                    // via the backend's partner_add_window message, instead
                    // of the button silently doing nothing, on request.
                    onTap: onAdd,
                    child: Opacity(
                      opacity: canAdd ? 1 : 0.4,
                      child: Container(
                        width: double.infinity,
                        padding: context.paddingSymmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC24B),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_alt_1,
                                color: const Color(0xFF6B4E00), size: 16.sp),
                            6.wBox,
                            TextWidget(
                              StringManager.addPartner.tr(),
                              style: context.bodySmall.w700
                                  .colorExt(const Color(0xFF6B4E00)),
                            ),
                          ],
                        ),
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

  Widget _partnerRow(BuildContext context, Map<String, dynamic> p) {
    final u = partnerUserOf(p);
    final name = (u?['name'] ?? u?['username'] ?? '').toString();
    final image =
        (u?['profile_image'] ?? u?['avatar'] ?? u?['image'] ?? '').toString();
    final coins = (p['partner_coins'] ??
            p['support_coins'] ??
            p['weekly_coins'] ??
            p['current_coins'] ??
            p['coins'] ??
            0)
        .toString();
    return Padding(
      padding: context.paddingOnly(bottom: 10),
      child: Row(
        children: [
          UserImage(
            image: image,
            displayName: name,
            imageSize: 34.w,
            uniquId: '${u?['id'] ?? ''}',
          ),
          10.wBox,
          Expanded(
            child: TextWidget(
              name.isEmpty ? '-' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodySmall.colorExt(ColorManager.white),
            ),
          ),
          TextWidget(
            coins,
            style: context.bodySmall.w600.colorExt(const Color(0xFFFFC24B)),
          ),
          if (canManage) ...[
            8.wBox,
            GestureDetector(
              onTap: () => onRemove(p, name.isEmpty ? '-' : name),
              child: Icon(Icons.close, color: ColorManager.redIcons, size: 18.sp),
            ),
          ],
        ],
      ),
    );
  }
}

/// Live progress toward the next level, from the backend's
/// `current.progress.{room_percent,total_percent}` (0.0-100.0) and
/// `current.next_level.title`, per the backend team's integration guide.
class _RoomSupportProgressCard extends StatelessWidget {
  final double roomPercent;
  final double totalPercent;
  final String nextLevelTitle;

  const _RoomSupportProgressCard({
    required this.roomPercent,
    required this.totalPercent,
    required this.nextLevelTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.paddingAll(14),
      decoration: const BoxDecoration(color: Color(0xFF0B4C63)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextWidget(
                StringManager.targetAndReward.tr(),
                style: context.bodySmall.w700.colorExt(ColorManager.white),
              ),
              const Spacer(),
              if (nextLevelTitle.isNotEmpty)
                TextWidget(
                  nextLevelTitle,
                  style: context.bodySmall.w600
                      .colorExt(const Color(0xFFFFC24B)),
                ),
            ],
          ),
          10.hBox,
          _progressRow(context, StringManager.roomCoins.tr(), roomPercent),
          8.hBox,
          _progressRow(context, StringManager.rewardCoins.tr(), totalPercent),
        ],
      ),
    );
  }

  Widget _progressRow(BuildContext context, String label, double percent) {
    final clamped = percent.clamp(0, 100).toDouble();
    return Row(
      children: [
        SizedBox(
          width: 70.w,
          child: TextWidget(
            label,
            style: context.bodySmall
                .size(11)
                .colorExt(ColorManager.white.withValues(alpha: 0.75)),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: clamped / 100,
              minHeight: 10.h,
              backgroundColor: ColorManager.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC24B)),
            ),
          ),
        ),
        8.wBox,
        SizedBox(
          width: 40.w,
          child: TextWidget(
            '${clamped.toStringAsFixed(0)}%',
            textAlign: TextAlign.end,
            style: context.bodySmall.size(11).w600
                .colorExt(ColorManager.white),
          ),
        ),
      ],
    );
  }
}

class _MyRoomCard extends StatelessWidget {
  final int level;
  final int visitors;
  final int roomCoins;
  final int rewardCoins;

  const _MyRoomCard({
    required this.level,
    required this.visitors,
    required this.roomCoins,
    required this.rewardCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0B4C63),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: context.paddingSymmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE9A8),
            ),
            child: TextWidget(
              StringManager.myRoom.tr(),
              textAlign: TextAlign.center,
              style: context.bodyMedium.w700.colorExt(
                const Color(0xFF6B4E00),
              ),
            ),
          ),
          Padding(
            padding: context.paddingSymmetric(horizontal: 10, vertical: 10),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(children: [
                  const SizedBox(),
                  _headCell(context, StringManager.roomLevel.tr()),
                  _headCell(context, StringManager.rewardCoins.tr()),
                  _headCell(context, StringManager.roomVisitors.tr()),
                  _headCell(context, StringManager.roomCoins.tr()),
                ]),
                _dataRow(
                  context,
                  StringManager.thisWeek.tr(),
                  '$level',
                  '$rewardCoins',
                  '$visitors',
                  '$roomCoins',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headCell(BuildContext context, String text) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 6),
      child: TextWidget(
        text,
        textAlign: TextAlign.center,
        style: context.bodySmall.size(11).w600
            .colorExt(ColorManager.white.withValues(alpha: 0.75)),
      ),
    );
  }

  TableRow _dataRow(
    BuildContext context,
    String label,
    String level,
    String rewardCoins,
    String roomVisitors,
    String roomCoins,
  ) {
    return TableRow(children: [
      Padding(
        padding: context.paddingSymmetric(vertical: 8),
        child: TextWidget(
          label,
          style: context.bodySmall.size(11).colorExt(ColorManager.white),
        ),
      ),
      Padding(
        padding: context.paddingSymmetric(vertical: 4, horizontal: 3),
        child: _valuePill(context, level),
      ),
      Padding(
        padding: context.paddingSymmetric(vertical: 4, horizontal: 3),
        child: _valuePill(context, rewardCoins),
      ),
      Padding(
        padding: context.paddingSymmetric(vertical: 4, horizontal: 3),
        child: _valuePill(context, roomVisitors),
      ),
      Padding(
        padding: context.paddingSymmetric(vertical: 4, horizontal: 3),
        child: _valuePill(context, roomCoins),
      ),
    ]);
  }

  Widget _valuePill(BuildContext context, String text) {
    return Container(
      alignment: Alignment.center,
      padding: context.paddingSymmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ColorManager.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextWidget(
        text,
        textAlign: TextAlign.center,
        style: context.bodySmall.size(11).w600.colorExt(ColorManager.white),
      ),
    );
  }
}

class _RankingTab extends StatefulWidget {
  final GetSupporterBloc supporterBloc;

  const _RankingTab({required this.supporterBloc});

  @override
  State<_RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<_RankingTab> {
  // Daily/Weekly/Monthly is a display-only filter for now -- the backend's
  // get-users-support endpoint returns one all-time list, no per-period
  // breakdown, so all three tabs currently show the same ranking data.
  int _period = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSupporterBloc, GetUserSupporterState>(
      bloc: widget.supporterBloc,
      builder: (context, state) {
        final top = state.topSupport?.topUser ?? [];
        final others = state.topSupport?.otherUsers ?? [];

        // Wrapped in its own Expanded -- HandlingDataWidget's empty state
        // (EmptyView) is returned in place of `child` with no size of its
        // own, so without this it inherited whatever tiny constraint the
        // IndexedStack passed down before/between frames and overflowed.
        return Column(
          children: [
            10.hBox,
            _PeriodTabs(
              index: _period,
              onChanged: (i) => setState(() => _period = i),
            ),
            8.hBox,
            Expanded(
              child: HandlingDataWidget(
                reqState: state.requestState,
                title: StringManager.titleEmptySupport.tr(),
                subTitle: StringManager.subTitleEmptySupport.tr(),
                child: ListView(
                  padding: context
                      .paddingSymmetric(horizontal: 14)
                      .copyWith(bottom: 16),
                  children: [
                    for (int i = 0; i < top.length; i++)
                      _RankRow(rank: i + 1, user: top[i]),
                    for (int i = 0; i < others.length; i++)
                      _RankRow(rank: i + 4, user: others[i]),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _PeriodTabs({required this.index, required this.onChanged});

  static const _labels = [
    StringManager.daily,
    StringManager.weekly,
    StringManager.monthly,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_labels.length, (i) {
        final selected = index == i;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: Padding(
            padding: context.paddingSymmetric(vertical: 6, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWidget(
                  _labels[i].tr(),
                  style: (selected
                          ? context.bodyMedium.w700
                          : context.bodyMedium.w400)
                      .colorExt(
                    selected
                        ? ColorManager.white
                        : ColorManager.white.withValues(alpha: 0.55),
                  ),
                ),
                4.hBox,
                Container(
                  width: 22.w,
                  height: 2.h,
                  color: selected
                      ? ColorManager.white
                      : ColorManager.transparent,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Rank 1-3 get a coloured gradient card (gold/silver/bronze); rank 4+ get a
/// plain numbered row -- matching the reference ranking design.
class _RankRow extends StatelessWidget {
  final int rank;
  final Top user;

  const _RankRow({required this.rank, required this.user});

  static const _gradients = {
    1: [Color(0xFFF2B90A), Color(0xFFC9820A)],
    2: [Color(0xFF5B8DEF), Color(0xFF2D5FC7)],
    3: [Color(0xFFE8813A), Color(0xFFC55C1E)],
  };

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[rank];
    return GestureDetector(
      onTap: () {
        if (user.id != null && user.id != 0) {
          Methods().userProfileNavigator(
            context: context,
            userId: '${user.id}',
          );
        }
      },
      child: Container(
        margin: context.paddingOnly(bottom: 10),
        padding: context.paddingSymmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient != null
              ? LinearGradient(colors: gradient)
              : null,
          color: gradient == null
              ? ColorManager.white.withValues(alpha: 0.08)
              : null,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 26.w,
              child: rank <= 3
                  ? Icon(Icons.emoji_events,
                      color: ColorManager.white, size: 20.sp)
                  : TextWidget(
                      '$rank',
                      textAlign: TextAlign.center,
                      style: context.bodyMedium.w600
                          .colorExt(ColorManager.white.withValues(alpha: 0.8)),
                    ),
            ),
            8.wBox,
            UserImage(
              image: user.image ?? '',
              displayName: user.name ?? '',
              imageSize: 40.w,
              uniquId: '${user.id}',
            ),
            10.wBox,
            Expanded(
              child: TextWidget(
                user.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium.w700.colorExt(ColorManager.white),
              ),
            ),
            TextWidget(
              user.total ?? '0',
              style: context.bodySmall.w600.colorExt(
                gradient != null
                    ? ColorManager.white
                    : const Color(0xFFFFC24B),
              ),
            ),
            4.wBox,
            ImageWidget(
              height: 16.h,
              width: 16.w,
              image: AssetsManager.coinsVip,
            ),
          ],
        ),
      ),
    );
  }
}


