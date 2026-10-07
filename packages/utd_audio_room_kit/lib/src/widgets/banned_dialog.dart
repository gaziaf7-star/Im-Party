import 'package:flutter/material.dart';

import '../models/ban_model.dart';

/// Shows the package's built-in "you have been banned" dialog.
///
/// Self-contained (hardcoded EN text, plus an Arabic line that is only shown
/// when the ambient locale is Arabic) so the package has no dependency on the
/// host app's localization. Resolves when the user dismisses it.
Future<void> showUTDBannedDialog(BuildContext context, UTDBanNotice notice) {
  // A single-active-session takeover is NOT a ban — show a distinct title, icon
  // and accent so the user understands their account moved to another device.
  final isKick = notice.source == UTDBanSource.signedInElsewhere;
  final accent = isKick ? Colors.orange : Colors.red;
  final titleEn = isKick ? 'Signed in on another device' : 'You have been banned';
  final titleAr = isKick ? 'تم تسجيل الدخول من جهاز آخر' : 'لقد تم حظرك';
  final icon = isKick ? Icons.devices_other : Icons.block;
  // The package has no localization of its own, so read the locale Flutter
  // already resolved for this subtree instead of taking an app dependency.
  final showArabic =
      Localizations.maybeLocaleOf(context)?.languageCode == 'ar';

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(icon, color: accent, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titleEn,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showArabic) ...[
              Text(
                titleAr,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],
            ..._buildBody(notice, showArabic),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

List<Widget> _buildBody(UTDBanNotice notice, bool showArabic) {
  // Single-active-session takeover — the account is now active on another device.
  if (notice.source == UTDBanSource.signedInElsewhere) {
    return [
      const Text(
        'Your account is now active on another device.',
        style: TextStyle(fontSize: 14),
      ),
      if (showArabic) ...[
        const SizedBox(height: 4),
        const Text(
          'تم تسجيل دخول حسابك من جهاز آخر.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    ];
  }

  // Disconnect fallback — reason/expiry unknown.
  if (notice.source == UTDBanSource.disconnect) {
    return [
      const Text('You have been removed by the host.',
          style: TextStyle(fontSize: 14)),
      if (showArabic) ...[
        const SizedBox(height: 4),
        const Text(
          'تمت إزالتك بواسطة المضيف.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    ];
  }

  // Re-entry blocked by a 403 — the token error carries no reason or expiry, so
  // show a neutral message rather than incorrectly claiming the ban is permanent.
  if (notice.source == UTDBanSource.tokenForbidden) {
    return [
      const Text('You are banned from this room.',
          style: TextStyle(fontSize: 14)),
      if (showArabic) ...[
        const SizedBox(height: 4),
        const Text(
          'أنت محظور من هذه الغرفة.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    ];
  }

  final widgets = <Widget>[];

  final reason = notice.reason;
  if (reason != null && reason.trim().isNotEmpty) {
    widgets.add(Text('Reason: $reason', style: const TextStyle(fontSize: 14)));
    if (showArabic) {
      widgets.add(const SizedBox(height: 2));
      widgets.add(Text(
        'السبب: $reason',
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ));
    }
    widgets.add(const SizedBox(height: 8));
  }

  if (notice.isPermanent) {
    widgets.add(const Text('This ban is permanent.',
        style: TextStyle(fontSize: 14)));
    if (showArabic) {
      widgets.add(const SizedBox(height: 2));
      widgets.add(const Text(
        'هذا الحظر دائم.',
        style: TextStyle(fontSize: 13, color: Colors.grey),
      ));
    }
  } else {
    final until = _formatDateTime(notice.expiresAt!.toLocal());
    widgets.add(
        Text('Banned until $until.', style: const TextStyle(fontSize: 14)));
    if (showArabic) {
      widgets.add(const SizedBox(height: 2));
      widgets.add(Text(
        'محظور حتى $until.',
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ));
    }
  }

  return widgets;
}

String _formatDateTime(DateTime dt) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
}
