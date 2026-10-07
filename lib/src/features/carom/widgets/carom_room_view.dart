import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';

import '../carom_room_controller.dart';
import '../domain/models/game_models.dart';
import '../game/carom_game.dart';
import '../services/carom_audio_service.dart';

const _kGold = Color(0xFFF5B83D);
const _kDark = Color(0xFF3A1A0B);

/// Replaces the room's seat grid while a Carrom game is active: a single
/// horizontally scrolling row of mic seats, then the lobby or the board. The
/// room's own chat list and bottom bar keep rendering beneath it.
class CaromRoomView extends StatelessWidget {
  final int seatCount;
  final double seatSize;
  final Widget Function(int index) seatCreator;

  const CaromRoomView({
    super.key,
    required this.seatCount,
    required this.seatSize,
    required this.seatCreator,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = CaromRoomController.instance;
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        if (!ctrl.isActive) return const SizedBox.shrink();
        final size = MediaQuery.sizeOf(context);
        final seat = seatSize.clamp(48.0, 62.0);
        final board = (size.width - 20).clamp(220.0, size.height * 0.40);
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
            const SizedBox(height: 6),
            if (ctrl.phase == CaromSessionPhase.playing && ctrl.flame != null)
              _BoardPanel(ctrl: ctrl, boardSize: board)
            else
              _LobbyPanel(ctrl: ctrl, height: board + 70),
          ],
        );
      },
    );
  }
}

// -------------------------------------------------------------------------
// Toolbar
// -------------------------------------------------------------------------

