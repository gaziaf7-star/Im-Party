import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/cache/cache_alpha_widget.dart';
import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';

class UserImage extends StatelessWidget {
  final double? imageSize;
  final double? frameSize;
  final double? positionedTop;
  final double? positionedBottom;
  final double? positionedLeft;
  final double? positionedRight;
  final double? imageWidth;
  final double? imageHeight;
  final String image;
  final String? frame;
  final String? frameType;
  final String? uniquId;
  final String? displayName;
  final BoxFit? boxFit;
  final Widget? child;
  final BoxBorder? border;
  final bool? isAsset;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? margin;
  // final bool isNotCache;

  const UserImage({
    this.child,
    this.imageHeight,
    this.imageWidth,
    required this.image,
    this.boxFit,
    this.imageSize,
    this.border,
    this.borderRadius,
    this.frameSize,
    this.frame,
    this.frameType,
    this.isAsset,
    this.margin,
    this.uniquId,
    this.displayName,
    this.positionedTop,
    this.positionedBottom,
    this.positionedLeft,
    this.positionedRight,
    // this.isNotCache = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            border:
                border ?? Border.all(color: ColorManager.transparent, width: 0),
            borderRadius: borderRadius ??
                BorderRadius.circular((frameSize ?? imageSize ?? 70.w) / 2),
          ),
          child: ClipRRect(
            borderRadius:
                borderRadius ?? ((frameSize ?? imageSize ?? 70.w) / 2).radius,
            child: SizedBox(
              width: imageSize,
              height: imageSize,
              // Single fallback across the whole app: user image → initials.
              // The app logo is never used as an avatar placeholder.
              child: image.isNotEmpty && image != ""
                  ? ImageViewWidget(
                      url: image,
                      boxFit: boxFit ?? BoxFit.cover,
                      width: imageWidth ?? imageSize ?? 60.w,
                      height: imageHeight ?? imageSize ?? 60.w,
                      // Avatar context: failing URL → initials, never the logo.
                      displayName: displayName ?? '',
                    )
                  : InitialsAvatar(
                      name: (displayName != null &&
                              displayName!.trim().isNotEmpty)
                          ? displayName!
                          : '',
                      size: imageWidth ?? imageSize ?? 60.w,
                      borderRadius: borderRadius is BorderRadius
                          ? borderRadius as BorderRadius
                          : null,
                    ),
            ),
          ),
        ),
        if (frame != null && frame!.trim().isNotEmpty)
          isAsset == true
              ? (frame!.contains("svg")
                  ? Positioned.fill(
                      child: SvgPicture.asset(
                        frame!,
                        width: frameSize ?? 70.w,
                        height: frameSize ?? 70.w,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Positioned.fill(
                      child: Image.asset(
                        frame!,
                        width: frameSize ?? 70.w,
                        height: frameSize ?? 70.w,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ))
              // Backend's own frame_type can be wrong for .svga files
              // (confirmed: a "files/xxx.svga" frame reported frame_type
              // "png" in a live my-data response) -- trust the extension
              // over that field whenever it looks like svga, same fix as
              // GiftController.userEntro for the entry animation.
              : (frameType == "svga" || Methods().isSvgaFile(frame ?? ''))
                  ? Positioned(
                      child: RepaintBoundary(
                        child: CacheSvgaWidget(
                          url: frame ?? '',
                          width: frameSize ?? 70.w,
                          height: frameSize ?? 70.w,
                          boxFit: BoxFit.cover,
                          isStopErrorAndLoadingFrame: false,
                        ),
                      ),
                    )
                  : frameType == "alpha"
                      ? Positioned(
                          child: RepaintBoundary(
                            child: CacheAlphaWidget(
                              url: frame ?? '',
                              width: frameSize ?? 70.w,
                              height: frameSize ?? 70.w,
                              isLoop: true,
                            ),
                          ),
                        )
                      : frameType == "vap"
                          ? Positioned(
                              child: RepaintBoundary(
                                child: CachedVapWidget(
                                  url: frame ?? '',
                                  width: frameSize ?? 70.w,
                                  height: frameSize ?? 70.w,
                                  isLoop: true,
                                ),
                              ),
                            )
                          : Positioned(
                              child: ImageViewWidget(
                                url: frame ?? "",
                                boxFit: boxFit ?? BoxFit.cover,
                                width: frameSize ?? 70.w,
                                height: frameSize ?? 70.w,
                                isStopLoadingAndError: false,
                              ),
                            ),
        child ?? const SizedBox(),
      ],
    );
  }
}
