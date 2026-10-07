import 'package:flutter/material.dart';

import '../api/token_api.dart';
import '../theme/utd_room_strings.dart';
import '../theme/utd_room_theme.dart';

/// Default view shown when the room fails to connect and the consumer did not
/// supply `onConnectError`. Replaces the otherwise-infinite loader with a clear
/// message and Retry / Exit actions.
class UTDConnectErrorView extends StatelessWidget {
  final UTDRoomTheme theme;
  final UTDRoomStrings strings;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  /// The error that caused the connect to fail, when known. A
  /// [UTDServiceNotAvailableException] means the engine refused because the
  /// service is not activated for the project — shown with a distinct message
  /// (and no Retry, since retrying can't help) rather than "connection failed".
  final Object? error;

  const UTDConnectErrorView({
    super.key,
    required this.theme,
    required this.strings,
    required this.onRetry,
    required this.onExit,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final notActivated = error is UTDServiceNotAvailableException;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(notActivated ? Icons.block : Icons.wifi_off,
                color: theme.danger, size: 48),
            const SizedBox(height: 16),
            Text(
              notActivated ? strings.serviceNotAvailable : strings.connectionFailed,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: theme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onExit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.onSurface,
                    side: BorderSide(
                        color: theme.onSurface.withValues(alpha: 0.4)),
                  ),
                  child: Text(strings.exit),
                ),
                // Retrying a not-activated refusal can't succeed, so offer only Exit.
                if (!notActivated) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(strings.retry),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
