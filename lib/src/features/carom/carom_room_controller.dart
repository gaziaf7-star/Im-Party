import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart' show Vector2;
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

import 'data/carom_api.dart';
import 'data/carom_models.dart';
import 'domain/models/game_models.dart';
import 'game/carom_game.dart';
import 'services/carom_audio_service.dart';
import 'widgets/carom_invite_dialog.dart';

enum CaromMode { duo, doubles }

enum CaromSessionPhase { lobby, playing }

/// A user sitting on one of the carrom sides.
class CaromSeatPlayer {
  final String uid;
  final String name;
  final String avatar;
  final bool forfeited;

  const CaromSeatPlayer({
    required this.uid,
    required this.name,
    required this.avatar,
    this.forfeited = false,
  });

  factory CaromSeatPlayer.fromInfo(CaromPlayerInfo p) => CaromSeatPlayer(
    uid: p.userId,
    name: p.name,
    avatar: EndPoints.getImage(p.avatar),
    forfeited: p.isForfeited,
  );
}

/// Result shown when the server reports `finished`.
class CaromResult {
  final List<String> winnerNames;
  final String winnerAvatar;
  final bool iWon;
  final int prize;

  const CaromResult({
    required this.winnerNames,
    required this.winnerAvatar,
    required this.iWon,
    required this.prize,
  });
}

/// Authoritative outcome of one shot (`shot_result` / `turn_timeout`).
class _ShotOutcome {
  final int version;
  final int shotId;
  final List<CaromPieceState> pieces;
  final Map<String, int> scores;
  final String queenStatus;
  final PlayerId? nextSeat;
  final bool gameOver;
  final String notice;
  final int noticeColor;
  final String foul;
  final DateTime? deadline;

  const _ShotOutcome({
    required this.version,
    required this.shotId,
    required this.pieces,
    required this.scores,
    required this.queenStatus,
    required this.nextSeat,
    required this.gameOver,
    required this.notice,
    required this.noticeColor,
    required this.foul,
    required this.deadline,
  });
}

/// Room-scoped Carrom session driven by the backend.
///
/// The server owns what matters (coins, turn order, scoring, winner). The
/// shooter's device simulates the physics, the rest of the room replays the
/// same shot from the `shot` event, and the server's `shot_result` is the
/// single source of truth the board snaps to once the pieces stop.
class CaromRoomController extends ChangeNotifier {
  CaromRoomController._();

  static final CaromRoomController instance = CaromRoomController._();

  final CaromApi _api = const CaromApi();

  CaromConfig config = CaromConfig.fallback;
  bool _configLoaded = false;

  int? _roomId;
  CaromServerGame? sg;
  int _version = 0;
  int _shotSeq = 0;
  DateTime? _deadline;

  /// When the current turn runs out (local clock) and how long a turn lasts.
  DateTime? turnEndsAt;
  int turnTotalMs = 20000;

  bool _active = false;
  bool _dismissed = false;
  bool _declined = false;
  bool _inviteOpen = false;
  bool busy = false;

  final Map<PlayerId, CaromSeatPlayer> seats = {};
  final Map<PlayerId, int> scores = {};
  String queenStatus = 'unpocketed';
  PlayerId activeSeat = PlayerId.player1;
  CaromGame? flame;
  CaromResult? result;

  /// Drives the room layout switch (seat row + Carrom panel instead of grid).
  final ValueNotifier<bool> activeNotifier = ValueNotifier<bool>(false);

  /// Seconds left for the current turn.
  final ValueNotifier<int> secondsLeft = ValueNotifier<int>(0);

  /// 0..1 while the local player is pulling the striker back.
  final ValueNotifier<double> aimPower = ValueNotifier<double>(0);

  /// Banner text (foul, queen, combo...) and its colour.
  final ValueNotifier<CaromNotice?> notice = ValueNotifier<CaromNotice?>(null);

  Timer? _ticker;
  Timer? _noticeTimer;
  Timer? _pendingTimer;
  final List<Map<String, dynamic>> _queue = [];
  bool _pumping = false;

  // The shot this device fired and is simulating / waiting on.
  int? _myShotId;
  _ShotOutcome? _pending;
  bool _gameOver = false;

  // Identity -----------------------------------------------------------------

  String get myUid => '${MyDataModel.getInstance().id}';

