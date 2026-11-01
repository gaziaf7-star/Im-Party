import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/daily_prize/view/daily_prize_dialog.dart';

/// Floating calendar shortcut on Home that opens the daily reward dialog.
///
/// Must be placed directly in a [Stack]: it fills the stack and positions
/// itself. Starts at the bottom-right corner, can be dragged anywhere, and
/// snaps to the nearest side when released. Bobs gently so it reads as
/// tappable.
class DailyRewardFloatingButton extends StatefulWidget {
  final double size;

  const DailyRewardFloatingButton({super.key, this.size = 64});

  @override
  State<DailyRewardFloatingButton> createState() =>
      _DailyRewardFloatingButtonState();
}

class _DailyRewardFloatingButtonState extends State<DailyRewardFloatingButton>
    with SingleTickerProviderStateMixin {
  static const double _sideMargin = 8;
  static const double _bottomMargin = 20;

  /// Where the user left it, kept for the session so it doesn't jump back
  /// when Home is rebuilt.
  static Offset? _savedPosition;

  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  Offset? _position;
  bool _dragging = false;

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  Offset _clamp(Offset p, Size area) {
    final s = widget.size;
    return Offset(
      p.dx.clamp(_sideMargin, area.width - s - _sideMargin),
      p.dy.clamp(_sideMargin, area.height - s - _bottomMargin),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(builder: (context, c) {
        final area = Size(c.maxWidth, c.maxHeight);
        final s = widget.size;
        final defaultPos = Offset(
          area.width - s - _sideMargin,
          area.height - s - _bottomMargin,
        );
        final pos = _clamp(_position ?? _savedPosition ?? defaultPos, area);

        return Stack(
          children: [
            AnimatedPositioned(
              // Follow the finger instantly; animate only the snap.
              duration: _dragging
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              left: pos.dx,
              top: pos.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => DailyPrizeDialog.show(context),
                onPanStart: (_) => setState(() {
                  _dragging = true;
                  _position = pos;
                }),
                onPanUpdate: (d) => setState(
                  () => _position = _clamp(pos + d.delta, area),
                ),
                onPanEnd: (_) => setState(() {
                  _dragging = false;
                  // Snap to the nearest side.
                  final snapX = pos.dx + s / 2 < area.width / 2
                      ? _sideMargin
                      : area.width - s - _sideMargin;
                  _position = _clamp(Offset(snapX, pos.dy), area);
                  _savedPosition = _position;
                }),
                child: AnimatedBuilder(
                  animation: _bob,
                  builder: (_, child) => Transform.translate(
                    offset: _dragging
                        ? Offset.zero
                        : Offset(
                            0, -4 * Curves.easeInOut.transform(_bob.value)),
                    child: child,
                  ),
                  child: Image.asset(
                    AssetsManager.dailyRewardIcon,
                    width: s,
                    height: s,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
