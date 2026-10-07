import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

import 'data/ludo_api.dart';
import 'data/ludo_models.dart';
import 'game/game_state.dart';
import 'game/ludo_flame_game.dart';
import 'models/game_mode.dart';
import 'models/player_color.dart';
import 'models/token.dart';
import 'services/sound_service.dart';
import 'widgets/ludo_invite_dialog.dart';

enum LudoLobbyMode { duo, multi }

enum LudoRuleSet { classic, simple }

enum LudoSessionPhase { lobby, playing }

/// A user sitting on one of the four Ludo colours.
class LudoSeatPlayer {
  final String uid;
  final String name;
  final String avatar;

  const LudoSeatPlayer({
    required this.uid,
    required this.name,
    required this.avatar,
  });
}

class LudoRankEntry {
  final int rank;
  final String uid;
  final String color;
  final String name;

  const LudoRankEntry({
    required this.rank,
    required this.uid,
    required this.color,
    required this.name,
  });
}

/// Result shown when the server reports `finished`.
class LudoResult {
  final String winnerName;
  final String winnerAvatar;
  final String winnerColor;
  final int prize;
  final List<LudoRankEntry> ranking;

  const LudoResult({
    required this.winnerName,
    required this.winnerAvatar,
    required this.winnerColor,
    required this.prize,
    required this.ranking,
  });
}

/// Room-scoped Ludo session driven by the backend.
///
/// The server owns everything that matters (coins, dice, turns, captures,
/// winner). The client only
///  - calls the REST API (create / join / leave / start / cancel / roll / move),
///  - applies the `ludo_event` frames the server pushes on the room channel,
///    strictly in `version` order (a gap triggers a snapshot re-fetch), and
///  - animates the result on the Flame board.
class LudoRoomController extends ChangeNotifier {
  LudoRoomController._();

  static final LudoRoomController instance = LudoRoomController._();

  /// Turn on once the backend implements the magic squares (see
  /// docs/LUDO_BACKEND_SPEC.md); until then the board must not show items the
  /// server will not honour.
  static const bool serverMagicItems = true;

  final LudoApi _api = const LudoApi();

  LudoConfig config = LudoConfig.fallback;
  bool _configLoaded = false;

  int? _roomId;
  LudoServerGame? sg;
  int _version = 0;
  DateTime? _deadline;

  /// When the current turn runs out (local clock) and how long a turn lasts.
  /// Drives the shrinking ring around the active player's avatar.
  DateTime? turnEndsAt;
  int turnTotalMs = 20000;

  /// Server clock minus device clock (ms), learned from `server_time_ms` on
  /// every pushed event so the turn ring is right even on a wrong device clock.
  int _skewMs = 0;

  DateTime _serverNowUtc() =>
      DateTime.now().toUtc().add(Duration(milliseconds: _skewMs));

  void _learnClock(Map<String, dynamic> content) {
    final t = content['server_time_ms'];
    if (t is num) _skewMs = t.toInt() - DateTime.now().millisecondsSinceEpoch;
  }

  /// Re-arms the turn ring from a server deadline (or a full turn when unknown
  /// or when the device clock disagrees with the server).
  void _markTurn(DateTime? deadline) {
    final total = config.turnTimeoutSeconds * 1000;
    var ms = deadline == null
        ? total
        : deadline.difference(_serverNowUtc()).inMilliseconds;
    if (ms <= 0 || ms > total + 2000) ms = total;
    turnTotalMs = total;
    turnEndsAt = DateTime.now().add(Duration(milliseconds: ms));
  }

  bool _active = false;
  bool _dismissed = false;
  bool _declined = false;
  bool _inviteOpen = false;
  bool busy = false;

  final Map<PlayerColor, LudoSeatPlayer> seats = {};
  LudoGameState? game;
  LudoFlameGame? flame;
  LudoResult? result;

