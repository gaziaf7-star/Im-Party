import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:general/src/core/constants/string_manager.dart';
import 'package:general/src/core/utils/methods.dart';

/// WhatsApp-style relative time labels shared by the chats list (last activity)
/// and the chat header / profile (last seen):
///  - < 1 min   -> "Now"
///  - < 60 min  -> "N min ago"
///  - same day  -> time without seconds (h:mm a, locale-aware)
///  - yesterday -> "Yesterday"
///  - older     -> date (yyyy/MM/dd)
/// The time/date cases go through [Methods.utcToLocal] (the app's tested,
/// locale-aware UTC->local formatter), so every surface shows the same value.
class RelativeTime {
  const RelativeTime._();

  static String fromMs(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return StringManager.timeNow.tr();
    if (diff.inMinutes < 60) {
      return StringManager.timeMinutesAgo
          .tr(namedArgs: {'minutes': '${diff.inMinutes}'});
    }

    final iso = DateTime.fromMillisecondsSinceEpoch(ms).toUtc().toIso8601String();
    if (_sameDay(dt, now)) {
      return Methods.utcToLocal(iso, format: 'h:mm a');
    }
    if (_sameDay(dt, now.subtract(const Duration(days: 1)))) {
      return StringManager.timeYesterday.tr();
    }
    return Methods.utcToLocal(iso, format: 'yyyy/MM/dd');
  }

  /// Parse an ISO-8601 (UTC) string and format it. Returns null for empty/invalid
  /// input so callers can fall back to a static label.
  static String? fromIso(String? iso) {
    if (iso == null || iso.trim().isEmpty) return null;
    final dt = DateTime.tryParse(iso);
    if (dt == null) return null;
    return fromMs(dt.millisecondsSinceEpoch);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// A shared clock that fires roughly every 30s so any widget showing a
/// [RelativeTime] label ("الآن" / "منذ N دقيقة" / "آخر ظهور ...") can rebuild and
/// keep the label current even when the underlying data (drift stream / bloc
/// state) hasn't changed. Wrap the surface in a [ListenableBuilder] over
/// [RelativeTimeTicker.instance].
///
/// Self-managing: the timer only runs while at least one widget is listening and
/// stops once the last listener detaches, so no manual disposal is needed and an
/// idle screen costs nothing.
class RelativeTimeTicker extends ChangeNotifier {
  RelativeTimeTicker._();

  static final RelativeTimeTicker instance = RelativeTimeTicker._();

  static const Duration _interval = Duration(seconds: 30);

  Timer? _timer;

  void _start() {
    _timer ??= Timer.periodic(_interval, (_) => notifyListeners());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _start();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) _stop();
  }
}
