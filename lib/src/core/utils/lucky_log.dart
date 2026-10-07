import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Release-safe, best-effort diagnostic logger for the lucky-gift pipeline.
///
/// `print`/`log` are stripped (or hidden, e.g. Huawei) in release builds, so the
/// LUCKYFLY trace is also appended to a plain text file on the device that can be
/// pulled WITHOUT root:
///
///   adb pull /storage/emulated/0/Android/data/com.ecoapps.live/files/theme2_lucky.log
///
/// Contract:
/// - Never throws and never blocks the UI (fire-and-forget, all I/O guarded).
/// - Writes are serialized through a single internal future chain so concurrent
///   callers can't interleave or corrupt the file.
/// - If the storage path is unavailable, it silently no-ops.
/// - The file is truncated (oldest half dropped) once it exceeds [_maxBytes] so
///   it can never grow without bound.
class LuckyLog {
  LuckyLog._();

  static const String _fileName = 'app_lucky.log';
  static const int _maxBytes = 1024 * 1024; // 1 MB cap.

  /// Serializes writes so overlapping fire-and-forget calls append in order
  /// and never race on the same file handle.
  static Future<void> _chain = Future<void>.value();

  /// Resolved once and reused; null means "resolution failed / unavailable".
  static File? _file;
  static bool _resolved = false;

  /// Appends a single timestamped line. Fire-and-forget: the returned future is
  /// the internal chain, callers do NOT need to await it.
  static void write(String msg) {
    // Chain off the previous write; swallow everything so a failure can never
    // surface to the caller or the global zone guard.
    _chain = _chain.then((_) => _append(msg)).catchError((_) {});
  }

  static Future<void> _append(String msg) async {
    final file = await _resolveFile();
    if (file == null) return;
    try {
      final line = '${DateTime.now().toIso8601String()} $msg\n';
      await file.writeAsString(line, mode: FileMode.append, flush: false);
      await _capIfNeeded(file);
    } catch (_) {
      // Best-effort: ignore I/O errors (no storage, permission, full disk).
    }
  }

  static Future<File?> _resolveFile() async {
    if (_resolved) return _file;
    _resolved = true;
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return _file = null;
      _file = File('${dir.path}/$_fileName');
    } catch (_) {
      _file = null;
    }
    return _file;
  }

  /// Keeps the file under [_maxBytes] by dropping the oldest half when the cap
  /// is exceeded, so the most recent trace is always preserved.
  static Future<void> _capIfNeeded(File file) async {
    try {
      final len = await file.length();
      if (len <= _maxBytes) return;
      final content = await file.readAsString();
      final keepFrom = content.length - (_maxBytes ~/ 2);
      var trimmed = keepFrom > 0 ? content.substring(keepFrom) : content;
      // Start the truncated file on a clean line boundary.
      final nl = trimmed.indexOf('\n');
      if (nl != -1 && nl + 1 < trimmed.length) {
        trimmed = trimmed.substring(nl + 1);
      }
      await file.writeAsString(trimmed, flush: false);
    } catch (_) {
      // If trimming fails, leave the file as-is rather than risk losing data.
    }
  }
}
