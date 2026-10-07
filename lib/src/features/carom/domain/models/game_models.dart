import 'package:flutter/material.dart';

enum PieceType { white, black, queen, striker }

enum PlayerId { player1, player2, player3, player4 }

enum TeamId { teamA, teamB }

enum GameMode {
  passAndPlay,
  vsAi,
  practice,
  doubles2v2,
  onlineMultiplayer1v1,
  onlineMultiplayer2v2,
}

enum AiDifficulty { easy, medium, hard }

enum BoardTheme { tournamentRed, classicBirch, darkMahogany, tournamentIvory }

enum TurnPhase {
  positioningStriker,
  aiming,
  piecesMoving,
  evaluatingTurn,
  gameOver,
}

class PlayerState {
  final PlayerId id;
  final String name;
  final PieceType targetColor;
  final TeamId teamId;
  int score;
  int whitePocketed;
  int blackPocketed;
  bool hasQueen;

  PlayerState({
    required this.id,
    required this.name,
    required this.targetColor,
    required this.teamId,
    this.score = 0,
    this.whitePocketed = 0,
    this.blackPocketed = 0,
    this.hasQueen = false,
  });

  void reset() {
    score = 0;
    whitePocketed = 0;
    blackPocketed = 0;
    hasQueen = false;
  }
}

class TeamState {
  final TeamId id;
  final String name;
  final PieceType targetColor;
  final List<PlayerId> playerIds;
  int score;
  int whitePocketed;
  int blackPocketed;
  bool hasQueen;

  TeamState({
    required this.id,
    required this.name,
    required this.targetColor,
    required this.playerIds,
    this.score = 0,
    this.whitePocketed = 0,
    this.blackPocketed = 0,
    this.hasQueen = false,
  });

  void reset() {
    score = 0;
    whitePocketed = 0;
    blackPocketed = 0;
    hasQueen = false;
  }
}

class PlayerBaselineConfig {
  final PlayerId playerId;
  final TeamId teamId;
  final bool isVertical;
  final double fixedCoordinate;
  final double minSlider;
  final double maxSlider;
  final double defaultAimX;
  final double defaultAimY;
  final String compassDirection;

  const PlayerBaselineConfig({
    required this.playerId,
    required this.teamId,
    required this.isVertical,
    required this.fixedCoordinate,
    required this.minSlider,
    required this.maxSlider,
    required this.defaultAimX,
    required this.defaultAimY,
    required this.compassDirection,
  });
}

class BoardConfig {
  static const double boardSize = 740.0; // Standard 74x74cm playing surface
  static const double frameWidth = 45.0; // Outer wooden frame
  static const double cushionWidth = 15.0; // Elastic wooden rebound cushion
  static const double cornerPocketRadius = 28.0;
  static const double pocketHoleRadius =
      26.5; // Competitive tournament capture radius (more challenging)
  static const double pocketFunnelRadius = 38.0; // Tighter entrance mouth
  static const double pocketSinkDistance = 26.5;

  static const double pieceRadius = 15.5; // ~3.1cm
  static const double strikerRadius = 20.5; // ~4.1cm
  static const double centerCircleRadius = 80.0;
  static const double outerCircleRadius = 180.0;

  // ─────────────────────────────────────────────────────────────────────────
  // 2v2 Carrom Team Layout (standard international rules)
  //
  //               NORTH — Player 3 (Team A ↕)
  //            ┌─────────────────────────┐
  //  WEST      │                         │  EAST
  //  Player 2  │     CARROM BOARD        │  Player 4
  //  (Team B ↔)│                         │  (Team B ↔)
  //            │                         │
  //            └─────────────────────────┘
  //               SOUTH — Player 1 (Team A ↕)
  //
  //  Team A (↕) = South + North  → players face each other vertically
  //  Team B (↔) = West  + East   → players face each other horizontally
  //  Turn order clockwise from South: P1→P2→P3→P4→P1…
  // ─────────────────────────────────────────────────────────────────────────
  static const double baselineYPlayer1 = 635.0; // South  / Bottom  → Team A
  static const double baselineXPlayer2 = 105.0; // West   / Left    → Team B
  static const double baselineYPlayer3 = 105.0; // North  / Top     → Team A
  static const double baselineXPlayer4 = 635.0; // East   / Right   → Team B
  static const double baselineYPlayer2 = 105.0; // legacy 1v1 alias

  static const double baselineMinSlider = 145.0;
  static const double baselineMaxSlider = 595.0;

  static const double baselineMinX = 145.0;
  static const double baselineMaxX = 595.0;

