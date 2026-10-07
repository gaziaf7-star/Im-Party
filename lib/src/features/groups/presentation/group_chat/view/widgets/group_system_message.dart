import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';

/// Renders a `kind=='system'` group event line (member_joined, member_left,
/// member_kicked, member_promoted, member_demoted, member_muted, group_renamed,
/// avatar_changed, owner_transferred) centered with distinct styling, separate
/// from normal chat bubbles (Plan 5.5 / 7.6).
class GroupSystemMessage extends StatelessWidget {
  final Message message;
  final List<GroupMemberEntity> members;

  const GroupSystemMessage({
    super.key,
    required this.message,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final text = _label();
    return Center(
      child: Container(
        margin: context.paddingSymmetric(vertical: 6, horizontal: 40),
        padding: context.paddingSymmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: ColorManager.grey.withValues(alpha: 0.18),
          borderRadius: 12.radius,
        ),
        child: TextWidget(
          text,
          isTranslate: false,
          textAlign: TextAlign.center,
          style: context.bodySmall.colorExt(
              ColorManager.momentPostTextColor.withValues(alpha: 0.65)),
        ),
      ),
    );
  }

  /// Name of the member this event is about, falling back to the raw body.
  String _actorName() {
    final id = message.senderId;
    if (id != null) {
      for (final m in members) {
        if (m.userId == id) return m.name;
      }
    }
    return message.body ?? '';
  }

  String _label() {
    final name = _actorName();
    switch (message.systemEvent) {
      case 'member_joined':
        return '$name ${StringManager.sysMemberJoined.tr()}';
      case 'member_left':
        return '$name ${StringManager.sysMemberLeft.tr()}';
      case 'member_kicked':
        return '$name ${StringManager.sysMemberKicked.tr()}';
      case 'member_promoted':
        return '$name ${StringManager.sysMemberPromoted.tr()}';
      case 'member_demoted':
        return '$name ${StringManager.sysMemberDemoted.tr()}';
      case 'member_muted':
        return '$name ${StringManager.sysMemberMuted.tr()}';
      case 'group_renamed':
        return StringManager.sysGroupRenamed.tr();
      case 'avatar_changed':
        return StringManager.sysAvatarChanged.tr();
      case 'owner_transferred':
        return '$name ${StringManager.sysOwnerTransferred.tr()}';
      default:
      // Unknown / future event: fall back to whatever the server sent.
        return message.body ?? message.systemEvent ?? '';
    }
  }
}