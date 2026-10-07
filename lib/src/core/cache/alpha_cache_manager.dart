import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:general/src/core/index.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class AlphaAssetCacheManager {
  static final AlphaAssetCacheManager _instance =
      AlphaAssetCacheManager._internal();
  factory AlphaAssetCacheManager() => _instance;
  AlphaAssetCacheManager._internal() {
    _initAsync();
  }

  Dio get _dio => di<Dio>(instanceName: 'downloadDio');
  static const String _hiveBoxName = 'alpha_cache_box';
  Box<String>? _cacheBox;

  static const int _maxCacheBytes = 300 * 1024 * 1024; // 300 MB
  // PERMANENT cache (owner spec 2026-06-11): these are admin-managed
  // assets (gift/entry effects, frames, emojis). Never age-evicted —
  // an admin edit uploads a NEW filename (new key), and the size-cap
  // LRU below reclaims space. Age kept only as a 1-year janitor for
  // keys no longer referenced by anything.
  static const Duration _maxAge = Duration(days: 365);

  // Initialization guard
  Completer<void>? _initCompleter;
  bool _isInitialized = false;

  /// Fire-and-forget initializer that catches exceptions
  void _initAsync() {
    _init().catchError((e) {
      Methods.printLog('AlphaAssetCacheManager init error: $e');
    });
  }

  Future<void> _init() async {
    await initHive();
  }

  /// Ensures Hive is initialized before any operation
  Future<void> _ensureInitialized() async {
    if (_isInitialized && _cacheBox != null) return;
    await initHive();
  }

  Future<void> initHive() async {
    // Prevent concurrent initialization
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
      Methods.printLog('Hive init error: $e');
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

  Future<void> _saveCachedAsset(String url, String path) async {
    await _ensureInitialized();
    final cleanKey = extractRelativePath(url);
    try {
      await _cacheBox?.put(cleanKey, path);
    } catch (e) {
      Methods.printLog('Failed to save cached asset: $e');
    }
  }

  Future<File?> _downloadAndCacheAsset(
    String url, {
    Function(int, int)? onReceiveProgress,
  }) async {
    final appPath = getCachePath();
    final cleanKey = extractRelativePath(url);
    final filePath = '$appPath/$cleanKey';
    final file = File(filePath);

    try {
      await file.parent.create(recursive: true);
      // Stream directly to disk to avoid holding the entire video in RAM.
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: onReceiveProgress,
      );
      await _saveCachedAsset(url, file.path);
      return file;
    } catch (e) {
      Methods.printLog('Download failed for $url: $e');
      return null;
    }
  }

  Future<File?> downloadWithProgress(
    String url, {
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final file = await getProcessedVideoFile(
        url,
        onReceiveProgress: onReceiveProgress,
      );
      return file;
    } catch (e) {
      Methods.printLog('Download failed for $url: $e');
      return null;
    }
  }

  Future<File?> getCachedAsset(
    String url, {
    Function(int, int)? onReceiveProgress,
  }) async {
    await _ensureInitialized();
    final uri_ = EndPoints.getImage(url);
    final appPath = getCachePath();
    final cleanKey = extractRelativePath(uri_);
    final file = File('$appPath/$cleanKey');

    try {
      if (await file.exists()) {
        // Verify file is readable
        final stat = await file.stat();
        if (stat.size > 0) {
          return file;
        }
      }
      return await _downloadAndCacheAsset(
        uri_,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      Methods.printLog('getCachedAsset error: $e');
      return await _downloadAndCacheAsset(
        uri_,
        onReceiveProgress: onReceiveProgress,
      );
    }
  }

  Future<File?> isExistFile(String url) async {
    final uri_ = EndPoints.getImage(url);
    final appPath = getCachePath();
    final cleanKey = extractRelativePath(uri_);
    final file = File('$appPath/$cleanKey');
    return await file.exists() ? file : null;
  }

  Future<Uint8List?> getCachedAssetAsBytes(String url) async {
    final file = await getCachedAsset(url);
    return await file?.readAsBytes();
  }

  Future<File?> getProcessedVideoFile(
    String url, {
    Function(int, int)? onReceiveProgress,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    await _ensureInitialized();

    final cleanKey = extractRelativePath(url);
    final processedKey = '${cleanKey}_processed';
    const total = 100;

    void report(int v) => onReceiveProgress?.call(v.clamp(0, total), total);

    // Phase boundaries
    const downloadEnd = 40;
    const analyzeEnd = 60;

    final cachedPath = _cacheBox?.get(processedKey);
    if (cachedPath != null) {
      final cachedFile = File(cachedPath);
      if (await cachedFile.exists()) {
        report(total);
        return cachedFile;
      } else {
        await _cacheBox?.delete(processedKey);
      }
    }

    // -------------------
    // 1) DOWNLOAD PROGRESS
    // -------------------
    final originalFile = await getCachedAsset(
      url,
      onReceiveProgress: (received, totalBytes) {
        if (totalBytes > 0) {
          final p = ((received / totalBytes) * downloadEnd).toInt();
          report(p);
        }
      },
    );

    if (originalFile == null || !await originalFile.exists()) {
      Methods.printLog('Download failed: $url');
      return null;
    }

    report(downloadEnd);

    // -------------------
    // 2) ANALYZE PHASE
    // -------------------
    String result;
    try {
      result = await ColorAnalyzer().detectColoredHalfFast(originalFile.path);
    } catch (e) {
      Methods.printLog('Analyze error: $e');
      return null;
    }

    report(analyzeEnd);

    final processedPath = '${getCachePath()}/${cleanKey}_processed.mp4';
    final processedFile = File(processedPath);

    String cmd = '';
    if (result == "left") {
      cmd = '-i "${originalFile.path}" '
          '-filter_complex "[0:v]crop=iw/2:ih:0:0[left];'
          '[0:v]crop=iw/2:ih:iw/2:0[right];'
          '[right][left]hstack=inputs=2[v]" '
          '-map "[v]" -map 0:a? -c:a copy '
          '-c:v libx264 -preset ultrafast -crf 18 '
          '"$processedPath"';
    } else if (result == "right") {
      cmd = '-i "${originalFile.path}" '
          '-filter_complex "[0:v]crop=iw/2:ih:iw/2:0[right];'
          '[0:v]crop=iw/2:ih:0:0[left];'
          '[left][right]hstack=inputs=2[v]" '
          '-map "[v]" -map 0:a? -c:a copy '
          '-c:v libx264 -preset ultrafast -crf 18 '
          '"$processedPath"';
    } else {
      return null;
    }

    // TRY TO GET DURATION (safer progress)
    double? durationSec;
    try {
      final infoSession =
          await FFprobeKit.getMediaInformation(originalFile.path);
      final info = infoSession.getMediaInformation();
      final durStr = info?.getDuration();
      durationSec = double.tryParse(durStr ?? "");
    } catch (_) {}

    // -------------------
    // 3) FFmpeg WITH PROGRESS
    // -------------------
    final ffmpegCompleter = Completer<void>();
    const ffmpegStart = analyzeEnd;
    const ffmpegEnd = total;
    bool isCompleted = false;

    void safeComplete() {
      if (!isCompleted) {
        isCompleted = true;
        if (!ffmpegCompleter.isCompleted) {
          ffmpegCompleter.complete();
        }
      }
    }

    try {
      await FFmpegKit.executeAsync(
        cmd,
        (session) async {
          try {
            final rc = await session.getReturnCode();
            if (rc == null || !rc.isValueSuccess()) {
              Methods.printLog(
                  'FFmpeg failed with return code: ${rc?.getValue()}');
            }
          } catch (e) {
            Methods.printLog('FFmpeg session error: $e');
          } finally {
            safeComplete();
          }
        },
        (log) {
          // Log callback - can be used for debugging
        },
        (stats) {
          final timeMs = stats.getTime();
          if (timeMs > 0) {
            final currentSec = timeMs / 1000.0;
            double frac;

            if (durationSec != null && durationSec > 0) {
              frac = (currentSec / durationSec).clamp(0.0, 1.0);
            } else {
              // fallback – assume 60s max
              frac = (currentSec / 60.0).clamp(0.0, 1.0);
            }

            final p = ffmpegStart + ((ffmpegEnd - ffmpegStart) * frac).toInt();
            report(p);
          }
        },
      );

      // Wait with timeout to prevent infinite hang
      await ffmpegCompleter.future.timeout(
        timeout,
        onTimeout: () {
          Methods.printLog('FFmpeg processing timed out after $timeout');
          safeComplete();
        },
      );
    } catch (e) {
      Methods.printLog('FFmpeg execution error: $e');
      safeComplete();
    }

    if (await processedFile.exists()) {
      final stat = await processedFile.stat();
      if (stat.size > 0) {
        await _cacheBox?.put(processedKey, processedPath);
        report(total);
        return processedFile;
      }
    }

    return null;
  }

  Future<int> getCacheSize() async {
    await _ensureInitialized();
    final keys = _cacheBox?.keys.cast<String>().toList() ?? [];
    int total = 0;
    for (final key in keys) {
      final path = _cacheBox?.get(key);
      if (path == null) continue;
      final file = key.endsWith('_processed') ? File(path) : File('${getCachePath()}/$key');
      if (await file.exists()) {
        total += await file.length();
      }
    }
    return total;
  }

  Future<void> evictExpiredCache() async {
    try {
      await _ensureInitialized();
      final keys = _cacheBox?.keys.cast<String>().toList() ?? [];
      if (keys.isEmpty) return;

      final appPath = getCachePath();
      final now = DateTime.now();
      final fileMeta = <_AlphaFileMeta>[];

      for (final key in keys) {
        final isProcessed = key.endsWith('_processed');
        final path = isProcessed ? _cacheBox?.get(key) : '$appPath/$key';
        if (path == null) {
          await _cacheBox?.delete(key);
          continue;
        }

        final file = File(path);
        if (!await file.exists()) {
          await _cacheBox?.delete(key);
          continue;
        }
        final stat = await file.stat();
        if (now.difference(stat.modified) > _maxAge) {
          await file.delete();
          await _cacheBox?.delete(key);
          if (!isProcessed) {
            final processedKey = '${key}_processed';
            final processedPath = _cacheBox?.get(processedKey);
            if (processedPath != null) {
              final pFile = File(processedPath);
              if (await pFile.exists()) await pFile.delete();
              await _cacheBox?.delete(processedKey);
            }
          }
        } else {
          fileMeta.add(_AlphaFileMeta(key, stat.size, stat.modified));
        }
      }

      int totalSize = fileMeta.fold(0, (sum, f) => sum + f.size);
      if (totalSize <= _maxCacheBytes) return;

      fileMeta.sort((a, b) => a.modified.compareTo(b.modified));
      for (final meta in fileMeta) {
        if (totalSize <= _maxCacheBytes) break;
        final isProcessed = meta.key.endsWith('_processed');
        final path = isProcessed ? _cacheBox?.get(meta.key) : '$appPath/${meta.key}';
        if (path != null) {
          final file = File(path);
          if (await file.exists()) await file.delete();
        }
        await _cacheBox?.delete(meta.key);
        totalSize -= meta.size;

        if (!isProcessed) {
          final processedKey = '${meta.key}_processed';
          final processedPath = _cacheBox?.get(processedKey);
          if (processedPath != null) {
            final pFile = File(processedPath);
            if (await pFile.exists()) {
              totalSize -= await pFile.length();
              await pFile.delete();
            }
            await _cacheBox?.delete(processedKey);
          }
        }
      }
    } catch (e) {
      Methods.printLog('[AlphaCache] eviction error: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _ensureInitialized();
      final keys = _cacheBox?.keys.cast<String>().toList() ?? [];
      final appPath = getCachePath();
      for (final key in keys) {
        final isProcessed = key.endsWith('_processed');
        final path = isProcessed ? _cacheBox?.get(key) : '$appPath/$key';
        if (path != null) {
          final file = File(path);
          if (await file.exists()) await file.delete();
        }
      }
      await _cacheBox?.clear();
    } catch (e) {
      Methods.printLog('[AlphaCache] clearAllCache error: $e');
    }
  }
}

class _AlphaFileMeta {
  final String key;
  final int size;
  final DateTime modified;
  const _AlphaFileMeta(this.key, this.size, this.modified);
}

class ColorAnalyzer {
  static final ColorAnalyzer _instance = ColorAnalyzer._internal();
  factory ColorAnalyzer() => _instance;
  ColorAnalyzer._internal();

  double _rgbToHue(double r, double g, double b) {
    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;

    final maxVal = max(rf, max(gf, bf));
    final minVal = min(rf, min(gf, bf));
    final delta = maxVal - minVal;

    if (delta == 0) return 0.0;

    double hue;
    if (maxVal == rf) {
      hue = ((gf - bf) / delta) % 6;
    } else if (maxVal == gf) {
      hue = ((bf - rf) / delta) + 2;
    } else {
      hue = ((rf - gf) / delta) + 4;
    }

    hue *= 60;
    if (hue < 0) hue += 360;
    return hue;
  }

  double _rgbToSaturation(double r, double g, double b) {
    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;

    final maxVal = max(rf, max(gf, bf));
    final minVal = min(rf, min(gf, bf));

    if (maxVal == 0) return 0.0;
    return (maxVal - minVal) / maxVal;
  }

  double _rgbToBrightness(double r, double g, double b) {
    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;
    return max(rf, max(gf, bf));
  }

  double _colorDiversityFromDecoded(img.Image decoded) {
    final image =
        (decoded.width > 400) ? img.copyResize(decoded, width: 400) : decoded;
    final cropH = (image.height * 0.75).floor();
    final cropped = img.copyCrop(image,
        x: 0, y: 0, width: image.width, height: max(1, cropH));

    final hueBuckets = <int>{};
    int totalColoredPixels = 0;
    double totalSaturation = 0.0;
    double totalBrightness = 0.0;

    for (int y = 0; y < cropped.height; y++) {
      for (int x = 0; x < cropped.width; x++) {
        final pixel = cropped.getPixel(x, y);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();

        final sat = _rgbToSaturation(r, g, b);
        final brightness = _rgbToBrightness(r, g, b);

        if (sat < 0.15 && brightness > 0.9) continue;
        if (sat < 0.1) continue;
        if (brightness < 0.05) continue;

        final hue = _rgbToHue(r, g, b);
        final hueBucket = (hue / 15).floor();
        hueBuckets.add(hueBucket);

        totalColoredPixels++;
        totalSaturation += sat;
        totalBrightness += brightness;
      }
    }

    if (totalColoredPixels == 0) return 0.0;

    final averageSaturation = totalSaturation / totalColoredPixels;
    final averageBrightness = totalBrightness / totalColoredPixels;
    final hueVariety = hueBuckets.length / 24.0;

    final diversity = (hueVariety * 0.45) +
        (averageSaturation * 0.5) +
        (averageBrightness * 0.05);

    if (averageSaturation < 0.15) {
      return diversity * 0.5;
    }

    return min(1.0, diversity);
  }

  Future<double> _getVideoDuration(String videoPath) async {
    final session = await FFprobeKit.getMediaInformation(videoPath);
    final info = session.getMediaInformation();
    if (info != null) {
      final durationStr = info.getDuration();
      if (durationStr != null) {
        return double.tryParse(durationStr) ?? 0.0;
      }
    }
    return 0.0;
  }

  Future<String> detectColoredHalfFast(String videoPath) async {
    final tempDir = await getTemporaryDirectory();
    final List<String> tempFiles = []; // Track temp files for cleanup

    try {
      final duration = await _getVideoDuration(videoPath);

      // Handle invalid duration
      if (duration <= 0) {
        Methods.printLog('Invalid video duration: $duration');
        return "left"; // Default fallback
      }

      final minEdge = (duration <= 5.0) ? 0.01 : 0.5;

      final times = (duration <= 5.0)
          ? List.generate(3, (i) {
              final step = duration / 4;
              return ((i + 1) * step).clamp(minEdge, duration - minEdge);
            })
          : [
              (duration * 0.25).clamp(minEdge, duration - minEdge),
              (duration * 0.5).clamp(minEdge, duration - minEdge),
              (duration * 0.75).clamp(minEdge, duration - minEdge),
            ];

      double leftSum = 0.0;
      double rightSum = 0.0;
      int successfulFrames = 0;

      for (final t in times) {
        final thumbPath =
            '${tempDir.path}/frame_${t.toStringAsFixed(2)}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        tempFiles.add(thumbPath);

        final cmd =
            '-ss $t -i "$videoPath" -vframes 1 -q:v 1 -vf scale=320:-2 "$thumbPath"';

        try {
          final session = await FFmpegKit.execute(cmd);
          final returnCode = await session.getReturnCode();

          if (returnCode == null || !returnCode.isValueSuccess()) {
            Methods.printLog('FFmpeg frame extraction failed at $t');
            continue;
          }
        } catch (e) {
          Methods.printLog('FFmpeg execute error at $t: $e');
          continue;
        }

        final thumbFile = File(thumbPath);
        if (await thumbFile.exists()) {
          try {
            final bytes = await thumbFile.readAsBytes();

            // Memory safety check
            if (bytes.isEmpty) {
              Methods.printLog('Empty frame file at $t');
              continue;
            }

            final decoded = img.decodeImage(bytes);

            if (decoded == null) {
              Methods.printLog('Failed to decode frame at $t');
              continue;
            }

            // Validate dimensions before cropping
            if (decoded.width < 2 || decoded.height < 1) {
              Methods.printLog(
                  'Invalid frame dimensions: ${decoded.width}x${decoded.height}');
              continue;
            }

            final halfW = decoded.width ~/ 2;

            // Ensure valid crop dimensions
            if (halfW < 1) {
              Methods.printLog('Invalid half width: $halfW');
              continue;
            }

            final leftImg = img.copyCrop(decoded,
                x: 0, y: 0, width: halfW, height: decoded.height);
            final rightImg = img.copyCrop(decoded,
                x: halfW,
                y: 0,
                width: decoded.width - halfW,
                height: decoded.height);

            Methods.printLog(
                'Frame at $t: Left width=${leftImg.width}, Right width=${rightImg.width}, Total width=${decoded.width}');

            leftSum += _colorDiversityFromDecoded(leftImg);
            rightSum += _colorDiversityFromDecoded(rightImg);
            successfulFrames++;
          } catch (e) {
            // Handle OutOfMemoryError and other decode exceptions
            Methods.printLog('Frame processing error at $t: $e');
            continue;
          }
        }
      }

      // Handle case where no frames were processed successfully
      if (successfulFrames == 0) {
        Methods.printLog('No frames processed successfully, using default');
        return "left";
      }

      Methods.printLog(
          'Left Sum: $leftSum, Right Sum: $rightSum (from $successfulFrames frames)');

      final result = leftSum > rightSum ? "left" : "right";
      Methods.printLog('Selected half: $result');
      return result;
    } catch (e) {
      Methods.printLog('detectColoredHalfFast error: $e');
      return "left"; // Default fallback on error
    } finally {
      // Clean up all temporary files
      for (final path in tempFiles) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          Methods.printLog('Failed to delete temp file $path: $e');
        }
      }
    }
  }
}
