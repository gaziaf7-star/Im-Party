import 'package:flutter/material.dart';

import '../../models/participant_model.dart';
import '../../theme/utd_room_scope.dart';
import '../../theme/utd_room_theme.dart';
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
    // maybeOf with a default fallback, not the strict `of` -- this row is
    // used from several default sheets, and any host app that never
    // establishes an ambient UTDRoomScope (see the note in
    // request_queue_sheet.dart) would otherwise crash here too.
    final theme = UTDRoomScope.maybeOf(context)?.theme ?? const UTDRoomTheme();
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
