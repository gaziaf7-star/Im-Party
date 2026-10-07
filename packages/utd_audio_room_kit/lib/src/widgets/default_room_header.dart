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
  /// Mirrors `UTDAudioRoomConfig.enableMinimize`.
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
  /// package's own ban-exit funnel (see UTDAudioRoom._handleBanned): leave →
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
        title: const Text('Leave room?'),
        content: const Text(
          'Keep the room running in the background, or exit completely.',
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (enableMinimize)
              _HeaderIconButton(
                icon: Icons.compress,
                tooltip: 'Minimize',
                onTap: () => _minimize(context),
              )
            else
              const SizedBox.shrink(),
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