  bool get isActive => _active;

  bool get hasGame => sg != null && sg!.isLive || result != null;

  CaromMode get mode =>
      sg?.mode == 'doubles' ? CaromMode.doubles : CaromMode.duo;
  bool get isDoubles => mode == CaromMode.doubles;
  int get entryFee => sg?.entryFee ?? 0;
  int get prizePool => sg?.prizePool ?? 0;
  String? get hostUid => sg?.hostUserId;
  bool get isHost => hostUid != null && hostUid == myUid;
  int get seatCount => isDoubles ? 4 : 2;

  CaromSessionPhase get phase => sg?.status == 'playing' || result != null
      ? CaromSessionPhase.playing
      : CaromSessionPhase.lobby;

  /// Sides in the order they appear in the lobby.
  List<PlayerId> get lobbySeats => isDoubles
      ? const [
          PlayerId.player1,
          PlayerId.player2,
          PlayerId.player3,
          PlayerId.player4,
        ]
      : const [PlayerId.player1, PlayerId.player2];

  PlayerId? get mySeat {
    for (final e in seats.entries) {
      if (e.value.uid == myUid) return e.key;
    }
    return null;
  }

  bool get canStart =>
      isHost &&
      phase == CaromSessionPhase.lobby &&
      seats.length >= (isDoubles ? 4 : 2) &&
      !busy;

  /// Colour a seat plays (player 1 & 3 = white, 2 & 4 = black).
  PieceType colorOf(PlayerId p) =>
      (p == PlayerId.player1 || p == PlayerId.player3)
      ? PieceType.white
      : PieceType.black;

  /// Quarter turns that bring the local player's side to the bottom.
  int get quarterTurns {
    switch (mySeat) {
      case PlayerId.player2:
        return isDoubles ? 3 : 2;
      case PlayerId.player3:
        return 2;
      case PlayerId.player4:
        return 1;
      default:
        return 0;
    }
  }

  bool get isMyTurn {
    final g = flame;
    return g != null &&
        result == null &&
        !_gameOver &&
        sg?.status == 'playing' &&
        mySeat != null &&
        mySeat == activeSeat &&
        _myShotId == null &&
        (g.currentPhase == TurnPhase.positioningStriker ||
            g.currentPhase == TurnPhase.aiming);
  }

  bool get isSimulating => flame?.isSimulating ?? false;

  int piecesPocketed(PieceType type) =>
      flame?.allBodies.where((b) => b.type == type && b.isPocketed).length ?? 0;

  // Config -------------------------------------------------------------------

  Future<CaromConfig> loadConfig() async {
    if (_configLoaded) return config;
    try {
      config = await _api.config();
      _configLoaded = true;
    } catch (_) {
      // Keep the built-in defaults; the server validates the fee anyway.
    }
    return config;
  }

  // Room lifecycle -----------------------------------------------------------

  /// Called once the user is connected to a room: picks up a game that is
  /// already running (late joiner / spectator).
  void onRoomEntered(int roomId) {
    if (_roomId != roomId) _teardown();
    _roomId = roomId;
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    final roomId = _roomId;
    if (roomId == null) return;
    try {
      final g = await _api.active(roomId);
      if (_roomId != roomId) return;
      if (g == null || !g.isLive) return;
      if (sg?.id == g.id && _version >= g.version) return;
      _applySnapshot(g);
      _version = g.version;
      final iAmIn = seats.values.any((s) => s.uid == myUid);
      if (g.status == 'playing' || iAmIn) {
        if (!_dismissed) _setActive(true);
      } else if (!_dismissed && !_declined) {
        _showInvite(g, null);
      }
    } catch (_) {}
  }

  /// Leaving the room: free the seat (best effort) and drop all local state.
  void reset() {
    final g = sg;
    if (g != null && g.isLive && result == null && mySeat != null) {
      unawaited(_api.leave(g.id).catchError((_) {}));
    }
    _roomId = null;
    _dismissed = false;
    _declined = false;
    _teardown();
  }

  // Actions ------------------------------------------------------------------

