part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class _ReplayWidget extends StatelessWidget {
  const _ReplayWidget({
    required this.entity,
    required this.isMe,
    required this.params,
  });

  final MessagesParameter params;
  final MessagesEntity entity;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    // Translucent "quote highlight" tint that reads on both sides: a light
    // white wash on the brand-gradient "my" bubble, a light brand-purple wash
    // on the white "their" bubble (was a flat primary/primary@0.5 fill that
    // used to just blend into — or clash with — the bubble behind it).
    final Color scrimColor = isMe
        ? ColorManager.white.withValues(alpha: 0.15)
        : ColorManager.brandGradientColors.last.withValues(alpha: 0.08);
    // Fixed per-side accent/text colors (was textPrimary throughout, which
    // defaults to black and would be invisible on the brand-gradient side).
    final Color accentColor =
    isMe ? ColorManager.onBrandGradient : ColorManager.brandGradientColors.last;
    final Color textColor =
    isMe ? ColorManager.onBrandGradient : ColorManager.momentPostTextColor;
    return IntrinsicHeight(
      child: Container(
        color: scrimColor,
        child: Row(
          children: [
            Container(
              width: 4.w,
              color: accentColor,
            ),
            10.wBox,
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                      context.paddingOnly(top: 6.5, end: 6.5, bottom: 6.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            Methods.isMe('${entity.replay?.messageUserId}')
                                ? StringManager.you.tr()
                                : params.name,
                            style: context.bodyMedium.w600
                                .size(15)
                                .colorExt(textColor),
                          ),
                          2.5.hBox,
                          entity.replay?.messageType == "img"
                              ? Row(
                            children: [
                              Icon(
                                CupertinoIcons.photo,
                                size: 14.h,
                                color: textColor,
                              ),
                              3.5.wBox,
                              TextWidget(
                                StringManager.photo.tr(),
                                style: context.bodyMedium
                                    .size(15)
                                    .colorExt(
                                    textColor.withValues(alpha: (0.7))),
                              ),
                            ],
                          )
                              : entity.replay?.messageType == "voice"
                              ? Row(
                            children: [
                              Icon(
                                CupertinoIcons.mic_fill,
                                size: 14.h,
                                color: textColor,
                              ),
                              3.5.wBox,
                              TextWidget(
                                StringManager.voice.tr(),
                                style: context.bodyMedium
                                    .size(15)
                                    .colorExt(textColor
                                    .withValues(alpha: (0.7))),
                              ),
                            ],
                          )
                              : entity.replay?.messageType == "video"
                              ? Row(
                            children: [
                              Icon(
                                CupertinoIcons.video_camera_solid,
                                size: 14.h,
                                color: textColor,
                              ),
                              3.5.wBox,
                              TextWidget(
                                StringManager.video,
                                style: context.bodyMedium
                                    .size(15)
                                    .colorExt(textColor
                                    .withValues(
                                    alpha: (0.7))),
                              ),
                            ],
                          )
                              : entity.replay!.messageType == "CP"
                              ? Row(
                            children: [
                              Icon(Icons.perm_identity_sharp,
                                  size: 18.h,
                                  color: textColor.withValues(
                                      alpha: (0.7))),
                              TextWidget(
                                StringManager.cP.tr(),
                                style: context.bodyLarge
                                    .colorExt(textColor
                                    .withValues(
                                    alpha: (0.7))),
                              ),
                            ],
                          )
                              : TextWidget(
                            entity.replay?.message ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodyMedium
                                .size(15)
                                .colorExt(textColor
                                .withValues(
                                alpha: (0.8))),
                          ),
                        ],
                      ),
                    ),
                  ),
                  5.wBox,
                  if (entity.replay?.messageType == "img")
                    if (entity.replay?.albums?.file?.isNotEmpty == true)
                      entity.replay?.albums?.isLocal == true
                          ? Image.file(
                        height: 60.h,
                        width: 55.w,
                        fit: BoxFit.cover,
                        File('${entity.replay?.albums?.file}'),
                      )
                          : ImageViewWidget(
                        height: 60.h,
                        width: 55.w,
                        url: entity.replay?.albums?.file ?? '',
                        boxFit: BoxFit.cover,
                      ),
                  if (entity.replay?.messageType == "video")
                    if (entity.replay?.albums?.file?.isNotEmpty == true)
                      entity.replay?.albums?.firstFrameFile != null
                          ? Image.file(
                        entity.replay!.albums!.firstFrameFile!,
                        height: 60.h,
                        width: 55.w,
                        fit: BoxFit.cover,
                      )
                          : ImageViewWidget(
                        url: EndPoints.getImage(
                            entity.replay!.albums!.firstFrame ?? ''),
                        height: 60.h,
                        width: 55.w,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}