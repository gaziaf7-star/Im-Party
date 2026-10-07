import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/domain/entities/reel_comment_entity.dart';

class CommentItem extends StatelessWidget {
  final ReelCommentEntity commentEntity;

  const CommentItem({
    super.key,
    required this.commentEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 8, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserImage(
            image: commentEntity.userProfilePic ?? '',
            displayName: commentEntity.userName ?? '',
            imageSize: 35.w,
          ),
          10.wBox, 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  commentEntity.userName ?? '',
                  style: context.bodyMedium
                      .colorExt(ColorManager.theme2TextSecondary)
                      .size(12),
                ),
                4.hBox,
                TextWidget(
                  commentEntity.comment ?? '',
                  style: context.bodyMedium
                      .colorExt(ColorManager.theme2TextPrimary)
                      .size(12),
                ),
                4.hBox,
                TextWidget(
                  Methods.formatDate(
                      (commentEntity.commentTime ?? ''),
                      locale: context.locale.languageCode),
                  style: context.bodyMedium
                      .colorExt(ColorManager.theme2TextSecondary)
                      .size(12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