  /// Drives the room layout switch (seat row + Ludo panel instead of the grid).
  final ValueNotifier<bool> activeNotifier = ValueNotifier<bool>(false);

  /// Seconds left for the current turn.
  final ValueNotifier<int> secondsLeft = ValueNotifier<int>(0);

  PlayerColor? rollingColor;
  DateTime? _rollStartedAt;

  /// Each player's own last roll, kept on screen so everybody sees who
  /// rolled what.
  final Map<PlayerColor, int> lastRollByColor = {};
  int rollTick = 0;

  Timer? _ticker;
  final List<Map<String, dynamic>> _queue = [];
  bool _pumping = false;

  // Identity -----------------------------------------------------------------

  String get myUid => '${MyDataModel.getInstance().id}';

  bool get isActive => _active;

  /// A live (lobby/playing) game exists in this room.
  bool get hasGame => sg != null && sg!.isLive || result != null;

  LudoLobbyMode get mode =>
      sg?.mode == 'duo' ? LudoLobbyMode.duo : LudoLobbyMode.multi;
  LudoRuleSet get rule =>
      sg?.rule == 'simple' ? LudoRuleSet.simple : LudoRuleSet.classic;
  bool get magic => sg?.magic ?? false;
  int get entryFee => sg?.entryFee ?? 0;
  int get prizePool => sg?.prizePool ?? 0;
  String? get hostUid => sg?.hostUserId;
  bool get isHost => hostUid != null && hostUid == myUid;

  LudoSessionPhase get phase => game != null
      ? LudoSessionPhase.playing
      : LudoSessionPhase.lobby;

  PlayerColor? get myColor {
    for (final e in seats.entries) {
      if (e.value.uid == myUid) return e.key;
    }
    return null;
  }

  bool get canStart =>
      isHost &&
      phase == LudoSessionPhase.lobby &&
      seats.length >= config.minPlayers &&
      !busy;

  bool get canRollNow {
    final g = game;
    final c = myColor;
    return g != null &&
        c != null &&
        result == null &&
        (!busy || _moveRest != null) &&
        !_rollQueued &&
        g.currentPlayer == c &&
        g.phase == TurnPhase.waitingForRoll;
  }

  // Config -------------------------------------------------------------------

  Future<LudoConfig> loadConfig() async {
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
    if (g != null && g.isLive && result == null) {
      final seated = myColor != null;
      if (seated) unawaited(_api.leave(g.id).catchError((_) {}));
    }
    _roomId = null;
    _dismissed = false;
    _declined = false;
    _teardown();
  }

  // Actions ------------------------------------------------------------------

