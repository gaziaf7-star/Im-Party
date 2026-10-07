import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:path_provider/path_provider.dart';

/// A persistent, file-backed [CacheStore] for dio_cache_interceptor.
///
/// Why a hand-rolled store instead of `hive_cache_store` / `drift_cache_store`:
/// the app deliberately avoids a Hive-backed HTTP cache (classic-Hive vs
/// hive_ce conflict) and must stay Shorebird-safe, so adding one of those
/// packages was previously rejected (see DioFactory history). This store uses
/// only `dart:io` + `path_provider` (already a dependency) — no native code
/// path that breaks Shorebird, no Hive — while giving cacheable GETs (catalogs
/// + the /bootstrap aggregate) survival across app restarts on weak devices,
/// which the old [MemCacheStore] could not.
///
/// Each entry is one JSON file named by a sanitized key under a dedicated
/// subdirectory of the app-support dir (NOT Documents, so it is never iCloud/
/// auto-backed-up). Reads/writes are guarded and best-effort: any IO failure
/// degrades to a cache miss, never throws into the request path.
class FileCacheStore extends CacheStore {
  FileCacheStore({this.subDir = 'http_cache'});

  /// Subdirectory (under the app support dir) holding the cache files.
  final String subDir;

  Directory? _dir;
  Completer<Directory>? _initing;

  Future<Directory> _ensureDir() async {
    final existing = _dir;
    if (existing != null) return existing;
    if (_initing != null) return _initing!.future;

    final completer = Completer<Directory>();
    _initing = completer;
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory('${base.path}/$subDir');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _dir = dir;
      completer.complete(dir);
    } catch (e) {
      // Reset so a later call can retry; surface to the awaiting caller.
      _initing = null;
      completer.completeError(e);
    }
    return completer.future;
  }

  /// Maps an arbitrary cache key to a fixed-length, filesystem-safe filename.
  ///
  /// The key is the request URL, which can be long (query params, signed URLs).
  /// base64-encoding it produced a filename that grew with the URL and could
  /// exceed the 255-byte filename limit on most filesystems — `writeAsString`
  /// then threw, was swallowed in [set], and that endpoint became a permanent
  /// cache miss. A SHA-256 hex digest is always 64 chars, bounding the filename
  /// regardless of URL length. The original key is still stored INSIDE the JSON
  /// (`url`/`key` fields), so [getFromPath] continues to match on `resp.url`.
  String _fileName(String key) {
    final digest = sha256.convert(utf8.encode(key));
    return '${digest.toString()}.json';
  }

  Future<File> _fileFor(String key) async {
    final dir = await _ensureDir();
    return File('${dir.path}/${_fileName(key)}');
  }

  @override
  Future<bool> exists(String key) async {
    try {
      final file = await _fileFor(key);
      return file.exists();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<CacheResponse?> get(String key) async {
    try {
      final file = await _fileFor(key);
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      if (raw.isEmpty) return null;
      return _decode(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final results = <CacheResponse>[];
    try {
      final dir = await _ensureDir();
      if (!await dir.exists()) return results;
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File || !entity.path.endsWith('.json')) continue;
        try {
          final raw = await entity.readAsString();
          if (raw.isEmpty) continue;
          final resp = _decode(jsonDecode(raw) as Map<String, dynamic>);
          if (resp == null) continue;
          if (pathExists(resp.url, pathPattern, queryParams: queryParams)) {
            results.add(resp);
          }
        } catch (_) {}
      }
    } catch (_) {}
    return results;
  }

  @override
  Future<void> set(CacheResponse response) async {
    try {
      final file = await _fileFor(response.key);
      await file.writeAsString(jsonEncode(_encode(response)), flush: true);
    } catch (_) {
      // Best-effort: a failed write just means the next request re-fetches.
    }
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    try {
      final file = await _fileFor(key);
      if (!await file.exists()) return;
      if (staleOnly) {
        final resp = await get(key);
        if (resp != null && !resp.isStaled()) return;
      }
      await file.delete();
    } catch (_) {}
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    try {
      final matches =
          await getFromPath(pathPattern, queryParams: queryParams);
      for (final resp in matches) {
        await delete(resp.key);
      }
    } catch (_) {}
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    try {
      final dir = await _ensureDir();
      if (!await dir.exists()) return;
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File || !entity.path.endsWith('.json')) continue;
        try {
          if (!staleOnly && priorityOrBelow == CachePriority.high) {
            await entity.delete();
            continue;
          }
          final raw = await entity.readAsString();
          if (raw.isEmpty) {
            await entity.delete();
            continue;
          }
          final resp = _decode(jsonDecode(raw) as Map<String, dynamic>);
          if (resp == null) {
            await entity.delete();
            continue;
          }
          final priorityMatch = resp.priority.index <= priorityOrBelow.index;
          final staleMatch = !staleOnly || resp.isStaled();
          if (priorityMatch && staleMatch) {
            await entity.delete();
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    // No persistent handles to release.
  }

  // ── (de)serialization ──────────────────────────────────────────────────────

  Map<String, dynamic> _encode(CacheResponse r) => {
        'cacheControl': r.cacheControl.toHeader(),
        'content': r.content == null ? null : base64Encode(r.content!),
        'date': r.date?.toIso8601String(),
        'eTag': r.eTag,
        'expires': r.expires?.toIso8601String(),
        'headers': r.headers == null ? null : base64Encode(r.headers!),
        'key': r.key,
        'lastModified': r.lastModified,
        'maxStale': r.maxStale?.toIso8601String(),
        'priority': r.priority.index,
        'requestDate': r.requestDate.toIso8601String(),
        'responseDate': r.responseDate.toIso8601String(),
        'url': r.url,
        'statusCode': r.statusCode,
      };

  CacheResponse? _decode(Map<String, dynamic> j) {
    final key = j['key'] as String?;
    final url = j['url'] as String?;
    final requestDate = _parseDate(j['requestDate']);
    final responseDate = _parseDate(j['responseDate']);
    if (key == null ||
        url == null ||
        requestDate == null ||
        responseDate == null) {
      return null;
    }
    final priorityIndex = j['priority'] as int?;
    return CacheResponse(
      cacheControl: CacheControl.fromString(j['cacheControl'] as String?),
      content: _decodeBytes(j['content']),
      date: _parseDate(j['date']),
      eTag: j['eTag'] as String?,
      expires: _parseDate(j['expires']),
      headers: _decodeBytes(j['headers']),
      key: key,
      lastModified: j['lastModified'] as String?,
      maxStale: _parseDate(j['maxStale']),
      priority: (priorityIndex != null &&
              priorityIndex >= 0 &&
              priorityIndex < CachePriority.values.length)
          ? CachePriority.values[priorityIndex]
          : CachePriority.normal,
      requestDate: requestDate,
      responseDate: responseDate,
      url: url,
      statusCode: j['statusCode'] as int? ?? 200,
    );
  }

  List<int>? _decodeBytes(dynamic value) =>
      value is String ? base64Decode(value) : null;

  DateTime? _parseDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;
}
