import 'package:flutter/material.dart';

const _kGold = Color(0xFFF5B83D);

/// "X started a Carrom game -- join?" prompt shown to everyone else in the
/// room when the backend pushes the `created` event. [onAccept] pays the entry
/// fee and takes a seat; [onReject] just dismisses (the user can still watch).
Future<void> showCaromInvite(
  BuildContext context, {
  required String hostName,
  required String hostAvatar,
  required int entryFee,
  required bool doubles,
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
            colors: [Color(0xFF6B2E14), Color(0xFF2B1209)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CARROM',
              style: TextStyle(
                color: _kGold,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF8B4A24),
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
                    '${hostName.isEmpty ? 'Someone' : hostName} started a '
                    '${doubles ? '2 vs 2' : '1 vs 1'} Carrom game',
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
              style: const TextStyle(color: _kGold, fontSize: 14),
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
                      backgroundColor: _kGold,
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
