import 'dart:async';
import 'dart:io';
import 'package:general/src/core/index.dart';

class SvgCacheManager {
  static final SvgCacheManager _instance = SvgCacheManager._internal();

  factory SvgCacheManager() => _instance;

  SvgCacheManager._internal() {
    _initAsync();
  }

  Dio get _dio => di<Dio>(instanceName: 'downloadDio');
  static const String _hiveBoxName = 'svg_cache_box';
  static const int _maxCacheBytes = 30 * 1024 * 1024; // 30 MB
  // PERMANENT cache (owner spec 2026-06-11): these are admin-managed
  // assets (gift/entry effects, frames, emojis). Never age-evicted —
  // an admin edit uploads a NEW filename (new key), and the size-cap
  // LRU below reclaims space. Age kept only as a 1-year janitor for
  // keys no longer referenced by anything.
  static const Duration _maxAge = Duration(days: 365);
  static const Duration _tmpMaxAge = Duration(minutes: 5);

  // Monotonic counter to guarantee unique temp paths even when two downloads of
  // the same url start within the same microsecond.
  static int _tmpSeq = 0;

  Box? _cacheBox;

  Completer<void>? _initCompleter;
  bool _isInitialized = false;

  void _initAsync() {
    _init().catchError((e) {
      Methods.printLog('[SvgCache] init error: $e');
    });
  }

