import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:general/src/core/index.dart';

class AssetCacheManager {
  static final AssetCacheManager _instance = AssetCacheManager._internal();
  factory AssetCacheManager() => _instance;
  AssetCacheManager._internal() {
    _initAsync();
    // A negative-cache entry is keyed by the asset's RELATIVE path, not its
    // host, so a 404 hit while EndPoints.storageURL still held its cold-start
    // bootstrap value (before /config/settings corrected it) would otherwise
    // keep poisoning that same key even after the real host is known. Drop
    // the whole negative cache the moment the storage base actually changes
    // so every such asset gets one real attempt against the correct host.
    EndPoints.storageBaseUrlVersion.addListener(_onStorageBaseUrlChanged);
  }

  void _onStorageBaseUrlChanged() {
    _missingAssets.clear();
  }
  Dio get _dio => di<Dio>(instanceName: 'downloadDio');
  static const String _hiveBoxName = 'asset_cache_box';
  Box<String>? _cacheBox;

  static const int _maxCacheBytes = 150 * 1024 * 1024; // 150 MB

  /// Cache policy (owner spec 2026-06-11):
  /// - VOLATILE (user-changeable media: avatars, room/live covers, custom
  ///   images): cache-first for [_volatileMaxAge], then auto-deleted to free
  ///   space for new content.
  /// - PERMANENT (admin-managed assets: gifts, badges, levels, VIP art,
  ///   banners — `files/`, `images/`, `banners/` prefixes): never age-evicted.
  ///   Admin edits upload a NEW filename, so the new asset is a new cache key
  ///   and the stale one falls out via the size-cap LRU.
  /// Size-cap eviction removes volatile entries first, permanent only after.
  static const Duration _volatileMaxAge = Duration(days: 4);
  static const Duration _tmpMaxAge = Duration(minutes: 5);

  static const List<String> _permanentPrefixes = [
    'files/',
    'images/',
    'banners/',
  ];

  static bool _isPermanent(String key) =>
      _permanentPrefixes.any(key.startsWith);

  // Monotonic counter to guarantee unique temp paths even when two downloads of
  // the same url start within the same microsecond.
  static int _tmpSeq = 0;

  Completer<void>? _initCompleter;
  bool _isInitialized = false;

  // In-flight network-fetch de-duplication. Keyed by the CANONICAL cleanKey
  // (extractRelativePath of the already-resolved uri_) — the SAME key the disk
  // and sync-hit paths use — so N widgets that open the same image at once share
  // ONE download instead of each starting its own. Only the network fetch is
  // shared; the cheap disk-existence check stays per-call. The shared entry is
  // removed in a try/finally (mirrors the proven SvgaMovieCache shape) to avoid
  // the remove/re-add race the reverted attempt hit.
  final Map<String, Future<File?>> _inFlightDownloads = {};

  /// Permanent-miss negative cache. A url whose download returned a definitive
  /// "not there" (HTTP 404/403/410) is recorded here so we stop re-fetching it
  /// on every rebuild / room re-entry — the widget shows its fallback (initials /
  /// placeholder) INSTANTLY instead of hammering the network N times for a file
  /// that does not exist. In-memory + TTL: cleared on restart and after
  /// [_missingTtl], so a file uploaded later is eventually retried.
  final Map<String, DateTime> _missingAssets = {};
  static const Duration _missingTtl = Duration(minutes: 10);

  bool _isMissing(String cleanKey) {
    final at = _missingAssets[cleanKey];
    if (at == null) return false;
    if (DateTime.now().difference(at) > _missingTtl) {
      _missingAssets.remove(cleanKey);
      return false;
    }
    return true;
  }

  /// Public sync check so a widget can short-circuit straight to its fallback
  /// without touching the network. [url] may be relative or absolute.
  bool isKnownMissing(String url) {
    final uri_ = EndPoints.getImage(url);
    if (uri_.isEmpty) return false;
    return _isMissing(extractRelativePath(uri_));
  }

  void _initAsync() {
    _init().catchError((e) {
      Methods.printLog('[AssetCacheManager] init error: $e');
    });
  }

