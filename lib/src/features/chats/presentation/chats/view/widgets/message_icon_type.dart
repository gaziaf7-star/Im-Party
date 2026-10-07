import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';

class MessageIconType extends StatelessWidget {
  const MessageIconType({
    super.key,
    required this.type,
    required this.message,
  });
  final String type;
  final String message;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'img':
        return Row(
          children: [
            Icon(
              CupertinoIcons.photo,
              size: 16.h,
              color: ColorManager.momentPostTextColor,
            ),
            2.5.wBox,
            TextWidget(
              StringManager.photo.tr(),
              style: context.bodyMedium.colorExt(
                ColorManager.momentPostTextColor,
              ),
            ),
          ],
        );
      case 'voice':
        return Row(
          children: [
            Icon(
              Icons.mic,
              size: 18.h,
              color: ColorManager.momentPostTextColor,
            ),
            TextWidget(
              StringManager.record.tr(),
              style: context.bodyLarge
                  .colorExt(ColorManager.momentPostTextColor),
            ),
          ],
        );
      case 'video':
        return Row(
          children: [
            Icon(
              Icons.video_camera_back,
              size: 18.h,
              color: ColorManager.momentPostTextColor,
            ),
            TextWidget(
              StringManager.video.tr(),
              style: context.bodyLarge
                  .colorExt(ColorManager.momentPostTextColor),
            ),
          ],
        );
      case 'file':
        return Row(
          children: [
            Icon(
              Icons.file_present,
              size: 18.h,
              color: ColorManager.momentPostTextColor,
            ),
            TextWidget(
              StringManager.file.tr(),
              style: context.bodyLarge
                  .colorExt(ColorManager.momentPostTextColor),
            ),
          ],
        );
      case 'CP':
        return Row(
          children: [
            Icon(
              Icons.perm_identity_sharp,
              size: 18.h,
              color: ColorManager.momentPostTextColor,
            ),
            TextWidget(
              StringManager.cP.tr(),
              style: context.bodyLarge
                  .colorExt(ColorManager.momentPostTextColor),
            ),
          ],
        );
      default:
      // Fixed light-black (was the medium-grey lightBlackChat) — requested
      // for the Chats page's message-preview text.
        return TextWidget(
          message,
          maxLines: 1,
          style:
          context.bodySmall.colorExt(ColorManager.momentPostTextColor),
          overflow: TextOverflow.ellipsis,
        );
    }
  }
}