  /// Returns an error message, or null on success.
  Future<String?> create({required CaromMode lobbyMode, required int fee}) async {
    final roomId = int.tryParse('${RoomData.instance.room.id}');
    if (roomId == null) return 'Room not available';
    try {
      final g = await _api.create(
        roomId: roomId,
        mode: lobbyMode.name,
        entryFee: fee,
      );
      _roomId = roomId;
      _resetLocal();
      _dismissed = false;
      _declined = false;
      _applySnapshot(g);
      _version = g.version;
      _setActive(true);
      return null;
    } on CaromException catch (e) {
      return e.friendly;
    } catch (_) {
      return 'Could not create the game';
    }
  }

  Future<void> join() async {
    final g = sg;
    if (g == null || busy || mySeat != null) return;
    await _guard(() async {
      final updated = await _api.join(g.id);
      _declined = false;
      _dismissed = false;
      _applySnapshot(updated);
      if (updated.version > _version) _version = updated.version;
      _setActive(true);
    });
  }

  /// Host in the lobby cancels; a seated player leaves (forfeit when playing);
  /// anyone else just closes the view.
  Future<void> leave() async {
    final g = sg;
    if (g == null || result != null) {
      _teardown();
      return;
    }
    if (mySeat == null) {
      closeView();
      return;
    }
    await _guard(() async {
      if (isHost && phase == CaromSessionPhase.lobby) {
        await _api.cancel(g.id);
      } else {
        await _api.leave(g.id);
      }
      _teardown();
    });
  }

  /// Hide the Carrom layout for this user without touching the game.
  void closeView() {
    _dismissed = true;
    _setActive(false);
  }

  /// Show the Carrom layout again (More options -> Carrom while running).
  void reopen() {
    _dismissed = false;
    if (sg != null || result != null) _setActive(true);
  }

  Future<void> start() async {
    final g = sg;
    if (g == null || !isHost) return;
    if (!canStart) {
      _toast(
        isDoubles
            ? 'All 4 seats must be filled to start'
            : 'Waiting for an opponent',
      );
      return;
    }
    await _guard(() async {
      final updated = await _api.start(g.id);
      _applySnapshot(updated);
      if (updated.version > _version) _version = updated.version;
    });
  }

  // Aiming & shooting (local player) -------------------------------------------

  Offset? _dragStart;
  Vector2? _aimDir;
  DateTime _lastAimSync = DateTime.fromMillisecondsSinceEpoch(0);

  bool get strikerValid => flame?.strikerComponent.isValidPosition ?? true;

  PlayerBaselineConfig? get _baseline {
    final g = flame;
    if (g == null) return null;
    return BoardConfig.getBaselineConfig(
      activeSeat,
      is4PlayerMode: g.is4PlayerMode,
    );
  }

  /// 0..1 position of the striker along the bottom edge as the player sees it.
  double get sliderFraction {
    final g = flame;
    final b = _baseline;
    if (g == null || b == null) return 0.5;
    final v = b.isVertical ? g.strikerBody.position.y : g.strikerBody.position.x;
    final f = ((v - b.minSlider) / (b.maxSlider - b.minSlider)).clamp(0.0, 1.0);
    return _sliderReversed ? 1 - f : f;
  }

  // On the rotated board (North / East) the baseline runs against the screen.
  bool get _sliderReversed => quarterTurns == 1 || quarterTurns == 2;

  /// Moves the striker along its baseline; [fraction] is the on-screen 0..1.
  void setSliderFraction(double fraction) {
    final g = flame;
    final b = _baseline;
    if (g == null || b == null || !isMyTurn) return;
    final f = _sliderReversed ? 1 - fraction : fraction;
    g.updateStrikerPlacement(b.minSlider + (b.maxSlider - b.minSlider) * f);
    _syncAim();
    notifyListeners();
  }

  void aimStart(Offset pos) {
    final g = flame;
    if (g == null || !isMyTurn) return;
    if (!g.strikerComponent.isValidPosition) {
      _showNotice('Clear the coins from the striker spot first', 0xFFEF4444);
      return;
    }
    final strikerPos = Offset(g.strikerBody.position.x, g.strikerBody.position.y);
    _dragStart = strikerPos;
    g.startAiming();
    final b = _baseline!;
    final defaultDir = Vector2(b.defaultAimX, b.defaultAimY).normalized();
    final drag = pos - strikerPos;
    if (drag.distance >= 4) {
      _applyDrag(drag);
    } else {
      _aimDir = defaultDir;
      aimPower.value = 0.15;
      g.updateAim(defaultDir, 0.15);
    }
    _syncAim(force: true);
  }

