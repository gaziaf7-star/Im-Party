import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/utd_room_controller.dart';
import '../../models/participant_model.dart';
import '../../models/seat_model.dart';
import '../../theme/utd_room_scope.dart';
import '../../theme/utd_room_strings.dart';
import 'member_row.dart';
import 'utd_sheet.dart';

/// Default host/admin queue of pending speak requests, with approve / reject.
class UTDRequestQueueSheet {
  static Future<void> show(
    BuildContext context, {
    required UTDRoomController controller,
  }) {
    return showUTDRoomSheet<void>(
      context,
      builder: (_) => _RequestQueue(controller: controller),
    );
  }
}

class _RequestQueue extends StatefulWidget {
  final UTDRoomController controller;

  const _RequestQueue({required this.controller});

  @override
  State<_RequestQueue> createState() => _RequestQueueState();
}

class _RequestQueueState extends State<_RequestQueue> {
  /// Request ids with an approve/reject call in flight — guards against a second
  /// tap re-firing the action before the backend removes the request from the
  /// queue (which would otherwise double-approve / double-reject).
  final Set<int> _processing = {};

  /// True while the sheet shows the audience invite picker instead of the
  /// pending-requests queue (host taps the invite icon / empty-state CTA).
  bool _inviteMode = false;

  /// Identities an invitation was just sent to (per sheet session) — rendered
  /// as a sent checkmark and not re-invitable from this sheet.
  final Set<String> _invited = {};

  /// Identities with an invite call in flight.
  final Set<String> _inviting = {};

  /// Transient inline error (a snackbar would render behind this open sheet).
  String? _error;
  Timer? _errorTimer;

  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }

  UTDParticipant _participant(String identity) {
    for (final p in widget.controller.participants) {
      if (p.id == identity) return p;
    }
    return UTDParticipant(id: identity, name: identity);
  }

  Future<void> _act(int requestId, Future<Object?> Function() op) async {
    if (_processing.contains(requestId)) return; // double-fire guard
    setState(() => _processing.add(requestId));
    Object? result;
    try {
      result = await op();
    } catch (_) {
      result = null;
    }
    if (!mounted) return;
    setState(() => _processing.remove(requestId));
    // approve returns a Map (null on failure); reject returns a bool.
    if (result == null || result == false) {
      // Prefer the engine's own explanation — "Stage is full" or "Already on
      // stage" tells the host what to do next; "action failed" does not.
      _showError(widget.controller.lastStageError ??
          UTDRoomScope.of(context).strings.actionFailed);
    }
  }

  void _showError(String message) {
    setState(() => _error = message);
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _error = null);
    });
  }

  /// Audience members eligible for a stage invitation: connected, not the
  /// local user, not the host, and not already on a guest tile.
  List<UTDParticipant> _invitableAudience() {
    final c = widget.controller;
    final me = c.localIdentity;
    return c.participants.where((p) {
      if (p.id.isEmpty || p.id == me) return false;
      if (p.id == c.hostIdentity) return false;
      return c.seatController.getSeatIndexByUserId(p.id) < 0;
    }).toList();
  }

  Future<void> _invite(String identity) async {
    if (_inviting.contains(identity) || _invited.contains(identity)) return;
    setState(() => _inviting.add(identity));
    Map<String, dynamic>? result;
    try {
      result = await widget.controller.inviteToSpeak(identity);
    } catch (_) {
      result = null;
    }
    if (!mounted) return;
    setState(() {
      _inviting.remove(identity);
      if (result != null) _invited.add(identity);
    });
    if (result == null) {
      _showError(widget.controller.lastStageError ??
          UTDRoomScope.of(context).strings.actionFailed);
    }
  }

  /// The audience picker view (invite mode).
  Widget _invitePicker(UTDRoomStrings strings, dynamic theme) {
    final audience = _invitableAudience();
    if (audience.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(strings.noOtherMembers,
            style: TextStyle(color: theme.onSurface.withValues(alpha: 0.7))),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: audience.length,
      itemBuilder: (context, i) {
        final p = audience[i];
        final busy = _inviting.contains(p.id);
        final sent = _invited.contains(p.id);
        return UTDMemberRow(
          participant: p,
          trailing: [
            if (busy)
              const SizedBox(
                width: 24,
                height: 24,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (sent)
              Icon(Icons.check_circle, color: theme.seatRingSpeaking)
            else
              IconButton(
                icon: Icon(Icons.person_add_alt_1, color: theme.primary),
                tooltip: strings.inviteToSpeak,
                onPressed: () => _invite(p.id),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = UTDRoomScope.of(context);
    final strings = scope.strings;
    final theme = scope.theme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: title + invite toggle (back arrow while in invite mode).
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                if (_inviteMode)
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.onSurface),
                    onPressed: () => setState(() => _inviteMode = false),
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    _inviteMode ? strings.invitePickerTitle : strings.requestQueue,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: theme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (!_inviteMode)
                  IconButton(
                    icon: Icon(Icons.person_add_alt_1, color: theme.primary),
                    tooltip: strings.inviteSomeoneCta,
                    onPressed: () => setState(() => _inviteMode = true),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
          if (_error != null) UTDSheetInlineError(_error!),
          if (_invited.isNotEmpty && _inviteMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(strings.invitationSent,
                  style:
                      TextStyle(color: theme.seatRingSpeaking, fontSize: 12)),
            ),
          Flexible(
            // React to seats so the cap banner + disabled approve stay live.
            child: ValueListenableBuilder<List<SeatState>>(
              valueListenable: widget.controller.seatController.seats,
              builder: (context, _, __) {
                if (_inviteMode) return _invitePicker(strings, theme);
                final full = !widget.controller.hasFreeGuestTile;
                return ValueListenableBuilder<List<SpeakerRequest>>(
                  valueListenable:
                      widget.controller.seatController.pendingRequests,
                  builder: (context, requests, _) {
                    if (requests.isEmpty) {
                      // Empty queue: invite someone instead (owner spec
                      // 2026-06-11).
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(strings.noPendingRequests,
                                style: TextStyle(
                                    color: theme.onSurface
                                        .withValues(alpha: 0.7))),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => _inviteMode = true),
                              icon: Icon(Icons.person_add_alt_1,
                                  color: theme.primary, size: 18),
                              label: Text(strings.inviteSomeoneCta,
                                  style: TextStyle(color: theme.primary)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color:
                                        theme.primary.withValues(alpha: 0.6)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (full)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(strings.guestSlotsFull,
                                style:
                                    TextStyle(color: theme.danger, fontSize: 13)),
                          ),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: requests.length,
                            itemBuilder: (context, i) {
                              final req = requests[i];
                              final busy = _processing.contains(req.id);
                              return UTDMemberRow(
                                participant: _participant(req.identity),
                                trailing: busy
                                    ? const [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Padding(
                                            padding: EdgeInsets.all(4),
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        ),
                                      ]
                                    : [
                                        IconButton(
                                          icon: Icon(Icons.check_circle,
                                              color: full
                                                  ? theme.onSurface
                                                      .withValues(alpha: 0.3)
                                                  : theme.seatRingSpeaking),
                                          tooltip: strings.approve,
                                          onPressed: full
                                              ? null
                                              : () => _act(
                                                  req.id,
                                                  () => widget.controller
                                                      .approveSpeakerRequest(
                                                          req.identity)),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.cancel,
                                              color: theme.danger),
                                          tooltip: strings.reject,
                                          onPressed: () => _act(
                                              req.id,
                                              () => widget.controller
                                                  .rejectSpeakerRequest(
                                                      req.identity)),
                                        ),
                                      ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
