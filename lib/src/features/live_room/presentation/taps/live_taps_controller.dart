import 'dart:async';
import 'dart:math';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';

/// TikTok-style tap-hearts (التكبيس) for the live room.
///
/// Design (owner spec 2026-06-11, scale target: hundreds of thousands of taps
/// per minute across all broadcasts):
/// - A tap costs ZERO network: one emoji animates locally, the tap joins a
///   batch.
/// - Every [pulseInterval] while tapping, ONE lossy UTD Stream data packet
///   carries the accumulated delta to everyone in the room — instant shared
///   counter + everyone sees each other's hearts. Lossy = no retransmission,
///   can never queue behind chat/gifts.
/// - Every [apiFlushInterval], the accumulated count goes to the backend
///   (Redis-aggregated, server-side 5-taps/sec credit cap + abuse strikes).
///   The backend broadcasts the OFFICIAL total (rate-limited server-side);
///   clients snap to it, so lost pulses or capped cheaters can't skew the
///   number anyone sees — and the stored per-broadcast total is tamper-proof.
class LiveTapsController {
  LiveTapsController._();
  static final LiveTapsController instance = LiveTapsController._();

  static const Duration pulseInterval = Duration(milliseconds: 300);
  static const Duration apiFlushInterval = Duration(seconds: 2);

  /// Soft cap on hearts animating at once — beyond it taps still COUNT but
  /// render fewer hearts (battery; matches the existing gradual-thinning UX).
  static const int maxConcurrentHearts = 24;

  /// Shared displayed total: official backend total + local optimistic delta.
  final ValueNotifier<int> displayTotal = ValueNotifier<int>(0);

  /// Heart spawn events for the overlay (each event = ONE emoji).
  /// The int is a monotonically increasing id; overlay reads [lastSpawnSeed]
  /// for randomization.
  final ValueNotifier<int> heartSpawns = ValueNotifier<int>(0);

  final Random _rng = Random();
  int lastSpawnSeed = 0;

  int _officialTotal = 0;
  int _optimistic = 0; // local+remote deltas since the last official snap
  int _pendingPulse = 0; // my taps awaiting a lossy pulse
  int _pendingApi = 0; // my taps awaiting the backend flush
  Timer? _pulseTimer;
  Timer? _apiTimer;
  bool _active = false;
  String _roomId = '';

  /// Blocked-until timestamp from the backend abuse guard (epoch ms). While
  /// in the future, taps are swallowed silently (the guard message was
  /// already shown by the API layer).
  int blockedUntilMs = 0;

  void start(String roomId) {
    if (_active && _roomId == roomId) return;
    stop();
    _active = true;
    _roomId = roomId;
    _officialTotal = 0;
    _optimistic = 0;
    _likedSent = false;
    displayTotal.value = 0;
  }

  void stop() {
    _active = false;
    _pulseTimer?.cancel();
    _pulseTimer = null;
    _apiTimer?.cancel();
    _apiTimer = null;
    _pendingPulse = 0;
    _pendingApi = 0;
    _roomId = '';
  }

  // ── Local tap ──

  /// First tap of this session already announced in chat?
  bool _likedSent = false;

  void onLocalTap() {
    if (!_active) return;
    if (DateTime.now().millisecondsSinceEpoch < blockedUntilMs) return;
    _announceFirstLike();
    _spawnHeart();
    _optimistic++;
    _pendingPulse++;
    _pendingApi++;
    displayTotal.value = _officialTotal + _optimistic;
    _pulseTimer ??= Timer.periodic(pulseInterval, (_) => _sendPulse());
    _apiTimer ??= Timer.periodic(apiFlushInterval, (_) => _flushToBackend());
  }

  /// One-time chat line on the viewer's FIRST tap (owner spec 2026-06-12):
  /// "«فلان» أحب هذا البث ❤️" — the `likedLive` sentinel is localized in
  /// LiveMessagesView for everyone; later taps are hearts only.
  void _announceFirstLike() {
    if (_likedSent) return;
    _likedSent = true;
    final me = MyDataModel.getInstance();
    LiveRoomData.instance.chatController?.sendMessage(
      '${me.name ?? ''} likedLive',
      userData: {
        'img': me.profile?.image ?? '',
        'senderId': me.id?.toString() ?? '',
        'senderName': me.name ?? '',
        'type': 'message',
      },
    );
  }

  void _spawnHeart() {
    lastSpawnSeed = _rng.nextInt(1 << 30);
    heartSpawns.value = heartSpawns.value + 1;
  }

  // ── Outgoing ──

  void _sendPulse() {
    if (_pendingPulse <= 0) {
      // Idle: stop the pulse timer until the next tap.
      _pulseTimer?.cancel();
      _pulseTimer = null;
      return;
    }
    final delta = _pendingPulse;
    _pendingPulse = 0;
    final controller = LiveRoomData.instance.liveController;
    if (controller == null) return;
    // Lossy on purpose: a dropped pulse only delays the count until the next
    // official snap — never blocks, never retries. Envelope matches the RTM
    // processor's `{messageContent: {message: ...}}` contract.
    unawaited(controller.roomManager.sendData(
      {
        'messageContent': {
          'message': 'live_tap_pulse',
          'c': delta,
          's': MyDataModel.getInstance().id?.toString() ?? '',
        },
      },
      lossy: true,
    ));
  }

  void _flushToBackend() {
    if (_pendingApi <= 0) {
      _apiTimer?.cancel();
      _apiTimer = null;
      return;
    }
    final count = _pendingApi;
    _pendingApi = 0;
    unawaited(_postTaps(count));
  }

  Future<void> _postTaps(int count) async {
    if (_roomId.isEmpty) return;
    try {
      final response = await di<DioFactory>().post(
        '${EndPoints.baseURL}/rooms/taps',
        data: {'room_id': _roomId, 'count': count},
      );
      final data = response.data is Map ? response.data['data'] : null;
      if (data is Map) {
        final blockedFor = int.tryParse('${data['blocked_for'] ?? 0}') ?? 0;
        final warning = data['warning']?.toString();
        if (blockedFor > 0) {
          blockedUntilMs =
              DateTime.now().millisecondsSinceEpoch + blockedFor * 1000;
        }
        if (warning != null && warning.isNotEmpty) {
          final ctx = navKey.currentContext;
          if (ctx != null) {
            Methods.showToast(ctx, message: warning, isError: true);
          }
        }
      }
    } catch (_) {
      // Taps are best-effort; the official broadcast reconciles everyone.
    }
  }

  // ── Incoming (RTM) ──

  /// A lossy pulse from another tapper: bump the shared estimate and render
  /// (thinned) hearts for their taps.
  void onRemotePulse(int count) {
    if (!_active || count <= 0) return;
    _optimistic += count;
    displayTotal.value = _officialTotal + _optimistic;
    // Render at most a few hearts per remote pulse — the counter carries the
    // real magnitude; the animation just has to feel alive.
    final toRender = min(count, 3);
    for (var i = 0; i < toRender; i++) {
      _spawnHeart();
    }
  }

  /// The backend's official room total: snap to it and drop the optimistic
  /// delta (it is now included — or capped away — server-side).
  void onOfficialTotal(int total) {
    if (!_active) return;
    if (total < _officialTotal) return; // stale/out-of-order broadcast
    _officialTotal = total;
    _optimistic = 0;
    displayTotal.value = total;
  }
}
