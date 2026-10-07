import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ReelsCacheManager extends CacheManager with ImageCacheManager {
  static const String _key = 'reelsVideoCache';

  static final ReelsCacheManager _instance = ReelsCacheManager._();
  factory ReelsCacheManager() => _instance;

  ReelsCacheManager._()
      : super(Config(
          _key,
          // WF4 CACHE-EVICT-01: video-appropriate bounds — feed videos are
          // large and short-lived, so cap object count and shorten staleness.
          stalePeriod: const Duration(days: 2),
          maxNrOfCacheObjects: 25,
        ));

  /// Returns the cached file if it exists, or null.
  /// Does NOT trigger a download.
  Future<File?> getCachedFileOrNull(String url) async {
    final fileInfo = await getFileFromCache(url);
    return fileInfo?.file;
  }
}
