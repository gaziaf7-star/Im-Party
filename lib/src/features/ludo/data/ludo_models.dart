// Server-side models for the Ludo backend (see docs/LUDO_BACKEND_SPEC.md and
// the backend's Flutter integration guide).

class LudoConfig {
  final List<int> allowedFees;
  final double commissionRate;
  final int turnTimeoutSeconds;
  final int lobbyTimeoutSeconds;
  final int minPlayers;
  final int maxPlayers;

  const LudoConfig({
    required this.allowedFees,
    required this.commissionRate,
    required this.turnTimeoutSeconds,
    required this.lobbyTimeoutSeconds,
    required this.minPlayers,
    required this.maxPlayers,
  });

  static const LudoConfig fallback = LudoConfig(
    allowedFees: [0, 100, 500, 1000, 5000, 10000, 50000],
    commissionRate: 0.05,
    turnTimeoutSeconds: 7,
    lobbyTimeoutSeconds: 180,
    minPlayers: 2,
    maxPlayers: 4,
  );

  factory LudoConfig.fromJson(Map<String, dynamic> j) => LudoConfig(
    allowedFees: (j['allowed_fees'] as List? ?? fallback.allowedFees)
        .map((e) => _int(e))
        .toList(),
    commissionRate: (j['commission_rate'] as num?)?.toDouble() ?? 0.05,
    turnTimeoutSeconds: _int(j['turn_timeout_seconds'], 7),
    lobbyTimeoutSeconds: _int(j['lobby_timeout_seconds'], 180),
    minPlayers: _int(j['min_players'], 2),
    maxPlayers: _int(j['max_players'], 4),
  );
}

class LudoPlayerInfo {
  final String userId;
  final String color;
  final String name;
  final String avatar;
  final bool isHost;
  final bool finished;

  const LudoPlayerInfo({
    required this.userId,
    required this.color,
    required this.name,
    required this.avatar,
    this.isHost = false,
    this.finished = false,
  });

  factory LudoPlayerInfo.fromJson(Map j) => LudoPlayerInfo(
    userId: '${j['user_id'] ?? j['id'] ?? ''}',
    color: '${j['color'] ?? ''}',
    name: '${j['name'] ?? ''}',
    avatar: '${j['avatar'] ?? ''}',
    isHost: j['is_host'] == true,
    finished: j['finished'] == true,
  );
}

/// Full game snapshot returned by every endpoint and by `created` / `started`.
class LudoServerGame {
  final int id;
  final int roomId;
  final String hostUserId;
  final String mode; // duo | multi
  final String rule; // classic | simple
  final bool magic;
  final int entryFee;
  final int prizePool;
  final int commission;
  final String status; // lobby | playing | finished | cancelled
  final String? currentColor;
  final DateTime? turnDeadlineAt;
  final int version;
  final Map<String, List<int>> board;
  final List<LudoPlayerInfo> players;
  final String? winnerUserId;
  final int? lastDice;

  const LudoServerGame({
    required this.id,
    required this.roomId,
    required this.hostUserId,
    required this.mode,
    required this.rule,
    required this.magic,
    required this.entryFee,
    required this.prizePool,
    required this.commission,
    required this.status,
    required this.currentColor,
    required this.turnDeadlineAt,
    required this.version,
    required this.board,
    required this.players,
    required this.winnerUserId,
    required this.lastDice,
  });

  bool get isLive => status == 'lobby' || status == 'playing';

  factory LudoServerGame.fromJson(Map<String, dynamic> j) {
    final board = <String, List<int>>{};
    final rawBoard = j['board'];
    if (rawBoard is Map) {
      rawBoard.forEach((color, data) {
        final tokens = data is Map ? data['tokens'] : data;
        if (tokens is List) {
          board['$color'] = tokens.map((e) => _int(e, -1)).toList();
        }
      });
    }
    return LudoServerGame(
      id: _int(j['id']),
      roomId: _int(j['room_id']),
      hostUserId: '${j['host_user_id'] ?? ''}',
      mode: '${j['mode'] ?? 'multi'}',
      rule: '${j['rule'] ?? 'classic'}',
      magic: j['magic'] == true,
      entryFee: _int(j['entry_fee']),
      prizePool: _int(j['prize_pool']),
      commission: _int(j['commission']),
      status: '${j['status'] ?? 'lobby'}',
      currentColor: j['current_color']?.toString(),
      turnDeadlineAt: j['turn_deadline_at'] != null
          ? DateTime.tryParse('${j['turn_deadline_at']}')
          : null,
      version: _int(j['version']),
      board: board,
      players: (j['players'] as List? ?? const [])
          .whereType<Map>()
          .map(LudoPlayerInfo.fromJson)
          .toList(),
      winnerUserId: j['winner_user_id']?.toString(),
      lastDice: j['last_dice'] == null ? null : _int(j['last_dice']),
    );
  }
}

/// Error body: `{ status:false, code, message }`.
class LudoException implements Exception {
  final String code;
  final String message;

  const LudoException(this.code, this.message);

  /// Friendly text shown in toasts.
  String get friendly => _messages[code] ?? (message.isEmpty ? code : message);

  static const Map<String, String> _messages = {
    'NOT_IN_ROOM': 'You must be in the room',
    'ROOM_HAS_ACTIVE_GAME': 'A Ludo game is already running in this room',
    'INVALID_FEE': 'Invalid entry fee',
    'INSUFFICIENT_BALANCE': 'Not enough coins',
    'GAME_NOT_FOUND': 'Game not found',
    'GAME_STARTED': 'The game has already started',
    'GAME_FULL': 'All seats are taken',
    'ALREADY_JOINED': 'You already joined this game',
    'NOT_HOST': 'Only the host can do that',
    'NEED_MORE_PLAYERS': 'At least 2 players are needed to start',
    'NOT_YOUR_TURN': 'It is not your turn',
    'INVALID_MOVE': 'That move is not allowed',
    'STALE_VERSION': 'Game refreshed, try again',
    'GAME_ENDED': 'The game has ended',
  };

  @override
  String toString() => 'LudoException($code): $message';
}

int _int(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? fallback;
}