  static PlayerBaselineConfig getBaselineConfig(
    PlayerId player, {
    bool is4PlayerMode = true,
  }) {
    switch (player) {
      case PlayerId.player1:
        // Side 1: South / Bottom → Team A
        return const PlayerBaselineConfig(
          playerId: PlayerId.player1,
          teamId: TeamId.teamA,
          isVertical: false,
          fixedCoordinate: baselineYPlayer1,
          minSlider: baselineMinSlider,
          maxSlider: baselineMaxSlider,
          defaultAimX: 0.0,
          defaultAimY: -1.0,
          compassDirection: 'South',
        );
      case PlayerId.player2:
        // In 1v1: Player 2 sits opposite at Side 3 (North / Top).
        // In 2v2: Player 2 takes Side 2 (West / Left, Team B).
        if (!is4PlayerMode) {
          return const PlayerBaselineConfig(
            playerId: PlayerId.player2,
            teamId: TeamId.teamB,
            isVertical: false,
            fixedCoordinate: baselineYPlayer3,
            minSlider: baselineMinSlider,
            maxSlider: baselineMaxSlider,
            defaultAimX: 0.0,
            defaultAimY: 1.0,
            compassDirection: 'North',
          );
        }
        return const PlayerBaselineConfig(
          playerId: PlayerId.player2,
          teamId: TeamId.teamB,
          isVertical: true,
          fixedCoordinate: baselineXPlayer2,
          minSlider: baselineMinSlider,
          maxSlider: baselineMaxSlider,
          defaultAimX: 1.0,
          defaultAimY: 0.0,
          compassDirection: 'West',
        );
      case PlayerId.player3:
        // Side 3: North / Top → Team A (Partner of Player 1 in 2v2)
        return const PlayerBaselineConfig(
          playerId: PlayerId.player3,
          teamId: TeamId.teamA,
          isVertical: false,
          fixedCoordinate: baselineYPlayer3,
          minSlider: baselineMinSlider,
          maxSlider: baselineMaxSlider,
          defaultAimX: 0.0,
          defaultAimY: 1.0,
          compassDirection: 'North',
        );
      case PlayerId.player4:
        // Side 4: East / Right → Team B (Partner of Player 2 in 2v2)
        return const PlayerBaselineConfig(
          playerId: PlayerId.player4,
          teamId: TeamId.teamB,
          isVertical: true,
          fixedCoordinate: baselineXPlayer4,
          minSlider: baselineMinSlider,
          maxSlider: baselineMaxSlider,
          defaultAimX: -1.0,
          defaultAimY: 0.0,
          compassDirection: 'East',
        );
    }
  }
}

class ShotResult {
  final List<PieceType> pocketedPieces;
  final bool strikerPocketed;
  final bool queenPocketed;

  ShotResult({
    required this.pocketedPieces,
    required this.strikerPocketed,
    required this.queenPocketed,
  });

  bool get isEmpty =>
      pocketedPieces.isEmpty && !strikerPocketed && !queenPocketed;
}

class ThemeStyling {
  final String name;
  final Color frameWoodDark;
  final Color frameWoodLight;
  final Color cushionColor;
  final Color surfaceColor;
  final Color surfaceSubtle;
  final Color linesColor;
  final Color cornerCircleColor;

  const ThemeStyling({
    required this.name,
    required this.frameWoodDark,
    required this.frameWoodLight,
    required this.cushionColor,
    required this.surfaceColor,
    required this.surfaceSubtle,
    required this.linesColor,
    required this.cornerCircleColor,
  });

  static const tournamentRed = ThemeStyling(
    name: 'Natural Teak',
    frameWoodDark: Color(0xFF1E100A),
    frameWoodLight: Color(0xFF3F2317),
    cushionColor: Color(0xFF2B160E),
    surfaceColor: Color(0xFFE8D3B5),
    surfaceSubtle: Color(0xFFDEC49F),
    linesColor: Color(0xE6141414), // crisp dark black lines as in photo
    cornerCircleColor: Color(0xFFD97706), // Rich Warm Tournament Amber Gold
  );

  static const classicBirch = ThemeStyling(
    name: 'Classic Birch',
    frameWoodDark: Color(0xFF24140D),
    frameWoodLight: Color(0xFF482716),
    cushionColor: Color(0xFF331B10),
    surfaceColor: Color(0xFFF5E8D3),
    surfaceSubtle: Color(0xFFE8D6BD),
    linesColor: Color(0xBF1C1C1C),
    cornerCircleColor: Color(0xFFB45309), // Warm Honey Bronze
  );

  static const darkMahogany = ThemeStyling(
    name: 'Dark Mahogany',
    frameWoodDark: Color(0xFF140A07),
    frameWoodLight: Color(0xFF2B160E),
    cushionColor: Color(0xFF201009),
    surfaceColor: Color(0xFFEAD4B8),
    surfaceSubtle: Color(0xFFDCC19E),
    linesColor: Color(0xBF1C1C1C),
    cornerCircleColor: Color(0xFFC28E2C), // Antique Brass Gold
  );

  static const tournamentIvory = ThemeStyling(
    name: 'Tournament Ivory',
    frameWoodDark: Color(0xFF1F120B),
    frameWoodLight: Color(0xFF3B2014),
    cushionColor: Color(0xFF2D180F),
    surfaceColor: Color(0xFFFBF4E8),
    surfaceSubtle: Color(0xFFF1E6D2),
    linesColor: Color(0xBF1C1C1C),
    cornerCircleColor: Color(0xFF92400E), // Burnished Caramel Gold
  );
}