  void aimUpdate(Offset pos) {
    final g = flame;
    final start = _dragStart;
    if (g == null || start == null) return;
    final drag = pos - start;
    if (drag.distance < 4) {
      final b = _baseline!;
      final d = Vector2(b.defaultAimX, b.defaultAimY).normalized();
      _aimDir = d;
      aimPower.value = 0.15;
      g.updateAim(d, 0.15);
    } else {
      _applyDrag(drag);
    }
    _syncAim();
  }

  // Slingshot: pulling the finger back from the striker aims the other way.
  void _applyDrag(Offset drag) {
    final dir = -Vector2(drag.dx, drag.dy).normalized();
    final power = ((drag.distance - 4.0) / 160.0).clamp(0.08, 1.0).toDouble();
    _aimDir = dir;
    aimPower.value = power;
    flame!.updateAim(dir, power);
  }

  void aimEnd() {
    final g = flame;
    final dir = _aimDir;
    final power = aimPower.value;
    _dragStart = null;
    _aimDir = null;
    aimPower.value = 0;
    if (g == null || dir == null) return;
    if (power >= 0.10 && isMyTurn) {
      unawaited(_fire(dir, power));
    } else {
      g.cancelAiming();
      _syncAim(force: true);
    }
    notifyListeners();
  }

  Future<void> _fire(Vector2 dir, double power) async {
    final g = flame;
    final game = sg;
    if (g == null || game == null) return;
    HapticFeedback.mediumImpact();
    final shotId = _shotSeq + 1;
    final pos = g.strikerBody.position.clone();
    _myShotId = shotId;
    _shotSeq = shotId;
    g.fireStriker(dir, power);
    notifyListeners();
    try {
      await _api.shot(
        game.id,
        shotId: shotId,
        strikerX: pos.x,
        strikerY: pos.y,
        angle: atan2(dir.y, dir.x),
        power: power,
      );
    } on CaromException catch (e) {
      _toast(e.friendly);
      _failShot();
    } catch (_) {
      _toast('Network error, please try again');
      _failShot();
    }
  }

  // The server refused the shot: drop the local simulation, restore the board.
  void _failShot() {
    _myShotId = null;
    unawaited(_refresh());
  }

  /// Streams the striker slider / aim to the room (throttled, best effort).
  void _syncAim({bool force = false}) {
    final g = flame;
    final game = sg;
    if (g == null || game == null || !config.aimSync || !isMyTurn) return;
    final now = DateTime.now();
    // One aim request in flight at a time, at most ~4 per second: the server
    // answers in ~1-2 s, so streaming faster only piles up requests.
    if (!force &&
        (_aimInFlight || now.difference(_lastAimSync).inMilliseconds < 250)) {
      return;
    }
    _lastAimSync = now;
    _aimInFlight = true;
    final b = _baseline!;
    final v = b.isVertical ? g.strikerBody.position.y : g.strikerBody.position.x;
    final dir = g.strikerComponent.aimVector;
    final aiming = g.strikerComponent.isAiming && dir != null;
    unawaited(
      _api
          .aim(
            game.id,
            sliderX: v,
            aiming: aiming,
            angle: dir == null ? 0 : atan2(dir.y, dir.x),
            power: g.strikerComponent.strikePower,
          )
          .catchError((_) {})
          .whenComplete(() => _aimInFlight = false),
    );
  }

  bool _aimInFlight = false;

  // Settling -------------------------------------------------------------------

  /// All pieces stopped. The shooter reports the board; everyone else waits
  /// for the server's `shot_result`.
  void _onSettled(ShotResult r) {
    final shotId = _myShotId;
    final g = flame;
    final game = sg;
    if (shotId != null && g != null && game != null) {
      unawaited(_reportResult(game.id, shotId, r, g));
      return;
    }
    final p = _pending;
    if (p != null) {
      _pending = null;
      _pendingTimer?.cancel();
      _applyOutcome(p);
    }
  }

