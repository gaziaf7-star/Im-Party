import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_permissions.dart';

enum MemberActionType { promote, demote, mute, kick, transferOwnership }

class MemberAction {
  final MemberActionType type;
  final int? muteDurationMinutes;

  const MemberAction(this.type, {this.muteDurationMinutes});
}

/// Presents the permission-filtered actions for [member] and returns the chosen
/// [MemberAction] (or null if dismissed). Visibility is derived from
/// [permissions] — the backend still enforces every action.
Future<MemberAction?> showMemberActionSheet(
  BuildContext context, {
  required GroupMemberEntity member,
  required GroupPermissions permissions,
}) {
  return showModalBottomSheet<MemberAction>(
    context: context,
    backgroundColor: ColorManager.scaffoldBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final tiles = <Widget>[];

      if (permissions.canPromoteMember(member)) {
        tiles.add(_ActionTile(
          icon: Icons.shield_outlined,
          label: StringManager.promote.tr(),
          onTap: () => Navigator.pop(
              ctx, const MemberAction(MemberActionType.promote)),
        ));
      }
      if (permissions.canDemoteMember(member)) {
        tiles.add(_ActionTile(
          icon: Icons.remove_moderator_outlined,
          label: StringManager.demote.tr(),
          onTap: () => Navigator.pop(
              ctx, const MemberAction(MemberActionType.demote)),
        ));
      }
      if (permissions.canMute(member)) {
        tiles.add(_ActionTile(
          icon: Icons.volume_off_outlined,
          label: StringManager.muteMember.tr(),
          onTap: () async {
            final choice = await _pickMuteDuration(ctx);
            if (choice == null) return; // dismissed
            if (!ctx.mounted) return;
            Navigator.pop(
              ctx,
              MemberAction(MemberActionType.mute,
                  muteDurationMinutes: choice.minutes),
            );
          },
        ));
      }
      if (permissions.canTransferTo(member)) {
        tiles.add(_ActionTile(
          icon: Icons.swap_horiz,
          label: StringManager.transferOwnership.tr(),
          onTap: () => Navigator.pop(
              ctx, const MemberAction(MemberActionType.transferOwnership)),
        ));
      }
      if (permissions.canKick(member)) {
        tiles.add(_ActionTile(
          icon: Icons.person_remove_outlined,
          label: StringManager.kickMember.tr(),
          isDestructive: true,
          onTap: () =>
              Navigator.pop(ctx, const MemberAction(MemberActionType.kick)),
        ));
      }

      return SafeArea(
        child: Padding(
          padding: ctx.paddingSymmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: ctx.paddingOnly(bottom: 8),
                decoration: BoxDecoration(
                  color: ColorManager.divider,
                  borderRadius: 4.radius,
                ),
              ),
              GradientName(child: TextWidget(
                member.name,
                isTranslate: false,
                style: ctx.bodyLarge.w600.colorExt(ColorManager.textPrimary),
              )),
              12.hBox,
              ...tiles,
            ],
          ),
        ),
      );
    },
  );
}

/// Wraps the chosen mute length so a barrier-dismiss (`null`) is unambiguously
/// distinct from the "forever" choice ([minutes] == null).
class _MuteChoice {
  final int? minutes;
  const _MuteChoice(this.minutes);
}

Future<_MuteChoice?> _pickMuteDuration(BuildContext context) {
  return showModalBottomSheet<_MuteChoice>(
    context: context,
    backgroundColor: ColorManager.scaffoldBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            12.hBox,
            TextWidget(
              StringManager.muteDuration.tr(),
              style: ctx.bodyLarge.w600.colorExt(ColorManager.textPrimary),
            ),
            12.hBox,
            _ActionTile(
              icon: Icons.timelapse,
              label: StringManager.muteFor1Hour.tr(),
              onTap: () => Navigator.pop(ctx, const _MuteChoice(60)),
            ),
            _ActionTile(
              icon: Icons.timelapse,
              label: StringManager.muteFor8Hours.tr(),
              onTap: () => Navigator.pop(ctx, const _MuteChoice(8 * 60)),
            ),
            _ActionTile(
              icon: Icons.timelapse,
              label: StringManager.muteFor1Day.tr(),
              onTap: () => Navigator.pop(ctx, const _MuteChoice(24 * 60)),
            ),
            _ActionTile(
              icon: Icons.all_inclusive,
              label: StringManager.muteForever.tr(),
              onTap: () => Navigator.pop(ctx, const _MuteChoice(null)),
            ),
          ],
        ),
      );
    },
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? ColorManager.red : ColorManager.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22.h),
      title: TextWidget(
        label,
        isTranslate: false,
        style: context.bodyMedium.w600.colorExt(color),
      ),
    );
  }
}
