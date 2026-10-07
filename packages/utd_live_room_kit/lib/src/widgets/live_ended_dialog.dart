import 'package:flutter/material.dart';

/// Shows the package's built-in "the live has ended" dialog.
///
/// Shown to every NON-host participant when the host leaves the room.
///
/// It used to print the English AND the Arabic line together, on a hardcoded
/// white surface — so an English user read half a dialog in a script they do
/// not use, sitting in a white box in a dark app. Text and colours now come
/// from the caller, and the package keeps a plain English default so it still
/// has no dependency on the host app's localization.
///
/// Resolves when the user dismisses it.
Future<void> showUTDLiveEndedDialog(
  BuildContext context, {
  String title = 'The live has ended',
  String message = 'The host has ended the live.',
  String confirmLabel = 'OK',
  Color? backgroundColor,
  Color? textColor,
  Color? secondaryTextColor,
  Color? accentColor,
}) {
  final theme = Theme.of(context);
  final surface = backgroundColor ?? theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;
  final onSurface = textColor ?? theme.colorScheme.onSurface;
  final muted = secondaryTextColor ?? onSurface.withValues(alpha: 0.70);
  final accent = accentColor ?? theme.colorScheme.primary;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.podcasts, color: accent, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14, color: muted),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}