  Future<void> _reportResult(
    int gameId,
    int shotId,
    ShotResult r,
    CaromGame g,
  ) async {
    final pieces = g.allBodies
        .where((b) => b.type != PieceType.striker)
        .map(
          (b) => CaromPieceState(
            id: b.id,
            type: b.type.name,
            x: b.position.x,
            y: b.position.y,
            isPocketed: b.isPocketed,
          ),
        )
        .toList();
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final updated = await _api.shotResult(
          gameId,
          shotId: shotId,
          pieces: pieces,
          strikerPocketed: r.strikerPocketed,
        );
        _fallbackSync(updated);
        return;
      } on CaromException catch (e) {
        _toast(e.friendly);
        break;
      } catch (_) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    _myShotId = null;
    await _refresh();
  }

  /// The pushed event normally drives the UI. If it has not arrived shortly
  /// after the REST answer, adopt the answer itself.
  void _fallbackSync(CaromServerGame response) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (sg?.id == response.id &&
          _version < response.version &&
          !_pumping &&
          _queue.isEmpty) {
        _applySnapshot(response);
        _version = response.version;
      }
    });
  }

  // Invitations ----------------------------------------------------------------

  void _showInvite(CaromServerGame g, Map? host) {
    if (_inviteOpen || _declined) return;
    final ctx = SafeNavigator.context;
    if (ctx == null) return;
    CaromPlayerInfo? hostPlayer;
    for (final p in g.players) {
      if (p.userId == g.hostUserId) hostPlayer = p;
    }
    final name = '${host?['name'] ?? hostPlayer?.name ?? ''}';
    final avatar = EndPoints.getImage(
      '${host?['avatar'] ?? hostPlayer?.avatar ?? ''}',
    );
    _inviteOpen = true;
    showCaromInvite(
      ctx,
      hostName: name,
      hostAvatar: avatar,
      entryFee: g.entryFee,
      doubles: g.isDoubles,
      onAccept: join,
      onReject: () => _declined = true,
    ).whenComplete(() => _inviteOpen = false);
  }

  // Events -------------------------------------------------------------------

  /// Entry point from the room message processor (`carom_event` frames).
  void onRemote(Map<String, dynamic> content) {
    _learnClock(content);
    final type = '${content['type']}';
    if (type != 'aim') {
      debugPrint(
        '[Carom] event type=$type game=${content['game_id']} '
        'v=${content['version']} (local v=$_version)',
      );
    }
    if (type == 'wallet_updated') {
      final balance = content['balance'];
      if (balance != null) RoomData.instance.myCoins.value = '$balance';
      return;
    }
    if (type == 'aim') {
      _onAim(content); // un-versioned, high frequency: never queued
      return;
    }
    _queue.add(content);
    unawaited(_pump());
  }

  Future<void> _pump() async {
    if (_pumping) return;
    _pumping = true;
    try {
      while (_queue.isNotEmpty) {
        final e = _queue.removeAt(0);
        try {
          await _handle(e);
        } catch (_) {
          // A malformed frame must never stall the queue.
        }
      }
    } finally {
      _pumping = false;
    }
  }

  Future<void> _handle(Map<String, dynamic> e) async {
    final type = '${e['type']}';
    final gameId = _int(e['game_id']);
    final version = _int(e['version']);

    if (type == 'created') {
      final raw = e['game'];
      if (raw is! Map) return;
      final g = CaromServerGame.fromJson(Map<String, dynamic>.from(raw));
      if (sg?.id == g.id) return;
      _resetLocal();
      _dismissed = false;
      _declined = false;
      _applySnapshot(g);
      _version = g.version;
      final host = e['host'] is Map ? e['host'] as Map : null;
      final hostId = '${host?['id'] ?? g.hostUserId}';
      if (hostId == myUid) {
        _setActive(true);
      } else {
        _showInvite(g, host);
      }
      return;
    }

    if (sg == null || sg!.id != gameId) {
      if (type == 'cancelled' || type == 'finished' || type == 'player_left') {
        return;
      }
      await _bootstrap();
      return;
    }

    if (version <= _version) return;
    if (version > _version + 1) {
      await _refresh();
      if (version <= _version) return;
    }
    _version = version;

    switch (type) {
      case 'player_joined':
        _onPlayerJoined(e);
        break;
      case 'player_left':
        _onPlayerLeft(e);
        break;
      case 'started':
        final raw = e['game'];
        if (raw is Map) {
          _applySnapshot(
            CaromServerGame.fromJson(Map<String, dynamic>.from(raw)),
          );
        } else {
          await _refresh();
        }
        if (!_dismissed) _setActive(true);
        break;
      case 'shot':
        _onShot(e);
        break;
      case 'shot_result':
      case 'turn_timeout':
        _onOutcome(e);
        break;
      case 'finished':
        _onFinished(e);
        break;
      case 'cancelled':
        _onCancelled(e);
        break;
    }
  }

  void _onPlayerJoined(Map<String, dynamic> e) {
    final raw = e['player'];
    if (raw is! Map) return;
    final p = CaromPlayerInfo.fromJson(raw);
    final s = _seat(p.seat);
    if (s == null) return;
    seats[s] = CaromSeatPlayer.fromInfo(p);
    if (p.userId == myUid && !_dismissed) _setActive(true);
    notifyListeners();
  }

  void _onPlayerLeft(Map<String, dynamic> e) {
    final s = _seat('${e['seat']}');
    final uid = '${e['user_id']}';
    if (s != null) {
      final playing = sg?.status == 'playing' && flame != null;
      final old = seats[s];
      if (playing && old != null) {
        // Mid-game the seat stays, greyed out as forfeited.
        seats[s] = CaromSeatPlayer(
          uid: old.uid,
          name: old.name,
          avatar: old.avatar,
          forfeited: true,
        );
      } else {
        seats.remove(s);
      }
    }
    if (uid == myUid) {
      _toast(
        e['reason'] == 'forfeit'
            ? 'You forfeited the Carrom game'
            : 'You left the Carrom game',
        error: false,
      );
      closeView();
    }
    notifyListeners();
  }

  /// A remote player fired: replay the same shot on this device.
  void _onShot(Map<String, dynamic> e) {
    final g = flame;
    final s = _seat('${e['seat']}');
    final shotId = _int(e['shot_id']);
    if (shotId > _shotSeq) _shotSeq = shotId;
    if (g == null || s == null) return;
    if (s == mySeat && shotId == _myShotId) return; // our own, already running
    _pending = null;
    activeSeat = s;
    g.resetStrikerForTurn(s);
    g.fireRemote(
      position: Vector2(
        _double(e['striker_x'], 370),
        _double(e['striker_y'], 635),
      ),
      angle: _double(e['angle']),
      power: _double(e['power'], 0.5),
    );
    _pauseTurnTimer();
    notifyListeners();
  }

  void _onOutcome(Map<String, dynamic> e) {
    final o = _ShotOutcome(
      version: _int(e['version']),
      shotId: _int(e['shot_id']),
      pieces: parsePieces(e['pieces']),
      scores: parseScores(e['scores']),
      queenStatus: '${e['queen_status'] ?? queenStatus}',
      nextSeat: _seat('${e['next_seat'] ?? e['next_player']}'),
      gameOver: e['game_over'] == true,
      notice: '${e['notice'] ?? ''}',
      noticeColor: _int(e['notice_color'], 0xFF38BDF8),
      foul: '${e['foul'] ?? 'none'}',
      deadline: e['turn_deadline_at'] == null
          ? null
          : DateTime.tryParse('${e['turn_deadline_at']}'),
    );
    // Others are still rolling the same shot: let it finish, then snap.
    if (isSimulating && _myShotId == null) {
      _pending = o;
      _pendingTimer?.cancel();
      _pendingTimer = Timer(const Duration(milliseconds: 2500), () {
        final p = _pending;
        if (p != null) {
          _pending = null;
          _applyOutcome(p);
        }
      });
      return;
    }
    _applyOutcome(o);
  }

  void _applyOutcome(_ShotOutcome o) {
    final g = flame;
    if (g == null) return;
    _pendingTimer?.cancel();
    _myShotId = null;
    if (o.pieces.isNotEmpty) g.syncPiecePositions(o.pieces);
    _setScores(o.scores);
    queenStatus = o.queenStatus;
    if (o.notice.isNotEmpty) _showNotice(o.notice, o.noticeColor);
    if (o.foul != 'none') {
      CaromAudio.instance.playFoul();
    } else if (o.queenStatus == 'covered' || o.notice.contains('QUEEN')) {
      CaromAudio.instance.playCheer();
    }
    if (o.gameOver) {
      _gameOver = true;
      _deadline = null;
      secondsLeft.value = 0;
      notifyListeners();
      return;
    }
    if (o.nextSeat != null) _beginTurn(o.nextSeat!, o.deadline);
    notifyListeners();
  }

  void _onFinished(Map<String, dynamic> e) {
    final winners = <String>[];
    String avatar = '';
    var iWon = false;
    final list = e['winners'] is List
        ? e['winners'] as List
        : (e['winner'] is Map ? [e['winner']] : const []);
    for (final w in list) {
      if (w is! Map) continue;
      winners.add('${w['name'] ?? ''}');
      if (avatar.isEmpty) avatar = EndPoints.getImage('${w['avatar'] ?? ''}');
      if ('${w['user_id']}' == myUid) iWon = true;
    }
    _setScores(parseScores(e['scores']));
    result = CaromResult(
      winnerNames: winners,
      winnerAvatar: avatar,
      iWon: iWon,
      prize: _int(e['prize']),
    );
    _gameOver = true;
    CaromAudio.instance.playWin();
    _ticker?.cancel();
    secondsLeft.value = 0;
    notifyListeners();
  }

  void _onCancelled(Map<String, dynamic> e) {
    final reason = switch ('${e['reason']}') {
      'host_cancelled' => 'The host cancelled the game. Coins refunded.',
      'lobby_expired' => 'Carrom lobby expired. Coins refunded.',
      'host_left' => 'The host left. Coins refunded.',
      _ => 'The Carrom game was cancelled. Coins refunded.',
    };
    _toast(reason, error: false);
    _teardown();
  }

  /// Live striker movement of the active remote player (un-versioned).
  void _onAim(Map<String, dynamic> e) {
    final g = flame;
    final s = _seat('${e['seat']}');
    if (g == null || s == null || s == mySeat || result != null) return;
    if (g.isSimulating || _pending != null) return;
    if (g.activePlayer != s) {
      activeSeat = s;
      g.resetStrikerForTurn(s);
    }
    final b = BoardConfig.getBaselineConfig(s, is4PlayerMode: g.is4PlayerMode);
    final slider = _double(e['slider'] ?? e['slider_x'], 370)
        .clamp(b.minSlider, b.maxSlider);
    g.updateStrikerPlacement(slider.toDouble());
    final power = _double(e['power']);
    if (e['aiming'] == true && power > 0) {
      if (!g.strikerComponent.isAiming) g.startAiming();
      final a = _double(e['angle']);
      g.updateAim(Vector2(cos(a), sin(a)), power);
    } else if (g.strikerComponent.isAiming) {
      g.cancelAiming();
    }
  }

  // State ----------------------------------------------------------------------

  Future<void> _refresh() async {
    final roomId = _roomId;
    if (roomId == null) return;
    try {
      final g = await _api.active(roomId);
      if (g == null || !g.isLive) {
        if (result == null) _teardown();
        return;
      }
      _applySnapshot(g);
      _version = g.version;
    } catch (_) {}
  }

  void _applySnapshot(CaromServerGame g) {
    final isNew = sg?.id != g.id;
    sg = g;
    if (g.shotSeq > _shotSeq || isNew) _shotSeq = g.shotSeq;
    seats.clear();
    for (final p in g.players) {
      final s = _seat(p.seat);
      if (s != null) seats[s] = CaromSeatPlayer.fromInfo(p);
    }
    _setScores(g.scores);
    queenStatus = g.queenStatus;
    if (g.status == 'playing' || g.status == 'finished') {
      _ensureGame(isNew || flame == null, g);
      final game = flame!;
      if (g.pieces.isNotEmpty) game.syncPiecePositions(g.pieces);
      _myShotId = null;
      _pending = null;
      if (g.status == 'playing') {
        _gameOver = false;
        _beginTurn(_seat(g.currentSeat) ?? PlayerId.player1, g.turnDeadlineAt);
      } else {
        _gameOver = true;
      }
    }
    notifyListeners();
  }

  void _ensureGame(bool fresh, CaromServerGame g) {
    if (!fresh && flame != null) return;
    final game = CaromGame(onTurnCompleted: _onSettled);
    game.is4PlayerMode = g.isDoubles;
    flame = game;
    CaromAudio.instance.preload();
  }

  void _beginTurn(PlayerId seat, DateTime? deadline) {
    final g = flame;
    if (g == null) return;
    activeSeat = seat;
    g.resetStrikerForTurn(seat);
    aimPower.value = 0;
    _dragStart = null;
    _aimDir = null;
    _deadline = deadline;
    _markTurn(deadline);
    _startTicker();
  }

  void _setScores(Map<String, int> raw) {
    if (raw.isEmpty) return;
    scores.clear();
    raw.forEach((k, v) {
      final s = _seat(k);
      if (s != null) scores[s] = v;
    });
  }

  /// Server clock minus device clock (ms), learned from `server_time_ms` on
  /// every pushed event so the turn ring is right even on a wrong device clock.
  int _skewMs = 0;

  DateTime _serverNowUtc() =>
      DateTime.now().toUtc().add(Duration(milliseconds: _skewMs));

  void _learnClock(Map<String, dynamic> content) {
    final t = content['server_time_ms'];
    if (t is num) _skewMs = t.toInt() - DateTime.now().millisecondsSinceEpoch;
  }

  void _markTurn(DateTime? deadline) {
    final total = config.turnTimeoutSeconds * 1000;
    var ms = deadline == null
        ? total
        : deadline.difference(_serverNowUtc()).inMilliseconds;
    if (ms <= 0 || ms > total + 2000) ms = total;
    turnTotalMs = total;
    turnEndsAt = DateTime.now().add(Duration(milliseconds: ms));
  }

  void _pauseTurnTimer() {
    _deadline = null;
    secondsLeft.value = 0;
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void _tick() {
    final end = turnEndsAt;
    if (end == null || flame == null || result != null || _gameOver) {
      secondsLeft.value = 0;
      return;
    }
    if (_deadline == null) return; // a shot is in flight, timer is paused
    secondsLeft.value = end
        .difference(DateTime.now())
        .inSeconds
        .clamp(0, config.turnTimeoutSeconds);
  }

  void _showNotice(String text, int color) {
    notice.value = CaromNotice(text, Color(color));
    _noticeTimer?.cancel();
    _noticeTimer = Timer(const Duration(milliseconds: 2400), () {
      notice.value = null;
    });
  }

  void _setActive(bool v) {
    _active = v;
    activeNotifier.value = v;
    notifyListeners();
  }

  void _resetLocal() {
    _queue.clear();
    _ticker?.cancel();
    _pendingTimer?.cancel();
    _noticeTimer?.cancel();
    notice.value = null;
    sg = null;
    seats.clear();
    scores.clear();
    queenStatus = 'unpocketed';
    // Stop the Flame loop explicitly so nothing keeps simulating/drawing once
    // the game is gone.
    flame?.pauseEngine();
    flame = null;
    result = null;
    _version = 0;
    _shotSeq = 0;
    _deadline = null;
    _myShotId = null;
    _pending = null;
    _gameOver = false;
    aimPower.value = 0;
    secondsLeft.value = 0;
  }

  void _teardown() {
    _resetLocal();
    // Free the native sound players too (they are re-created on the next game).
    CaromAudio.instance.dispose();
    _setActive(false);
  }

  void refresh() => notifyListeners();

  PlayerId? _seat(String? name) {
    for (final p in PlayerId.values) {
      if (p.name == name) return p;
    }
    return null;
  }

  static int _int(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? fallback;
  }

  static double _double(dynamic v, [double fallback = 0]) =>
      v is num ? v.toDouble() : (double.tryParse('$v') ?? fallback);

  /// Runs a REST action with a busy lock and uniform error handling.
  Future<void> _guard(
    Future<void> Function() action, {
    VoidCallback? onFail,
  }) async {
    busy = true;
    notifyListeners();
    try {
      await action();
    } on CaromException catch (e) {
      onFail?.call();
      _toast(e.friendly);
      if (e.code == 'STALE_VERSION' ||
          e.code == 'NOT_YOUR_TURN' ||
          e.code == 'GAME_ENDED') {
        await _refresh();
      }
    } catch (_) {
      onFail?.call();
      _toast('Network error, please try again');
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _toast(String message, {bool error = true}) {
    final ctx = SafeNavigator.context;
    if (ctx == null) return;
    Methods.showToast(ctx, message: message, isError: error);
  }
}

class CaromNotice {
  final String text;
  final Color color;

  const CaromNotice(this.text, this.color);
}
