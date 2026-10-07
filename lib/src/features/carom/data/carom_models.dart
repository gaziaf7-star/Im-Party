// Server-side models for the Carrom backend (see docs/CAROM_BACKEND_SPEC.md).

class CaromConfig {
  final List<int> allowedFees;
  final double commissionRate;
  final int turnTimeoutSeconds;
  final int lobbyTimeoutSeconds;
  final bool aimSync;

  const CaromConfig({
    required this.allowedFees,
    required this.commissionRate,
    required this.turnTimeoutSeconds,
    required this.lobbyTimeoutSeconds,
    required this.aimSync,
  });

  static const CaromConfig fallback = CaromConfig(
    allowedFees: [0, 100, 500, 1000, 5000, 10000, 50000],
    commissionRate: 0.05,
    turnTimeoutSeconds: 20,
    lobbyTimeoutSeconds: 180,
    aimSync: true,
  );

  factory CaromConfig.fromJson(Map<String, dynamic> j) => CaromConfig(
    allowedFees: (j['allowed_fees'] as List? ?? fallback.allowedFees)
        .map((e) => _int(e))
        .toList(),
    commissionRate: (j['commission_rate'] as num?)?.toDouble() ?? 0.05,
    turnTimeoutSeconds: _int(j['turn_timeout_seconds'], 20),
    lobbyTimeoutSeconds: _int(j['lobby_timeout_seconds'], 180),
    aimSync: j['aim_sync'] != false,
  );
}

/// Position of one coin as the server stores it (board units, 0..740).
class CaromPieceState {
  final int id;
  final String type; // white | black | queen
  final double x;
  final double y;
  final bool isPocketed;

  const CaromPieceState({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.isPocketed,
  });

  factory CaromPieceState.fromJson(Map j) => CaromPieceState(
    id: _int(j['id']),
    type: '${j['type'] ?? 'white'}',
    x: (j['x'] as num?)?.toDouble() ?? 370,
    y: (j['y'] as num?)?.toDouble() ?? 370,
    isPocketed: j['pocketed'] == true || j['isPocketed'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'x': double.parse(x.toStringAsFixed(2)),
    'y': double.parse(y.toStringAsFixed(2)),
    'pocketed': isPocketed,
  };
}

class CaromPlayerInfo {
  final String userId;

  /// player1 .. player4 (see the seat table in the backend spec).
  final String seat;
  final String name;
  final String avatar;
  final bool isHost;
  final String status; // joined | winner | loser | forfeited

  const CaromPlayerInfo({
    required this.userId,
    required this.seat,
    required this.name,
    required this.avatar,
    this.isHost = false,
    this.status = 'joined',
  });

  bool get isForfeited => status == 'forfeited' || status == 'left';

  factory CaromPlayerInfo.fromJson(Map j) {
    final avatar = '${j['avatar'] ?? ''}';
    final photo = '${j['profile_image'] ?? ''}';
    return CaromPlayerInfo(
      userId: '${j['user_id'] ?? j['id'] ?? ''}',
      seat: '${j['seat'] ?? ''}',
      name: '${j['name'] ?? ''}',
      avatar: avatar.isNotEmpty ? avatar : photo,
      isHost: j['is_host'] == true,
      status: '${j['status'] ?? 'joined'}',
    );
  }
}

/// Full game snapshot returned by every endpoint and by `created` / `started`.
class CaromServerGame {
  final int id;
  final int roomId;
  final String hostUserId;
  final String mode; // duo | doubles
  final int entryFee;
  final int prizePool;
  final int commission;
  final String status; // lobby | playing | finished | cancelled
  final String? currentSeat;
  final DateTime? turnDeadlineAt;
  final int version;
  final int shotSeq;
  final String queenStatus; // unpocketed | waitingForCover | covered
  final String? queenSeat;
  final Map<String, int> scores;
  final List<CaromPieceState> pieces;
  final List<CaromPlayerInfo> players;
  final String? winnerUserId;

  const CaromServerGame({
    required this.id,
    required this.roomId,
    required this.hostUserId,
    required this.mode,
    required this.entryFee,
    required this.prizePool,
    required this.commission,
    required this.status,
    required this.currentSeat,
    required this.turnDeadlineAt,
    required this.version,
    required this.shotSeq,
    required this.queenStatus,
    required this.queenSeat,
    required this.scores,
    required this.pieces,
    required this.players,
    required this.winnerUserId,
  });

  bool get isLive => status == 'lobby' || status == 'playing';
  bool get isDoubles => mode == 'doubles';

  factory CaromServerGame.fromJson(Map<String, dynamic> j) => CaromServerGame(
    id: _int(j['id']),
    roomId: _int(j['room_id']),
    hostUserId: '${j['host_user_id'] ?? ''}',
    mode: '${j['mode'] ?? 'duo'}',
    entryFee: _int(j['entry_fee']),
    prizePool: _int(j['prize_pool']),
    commission: _int(j['commission']),
    status: '${j['status'] ?? 'lobby'}',
    currentSeat: (j['current_seat'] ?? j['current_player'])?.toString(),
    turnDeadlineAt: j['turn_deadline_at'] != null
        ? DateTime.tryParse('${j['turn_deadline_at']}')
        : null,
    version: _int(j['version']),
    shotSeq: _int(j['shot_seq']),
    queenStatus: '${j['queen_status'] ?? 'unpocketed'}',
    queenSeat: j['queen_seat']?.toString(),
    scores: parseScores(j['scores']),
    pieces: parsePieces(j['pieces']),
    players: (j['players'] as List? ?? const [])
        .whereType<Map>()
        .map(CaromPlayerInfo.fromJson)
        .toList(),
    winnerUserId: j['winner_user_id']?.toString(),
  );
}

Map<String, int> parseScores(dynamic raw) {
  final out = <String, int>{};
  if (raw is Map) raw.forEach((k, v) => out['$k'] = _int(v));
  return out;
}

List<CaromPieceState> parsePieces(dynamic raw) => raw is List
    ? raw.whereType<Map>().map(CaromPieceState.fromJson).toList()
    : const [];

/// Error body: `{ status:false, code, message }`.
class CaromException implements Exception {
  final String code;
  final String message;

  const CaromException(this.code, this.message);

  String get friendly => _messages[code] ?? (message.isEmpty ? code : message);

  static const Map<String, String> _messages = {
    'NOT_IN_ROOM': 'You must be in the room',
    'ROOM_HAS_ACTIVE_GAME': 'A game is already running in this room',
    'INVALID_FEE': 'Invalid entry fee',
    'INSUFFICIENT_BALANCE': 'Not enough coins',
    'GAME_NOT_FOUND': 'Game not found',
    'GAME_STARTED': 'The game has already started',
    'GAME_FULL': 'All seats are taken',
    'ALREADY_JOINED': 'You already joined this game',
    'NOT_HOST': 'Only the host can do that',
    'NEED_MORE_PLAYERS': 'More players are needed to start',
    'NOT_YOUR_TURN': 'It is not your turn',
    'INVALID_SHOT': 'That shot is not allowed',
    'STALE_VERSION': 'Game refreshed, try again',
    'GAME_ENDED': 'The game has ended',
  };

  @override
  String toString() => 'CaromException($code): $message';
}

int _int(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? fallback;
}
