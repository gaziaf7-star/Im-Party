import 'package:flutter/material.dart';

import '../../theme/utd_room_scope.dart';

/// Shows a brief snackbar using the nearest [ScaffoldMessenger]. Safe no-op if
/// the context is no longer mounted or has no messenger.
void utdShowSnack(BuildContext context, String message) {
  if (!context.mounted) return;
  utdShowSnackVia(ScaffoldMessenger.maybeOf(context), message);
}

/// Shows a snackbar via an already-captured [ScaffoldMessengerState].
///
/// Use this when the originating context will be popped before the snackbar
/// fires — e.g. a sheet action that pops the sheet, then awaits an API call and
/// only then reports failure. Capture the messenger *before* the pop
/// (`ScaffoldMessenger.maybeOf(context)`) and call this after; otherwise the
/// snackbar is keyed on the now-defunct sheet context and never appears.
void utdShowSnackVia(ScaffoldMessengerState? messenger, String message) {
  messenger
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

/// Shows a themed modal bottom sheet for the package's built-in default UI.
///
/// Modal sheets are pushed as a separate route that does NOT inherit the room's
/// [UTDRoomScope]. This helper captures the scope from [context] before showing
/// and re-wraps the sheet body in a fresh [UTDRoomScope], so nested default UI
/// (and [UTDRoomScope.of] inside the sheet) keeps working.
Future<T?> showUTDRoomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final scope = UTDRoomScope.maybeOf(context);
  final theme = scope?.theme;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme?.sheetBackground ?? const Color(0xFF1C1C1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      final body = SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (theme != null) ...[
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.sheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Flexible(child: builder(sheetContext)),
          ],
        ),
      );
      // Re-establish the scope inside the sheet's own route.
      return scope == null
          ? body
          : UTDRoomScope(
              theme: scope.theme,
              strings: scope.strings,
              controller: scope.controller,
              showSeatNames: scope.showSeatNames,
              hostSeatIndex: scope.hostSeatIndex,
              roomOwnerId: scope.roomOwnerId,
              child: body,
            );
    },
  );
}

/// A compact, in-context error banner for use INSIDE a modal sheet that stays
/// open after a failed action (member list, request queue, ban list). A snackbar
/// there renders *behind* the sheet, so these sheets surface failures inline
/// instead. Pair with a `String?` state field that you set on failure and clear
/// after a few seconds.
class UTDSheetInlineError extends StatelessWidget {
  final String message;

  const UTDSheetInlineError(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final danger = UTDRoomScope.maybeOf(context)?.theme.danger ?? Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: danger),
          const SizedBox(width: 6),
          Expanded(
            child: Text(message,
                style: TextStyle(color: danger, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// A simple tappable row used inside the default sheets: leading icon + label,
/// with an optional destructive color.
class UTDSheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const UTDSheetAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scope = UTDRoomScope.maybeOf(context);
    final fg = color ?? scope?.theme.onSurface ?? Colors.white;
    return ListTile(
      leading: Icon(icon, color: fg),
      title: Text(label, style: TextStyle(color: fg)),
      onTap: onTap,
    );
  }
}
