import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:general/src/core/constants/color_manager.dart';
import 'package:general/src/core/constants/string_manager.dart';
import 'package:general/src/core/utils/media_auto_download_prefs.dart';
import 'package:general/src/core/widgets/image_view_widget.dart';

/// WhatsApp-style lazy image with tap-to-download.
///
/// Behaviour:
///   - On first build it asks [MediaAutoDownloadPrefs.shouldAutoDownload]:
///     if auto-download is enabled AND the current network policy permits,
///     the image streams in immediately as before.
///   - Otherwise it shows a tappable placeholder (cloud + size, like WhatsApp);
///     tapping the placeholder loads it manually (and caches it via the
///     standard [ImageViewWidget] cache — subsequent views are instant).
///
/// Designed as a drop-in for chat-media [ImageViewWidget] usages; the same
/// width/height/borderRadius/boxFit knobs work the same way.
class LazyMediaImage extends StatefulWidget {
  const LazyMediaImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.boxFit,
    this.borderRadius,
    this.placeholderColor,
  });

  final String url;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;

  @override
  State<LazyMediaImage> createState() => _LazyMediaImageState();
}

class _LazyMediaImageState extends State<LazyMediaImage> {
  bool? _autoDownloadDecision;
  bool _forceLoad = false;

  @override
  void initState() {
    super.initState();
    _resolveDecision();
  }

  Future<void> _resolveDecision() async {
    final ok = await MediaAutoDownloadPrefs.shouldAutoDownload();
    if (mounted) setState(() => _autoDownloadDecision = ok);
  }

  @override
  Widget build(BuildContext context) {
    // Until the prefs are read we don't blank the bubble — show the placeholder
    // skeleton so the bubble keeps its shape and doesn't pop in/out.
    if (_autoDownloadDecision == null) {
      return _placeholder(loading: true);
    }
    if (_autoDownloadDecision == true || _forceLoad) {
      return ImageViewWidget(
        url: widget.url,
        height: widget.height,
        width: widget.width,
        boxFit: widget.boxFit ?? BoxFit.cover,
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _forceLoad = true),
      child: _placeholder(loading: false),
    );
  }

  Widget _placeholder({required bool loading}) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.placeholderColor ?? Colors.black.withValues(alpha: 0.08),
        borderRadius: widget.borderRadius,
      ),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_download_outlined,
                    size: 32, color: Colors.white70),
                const SizedBox(height: 6),
                Text(
                  StringManager.tapToLoadImage.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorManager.onDark.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}
