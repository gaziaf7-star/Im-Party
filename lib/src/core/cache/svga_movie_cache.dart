import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:general/src/core/cache/svga_cache_manager.dart';

/// In-memory cache for SVGA raw bytes.
///
/// Caches [Uint8List] instead of [MovieEntity] so each consumer gets a
/// freshly parsed entity — avoids shared-mutable-state bugs with
/// [MovieEntity.dynamicItem] (setHidden, setText, setImage) bleeding
/// across widgets.
class SvgaMovieCache {
  SvgaMovieCache._();
  static final SvgaMovieCache instance = SvgaMovieCache._();

  static const int _maxSize = 30;

  final Map<String, Uint8List> _cache = {};
  final LinkedHashSet<String> _accessOrder = LinkedHashSet<String>();
  final Map<String, Future<Uint8List?>> _inFlight = {};

  Future<MovieEntity?> loadFromUrl(String url) async {
    final bytes = await _loadBytes(
      key: url,
      producer: () async {
        final file = await SVGAAssetCacheManager().getCachedAsset(url);
        if (file == null) return null;
        return file.readAsBytes();
      },
    );
    if (bytes == null) return null;
    return SVGAParser.shared.decodeFromBuffer(bytes);
  }

  Future<MovieEntity?> loadFromAsset(String assetPath) async {
    final bytes = await _loadBytes(
      key: assetPath,
      producer: () async {
        final data = await rootBundle.load(assetPath);
        return data.buffer.asUint8List();
      },
    );
    if (bytes == null) return null;
    return SVGAParser.shared.decodeFromBuffer(bytes);
  }

  Future<MovieEntity?> loadFromFile(File file) async {
    final bytes = await _loadBytes(
      key: file.path,
      producer: () => file.readAsBytes(),
    );
    if (bytes == null) return null;
    return SVGAParser.shared.decodeFromBuffer(bytes);
  }

  bool isCached(String key) => _cache.containsKey(key);

  Future<void> preloadAssets(List<String> assetPaths) async {
    await Future.wait(assetPaths.map(loadFromAsset), eagerError: false);
  }

  Future<void> preloadUrls(List<String> urls) async {
    await Future.wait(urls.map(loadFromUrl), eagerError: false);
  }

  void evict(String key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  Future<Uint8List?> _loadBytes({
    required String key,
    required Future<Uint8List?> Function() producer,
  }) async {
    if (_cache.containsKey(key)) {
      _accessOrder
        ..remove(key)
        ..add(key);
      return _cache[key];
    }

    if (_inFlight.containsKey(key)) {
      return _inFlight[key];
    }

    final future = _fetchAndStore(key, producer);
    _inFlight[key] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<Uint8List?> _fetchAndStore(
    String key,
    Future<Uint8List?> Function() producer,
  ) async {
    try {
      final bytes = await producer();
      if (bytes == null) return null;
      _evictIfNeeded();
      _cache[key] = bytes;
      _accessOrder.add(key);
      return bytes;
    } catch (e) {
      if (kDebugMode) log('[SvgaMovieCache] Failed to load $key: $e');
      return null;
    }
  }

  void _evictIfNeeded() {
    while (_cache.length >= _maxSize && _accessOrder.isNotEmpty) {
      final oldest = _accessOrder.first;
      _accessOrder.remove(oldest);
      _cache.remove(oldest);
    }
  }
}
