import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/utd_room_controller.dart';
import '../../models/participant_model.dart';
import '../../models/seat_model.dart';
import '../../theme/utd_room_scope.dart';
import '../../theme/utd_room_strings.dart';
import '../../theme/utd_room_theme.dart';
import 'member_row.dart';
import 'utd_sheet.dart';

/// Default host/admin queue of pending speak requests, with approve / reject.
class UTDRequestQueueSheet {
  static Future<void> show(
    BuildContext context, {
    required UTDRoomController controller,
  }) {
    // White background + black text, full width, half the screen's height —
    // on request. Built with its own explicit UTDRoomScope (instead of the
    // shared showUTDRoomSheet's dark default) so both this sheet's chrome
    // and every nested default widget (UTDMemberRow's user-card rows
    // included) consistently pick up the light theme via the normal
    // ancestor lookup, with no per-widget special-casing needed.
    const lightTheme = UTDRoomTheme(
      sheetBackground: Colors.white,
      sheetHandle: Color(0x33000000),
      onSurface: Colors.black,
      surface: Colors.white,
    );
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: lightTheme.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return UTDRoomScope(
          theme: lightTheme,
          strings: UTDRoomStrings.en(),
          controller: controller,
          showSeatNames: false,
          hostSeatIndex: -1,
          roomOwnerId: '',
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(sheetContext).size.height * 0.5,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lightTheme.sheetHandle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _RequestQueue(controller: controller)),
                ],
              ),
            ),
          ),
        );
      },
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
      // maybeOf, not of: this sheet's controller/data already come from
      // `widget.controller` (passed in directly), not the scope -- the
      // scope is only ever used here for theme/strings labels, so a missing
      // ambient UTDRoomScope (this host app never establishes one at all;
      // see the fallback note on `build` below) should fall back to the
      // English defaults instead of crashing the whole sheet.
      _showError(
        (UTDRoomScope.maybeOf(context)?.strings ?? UTDRoomStrings.en())
            .actionFailed,
      );
    }
  }

  void _showError(String message) {
    setState(() => _error = message);
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _error = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    // maybeOf with a default fallback, not the strict `of` (which asserts
    // and crashes the whole sheet): this host app never wraps its custom
    // room UI in a UTDRoomScope anywhere (that InheritedWidget is only ever
    // constructed by showUTDRoomSheet's own re-wrap, never established from
    // scratch), so `of` always threw "No UTDRoomScope found in context" no
    // matter which context called .show(). This widget's actual data
    // (`widget.controller`) never came from the scope anyway -- only the
    // theme/strings labels below do -- so a sensible built-in default is a
    // safe, complete substitute rather than a crash.
    final scope = UTDRoomScope.maybeOf(context);
    final strings = scope?.strings ?? UTDRoomStrings.en();
    final theme = scope?.theme ?? const UTDRoomTheme();

    // Fills whatever height the caller gives it (UTDRequestQueueSheet.show
    // sizes the sheet itself to half the screen) rather than capping its
    // own height, so standalone embedders keep their previous behaviour via
    // whatever constraints they already impose.
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(strings.requestQueue,
                style: TextStyle(
                    color: theme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
          if (_error != null) UTDSheetInlineError(_error!),
          Flexible(
            child: ValueListenableBuilder<List<SpeakerRequest>>(
              valueListenable: widget.controller.seatController.pendingRequests,
              builder: (context, requests, _) {
                if (requests.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(strings.noPendingRequests,
                        style: TextStyle(
                            color: theme.onSurface.withValues(alpha: 0.7))),
                  );
                }
                return ListView.builder(
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
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ]
                          : [
                              IconButton(
                                icon: Icon(Icons.check_circle,
                                    color: theme.seatRingSpeaking),
                                tooltip: strings.approve,
                                onPressed: () => _act(
                                    req.id,
                                    () => widget.controller
                                        .approveSpeakerRequest(req.id)),
                              ),
                              IconButton(
                                icon: Icon(Icons.cancel, color: theme.danger),
                                tooltip: strings.reject,
                                onPressed: () => _act(
                                    req.id,
                                    () => widget.controller
                                        .rejectSpeakerRequest(req.id)),
                              ),
                            ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
  }
}
