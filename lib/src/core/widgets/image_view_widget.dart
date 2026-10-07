import 'package:general/src/core/index.dart';

class ImageViewWidget extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double? maxHeight;
  final double? widthLoading;
  final double? heightLoading;
  final double? widthError;
  final double? heightError;
  final double? radius;
  final double? scale;
  final BoxFit? boxFit;
  final BoxShape? shape;
  final Widget? child;
  final EdgeInsetsDirectional? padding;
  final EdgeInsetsDirectional? margin;
  final Border? border;
  final bool? isFromRoom;
  final bool? isCp;
  final bool? isBubble;
  final bool? isRoomProfile;
  final bool isStopLoadingAndError;
  final bool isStopForProfileRoom;
  final void Function()? detectError;
  final bool? isGift;
  final bool showLoadingIndicator;
  final bool canRetry;

  /// When non-null, marks this as an AVATAR: on load failure it falls back to
  /// the user's initials (InitialsAvatar) instead of the app logo. Pass an
  /// empty string for an avatar with no known name (renders '?').
  final String? displayName;

  /// When true this is a ROOM/LIVE COVER: an empty/failed image falls back to
  /// the neutral [RoomCoverPlaceholder] instead of the app logo.
  final bool isRoomCover;

  /// When true the empty/failed fallback keeps the BRAND APP LOGO. Defaults to
  /// FALSE so a photoless image NEVER shows the brand logo — the generic
  /// fallback is the neutral [PersonPlaceholder]. Set true ONLY at genuine
  /// brand-logo slots.
  final bool fallbackToLogo;

  const ImageViewWidget({
    required this.url,
    super.key,
    this.height,
    this.width,
    this.padding,
    this.shape,
    this.boxFit,
    this.margin,
    this.border,
    this.child,
    this.radius,
    this.isFromRoom,
    this.widthError,
    this.heightError,
    this.isCp,
    this.isBubble = false,
    this.isRoomProfile = false,
    this.heightLoading,
    this.scale,
    this.maxHeight,
    this.widthLoading,
    this.detectError,
    this.isStopLoadingAndError = true,
    this.isStopForProfileRoom = false,
    this.isGift = false,
    this.showLoadingIndicator = false,
    this.canRetry = false,
    this.displayName,
    this.isRoomCover = false,
    this.fallbackToLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    final lower = url.toLowerCase();
    final isSvg = lower.endsWith('.svg');
    final isSvga = lower.endsWith('.svga');

    if (isSvg) {
      return CacheSvgWidget(
        url: url,
        height: height,
        width: width,
        padding: padding,
        shape: shape,
        boxFit: boxFit,
        margin: margin,
        border: border,
        radius: radius,
        isFromRoom: isFromRoom,
        widthError: widthError,
        heightError: heightError,
        isCp: isCp,
        isBubble: isBubble,
        isRoomProfile: isRoomProfile,
        heightLoading: heightLoading,
        scale: scale,
        maxHeight: maxHeight,
        widthLoading: widthLoading,
        detectError: detectError,
        isStopLoadingAndError: isStopLoadingAndError,
        isStopForProfileRoom: isStopForProfileRoom,
        isGift: isGift,
        displayName: displayName,
        fallbackToLogo: fallbackToLogo,
        child: child,
      );
    }

    if (isSvga) {
      return CacheSvgaWidget(
        url: url,
        height: height,
        width: width,
        boxFit: boxFit,
        radius: radius,
        shape: shape,
        detectError: detectError,
        isShowGift: isGift ?? false,
        isStopForProfileRoom: isStopForProfileRoom,
        isStopErrorAndLoadingFrame: isStopLoadingAndError,
      );
    }

    return CacheImageWidget(
      url: url,
      height: height,
      width: width,
      padding: padding,
      shape: shape,
      boxFit: boxFit,
      margin: margin,
      border: border,
      radius: radius,
      isFromRoom: isFromRoom,
      widthError: widthError,
      heightError: heightError,
      isCp: isCp,
      isBubble: isBubble,
      isRoomProfile: isRoomProfile,
      heightLoading: heightLoading,
      scale: scale,
      maxHeight: maxHeight,
      widthLoading: widthLoading,
      detectError: detectError,
      isStopLoadingAndError: isStopLoadingAndError,
      isStopForProfileRoom: isStopForProfileRoom,
      isGift: isGift,
      showLoadingIndicator: showLoadingIndicator,
      canRetry: canRetry,
      displayName: displayName,
      isRoomCover: isRoomCover,
      fallbackToLogo: fallbackToLogo,
      child: child,
    );
  }
}
