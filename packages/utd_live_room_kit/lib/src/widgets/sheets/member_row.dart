import 'package:flutter/material.dart';

import '../../models/participant_model.dart';
import '../../theme/utd_room_scope.dart';
import '../default_avatar.dart';

/// A single participant row used by the default member list / invite sheets:
/// avatar + name + optional role badge + trailing action widgets.
class UTDMemberRow extends StatelessWidget {
  final UTDParticipant participant;
  final String? role;
  final List<Widget> trailing;
  final VoidCallback? onTap;

  const UTDMemberRow({
    super.key,
    required this.participant,
    this.role,
    this.trailing = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scope = UTDRoomScope.of(context);
    final theme = scope.theme;
    final name = participant.name.isNotEmpty
        ? participant.name
        : (participant.attributes['name'] ?? participant.id);

    return ListTile(
      onTap: onTap,
      leading: UTDDefaultAvatar(
        url: participant.attributes['avatar'],
        name: name,
        fallbackId: participant.id,
        size: 40,
        theme: theme,
      ),
      title: Text(name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: theme.onSurface)),
      subtitle: role != null
          ? Text(role!, style: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)))
          : null,
      trailing: trailing.isEmpty
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: trailing),
    );
  }
}
