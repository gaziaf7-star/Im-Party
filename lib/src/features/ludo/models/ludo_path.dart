import 'player_color.dart';

/// A simple (row, col) grid cell on the 15x15 Ludo board.
class Cell {
  final int row;
  final int col;
  const Cell(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Cell && other.row == row && other.col == col;

  @override
  int get hashCode => row * 100 + col;

  @override
  String toString() => '($row,$col)';
}

/// All the static geometry of a standard Ludo board, expressed as
/// coordinates on a 15x15 grid (rows/cols 0..14).
///
/// The 52-cell shared outer track is traced clockwise starting at
/// Green's start square. Every other color's start square sits exactly
/// 13 cells further along the same list (52 / 4 colors = 13), since the
/// board is symmetric.
class LudoPath {
  LudoPath._();

  /// The 52 shared track cells, in travel order (clockwise), index 0..51.
  static const List<Cell> track = [
    Cell(6, 1),
    Cell(6, 2),
    Cell(6, 3),
    Cell(6, 4),
    Cell(6, 5),
    Cell(5, 6),
    Cell(4, 6),
    Cell(3, 6),
    Cell(2, 6),
    Cell(1, 6),
    Cell(0, 6),
    Cell(0, 7),
    Cell(0, 8),
    Cell(1, 8),
    Cell(2, 8),
    Cell(3, 8),
    Cell(4, 8),
    Cell(5, 8),
    Cell(6, 9),
    Cell(6, 10),
    Cell(6, 11),
    Cell(6, 12),
    Cell(6, 13),
    Cell(6, 14),
    Cell(7, 14),
    Cell(8, 14),
    Cell(8, 13),
    Cell(8, 12),
    Cell(8, 11),
    Cell(8, 10),
    Cell(8, 9),
    Cell(9, 8),
    Cell(10, 8),
    Cell(11, 8),
    Cell(12, 8),
    Cell(13, 8),
    Cell(14, 8),
    Cell(14, 7),
    Cell(14, 6),
    Cell(13, 6),
    Cell(12, 6),
    Cell(11, 6),
    Cell(10, 6),
    Cell(9, 6),
    Cell(8, 5),
    Cell(8, 4),
    Cell(8, 3),
    Cell(8, 2),
    Cell(8, 1),
    Cell(8, 0),
    Cell(7, 0),
    Cell(6, 0),
  ];

  /// Index into [track] where each color enters the shared path.
  static const Map<PlayerColor, int> startIndex = {
    PlayerColor.green: 0,
    PlayerColor.yellow: 13,
    PlayerColor.blue: 26,
    PlayerColor.red: 39,
  };

  /// Cells marked as "safe" (no capturing allowed there) — every player's
  /// start square plus one star cell roughly opposite each start on the
  /// other arms, matching the star marks on a standard board.
  static const List<int> safeTrackIndices = [0, 8, 13, 21, 26, 34, 39, 47];

  /// The 6-cell colored home stretch leading into the center for each
  /// color, followed by the center finish cell (7,7).
  static const Map<PlayerColor, List<Cell>> homeStretch = {
    PlayerColor.green: [
      Cell(7, 1),
      Cell(7, 2),
      Cell(7, 3),
      Cell(7, 4),
      Cell(7, 5),
      Cell(7, 6),
    ],
    PlayerColor.yellow: [
      Cell(1, 7),
      Cell(2, 7),
      Cell(3, 7),
      Cell(4, 7),
      Cell(5, 7),
      Cell(6, 7),
    ],
    PlayerColor.blue: [
      Cell(7, 13),
      Cell(7, 12),
      Cell(7, 11),
      Cell(7, 10),
      Cell(7, 9),
      Cell(7, 8),
    ],
    PlayerColor.red: [
      Cell(13, 7),
      Cell(12, 7),
      Cell(11, 7),
      Cell(10, 7),
      Cell(9, 7),
      Cell(8, 7),
    ],
  };

  static const Cell center = Cell(7, 7);

  /// The 4 base-slot cells (inside each colored home corner) where a
  /// color's tokens sit before entering play. Arranged 2x2, matching the
  /// four dots in the screenshot.
  static const Map<PlayerColor, List<Cell>> baseSlots = {
    PlayerColor.green: [Cell(4, 1), Cell(4, 2), Cell(4, 3), Cell(4, 4)],
    PlayerColor.yellow: [Cell(4, 10), Cell(4, 11), Cell(4, 12), Cell(4, 13)],
    PlayerColor.blue: [Cell(10, 10), Cell(10, 11), Cell(10, 12), Cell(10, 13)],
    PlayerColor.red: [Cell(10, 1), Cell(10, 2), Cell(10, 3), Cell(10, 4)],
  };


  /// Total number of steps a token travels from its start square to the
  /// winning cell: 50 remaining shared-track steps (it stands on step 0 at start)
  /// + 6 colored home-stretch cells (51..56) + the centre (57), matching the
  /// server's step numbering (57 = home).
  static const int stepsToFinish = 57;

  /// Resolve a token's logical [relativeStep] (0 = just left base and
  /// standing on its own start square, up to [stepsToFinish] = finished)
  /// into a board [Cell] for the given [color].
  static Cell cellForStep(PlayerColor color, int relativeStep) {
    if (relativeStep < 0) {
      throw ArgumentError('relativeStep must be >= 0 (token is in base)');
    }
    if (relativeStep <= 50) {
      final globalIndex = (startIndex[color]! + relativeStep) % track.length;
      return track[globalIndex];
    }
    if (relativeStep <= 56) {
      return homeStretch[color]![relativeStep - 51];
    }
    return center; // 57: the centre of the board (home)
  }

  /// Whether the shared-track cell at [relativeStep] (0..50) is a safe
  /// square where tokens cannot be captured.
  static bool isSafeStep(PlayerColor color, int relativeStep) {
    if (relativeStep < 0 || relativeStep >= 51) {
      return true; // home stretch/base/finish are always safe
    }
    final globalIndex = (startIndex[color]! + relativeStep) % track.length;
    return safeTrackIndices.contains(globalIndex);
  }
}
