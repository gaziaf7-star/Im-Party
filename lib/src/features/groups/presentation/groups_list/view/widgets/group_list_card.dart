import 'package:general/src/core/index.dart';
import 'package:general/src/features/chats/presentation/chats/view/widgets/contact_quick_view.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';

class GroupListCard extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback onTap;

  /// WhatsApp-style relative last-activity label (passed by the unified chats
  /// list). Empty when unknown (e.g. the standalone groups screen).
  final String timeLabel;

  /// Last-message preview shown under the group name (like WhatsApp). When empty
  /// the row falls back to the members count.
  final String subtitle;

  const GroupListCard({
    super.key,
    required this.group,
    required this.onTap,
    this.timeLabel = '',
    this.subtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    // Layout mirrors ChatRoomCard exactly (same padding/avatar size/trailing
    // column) so group and 1:1 rows align on one column.
    return Container(
      padding: context.paddingSymmetric(horizontal: 5, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: 6.radius,
        child: SizedBox(
          height: 70.h,
          child: Row(
            children: [
              // Tapping the avatar opens the group quick-view (mini profile)
              // — same UX as 1:1 contacts. From there, the user can view the
              // full info page or open the chat.
              GestureDetector(
                onTap: () => showGroupQuickView(
                  context,
                  name: group.name,
                  image: group.avatar,
                  membersCount: group.membersCount,
                  onViewInfo: () => Navigator.of(context).pushNamed(
                    Routes.groupViewScreen,
                    arguments: group,
                  ),
                ),
                child: UserImage(
                  image: group.avatar.isEmpty
                      ? ''
                      : EndPoints.getImage(group.avatar),
                  displayName: group.name,
                  imageSize: 60.h,
                ),
              ),
              10.wBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      group.name,
                      isTranslate: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyLarge.w600
                          .colorExt(ColorManager.textPrimary),
                    ),
                    5.hBox,
                    TextWidget(
                      // WhatsApp shows the last message in the row; fall back to
                      // the members count when there is no message yet.
                      subtitle.isNotEmpty
                          ? subtitle
                          : '${group.membersCount} ${StringManager.membersCount.tr()}',
                      isTranslate: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium
                          .colorExt(ColorManager.greyTextColor)
                          .size(12),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (timeLabel.isNotEmpty)
                    TextWidget(
                      timeLabel,
                      isTranslate: false,
                      style: context.bodyMedium
                          .colorExt(ColorManager.lightBlackChat),
                    ),
                  if (group.unreadCount > 0) ...[
                    6.hBox,
                    Container(
                      constraints: BoxConstraints(minWidth: 20.w),
                      padding: context.paddingSymmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ColorManager.primary,
                        borderRadius: 20.radius,
                      ),
                      child: TextWidget(
                        group.unreadCount > 99 ? '99+' : '${group.unreadCount}',
                        isTranslate: false,
                        textAlign: TextAlign.center,
                        style: context.bodyMedium
                            .size(11)
                            .w600
                            .colorExt(ColorManager.buttonTextColor),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
