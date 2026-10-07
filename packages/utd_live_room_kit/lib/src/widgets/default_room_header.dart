import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/utd_room_controller.dart';

/// Built-in header shown when the host app does not supply its own
/// `config.headerWidget`. It is intentionally minimal — a transparent bar with
/// a top [SafeArea] holding just two affordances so a room is usable out of the
/// box: a **minimize** button (left) and an **exit** button (right).
///
/// Apps that want richer chrome (room title, visitors, rank…) should pass their
/// own `headerWidget` instead — this widget is only a fallback default.
class UTDDefaultRoomHeader extends StatelessWidget {
  final UTDRoomController controller;

  /// When false the minimize button is hidden (the exit button always shows).
  /// Mirrors `UTDLiveRoomConfig.enableMinimize`.
  final bool enableMinimize;

  const UTDDefaultRoomHeader({
    super.key,
    required this.controller,
    this.enableMinimize = true,
  });

  void _minimize(BuildContext context) {
    // No-ops internally until the room is connected.
    controller.minimize.startMinimize(context);
  }

  /// Leaves the room and hands control back to the host app. Mirrors the
  /// package's own ban-exit funnel (see UTDLiveRoom._handleBanned): leave →
  /// pop to the first route → fire the host's `onClose` (e.g. exitRoom), which
  /// only tears down state and does not navigate, so the route must be popped
  /// here.
  Future<void> _exit(BuildContext context) async {
    final onClose = controller.minimize.config?.onClose;
    await controller.leave();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    onClose?.call();
  }

  void _showExitDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Leave room?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        content: const Text(
          'Keep the room running in the background, or exit completely.',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              // Use the header's (room-level) context, not the dialog context,
              // so startMinimize pops the room route rather than the dialog.
              _minimize(context);
            },
            icon: const Icon(Icons.expand_more),
            label: const Text('Keep'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              _exit(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            icon: const Icon(Icons.close),
            label: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (enableMinimize)
              _HeaderIconButton(
                icon: Icons.compress,
                tooltip: 'Minimize',
                onTap: () => _minimize(context),
              )
            else
              const SizedBox.shrink(),
            // Host-only live-duration timer (renders nothing until the host
            // goes live, and only ever appears on the host's device).
            Expanded(
              child: Center(child: _LiveTimer(controller: controller)),
            ),
            _HeaderIconButton(
              icon: Icons.close,
              tooltip: 'Exit',
              onTap: () => _showExitDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Host-only "how long the live has been running" timer.
///
/// Anchored to [UTDMediaController.liveStartedAt], which is set once when the
/// host taps "Go Live" and only ever becomes non-null on the host's own device
/// — so this widget is inherently host-only and renders nothing for audience or
/// while the host is still in the pre-live preview. It keeps ticking through
/// camera toggles and reconnects (the anchor never resets).
class _LiveTimer extends StatefulWidget {
  final UTDRoomController controller;

  const _LiveTimer({required this.controller});

  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  ValueNotifier<DateTime?> get _startedAt =>
      widget.controller.mediaController.liveStartedAt;

  @override
  void initState() {
    super.initState();
    _startedAt.addListener(_syncTicker);
    _syncTicker();
  }

  /// Starts the 1s ticker once a start time exists; stops it otherwise.
  void _syncTicker() {
    if (_startedAt.value == null) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    _tick();
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final start = _startedAt.value;
    if (start == null || !mounted) return;
    final e = DateTime.now().difference(start);
    setState(() => _elapsed = e.isNegative ? Duration.zero : e);
  }

  @override
  void dispose() {
    _startedAt.removeListener(_syncTicker);
    _ticker?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: _startedAt,
      builder: (context, start, _) {
        if (start == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _format(_elapsed),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A circular, semi-transparent icon button with a white glyph so it stays
/// legible over any room background.
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
