import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../game/game_state.dart';
import '../ludo_room_controller.dart';
import '../models/player_color.dart';
import '../services/sound_service.dart';
import 'ludo_animated_dice.dart';
import 'ludo_logo_widget.dart';

const _kYellow = Color(0xFFFFC928);

/// Replaces the room's seat grid while a Ludo game is active: a single
/// horizontally scrolling row of mic seats, then the lobby or the board. The
/// room's own chat list and bottom bar keep rendering beneath it.
class LudoRoomView extends StatelessWidget {
  final int seatCount;
  final double seatSize;
  final Widget Function(int index) seatCreator;

  const LudoRoomView({
    super.key,
    required this.seatCount,
    required this.seatSize,
    required this.seatCreator,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = LudoRoomController.instance;
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        if (!ctrl.isActive) return const SizedBox.shrink();
        final size = MediaQuery.sizeOf(context);
        final seat = seatSize.clamp(48.0, 62.0);
        final board = (size.width - 20).clamp(220.0, size.height * 0.46);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Toolbar(ctrl: ctrl),
            SizedBox(
              height: seat + 20,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: seatCount,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => SizedBox(
                  width: seat,
                  child: Column(
                    children: [
                      SizedBox(
                        width: seat,
                        height: seat,
                        // The kit sizes its seat widget to [seatSize]; scale it
                        // down to the compact row size instead of overflowing.
                        child: FittedBox(
                          child: SizedBox(
                            width: seatSize,
                            height: seatSize,
                            child: seatCreator(i),
                          ),
                        ),
                      ),
                      Text(
                        i == 0 ? 'Owner' : '$i',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            if (ctrl.phase == LudoSessionPhase.playing && ctrl.game != null)
              _BoardPanel(ctrl: ctrl, boardSize: board)
            else
              _LobbyPanel(ctrl: ctrl, height: board + 40),
          ],
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  final LudoRoomController ctrl;

  const _Toolbar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B2FF7), Color(0xFFB4177E)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: _kYellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  ctrl.rule == LudoRuleSet.classic ? 'Classic' : 'Simple',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (ctrl.entryFee > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '🪙 ${ctrl.entryFee}  •  Pool ${ctrl.prizePool}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const Spacer(),
          _ToolBtn(
            icon: Icons.question_mark_rounded,
            onTap: () => _showHelp(context),
          ),
          const SizedBox(width: 8),
          _ToolBtn(
            icon: SoundService.instance.isSoundEnabled
                ? Icons.music_note_rounded
                : Icons.music_off_rounded,
            onTap: () {
              SoundService.instance.toggleSound();
              ctrl.refresh();
            },
          ),
          const SizedBox(width: 8),
          _ToolBtn(
            icon: Icons.power_settings_new_rounded,
            color: const Color(0xFFFF3B4D),
            onTap: () => _confirmLeave(context),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A0B6B),
        title: const Text('Ludo', style: TextStyle(color: Colors.white)),
        content: Text(
          'Roll a 6 to bring a token out, then race all tokens home. '
          'Landing on an opponent captures it (not on star squares).\n\n'
          'Mode: ${ctrl.rule == LudoRuleSet.classic ? 'Classic (4 tokens home)' : 'Simple (2 tokens home)'}\n'
          'Magic: ${ctrl.magic ? 'On' : 'Off'}',
          style: const TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: _kYellow)),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    final seated = ctrl.myColor != null;
    final playing = ctrl.phase == LudoSessionPhase.playing;
    late final String title;
    late final String action;
    if (ctrl.result != null) {
      title = 'Close Ludo?';
      action = 'Close';
    } else if (ctrl.isHost && !playing) {
      title = 'Cancel the game? Entry fees are refunded.';
      action = 'Cancel game';
    } else if (seated && playing) {
      title = 'Leave the game? You will forfeit your entry fee.';
      action = 'Leave';
    } else if (seated) {
      title = 'Leave Ludo? Your entry fee is refunded.';
      action = 'Leave';
    } else {
      title = 'Close the Ludo view?';
      action = 'Close';
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A0B6B),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.leave();
            },
            child: Text(action, style: const TextStyle(color: _kYellow)),
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ToolBtn({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// Lobby
// -------------------------------------------------------------------------

class _LobbyPanel extends StatelessWidget {
  final LudoRoomController ctrl;
  final double height;

  const _LobbyPanel({required this.ctrl, required this.height});

  static const _order = [
    PlayerColor.green,
    PlayerColor.yellow,
    PlayerColor.blue,
    PlayerColor.red,
  ];

  @override
  Widget build(BuildContext context) {
    final slots = ctrl.mode == LudoLobbyMode.duo
        ? const [PlayerColor.green, PlayerColor.blue]
        : _order;
    final canJoin = ctrl.myColor == null;
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const LudoLogoWidget(scale: 0.9),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE040A0), Color(0xFF9C1F7A)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                bottom: BorderSide(color: Color(0xFF5A0E47), width: 7),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 12,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final c in slots)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: _LobbySlot(
                      color: c,
                      player: ctrl.seats[c],
                      onJoin: canJoin ? ctrl.join : null,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game mode: ${ctrl.rule == LudoRuleSet.classic ? 'Classic' : 'Simple'}'
                '     Magic: ${ctrl.magic ? 'On' : 'Off'}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              if (ctrl.entryFee > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Entry fee: ${ctrl.entryFee}     Prize pool: ${ctrl.prizePool}',
                    style: const TextStyle(color: _kYellow, fontSize: 12),
                  ),
                ),
              if (ctrl.isHost && !ctrl.canStart && !ctrl.busy)
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    'Waiting for at least 2 players…',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 118,
                child: _ActionBtn(
                  label: ctrl.isHost
                      ? 'Cancel'
                      : (ctrl.myColor != null ? 'Leave' : 'Close'),
                  filled: false,
                  onTap: ctrl.busy ? null : ctrl.leave,
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 118,
                child: _ActionBtn(
                  label: ctrl.isHost
                      ? 'Start'
                      : (canJoin
                          ? (ctrl.entryFee > 0 ? 'Join ${ctrl.entryFee}' : 'Join')
                          : 'Waiting…'),
                  filled: true,
                  onTap: ctrl.isHost
                      ? (ctrl.canStart ? ctrl.start : null)
                      : (canJoin && !ctrl.busy ? ctrl.join : null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LobbySlot extends StatelessWidget {
  final PlayerColor color;
  final LudoSeatPlayer? player;
  final VoidCallback? onJoin;

  const _LobbySlot({required this.color, required this.player, this.onJoin});

  @override
  Widget build(BuildContext context) {
    final p = player;
    return GestureDetector(
      onTap: p == null ? onJoin : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
              border: Border.all(color: color.baseColor, width: 2.5),
            ),
            child: ClipOval(
              child: p == null
                  ? Icon(
                      onJoin != null ? Icons.add_rounded : Icons.person_outline,
                      color: Colors.white70,
                    )
                  : _Avatar(url: p.avatar, name: p.name),
            ),
          ),
          Container(
            width: 58,
            height: 10,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9AD5), Color(0xFFB02A86)],
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 3)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              p?.name ?? color.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    // filled = primary (Start / Play again): cream-white 3D; else blue 3D.
    final top = filled
        ? (enabled ? const Color(0xFFFFFFFF) : const Color(0xFFE0E0E0))
        : const Color(0xFF4FA3FF);
    final bottom = filled
        ? (enabled ? const Color(0xFFD9D9D9) : const Color(0xFFBDBDBD))
        : const Color(0xFF1E6FE0);
    final edge = filled ? const Color(0xFF9E9E9E) : const Color(0xFF0D47A1);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [top, bottom],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border(bottom: BorderSide(color: edge, width: 5)),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 5)),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? const Color(0xFF7A3E00) : const Color(0xFF0B3A8A),
            fontWeight: FontWeight.w900,
            fontSize: 19,
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final String name;

  const _Avatar({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: Colors.deepPurple,
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
    if (url.isEmpty) return fallback;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

// -------------------------------------------------------------------------
// Board
// -------------------------------------------------------------------------

class _BoardPanel extends StatelessWidget {
  final LudoRoomController ctrl;
  final double boardSize;

  const _BoardPanel({required this.ctrl, required this.boardSize});

  // Quadrant origin (in board cells) per colour, matching BoardComponent.
  static const _origin = {
    PlayerColor.green: Offset(0, 0),
    PlayerColor.yellow: Offset(9, 0),
    PlayerColor.blue: Offset(9, 9),
    PlayerColor.red: Offset(0, 9),
  };

  @override
  Widget build(BuildContext context) {
    final g = ctrl.game!;
    final flame = ctrl.flame!;
    final cell = boardSize / 15;
    const pad = 6.0;
    return Container(
      width: boardSize + pad * 2,
      height: boardSize + pad * 2,
      padding: const EdgeInsets.all(pad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB5772F), Color(0xFF6B3F17)],
        ),
        border: Border.all(color: const Color(0xFF3E2410), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cell * 0.35),
              child: GameWidget(game: flame),
            ),
          ),
          for (final c in PlayerColor.values)
            if (ctrl.seats[c] != null) _quadrantInfo(c, cell, g),
          if (g.phase == TurnPhase.gameOver)
            Positioned.fill(child: _WinOverlay(ctrl: ctrl)),
        ],
      ),
    );
  }

  /// Avatar, name and (on the active player's turn) the dice, drawn inside the
  /// player's own home quadrant, on the outer side away from the tokens.
  Widget _quadrantInfo(PlayerColor c, double cell, LudoGameState g) {
    final p = ctrl.seats[c]!;
    final o = _origin[c]!;
    final top = c == PlayerColor.green || c == PlayerColor.yellow;
    final turn = g.currentPlayer == c && g.phase != TurnPhase.gameOver;
    final avatarD = cell * 2.1;
    final avatarY = top ? 0.4 : 2.75;
    final diceD = cell * 2.2;
    final diceY = top ? 0.5 : 2.85;
    final canRoll = turn && ctrl.canRollNow;
    return Positioned(
      left: o.dx * cell,
      top: o.dy * cell,
      width: cell * 6,
      height: cell * 6,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: cell * 0.55,
            top: cell * avatarY,
            child: Container(
              width: avatarD,
              height: avatarD,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: turn ? 3 : 2),
                boxShadow: turn
                    ? const [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(child: _Avatar(url: p.avatar, name: p.name)),
            ),
          ),
          if (turn && ctrl.turnEndsAt != null)
            Positioned(
              left: cell * 0.55 - cell * 0.18,
              top: cell * avatarY - cell * 0.18,
              child: IgnorePointer(
                child: _TurnRing(
                  key: ValueKey(
                    '${c.name}-${ctrl.turnEndsAt!.millisecondsSinceEpoch}',
                  ),
                  size: avatarD + cell * 0.36,
                  stroke: (cell * 0.2).clamp(3.0, 6.0),
                  endsAt: ctrl.turnEndsAt!,
                  totalMs: ctrl.turnTotalMs,
                ),
              ),
            ),
          Positioned(
            left: cell * 0.1,
            top: cell * (avatarY + 2.15),
            width: cell * 3.2,
            child: Text(
              p.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: cell * 0.42,
                fontWeight: FontWeight.w700,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 3)],
              ),
            ),
          ),
          // Every player keeps their own dice, showing THEIR last roll. The
          // active player's dice is bright and tappable; the others are dimmed
          // so nobody sees someone else's number on their own dice.
          Positioned(
            left: cell * 3.3,
            top: cell * diceY,
            width: diceD,
            height: diceD,
            child: Opacity(
              opacity: turn ? 1 : 0.55,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canRoll ? ctrl.roll : null,
                child: FittedBox(
                  child: LudoAnimatedDice(
                    diceValue: ctrl.lastRollByColor[c] ??
                        (turn ? g.lastDiceValue : null) ??
                        1,
                    isRolling: ctrl.rollingColor == c,
                    canRoll: canRoll,
                    waiting: turn && g.phase == TurnPhase.waitingForRoll,
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

class _WinOverlay extends StatelessWidget {
  final LudoRoomController ctrl;

  const _WinOverlay({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final r = ctrl.result;
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 4),
            Text(
              r == null || r.winnerName.isEmpty
                  ? 'Game over'
                  : '${r.winnerName} wins!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (r != null && r.prize > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Prize: ${r.prize} coins',
                  style: const TextStyle(color: _kYellow, fontSize: 14),
                ),
              ),
            if (r != null && r.ranking.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final e in r.ranking)
                Text(
                  '#${e.rank}  ${e.name}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: 110,
              child: _ActionBtn(label: 'Close', filled: true, onTap: ctrl.leave),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular countdown around the active player's avatar. The arc shrinks
/// smoothly to nothing and shifts green -> yellow -> red as time runs out.
class _TurnRing extends StatelessWidget {
  final double size;
  final double stroke;
  final DateTime endsAt;
  final int totalMs;

  const _TurnRing({
    super.key,
    required this.size,
    required this.stroke,
    required this.endsAt,
    required this.totalMs,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = endsAt.difference(DateTime.now()).inMilliseconds;
    final startFraction = (remaining / totalMs).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: startFraction, end: 0),
      duration: Duration(milliseconds: remaining.clamp(0, totalMs)),
      curve: Curves.linear,
      builder: (_, f, __) => CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(fraction: f, stroke: stroke),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final double stroke;

  _RingPainter({required this.fraction, required this.stroke});

  Color get _color => fraction > 0.5
      ? Color.lerp(
          const Color(0xFFFFD600),
          const Color(0xFF2EE66B),
          (fraction - 0.5) * 2,
        )!
      : Color.lerp(
          const Color(0xFFFF3B4D),
          const Color(0xFFFFD600),
          fraction * 2,
        )!;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = stroke / 2;
    final arc = rect.deflate(inset);
    canvas.drawArc(
      arc,
      0,
      6.2831853,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.black26,
    );
    if (fraction <= 0) return;
    canvas.drawArc(
      arc,
      -1.5707963,
      6.2831853 * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke
        ..color = _color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.stroke != stroke;
}
