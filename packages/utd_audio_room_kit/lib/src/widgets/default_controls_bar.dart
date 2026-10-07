import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/utd_room_controller.dart';
import '../models/participant_model.dart';
import '../models/role_model.dart';
import '../models/seat_model.dart';
import '../theme/utd_room_scope.dart';
import '../theme/utd_room_strings.dart';
import '../theme/utd_room_theme.dart';
import 'message_input_sheet.dart';
import 'sheets/member_list_sheet.dart';
import 'sheets/request_queue_sheet.dart';

/// The package's built-in role-aware controls bar (used when the consumer does
/// not supply `controlsBarWidget`).
///
/// - Everyone: chat, speaker toggle, and mic toggle (when publish is allowed).
/// - Audience in `request` seat mode: apply-to-speak / cancel-request.
/// - Host/admin: member list + speak-request queue (with a pending-count badge).
///
/// Rebuilds are scoped: reactive notifiers drive [ValueListenableBuilder]s, and
/// role changes (which have no notifier) are caught via [roleChangeStream] /
/// [participantsStream]. It deliberately does NOT listen to the 300ms
/// `activeSpeakers` poll.
class UTDDefaultControlsBar extends StatefulWidget {
  final UTDRoomController controller;

  const UTDDefaultControlsBar({super.key, required this.controller});

  @override
  State<UTDDefaultControlsBar> createState() => _UTDDefaultControlsBarState();
}

class _UTDDefaultControlsBarState extends State<UTDDefaultControlsBar> {
  StreamSubscription<UTDRoleChangeEvent>? _roleSub;
  StreamSubscription<List<UTDParticipant>>? _participantsSub;

  UTDRoomController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    // Role has no ValueNotifier; rebuild when the local user's role changes or
    // when participant metadata (which carries role) updates.
    _roleSub = _c.roleChangeStream.listen((e) {
      if (!mounted) return;
      if (e.identity == _c.localIdentity) setState(() {});
    });
    _participantsSub = _c.participantsStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _roleSub?.cancel();
    _participantsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = UTDRoomScope.maybeOf(context);
    final theme = scope?.theme ?? const UTDRoomTheme();
    final strings = scope?.strings ?? UTDRoomStrings.en();
    final isHostOrAdmin = _c.isHostOrAdmin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Chat — replaced by a lock indicator when comments are locked and the
          // local user may not comment. Rebuilds on lock change (here) and on
          // role change (the setState listeners above keep canIComment fresh).
          ValueListenableBuilder<bool>(
            valueListenable: _c.commentsLocked,
            builder: (_, __, ___) {
              if (!_c.canIComment) {
                return _circle(
                  theme,
                  icon: Icons.lock_outline,
                  iconColor: theme.danger,
                  onTap: () => ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: Text(strings.commentsLocked)),
                  ),
                );
              }
              return _circle(
                theme,
                icon: Icons.chat_bubble_outline,
                onTap: () =>
                    UTDMessageInputSheet.show(context, _c.chatController),
              );
            },
          ),
          // Mic — only meaningful when the local user may publish.
          ValueListenableBuilder<bool>(
            valueListenable: _c.mediaController.canPublish,
            builder: (_, canPublish, __) {
              if (!canPublish) return const SizedBox.shrink();
              return ValueListenableBuilder<bool>(
                valueListenable: _c.mediaController.isMicEnabled,
                builder: (_, isOn, __) => _circle(
                  theme,
                  icon: isOn ? Icons.mic : Icons.mic_off,
                  iconColor: isOn ? theme.onSurface : theme.danger,
                  onTap: _c.mediaController.toggleMicrophone,
                ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _c.mediaController.isSpeakerOn,
            builder: (_, isOn, __) => _circle(
              theme,
              icon: isOn ? Icons.volume_up : Icons.volume_off,
              onTap: _c.mediaController.toggleSpeaker,
            ),
          ),
          if (isHostOrAdmin) ...[
            _circle(
              theme,
              icon: Icons.people_alt_outlined,
              onTap: () => UTDMemberListSheet.show(context, controller: _c),
            ),
            _requestQueueButton(theme, strings),
            _lockCommentsButton(theme),
          ] else
            _applyToSpeakButton(theme, strings),
        ],
      ),
    );
  }

  /// Host/admin request-queue button with a live pending-count badge.
  Widget _requestQueueButton(UTDRoomTheme theme, UTDRoomStrings strings) {
    return ValueListenableBuilder<List<SpeakerRequest>>(
      valueListenable: _c.seatController.pendingRequests,
      builder: (_, requests, __) {
        final count = requests.length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _circle(
              theme,
              icon: Icons.pan_tool_alt_outlined,
              onTap: () => UTDRequestQueueSheet.show(context, controller: _c),
            ),
            if (count > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: BoxDecoration(
                    color: theme.pendingBadge,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Host/admin comment-lock toggle. Drives the lock via the backend; the
  /// `_chat_lock` broadcast + `chat_locked` metadata flow back and update
  /// [UTDRoomController.commentsLocked] on every device (including this one),
  /// so the icon is never flipped optimistically here.
  Widget _lockCommentsButton(UTDRoomTheme theme) {
    return ValueListenableBuilder<bool>(
      valueListenable: _c.commentsLocked,
      builder: (_, locked, __) => _circle(
        theme,
        icon: locked ? Icons.lock : Icons.lock_open,
        iconColor: locked ? theme.danger : theme.onSurface,
        onTap: () => _c.setCommentsLocked(!locked),
      ),
    );
  }

  /// Audience apply-to-speak / cancel-request (only shown in `request` mode).
  Widget _applyToSpeakButton(UTDRoomTheme theme, UTDRoomStrings strings) {
    return ValueListenableBuilder<String>(
      valueListenable: _c.seatController.seatMode,
      builder: (_, mode, __) {
        if (mode != 'request') return const SizedBox.shrink();
        return ValueListenableBuilder<List<SeatState>>(
          valueListenable: _c.seatController.seats,
          builder: (_, __, ___) {
            // Already on a seat → nothing to apply for.
            if (_c.localSeatIndex >= 0) return const SizedBox.shrink();
            return ValueListenableBuilder<List<SpeakerRequest>>(
              valueListenable: _c.seatController.pendingRequests,
              builder: (_, requests, __) {
                final me = _c.localIdentity;
                final requested =
                    me != null && requests.any((r) => r.identity == me);
                return TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: requested
                        ? theme.surface
                        : theme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(
                      requested ? Icons.hourglass_top : Icons.pan_tool_alt,
                      size: 18),
                  label: Text(
                      requested ? strings.cancelRequest : strings.applyToSpeak),
                  onPressed: () async {
                    if (requested) {
                      await _c.cancelSpeakerRequest();
                    } else {
                      await _c.requestToSpeak();
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _circle(
    UTDRoomTheme theme, {
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.iconButtonBackground,
        ),
        child: Icon(icon, color: iconColor ?? theme.onSurface, size: 22),
      ),
    );
  }
}