  /// Returns an error message, or null on success.
  Future<String?> create({
    required LudoLobbyMode lobbyMode,
    required LudoRuleSet ruleSet,
    required bool magicOn,
    required int fee,
  }) async {
    final roomId = int.tryParse('${RoomData.instance.room.id}');
    if (roomId == null) return 'Room not available';
    try {
      final g = await _api.create(
        roomId: roomId,
        mode: lobbyMode.name,
        rule: ruleSet.name,
        magic: magicOn,
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
    } on LudoException catch (e) {
      return e.friendly;
    } catch (_) {
      return 'Could not create the game';
    }
  }

  Future<void> join() async {
    final g = sg;
    if (g == null || busy || myColor != null) return;
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
    if (myColor == null) {
      closeView();
      return;
    }
    await _guard(() async {
      if (isHost && phase == LudoSessionPhase.lobby) {
        await _api.cancel(g.id);
      } else {
        await _api.leave(g.id);
      }
      _teardown();
    });
  }

  /// Hide the Ludo layout for this user without touching the game.
  void closeView() {
    _dismissed = true;
    _setActive(false);
  }

  /// Show the Ludo layout again (More options → Ludo while a game is running).
  void reopen() {
    _dismissed = false;
    if (sg != null || result != null) _setActive(true);
  }

  Future<void> start() async {
    final g = sg;
    if (g == null || !isHost) return;
    if (seats.length < config.minPlayers) {
      _toast('At least ${config.minPlayers} players are needed to start');
      return;
    }
    await _guard(() async {
      final updated = await _api.start(g.id);
      _applySnapshot(updated);
      if (updated.version > _version) _version = updated.version;
    });
  }

  /// Rolls instantly on the screen (dice spins the moment it is tapped) and
  /// shows the server's value as soon as the REST call returns, without waiting
  /// for the pushed `rolled` frame.
  Future<void> roll() async {
    final g = sg;
    final c = myColor;
    if (g == null || c == null || !canRollNow) return;
    rollingColor = c;
    _rollStartedAt = DateTime.now();
    rollTick++;
    notifyListeners();
    // After a 6 the next roll can be tapped while our move is still on its way
    // to the server: spin now, send the roll as soon as the move is saved.
    final pending = _moveRest;
    if (pending != null) {
      _rollQueued = true;
      await pending;
      _rollQueued = false;
      if (game?.phase != TurnPhase.waitingForRoll ||
          game?.currentPlayer != c ||
          result != null) {
        rollingColor = null;
        notifyListeners();
        return;
      }
    }
    await _guard(
      () async {
        final updated = await _api.roll(g.id);
        _applyRollResponse(updated, c);
      },
      onFail: () {
        rollingColor = null;
      },
    );
  }

  bool _rollQueued = false;
  PlayerColor? _rolledColor;
  Future<void>? _moveRest;

  void _applyRollResponse(LudoServerGame updated, PlayerColor c) {
    if (sg?.id != updated.id) return;
    _repinBoardLater(updated);
    final clean = !_pumping && _queue.isEmpty;
    if (!clean || updated.version <= _version || updated.status != 'playing') {
      _fallbackSync(updated);
      return;
    }
    if (updated.version == _version + 1 &&
        updated.lastDice != null &&
        updated.currentColor == c.name) {
      _version = updated.version; // the pushed `rolled` frame is now a duplicate
      unawaited(_onRolled({'color': c.name, 'dice': updated.lastDice}));
      return;
    }
    // The server already played on (no movable token, or it moved the only
    // possible token itself): replay roll -> number -> move for the screen.
    _version = updated.version;
    unawaited(_playRollOutcome(updated, c));
  }

  Future<void> _playRollOutcome(LudoServerGame updated, PlayerColor c) async {
    final st = game;
    if (st == null) {
      _applySnapshot(updated);
      return;
    }
    LudoToken? moved;
    var from = -1;
    var to = -1;
    final steps = updated.board[c.name];
    if (steps != null) {
      for (var i = 0; i < 4 && i < steps.length; i++) {
        final t = st.tokens[c]![i];
        if (steps[i] > t.relativeStep) {
          moved = t;
          from = t.relativeStep;
          to = steps[i];
          break;
        }
      }
    }
    final dice = moved != null ? (from < 0 ? 6 : to - from) : updated.lastDice;
    final elapsed = _rollStartedAt == null
        ? 0
        : DateTime.now().difference(_rollStartedAt!).inMilliseconds;
    if (dice != null) await _onRolled({'color': c.name, 'dice': dice});
    await Future.delayed(
      Duration(milliseconds: (700 - elapsed).clamp(0, 700) + 250),
    );
    if (sg?.id != updated.id) return;
    if (moved != null) {
      st.phase = TurnPhase.animating;
      await _stepTo(st, moved, from, to);
    }
    var captured = false;
    for (final oc in PlayerColor.values) {
      final os = updated.board[oc.name];
      if (oc == c || os == null) continue;
      for (var i = 0; i < 4 && i < os.length; i++) {
        if (os[i] == -1 && st.tokens[oc]![i].relativeStep >= 0) captured = true;
      }
    }
    _applySnapshot(updated);
    _version = updated.version;
    if (st.phase != TurnPhase.gameOver) {
      if (moved == null &&
          updated.currentColor == c.name &&
          updated.lastDice != null) {
        // Rolled but not moved yet (e.g. a 6 with several tokens): choose one.
        st.lastDiceValue = updated.lastDice;
        st.phase = TurnPhase.waitingForTokenChoice;
      } else {
        st.lastDiceValue = null;
        st.phase = TurnPhase.waitingForRoll;
      }
    }
    if (captured) SoundService.instance.playCapture();
    st.refresh();
    notifyListeners();
  }

  // Optimistic token move ---------------------------------------------------
  Future<void>? _optMove;
  PlayerColor? _optColor;
  int _optSlot = -1;

  /// Moves the token on screen immediately (the dice value is already known),
  /// then reconciles with the server's answer.
  Future<void> chooseToken(LudoToken token) async {
    final g = sg;
    final st = game;
    if (g == null || st == null || busy) return;
    if (token.color != myColor || st.phase != TurnPhase.waitingForTokenChoice) {
      return;
    }
    final dice = st.lastDiceValue;
    if (dice == null || !token.canMove(dice)) return;

    final from = token.relativeStep;
    final to = from < 0 ? 0 : from + dice;
    _optColor = token.color;
    _optSlot = token.slot;
    st.phase = TurnPhase.animating;
    st.refresh();
    _optMove = _stepTo(st, token, from, to).then((_) {
      _predictTurn(st, token, dice);
    });

    final rest = _guard(
      () async {
        final updated = await _api.move(g.id, token.slot);
        await _optMove;
        _finishOptimistic(updated);
      },
      onFail: () {
        // Server refused: put the token back.
        _optMove = null;
        _optColor = null;
        token.relativeStep = from;
        st.phase = TurnPhase.waitingForTokenChoice;
        st.refresh();
      },
    );
    _moveRest = rest;
    await rest;
    if (identical(_moveRest, rest)) _moveRest = null;
  }

  /// Hands the turn over on screen right after our own move instead of waiting
  /// for the server (a 6, or a token reaching home, keeps the turn). The
  /// server's answer corrects this if its rules differ.
  void _predictTurn(LudoGameState st, LudoToken token, int dice) {
    if (st.phase == TurnPhase.gameOver) return;
    final bonus = dice == 6 || token.isFinished;
    st.lastDiceValue = null;
    st.phase = TurnPhase.waitingForRoll;
    if (!bonus) {
      var next = st.currentPlayer.next;
      for (var i = 0; i < 4 && !seats.containsKey(next); i++) {
        next = next.next;
      }
      st.currentPlayer = next;
    }
    _markTurn(null);
    st.refresh();
    notifyListeners();
  }

  /// REST answer for our own move. If the pushed frames have not delivered it
  /// yet, adopt the returned snapshot (captures, turn, dice) right away.
  void _finishOptimistic(LudoServerGame updated) {
    _optMove = null;
    _optColor = null;
    if (sg?.id != updated.id) return;
    _repinBoardLater(updated);
    if (updated.version <= _version) return; // events already applied it
    final st = game;
    var captured = false;
    if (st != null) {
      for (final c in PlayerColor.values) {
        final steps = updated.board[c.name];
        if (steps == null) continue;
        for (var i = 0; i < 4 && i < steps.length; i++) {
          if (steps[i] == -1 && st.tokens[c]![i].relativeStep >= 0) {
            captured = true;
          }
        }
      }
    }
    _applySnapshot(updated);
    _version = updated.version;
    if (captured) SoundService.instance.playCapture();
  }

  /// Runs a REST action with a busy lock and uniform error handling.
  Future<void> _guard(
    Future<void> Function() action, {
    VoidCallback? onFail,
  }) async {
    busy = true;
    notifyListeners();
    try {
      await action();
    } on LudoException catch (e) {
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

  /// The pushed event normally drives the UI. If it has not advanced the
  /// version shortly after the REST call returned, apply the response itself.
  void _fallbackSync(LudoServerGame response) {
    Future.delayed(const Duration(milliseconds: 2500), () {
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

  void _showInvite(LudoServerGame g, Map? host) {
    if (_inviteOpen || _declined) return;
    final ctx = SafeNavigator.context;
    if (ctx == null) return;
    LudoPlayerInfo? hostPlayer;
    for (final p in g.players) {
      if (p.userId == g.hostUserId) hostPlayer = p;
    }
    final name = '${host?['name'] ?? hostPlayer?.name ?? ''}';
    final avatar =
        EndPoints.getImage('${host?['avatar'] ?? hostPlayer?.avatar ?? ''}');
    _inviteOpen = true;
    showLudoInvite(
      ctx,
      hostName: name,
      hostAvatar: avatar,
      entryFee: g.entryFee,
      onAccept: join,
      onReject: () => _declined = true,
    ).whenComplete(() => _inviteOpen = false);
  }

  // Events -------------------------------------------------------------------

  /// Entry point from the room message processor (`ludo_event` frames).
  void onRemote(Map<String, dynamic> content) {
    _learnClock(content);
    final type = '${content['type']}';
    debugPrint(
      '[Ludo] event type=$type game=${content['game_id']} '
      'v=${content['version']} (local v=$_version)',
    );
    if (type == 'wallet_updated') {
      final balance = content['balance'];
      if (balance != null) RoomData.instance.myCoins.value = '$balance';
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
      final g = LudoServerGame.fromJson(Map<String, dynamic>.from(raw));
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
      // End-of-game frames for a game we already dropped (e.g. our own cancel
      // echoing back) need no work.
      if (type == 'cancelled' || type == 'finished' || type == 'player_left') {
        return;
      }
      // A game we do not know yet (we joined the room after `created`).
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
          final g = LudoServerGame.fromJson(Map<String, dynamic>.from(raw));
          _applySnapshot(g);
        } else {
          await _refresh();
        }
        if (!_dismissed) _setActive(true);
        break;
      case 'rolled':
        await _onRolled(e);
        break;
      case 'moved':
        await _onMoved(e);
        break;
      case 'turn':
        _onTurn(e);
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
    final p = LudoPlayerInfo.fromJson(raw);
    final c = _color(p.color);
    if (c == null) return;
    seats[c] = LudoSeatPlayer(
      uid: p.userId,
      name: p.name,
      avatar: EndPoints.getImage(p.avatar),
    );
    if (p.userId == myUid && !_dismissed) _setActive(true);
    notifyListeners();
  }

  void _onPlayerLeft(Map<String, dynamic> e) {
    final c = _color('${e['color']}');
    final uid = '${e['user_id']}';
    if (c != null) {
      seats.remove(c);
      game?.activePlayers.remove(c);
      game?.refresh();
    }
    if (uid == myUid) {
      _toast(
        e['reason'] == 'forfeit'
            ? 'You forfeited the Ludo game'
            : 'You left the Ludo game',
        error: false,
      );
      closeView();
    }
    notifyListeners();
  }

  Future<void> _onRolled(Map<String, dynamic> e) async {
    final st = game;
    final c = _color('${e['color']}');
    if (st == null || c == null) return;
    st.currentPlayer = c;
    _rolledColor = c;
    st.lastDiceValue = _int(e['dice'], 1);
    debugPrint('[Ludo] rolled color=${c.name} dice=${st.lastDiceValue}');
    st.phase = TurnPhase.waitingForTokenChoice;
    // The dice widget plays its own roll/result sounds. If the spin was already
    // started by our tap, keep it going (no second spin) and stop it once the
    // minimum spin time has passed so the real value is revealed.
    final mine = rollingColor == c && _rollStartedAt != null;
    final elapsed = mine
        ? DateTime.now().difference(_rollStartedAt!).inMilliseconds
        : 0;
    if (!mine) {
      rollingColor = c;
      rollTick++;
    }
    _rollStartedAt = null;
    if (st.lastDiceValue != null) lastRollByColor[c] = st.lastDiceValue!;
    st.refresh();
    notifyListeners();
    final wait = (700 - elapsed).clamp(0, 700);
    Future.delayed(Duration(milliseconds: wait), () {
      if (rollingColor == c) {
        rollingColor = null;
        notifyListeners();
      }
    });
    // Other players' rolls: let the dice finish spinning and show its number
    // before the next frame (their token move) starts, so watchers see
    // roll -> number -> move in order.
    if (!mine) await Future.delayed(const Duration(milliseconds: 900));
  }

  Future<void> _onMoved(Map<String, dynamic> e) async {
    final st = game;
    final c = _color('${e['color']}');
    final slot = _int(e['token_slot'], -1);
    if (st == null || c == null || slot < 0) return;
    final tok = st.tokens[c]?[slot];
    if (tok == null) return;

    final from = _int(e['from_step'], tok.relativeStep);
    final to = _int(e['to_step'], tok.relativeStep);
    debugPrint('[Ludo] moved ${c.name}#$slot $from -> $to');
    st.phase = TurnPhase.animating;

    // A rocket square makes the server move the token further than the dice
    // value: walk the dice steps first, pause, then jump the bonus steps.
    // Prefer the server's `landed_step` (where the dice ended); fall back to
    // from + the last dice value for older frames.
    final dice = lastRollByColor[c];
    final landed = e['landed_step'] != null
        ? _int(e['landed_step'], -1)
        : (dice != null ? from + dice : -1);
    final rocket = from >= 0 && landed > from && to > landed && to < 51;
    if (_optMove != null && _optColor == c && _optSlot == slot) {
      // Our own move is already animating on screen: let it finish, then pin
      // the token to the server's final square.
      await _optMove;
      _optMove = null;
      _optColor = null;
      if (rocket) await Future.delayed(const Duration(milliseconds: 300));
      await _stepTo(st, tok, tok.relativeStep, to);
    } else if (rocket) {
      await _stepTo(st, tok, from, landed);
      await Future.delayed(const Duration(milliseconds: 300));
      await _stepTo(st, tok, landed, to);
    } else {
      await _stepTo(st, tok, from, to);
    }
    _repinLater(c, slot, to);

    var captured = false;
    final caps = e['captured'];
    if (caps is List) {
      for (final item in caps) {
        captured = _applyCapture(st, tok, item) || captured;
      }
    }
    if (captured) {
      SoundService.instance.playCapture();
      st.refresh();
      await Future.delayed(const Duration(milliseconds: 360));
    }
    if (e['reached_home'] == true) SoundService.instance.playTokenHome();

    if (st.phase != TurnPhase.gameOver) {
      st.lastDiceValue = null;
      st.phase = TurnPhase.waitingForRoll;
    }
    st.refresh();
    notifyListeners();
  }

  /// Safety net for our own roll/move: if, a moment after the REST answer, no
  /// newer state arrived and the screen still differs from the server board
  /// (or still waits on a stale dice), snap everything to the server's state.
  void _repinBoardLater(LudoServerGame g) {
    Future.delayed(const Duration(milliseconds: 2600), () {
      final st = game;
      if (st == null || sg?.id != g.id || _version != g.version) return;
      if (_pumping || _queue.isNotEmpty || g.status != 'playing') return;
      var diff = false;
      for (final c in PlayerColor.values) {
        final steps = g.board[c.name];
        if (steps == null) continue;
        for (var i = 0; i < 4 && i < steps.length; i++) {
          if (st.tokens[c]![i].relativeStep != steps[i]) diff = true;
        }
      }
      if (diff) _syncState(g);
      notifyListeners();
    });
  }

  /// Safety net: shortly after a move, force the token onto the server's final
  /// square if nothing newer happened (keeps every screen identical).
  void _repinLater(PlayerColor c, int slot, int to) {
    final v = _version;
    final id = sg?.id;
    Future.delayed(const Duration(milliseconds: 1200), () {
      final st = game;
      if (st == null || sg?.id != id || _version != v) return;
      final t = st.tokens[c]?[slot];
      if (t != null && t.relativeStep != to) {
        t.relativeStep = to;
        st.refresh();
      }
    });
  }

  /// Moves [tok] to [to] in ONE state change. The Flame token component
  /// animates the whole path itself (hop arcs, per-cell sounds), so it plays as
  /// one continuous motion instead of restarting at every square.
  Future<void> _stepTo(
    LudoGameState st,
    LudoToken tok,
    int from,
    int to,
  ) async {
    final steps = (to - from).abs();
    tok.relativeStep = to;
    st.refresh();
    final ms = from < 0 ? 330 : (steps <= 1 ? 190 : steps * 135 + 60);
    await Future.delayed(Duration(milliseconds: ms));
  }

  /// `captured` may list `{color, token_slot}` objects or bare colour names;
  /// support both.
  bool _applyCapture(LudoGameState st, LudoToken mover, dynamic item) {
    if (item is Map) {
      final c = _color('${item['color']}');
      final slot = _int(item['token_slot'] ?? item['slot'], -1);
      if (c != null && slot >= 0 && slot < 4) {
        st.tokens[c]![slot].relativeStep = -1;
        return true;
      }
      return false;
    }
    final c = _color('$item');
    if (c == null || !mover.isOnSharedTrack) return false;
    var any = false;
    for (final t in st.tokens[c]!) {
      if (t.isOnSharedTrack && t.cell == mover.cell) {
        t.relativeStep = -1;
        any = true;
      }
    }
    return any;
  }

  void _onTurn(Map<String, dynamic> e) {
    final st = game;
    final c = _color('${e['current_color']}');
    if (st == null || c == null) return;
    st.currentPlayer = c;
    _rolledColor = null;
    st.lastDiceValue = null;
    if (st.phase != TurnPhase.gameOver) st.phase = TurnPhase.waitingForRoll;
    final d = e['turn_deadline_at'];
    _deadline = d == null ? null : DateTime.tryParse('$d');
    _markTurn(_deadline);
    _tick();
    st.refresh();
    notifyListeners();
  }

  void _onFinished(Map<String, dynamic> e) {
    final st = game;
    final w = e['winner'] is Map ? e['winner'] as Map : const {};
    final ranking = <LudoRankEntry>[];
    if (e['ranking'] is List) {
      for (final r in e['ranking'] as List) {
        if (r is Map) {
          ranking.add(
            LudoRankEntry(
              rank: _int(r['rank']),
              uid: '${r['user_id']}',
              color: '${r['color']}',
              name: '${r['name'] ?? ''}',
            ),
          );
        }
      }
    }
    result = LudoResult(
      winnerName: '${w['name'] ?? ''}',
      winnerAvatar: EndPoints.getImage('${w['avatar'] ?? ''}'),
      winnerColor: '${w['color'] ?? ''}',
      prize: _int(e['prize']),
      ranking: ranking,
    );
    if (st != null) {
      st.winner = _color('${w['color']}');
      st.phase = TurnPhase.gameOver;
      st.refresh();
    }
    SoundService.instance.playWin();
    _ticker?.cancel();
    notifyListeners();
  }

  void _onCancelled(Map<String, dynamic> e) {
    final reason = switch ('${e['reason']}') {
      'host_cancelled' => 'The host cancelled the game. Coins refunded.',
      'lobby_expired' => 'Ludo lobby expired. Coins refunded.',
      'host_left' => 'The host left. Coins refunded.',
      _ => 'The Ludo game was cancelled. Coins refunded.',
    };
    _toast(reason, error: false);
    _teardown();
  }

  // Snapshots ----------------------------------------------------------------

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

  void _applySnapshot(LudoServerGame g) {
    final isNew = sg?.id != g.id;
    sg = g;
    seats.clear();
    for (final p in g.players) {
      final c = _color(p.color);
      if (c != null) {
        seats[c] = LudoSeatPlayer(
          uid: p.userId,
          name: p.name,
          avatar: EndPoints.getImage(p.avatar),
        );
      }
    }
    _deadline = g.turnDeadlineAt;
    _markTurn(g.turnDeadlineAt);
    if (g.status == 'playing' || g.status == 'finished') {
      _ensureGame(isNew || game == null);
      _syncState(g);
      _startTicker();
    }
    notifyListeners();
  }

  void _ensureGame(bool fresh) {
    if (!fresh && game != null) return;
    final st = LudoGameState(mode: GameMode.partyRoom);
    game = st;
    LudoGameState.activeState = st;
    flame = LudoFlameGame(
      gameState: st,
      canControl: (color) => myColor == color,
      onTokenChosen: (t) => unawaited(chooseToken(t)),
    );
  }

  void _syncState(LudoServerGame g) {
    final st = game!;
    st.tokensToWin = g.rule == 'simple' ? 2 : 4;
    st.magic = serverMagicItems && g.magic;
    st.activePlayers
      ..clear()
      ..addAll(seats.keys);
    st.playerProfiles.clear();
    for (final e in seats.entries) {
      st.playerProfiles[e.key] = {
        'name': e.value.name,
        'avatar': e.value.avatar,
      };
    }
    for (final c in PlayerColor.values) {
      final steps = g.board[c.name];
      if (steps == null) continue;
      for (var i = 0; i < 4 && i < steps.length; i++) {
        st.tokens[c]![i].relativeStep = steps[i];
      }
    }
    final cur = _color(g.currentColor);
    if (cur != null) st.currentPlayer = cur;
    st.lastDiceValue = g.lastDice;
    if (g.status == 'finished') {
      st.phase = TurnPhase.gameOver;
    } else {
      // The snapshot keeps the previous player's dice after a pass/timeout, so
      // only wait for a token choice when the current player can really move
      // with that number; otherwise it is their turn to roll.
      // last_dice can be stale (previous player's roll), so trust it only when
      // this client saw the current player roll.
      var pending = g.lastDice != null && _rolledColor == cur;
      if (pending && cur != null) {
        pending = st.tokens[cur]!.any((t) => t.canMove(g.lastDice!));
      }
      st.phase = pending
          ? TurnPhase.waitingForTokenChoice
          : TurnPhase.waitingForRoll;
      if (!pending) st.lastDiceValue = null;
    }
    st.refresh();
  }

  // Timer --------------------------------------------------------------------

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void _tick() {
    final d = _deadline;
    if (d == null || game == null || result != null) {
      secondsLeft.value = 0;
      return;
    }
    final left = d.difference(_serverNowUtc()).inSeconds;
    secondsLeft.value = left.clamp(0, config.turnTimeoutSeconds);
  }

  // Helpers ------------------------------------------------------------------

  void _setActive(bool v) {
    _active = v;
    activeNotifier.value = v;
    notifyListeners();
  }

  void _resetLocal() {
    _queue.clear();
    _ticker?.cancel();
    sg = null;
    seats.clear();
    game = null;
    flame = null;
    result = null;
    _version = 0;
    _deadline = null;
    rollingColor = null;
    lastRollByColor.clear();
  }

  void _teardown() {
    if (LudoGameState.activeState == game) LudoGameState.activeState = null;
    _resetLocal();
    _setActive(false);
  }

  void refresh() => notifyListeners();

  PlayerColor? _color(String? name) {
    for (final c in PlayerColor.values) {
      if (c.name == name) return c;
    }
    return null;
  }

  static int _int(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? fallback;
  }

  void _toast(String message, {bool error = true}) {
    final ctx = SafeNavigator.context;
    if (ctx == null) return;
    Methods.showToast(ctx, message: message, isError: error);
  }
}