  Future _init() async {
    await initHive();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized && _cacheBox != null) return;
    await initHive();
  }

  Future initHive() async {
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return;
    }

    if (_isInitialized && _cacheBox != null) return;

    _initCompleter = Completer<void>();

    try {
      if (!Hive.isBoxOpen(_hiveBoxName)) {
        _cacheBox = await Hive.openBox(_hiveBoxName);
      } else {
        _cacheBox = Hive.box(_hiveBoxName);
      }
      _isInitialized = true;
    } catch (e) {
      Methods.printLog('[SvgCache] Hive init error: $e');
      rethrow;
    } finally {
      _initCompleter!.complete();
      _initCompleter = null;
    }
  }

  String extractRelativePath(String url) {
    String prefix = EndPoints.storageURL;
    final index = url.indexOf(prefix);
    if (index != -1) {
      return url.substring(index + prefix.length);
    }
    return url;
  }

  String getCachePath() {
    return EndPoints.localPath;
  }

  Future _saveCachedSvg(String url) async {
    final cleanKey = extractRelativePath(url);
    await _cacheBox?.put(cleanKey, cleanKey);
  }

  /// Downloads and caches an SVG file
  Future<File?> _downloadAndCacheSvg(String url) async {
    return downloadWithProgress(url);
  }

  /// Downloads and caches an SVG file with progress
  Future<File?> downloadWithProgress(String url,
      {Function(int, int)? onReceiveProgress}) async {
    final appPath = getCachePath();
    final cleanKey = extractRelativePath(url);
    final file = File('$appPath/$cleanKey');
    // Unique temp path in the SAME directory as the final file so the rename
    // stays intra-filesystem/atomic, and so two concurrent downloads of the
    // same url never share a temp file (which would interleave bytes and
    // corrupt the final asset). Each temp is fully written before its rename,
    // so last-writer-wins still produces a COMPLETE file.
    final tempFile = File(
        '${file.path}.${DateTime.now().microsecondsSinceEpoch}_${_tmpSeq++}.tmp');

    try {
      await file.parent.create(recursive: true);
      // Stream directly to a temp file, then atomically move it to the final
      // path so a failed/partial download never leaves a corrupt file at the
      // cache key.
      await _dio.download(
        url,
        tempFile.path,
        onReceiveProgress: onReceiveProgress,
      );
      await tempFile.rename(file.path);
      await _saveCachedSvg(url);
      return file;
    } catch (_) {
      if (await tempFile.exists()) {
        await tempFile.delete().catchError((_) => tempFile);
      }
      return null;
    }
  }

  // Best-effort sweep of leftover "*.tmp" files (from app-kill or rename-loser
  // races) older than [_tmpMaxAge]. Stale temps are not tracked in Hive, so
  // they would otherwise accumulate and evade the size cap.
  Future<void> _sweepOrphanTemps() async {
    try {
      final appPath = getCachePath();
      final dir = Directory(appPath);
      if (!await dir.exists()) return;
      final now = DateTime.now();
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is! File || !entity.path.endsWith('.tmp')) continue;
        try {
          final stat = await entity.stat();
          if (now.difference(stat.modified) > _tmpMaxAge) {
            await entity.delete();
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Returns a cached SVG file if available, otherwise downloads it
  Future<File?> getCachedSvg(String url) async {
    await _ensureInitialized();
    final String uri_ = EndPoints.getImage(url);
    if (!uri_.endsWith('.svg')) return null; // Only handle SVGs

    final appPath = getCachePath();
    final cleanKey = extractRelativePath(uri_);
    final file = File('$appPath/$cleanKey');

    if (await file.exists()) {
      final stat = await file.stat();
      if (stat.size > 0) {
        await file.setLastModified(DateTime.now());
        return file;
      }
      await file.delete();
      await _cacheBox?.delete(cleanKey);
    }
    return await _downloadAndCacheSvg(uri_);
  }

  /// Checks if the SVG file already exists locally
  Future<File?> isExistSvg(String url) async {
    final String uri_ = EndPoints.getImage(url);
    if (!uri_.endsWith('.svg')) return null;

    final appPath = getCachePath();
    final cleanKey = extractRelativePath(uri_);
    final file = File('$appPath/$cleanKey');

    return await file.exists() ? file : null;
  }

  /// Returns the SVG file bytes (e.g., for rendering with flutter_svg)
  Future<List<int>?> getCachedSvgAsBytes(String url) async {
    final file = await getCachedSvg(url);
    return await file?.readAsBytes();
  }

  Future<void> clearAllCache() async {
    try {
      await _ensureInitialized();
      final keys = _cacheBox?.keys.cast<String>().toList() ?? [];
      final appPath = getCachePath();
      for (final key in keys) {
        final file = File('$appPath/$key');
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _cacheBox?.clear();
    } catch (e) {
      Methods.printLog('[SvgCache] clearAllCache error: $e');
    }
  }

  Future<void> evictExpiredCache() async {
    try {
      await _ensureInitialized();
      await _sweepOrphanTemps();
      final keys = _cacheBox?.keys.cast<String>().toList() ?? [];
      if (keys.isEmpty) return;

      final appPath = getCachePath();
      final now = DateTime.now();
      final fileMeta = <_SvgFileMeta>[];

      for (final key in keys) {
        final file = File('$appPath/$key');
        if (!await file.exists()) {
          await _cacheBox?.delete(key);
          continue;
        }
        final stat = await file.stat();
        if (now.difference(stat.modified) > _maxAge) {
          await file.delete();
          await _cacheBox?.delete(key);
        } else {
          fileMeta.add(_SvgFileMeta(key, stat.size, stat.modified));
        }
      }

      int totalSize = fileMeta.fold(0, (sum, f) => sum + f.size);
      if (totalSize <= _maxCacheBytes) return;

      fileMeta.sort((a, b) => a.modified.compareTo(b.modified));
      for (final meta in fileMeta) {
        if (totalSize <= _maxCacheBytes) break;
        final file = File('$appPath/${meta.key}');
        if (await file.exists()) await file.delete();
        await _cacheBox?.delete(meta.key);
        totalSize -= meta.size;
      }
    } catch (e) {
      // Eviction is best-effort; don't crash the app.
    }
  }
}

class _SvgFileMeta {
  final String key;
  final int size;
  final DateTime modified;
  const _SvgFileMeta(this.key, this.size, this.modified);
}
