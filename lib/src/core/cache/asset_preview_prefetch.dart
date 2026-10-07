import 'dart:io';

import 'package:general/src/core/cache/alpha_cache_manager.dart';
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/cache/svga_cache_manager.dart';
import 'package:general/src/core/cache/vap_cache_manager.dart';
import 'package:general/src/core/cache/video_cache_manager.dart';
import 'package:general/src/core/constants/end_points.dart';
import 'package:general/src/core/utils/asset_preview_source.dart';

/// Downloads a store / backpack item into the cache its player reads from.
///
/// Each animation kind keeps its own cache directory, so the manager used to
/// fetch a file has to be the manager the widget will later look in. Routing by
/// the ware's `image_type` column got that wrong for every mislabelled row — an
/// `.svga` declared as `alpha` landed in the alpha cache and the SVGA player
/// then found nothing — which is why this keys off [AssetPreviewSource.kind]
/// instead.
class AssetPreviewPrefetch {
  const AssetPreviewPrefetch._();

  /// Returns the cached file, downloading it first if needed.
  ///
  /// [onProgress] is called with (received, total) during a download only;
  /// a cache hit returns without ever reporting progress.
  static Future<File?> ensureCached(
    AssetPreviewSource source, {
    void Function(int received, int total)? onProgress,
  }) async {
    if (!source.isPlayable) return null;

    final cached = await cachedFile(source);
    if (cached != null) return cached;

    return _download(source, onProgress);
  }

  /// The already-cached file, or null if it still has to be downloaded.
  /// Callers use this to decide whether a progress bar is worth showing at all.
  static Future<File?> cachedFile(AssetPreviewSource source) {
    if (!source.isPlayable) return Future.value(null);
    return _lookUp(source);
  }

  static Future<File?> _lookUp(AssetPreviewSource source) {
    switch (source.kind) {
      case AssetPreviewKind.svga:
        return SVGAAssetCacheManager().isExistFile(source.url);
      case AssetPreviewKind.mp4:
        return VideoAssetCacheManager().isExistFile(source.url);
      case AssetPreviewKind.vap:
        return VapAssetCacheManager().isExistFile(source.url);
      case AssetPreviewKind.alpha:
        return AlphaAssetCacheManager().isExistFile(source.url);
      case AssetPreviewKind.still:
      case AssetPreviewKind.none:
        return AssetCacheManager().isExistFile(source.url);
    }
  }

  static Future<File?> _download(
    AssetPreviewSource source,
    void Function(int, int)? onProgress,
  ) {
    final url = EndPoints.getImage(source.url);
    // total is -1 while the server withholds a content length; the caller
    // cannot draw a bar from that, so those ticks are dropped here rather than
    // at every call site.
    void report(int received, int total) {
      if (total > 0) onProgress?.call(received, total);
    }

    switch (source.kind) {
      case AssetPreviewKind.svga:
        return SVGAAssetCacheManager()
            .downloadWithProgress(url, onReceiveProgress: report);
      case AssetPreviewKind.mp4:
        return VideoAssetCacheManager()
            .downloadWithProgress(url, onReceiveProgress: report);
      case AssetPreviewKind.vap:
        return VapAssetCacheManager()
            .downloadWithProgress(url, onReceiveProgress: report);
      case AssetPreviewKind.alpha:
        return AlphaAssetCacheManager()
            .downloadWithProgress(url, onReceiveProgress: report);
      case AssetPreviewKind.still:
      case AssetPreviewKind.none:
        return AssetCacheManager()
            .downloadWithProgress(url, onReceiveProgress: report);
    }
  }
}
