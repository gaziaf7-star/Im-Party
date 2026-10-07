import 'package:general/src/features/chats/chats.dart';

/// Opens [imagePath] full-screen on a black backdrop with pinch-zoom — the clean
/// photo viewer used for both a contact's avatar (after the quick-view) and a
/// group's avatar. No-op for an empty path.
void openFullPhoto(BuildContext context, String imagePath) {
  if (imagePath.isEmpty) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: ColorManager.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: ImageViewWidget(
                  url: EndPoints.getImage(imagePath),
                  boxFit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              left: 12.w,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: ColorManager.white, size: 28.h),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// WhatsApp-style contact quick-view shown when the user taps a chat avatar:
/// a small card with the name header, a square avatar, and two actions
/// (info -> profile, message -> open chat). Tapping the avatar itself opens the
/// full photo. Replaces the old full-screen image viewer that looked broken.
Future<void> showContactQuickView(
  BuildContext context, {
  required String name,
  required String image,
  required String userId,
  bool hasColorName = false,
  required VoidCallback onMessage,
}) {
  return showDialog(
    context: context,
    builder: (_) => _ContactQuickView(
      name: name,
      image: image,
      userId: userId,
      onMessage: onMessage,
    ),
  );
}

/// WhatsApp-style group quick-view shown when the user taps the group header
/// in a group chat: name + square avatar + actions (info -> the read-only
/// group screen, message -> close + stay in chat). Tapping the avatar opens
/// the full photo. Mirrors [showContactQuickView] so the two flows feel
/// identical.
Future<void> showGroupQuickView(
  BuildContext context, {
  required String name,
  required String image,
  required int membersCount,
  required VoidCallback onViewInfo,
}) {
  return showDialog(
    context: context,
    builder: (_) => _GroupQuickView(
      name: name,
      image: image,
      membersCount: membersCount,
      onViewInfo: onViewInfo,
    ),
  );
}

class _ContactQuickView extends StatelessWidget {
  const _ContactQuickView({
    required this.name,
    required this.image,
    required this.userId,
    required this.onMessage,
  });

  final String name;
  final String image;
  final String userId;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 36.w),
      backgroundColor: ColorManager.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: 10.radius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name header.
          Container(
            width: double.infinity,
            color: ColorManager.primary,
            padding: context.paddingSymmetric(horizontal: 16, vertical: 12),
            child: TextWidget(
              name,
              isTranslate: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  context.bodyLarge.bold.colorExt(ColorManager.buttonTextColor),
            ),
          ),
          // Square avatar — tap to open the full photo. Uses UserImage so
          // people without a picture see their initials on a colored circle,
          // not the black app logo (which read as a broken thumbnail).
          GestureDetector(
            onTap: () => openFullPhoto(context, image),
            child: AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (_, c) => UserImage(
                  image: image.isEmpty ? '' : EndPoints.getImage(image),
                  displayName: name,
                  imageSize: c.maxWidth,
                  boxFit: BoxFit.cover,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
          // Actions: info (-> profile) + message (-> open chat).
          Row(
            children: [
              Expanded(
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      Routes.userProfile,
                      arguments: UserProfileParameter(userId: userId),
                    );
                  },
                  icon: Icon(Icons.info_outline,
                      color: ColorManager.primary, size: 26.h),
                ),
              ),
              Container(width: 1, height: 28.h, color: ColorManager.grey2),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onMessage();
                  },
                  icon: Icon(Icons.chat_bubble_outline,
                      color: ColorManager.primary, size: 24.h),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupQuickView extends StatelessWidget {
  const _GroupQuickView({
    required this.name,
    required this.image,
    required this.membersCount,
    required this.onViewInfo,
  });

  final String name;
  final String image;
  final int membersCount;
  final VoidCallback onViewInfo;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 36.w),
      backgroundColor: ColorManager.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: 10.radius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name + member count header.
          Container(
            width: double.infinity,
            color: ColorManager.primary,
            padding: context.paddingSymmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  name,
                  isTranslate: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyLarge.bold
                      .colorExt(ColorManager.buttonTextColor),
                ),
                2.hBox,
                TextWidget(
                  '$membersCount ${StringManager.membersCount.tr()}',
                  isTranslate: false,
                  style: context.bodySmall.colorExt(
                    ColorManager.buttonTextColor.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          // Square avatar — tap to open the full photo. Uses UserImage so
          // groups without a picture show their initials (not the logo).
          GestureDetector(
            onTap: () => openFullPhoto(context, image),
            child: AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (_, c) => UserImage(
                  image: image.isEmpty ? '' : EndPoints.getImage(image),
                  displayName: name,
                  imageSize: c.maxWidth,
                  boxFit: BoxFit.cover,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
          // One action: open the read-only group info screen.
          InkWell(
            onTap: () {
              Navigator.pop(context);
              onViewInfo();
            },
            child: Padding(
              padding: context.paddingSymmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline,
                      color: ColorManager.primary, size: 22.h),
                  8.wBox,
                  TextWidget(
                    StringManager.viewGroupInfo.tr(),
                    isTranslate: false,
                    style: context.bodyMedium
                        .colorExt(ColorManager.primary)
                        .w600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