  Future<void> _init() async {
    await initHive();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized && _cacheBox != null) return;
    await initHive();
  }

  Future<void> initHive() async {
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return;
    }

    if (_isInitialized && _cacheBox != null) return;

    _initCompleter = Completer<void>();

    try {
      if (!Hive.isBoxOpen(_hiveBoxName)) {
        _cacheBox = await Hive.openBox<String>(_hiveBoxName);
      } else {
        _cacheBox = Hive.box<String>(_hiveBoxName);
      }
      _isInitialized = true;
    } catch (e) {
      Methods.printLog('[AssetCacheManager] Hive init error: $e');
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

  Future<void> _saveCachedAsset(String url) async {
    final cleanKey = extractRelativePath(url);
    await _cacheBox?.put(cleanKey, cleanKey);
  }

  /// De-duplicated network fetch. [resolvedUrl] is the fully-resolved absolute
  /// url and [cleanKey] is its canonical cache key (already computed by the
  /// caller from the SAME resolved url, so the dedup key is identical to the
  /// disk/sync-hit key). Concurrent callers for the same [cleanKey] await ONE
  /// download; everyone else starts (and removes) their own entry.
  Future<File?> _downloadAndCacheAsset(String resolvedUrl, String cleanKey) {
    final inFlight = _inFlightDownloads[cleanKey];
    if (inFlight != null) {
      return inFlight;
    }

    final future = downloadWithProgress(resolvedUrl, cleanKey: cleanKey);
    _inFlightDownloads[cleanKey] = future;
    // Mirror SvgaMovieCache: remove the entry once the shared future settles,
    // whether it succeeds or fails, so a later wave can fetch again.
    future.whenComplete(() {
      // Only clear if it is still OUR entry (defensive against a stale key).
      if (identical(_inFlightDownloads[cleanKey], future)) {
        _inFlightDownloads.remove(cleanKey);
      }
    });
    return future;
  }

  Future<File?> downloadWithProgress(String url,
      {Function(int, int)? onReceiveProgress, String? cleanKey}) async {
    final appPath = getCachePath();
    cleanKey ??= extractRelativePath(url);
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
      // Stream directly to a temp file to avoid holding the whole asset in RAM,
      // then atomically move it to the final path so a failed/partial download
      // never leaves a corrupt file at the cache key.
      await _dio.download(
        url,
        tempFile.path,
        onReceiveProgress: onReceiveProgress,
      );
      await tempFile.rename(file.path);
      await _saveCachedAsset(url);
      return file;
    } catch (e) {
      // Definitive "not there" (404/403/410) => negative-cache it so we never
      // re-download a file that does not exist; transient errors (timeout /
      // network) are NOT cached so a retry on a better connection still works.
      if (e is DioException) {
        final code = e.response?.statusCode;
        if (code == 404 || code == 403 || code == 410) {
          _missingAssets[cleanKey] = DateTime.now();
        }
      }
      Methods.printLog('[AssetCacheManager] download failed for $url: $e');
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

  Future<File?> getCachedAsset(String url) async {
    await _ensureInitialized();
    final String uri_ = EndPoints.getImage(url);
    // A null/empty source resolves to '' via getImage(); never hand an empty
    // URL to Dio.download (it throws on an empty/relative path). Treat it as a
    // cache miss with no asset so callers fall back to their placeholder.
    if (uri_.isEmpty) return null;
    final appPath = getCachePath();
    final cleanKey = extractRelativePath(uri_);
    final file = File('$appPath/$cleanKey');

    if (await file.exists()) {
      if (await file.length() > 0) {
        await file.setLastModified(DateTime.now());
        return file;
      }
      await file.delete();
      await _cacheBox?.delete(cleanKey);
    }
    // Negative cache: a key that already 404/403'd this session is not on the
    // server — return null immediately (no network) so the caller shows its
    // fallback instantly instead of re-downloading on every rebuild/re-entry.
    if (_isMissing(cleanKey)) return null;

    // Miss: join (or start) the single in-flight download for this canonical
    // key. We pass uri_ (resolved) and cleanKey (computed from uri_) so the
    // dedup key matches the disk/sync-hit key exactly.
    final downloaded = await _downloadAndCacheAsset(uri_, cleanKey);

    // Display-safety: do NOT trust a (possibly-stale) shared leader result.
    // Re-verify the on-disk file so a JOINER always returns the finished file
    // by its canonical path (the same path its CacheImageWidget will FileImage).
    if (await file.exists() && await file.length() > 0) {
      return file;
    }
    // The shared download failed (timeout on a slow room-enter). Return null so
    // EACH widget runs its OWN bounded retry/backoff independently — one shared
    // failure must NOT blank all N joiners at once (the bug the revert had).
    return downloaded;
  }

  Future<File?> isExistFile(String url) async {
    final String uri_ = EndPoints.getImage(url);
    final appPath = getCachePath();
    final cleanKey = extractRelativePath(uri_);
    final file = File('$appPath/$cleanKey');
    return await file.exists() ? file : null;
  }

  Future<Uint8List?> getCachedAssetAsBytes(String url) async {
    final file = await getCachedAsset(url);
    return await file?.readAsBytes();
  }

  /// Delete a single cached entry (file + Hive key). Used to evict corrupt files.
  Future<void> evict(String url) async {
    try {
      final String uri_ = EndPoints.getImage(url);
      final cleanKey = extractRelativePath(uri_);
      final appPath = getCachePath();
      final file = File('$appPath/$cleanKey');
      if (await file.exists()) await file.delete();
      await _cacheBox?.delete(cleanKey);
    } catch (_) {}
  }

  Future<int> getCacheSize() async {
    final keys = _cacheBox?.keys.cast<String>() ?? [];
    final appPath = getCachePath();
    int total = 0;
    for (final key in keys) {
      final file = File('$appPath/$key');
      if (await file.exists()) {
        total += await file.length();
      }
    }
    return total;
  }

  Future<void> evictExpiredCache() async {
    try {
      await _ensureInitialized();
      await _sweepOrphanTemps();
      final keys = _cacheBox?.keys.cast<String>().toList() ?? [];
      if (keys.isEmpty) return;

      final appPath = getCachePath();
      final now = DateTime.now();
      final fileMeta = <_FileMeta>[];

      // Phase 1: age-evict VOLATILE entries only (permanent admin assets are
      // never deleted by age — their invalidation is the new-filename upload).
      for (final key in keys) {
        final file = File('$appPath/$key');
        if (!await file.exists()) {
          await _cacheBox?.delete(key);
          continue;
        }
        final stat = await file.stat();
        if (!_isPermanent(key) &&
            now.difference(stat.modified) > _volatileMaxAge) {
          await file.delete();
          await _cacheBox?.delete(key);
        } else {
          fileMeta.add(_FileMeta(key, stat.size, stat.modified));
        }
      }

      // Phase 2: if still over size limit, evict oldest by access time —
      // volatile entries first, permanent assets only as a last resort.
      int totalSize = fileMeta.fold(0, (sum, f) => sum + f.size);
      if (totalSize <= _maxCacheBytes) return;

      fileMeta.sort((a, b) {
        final aPerm = _isPermanent(a.key), bPerm = _isPermanent(b.key);
        if (aPerm != bPerm) return aPerm ? 1 : -1;
        return a.modified.compareTo(b.modified);
      });
      for (final meta in fileMeta) {
        if (totalSize <= _maxCacheBytes) break;
        final file = File('$appPath/${meta.key}');
        if (await file.exists()) {
          await file.delete();
        }
        await _cacheBox?.delete(meta.key);
        totalSize -= meta.size;
      }
    } catch (e) {
      Methods.printLog('[AssetCacheManager] eviction error: $e');
    }
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
      Methods.printLog('[AssetCacheManager] clearAllCache error: $e');
    }
  }
}

class _FileMeta {
  final String key;
  final int size;
  final DateTime modified;
  const _FileMeta(this.key, this.size, this.modified);
}