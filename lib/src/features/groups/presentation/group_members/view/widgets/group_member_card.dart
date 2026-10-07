import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';

class GroupMemberCard extends StatelessWidget {
  final GroupMemberEntity member;
  final bool canManage;
  final VoidCallback onTap;

  const GroupMemberCard({
    super.key,
    required this.member,
    required this.canManage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: canManage ? onTap : null,
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            UserImage(
              image: member.avatar.isEmpty
                  ? ''
                  : EndPoints.getImage(member.avatar),
              displayName: member.name,
              imageSize: 46.w,
            ),
            12.wBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientName(child: TextWidget(
                    member.name,
                    isTranslate: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyMedium.w600
                        .colorExt(ColorManager.textPrimary),
                  )),
                  if (member.isMuted)
                    TextWidget(
                      StringManager.muted.tr(),
                      style: context.bodyMedium
                          .colorExt(ColorManager.greyTextColor)
                          .size(11),
                    ),
                ],
              ),
            ),
            _RoleBadge(role: member.role),
            if (canManage) ...[
              6.wBox,
              Icon(Icons.more_vert,
                  size: 18.h, color: ColorManager.greyTextColor),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final GroupRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == GroupRole.member) return const SizedBox.shrink();
    final isOwner = role == GroupRole.owner;
    final label =
        isOwner ? StringManager.groupOwner.tr() : StringManager.groupAdmin.tr();
    final color = isOwner ? ColorManager.primary : ColorManager.blue;
    return Container(
      padding: context.paddingSymmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: 20.radius,
      ),
      child: TextWidget(
        label,
        isTranslate: false,
        style: context.bodyMedium.w600.colorExt(color).size(11),
      ),
    );
  }
}
