// part of 'package:general/src/features/chats/presentation/notification/view/notification_screen.dart';

import '../../../../../../core/index.dart';

class NotificationCard extends StatelessWidget {
  final String content;
  final String created;
  final String img;
  final int? userId;
  final int index;

  const NotificationCard({
    super.key,
    required this.content,
    required this.created,
    required this.index,
    required this.userId,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingAll(10),
      child: Column(
        children: [
          Text(
            created,
            style: context.bodyMedium
                .colorExt(ColorManager.momentPostTextColor.withValues(alpha: 0.7)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                AssetsManager.notification,
                width: 50.w,
              ),
              Container(
                width: 275.w,
                margin: context.paddingSymmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.r),
                    bottomRight: Radius.circular(10.r),
                    topRight: Radius.circular(10.r),
                  ),
                ),
                child: Padding(
                  padding: context
                      .paddingSymmetric(horizontal: 8, vertical: 8)
                      .copyWith(end: 10),
                  child: Text(
                    content,
                    // Fixed light-black (was the panel-driven textPrimary) —
                    // requested for the notification page's text.
                    style: context.bodyMedium
                        .size(16)
                        .colorExt(ColorManager.momentPostTextColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}