class _Toolbar extends StatelessWidget {
  final CaromRoomController ctrl;

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
                colors: [Color(0xFFB4601A), Color(0xFF6B2E14)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.adjust_rounded, color: _kGold, size: 16),
                const SizedBox(width: 4),
                Text(
                  ctrl.isDoubles ? 'Carrom 2v2' : 'Carrom 1v1',
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
            icon: CaromAudio.instance.soundEnabled
                ? Icons.music_note_rounded
                : Icons.music_off_rounded,
            onTap: () {
              CaromAudio.instance.soundEnabled =
                  !CaromAudio.instance.soundEnabled;
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
        backgroundColor: _kDark,
        title: const Text('Carrom', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Slide the striker along your line, pull back from it to aim '
          'and release to shoot. Pocket your own coins to keep the turn. '
          'Cover the Queen right after pocketing it. A pocketed striker is '
          'a foul. Clear all your coins after covering the Queen to win.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: _kGold)),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    final seated = ctrl.mySeat != null;
    final playing = ctrl.phase == CaromSessionPhase.playing;
    late final String title;
    late final String action;
    if (ctrl.result != null) {
      title = 'Close Carrom?';
      action = 'Close';
    } else if (ctrl.isHost && !playing) {
      title = 'Cancel the game? Entry fees are refunded.';
      action = 'Cancel game';
    } else if (seated && playing) {
      title = 'Leave the game? You will forfeit your entry fee.';
      action = 'Leave';
    } else if (seated) {
      title = 'Leave Carrom? Your entry fee is refunded.';
      action = 'Leave';
    } else {
      title = 'Close the Carrom view?';
      action = 'Close';
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kDark,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
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
            child: Text(action, style: const TextStyle(color: _kGold)),
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
  final CaromRoomController ctrl;
  final double height;

  const _LobbyPanel({required this.ctrl, required this.height});

  @override
  Widget build(BuildContext context) {
    final canJoin = ctrl.mySeat == null;
    final need = ctrl.seatCount;
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'CARROM',
            style: TextStyle(
              color: _kGold,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB4601A), Color(0xFF6B2E14)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                bottom: BorderSide(color: Color(0xFF3A1A0B), width: 7),
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
                for (final s in ctrl.lobbySeats)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: _LobbySlot(
                      seat: s,
                      player: ctrl.seats[s],
                      doubles: ctrl.isDoubles,
                      onJoin: canJoin && !ctrl.busy ? ctrl.join : null,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ctrl.isDoubles
                    ? '2 vs 2 • partners sit opposite each other'
                    : '1 vs 1',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              if (ctrl.entryFee > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Entry fee: ${ctrl.entryFee}     Prize pool: ${ctrl.prizePool}',
                    style: const TextStyle(color: _kGold, fontSize: 12),
                  ),
                ),
              if (ctrl.isHost && !ctrl.canStart && !ctrl.busy)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Waiting for $need players…',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
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
                      : (ctrl.mySeat != null ? 'Leave' : 'Close'),
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
                            ? (ctrl.entryFee > 0
                                  ? 'Join ${ctrl.entryFee}'
                                  : 'Join')
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
  final PlayerId seat;
  final CaromSeatPlayer? player;
  final bool doubles;
  final VoidCallback? onJoin;

  const _LobbySlot({
    required this.seat,
    required this.player,
    required this.doubles,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final p = player;
    final white = seat == PlayerId.player1 || seat == PlayerId.player3;
    final label = doubles
        ? 'Team ${white ? 'A' : 'B'}'
        : (seat == PlayerId.player1 ? 'White' : 'Black');
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
              border: Border.all(
                color: white ? Colors.white : const Color(0xFF1B1B1B),
                width: 3,
              ),
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
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              p?.name ?? label,
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
    final top = filled
        ? (enabled ? const Color(0xFFFFFFFF) : const Color(0xFFE0E0E0))
        : const Color(0xFFE9A23B);
    final bottom = filled
        ? (enabled ? const Color(0xFFD9D9D9) : const Color(0xFFBDBDBD))
        : const Color(0xFFB4601A);
    final edge = filled ? const Color(0xFF9E9E9E) : const Color(0xFF6B2E14);
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
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? const Color(0xFF7A3E00) : Colors.white,
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
      color: const Color(0xFF8B4A24),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
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
  final CaromRoomController ctrl;
  final double boardSize;

  const _BoardPanel({required this.ctrl, required this.boardSize});

  @override
  Widget build(BuildContext context) {
    final game = ctrl.flame!;
    final myTurn = ctrl.isMyTurn;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PlayersBar(ctrl: ctrl),
        const SizedBox(height: 6),
        SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              DecoratedBox(
                position: DecorationPosition.background,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: RotatedBox(
                  quarterTurns: ctrl.quarterTurns,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: BoardConfig.boardSize,
                        height: BoardConfig.boardSize,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: RepaintBoundary(
                                child: GameWidget<CaromGame>(game: game),
                              ),
                            ),
                            if (myTurn)
                              Positioned.fill(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onPanStart: (d) =>
                                      ctrl.aimStart(d.localPosition),
                                  onPanUpdate: (d) =>
                                      ctrl.aimUpdate(d.localPosition),
                                  onPanEnd: (_) => ctrl.aimEnd(),
                                  onPanCancel: ctrl.aimEnd,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: IgnorePointer(
                  child: ValueListenableBuilder<CaromNotice?>(
                    valueListenable: ctrl.notice,
                    builder: (_, n, __) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: n == null
                          ? const SizedBox.shrink(key: ValueKey('none'))
                          : Container(
                              key: ValueKey(n.text),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.78),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: n.color, width: 1.5),
                              ),
                              child: Text(
                                n.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: n.color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              if (ctrl.result != null)
                Positioned.fill(child: _WinOverlay(ctrl: ctrl)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _Controls(ctrl: ctrl, width: boardSize),
      ],
    );
  }
}

/// One chip per side: avatar (with the shrinking turn ring on the active
/// player), name, score and how many of their coins are pocketed.
class _PlayersBar extends StatelessWidget {
  final CaromRoomController ctrl;

  const _PlayersBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final seats = ctrl.lobbySeats;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          for (final s in seats)
            Expanded(
              child: _PlayerChip(
                ctrl: ctrl,
                seat: s,
                compact: seats.length > 2,
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final CaromRoomController ctrl;
  final PlayerId seat;
  final bool compact;

  const _PlayerChip({
    required this.ctrl,
    required this.seat,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final p = ctrl.seats[seat];
    final active = ctrl.activeSeat == seat && ctrl.result == null;
    final color = ctrl.colorOf(seat);
    final white = color == PieceType.white;
    final size = compact ? 34.0 : 40.0;
    final out = p?.forfeited ?? false;
    final total = ctrl.piecesPocketed(color);
    final endsAt = ctrl.turnEndsAt;
    return Opacity(
      opacity: out ? 0.4 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: active ? 0.5 : 0.28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? _kGold : Colors.white12,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: size + 6,
              height: size + 6,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (active && endsAt != null && !ctrl.isSimulating)
                    _TurnRing(
                      key: ValueKey(endsAt),
                      size: size + 6,
                      stroke: 3,
                      endsAt: endsAt,
                      totalMs: ctrl.turnTotalMs,
                    ),
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: white ? Colors.white : const Color(0xFF1B1B1B),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: p == null
                          ? const Icon(
                              Icons.person_outline,
                              color: Colors.white54,
                              size: 18,
                            )
                          : _Avatar(url: p.avatar, name: p.name),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    out ? 'Forfeited' : (p?.name ?? '—'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${ctrl.scores[seat] ?? 0} pts  ${white ? '⚪' : '⚫'} $total/9',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _kGold, fontSize: 10),
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

/// Striker slider + status line under the board.
class _Controls extends StatelessWidget {
  final CaromRoomController ctrl;
  final double width;

  const _Controls({required this.ctrl, required this.width});

  @override
  Widget build(BuildContext context) {
    final myTurn = ctrl.isMyTurn;
    final seated = ctrl.mySeat != null;
    final active = ctrl.seats[ctrl.activeSeat];
    final queen = switch (ctrl.queenStatus) {
      'waitingForCover' => '👑 cover it!',
      'covered' => '👑 covered',
      _ => '👑 on board',
    };
    final String status;
    if (ctrl.result != null) {
      status = 'Game over';
    } else if (myTurn) {
      status = 'Your turn — slide, pull back and release';
    } else if (ctrl.isSimulating) {
      status = 'Shot in play…';
    } else if (seated && ctrl.mySeat == ctrl.activeSeat) {
      status = 'Checking the shot…';
    } else {
      status = '${active?.name ?? 'Player'}\'s turn';
    }
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: myTurn ? _kGold : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: ctrl.secondsLeft,
                builder: (_, s, __) => Text(
                  s > 0 ? '${s}s   ' : '',
                  style: TextStyle(
                    color: s <= 5 ? const Color(0xFFFF3B4D) : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                queen,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 34,
            child: Opacity(
              opacity: myTurn ? 1 : 0.35,
              child: IgnorePointer(
                ignoring: !myTurn,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 10,
                    activeTrackColor: _kGold,
                    inactiveTrackColor: Colors.black38,
                    thumbColor: Colors.white,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: ctrl.sliderFraction,
                    onChanged: ctrl.setSliderFraction,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
            child: ValueListenableBuilder<double>(
              valueListenable: ctrl.aimPower,
              builder: (_, p, __) => ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: p,
                  backgroundColor: Colors.white12,
                  color: Color.lerp(
                    const Color(0xFF2EE66B),
                    const Color(0xFFFF3B4D),
                    p,
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
  final CaromRoomController ctrl;

  const _WinOverlay({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final r = ctrl.result;
    final names = r == null ? '' : r.winnerNames.where((n) => n.isNotEmpty).join(' & ');
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 4),
          Text(
            r == null || names.isEmpty
                ? 'Game over'
                : (r.iWon ? 'You win!' : '$names wins!'),
            textAlign: TextAlign.center,
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
                style: const TextStyle(color: _kGold, fontSize: 14),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: 110,
            child: _ActionBtn(label: 'Close', filled: true, onTap: ctrl.leave),
          ),
        ],
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
    final arc = (Offset.zero & size).deflate(stroke / 2);
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
