import 'package:flutter/material.dart';

import 'ludo_logo_widget.dart';

const _kYellow = Color(0xFFFFC928);

/// "X created a Ludo game — join?" prompt shown to everyone else in the room
/// when the backend pushes the `created` event. [onAccept] pays the entry fee
/// and takes a seat; [onReject] just dismisses (the user can still watch).
Future<void> showLudoInvite(
  BuildContext context, {
  required String hostName,
  required String hostAvatar,
  required int entryFee,
  required VoidCallback onAccept,
  required VoidCallback onReject,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B2FF7), Color(0xFF3A0CA3)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LudoLogoWidget(scale: 0.6, showSubtitle: false),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepPurple,
                  backgroundImage:
                      hostAvatar.isEmpty ? null : NetworkImage(hostAvatar),
                  child: hostAvatar.isEmpty
                      ? Text(
                          hostName.isEmpty ? '?' : hostName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    '${hostName.isEmpty ? 'Someone' : hostName} started a Ludo game',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entryFee > 0 ? 'Entry fee: $entryFee coins' : 'Free to join',
              style: const TextStyle(color: _kYellow, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      onReject();
                      Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onAccept();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kYellow,
                      foregroundColor: const Color(0xFF3A1C00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
