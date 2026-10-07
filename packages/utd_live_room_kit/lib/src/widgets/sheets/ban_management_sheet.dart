import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/utd_room_controller.dart';
import '../../models/ban_model.dart';
import '../../theme/utd_room_scope.dart';
import '../default_avatar.dart';
import 'utd_sheet.dart';

/// Default host/admin view of the project's active bans, with an unban action.
class UTDBanManagementSheet {
  static Future<void> show(
    BuildContext context, {
    required UTDRoomController controller,
  }) {
    return showUTDRoomSheet<void>(
      context,
      builder: (_) => _BanManagement(controller: controller),
    );
  }
}

class _BanManagement extends StatefulWidget {
  final UTDRoomController controller;

  const _BanManagement({required this.controller});

  @override
  State<_BanManagement> createState() => _BanManagementState();
}

class _BanManagementState extends State<_BanManagement> {
  bool _loading = true;
  List<UTDBannedUser> _bans = const [];

  /// Identities with an unban call in flight — guards against a second tap
  /// re-firing before the row is removed.
  final Set<String> _unbanning = {};

  /// Transient inline error (a snackbar would render behind this open sheet).
  String? _error;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }

  void _showError(String message) {
    setState(() => _error = message);
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _error = null);
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final page = await widget.controller.listBans();
    if (!mounted) return;
    setState(() {
      _bans = page?.data ?? const [];
      _loading = false;
    });
  }

  Future<void> _unban(UTDBannedUser ban) async {
    if (_unbanning.contains(ban.identity)) return; // double-tap guard
    setState(() => _unbanning.add(ban.identity));
    bool ok = false;
    try {
      ok = await widget.controller.unbanUser(
        ban.identity,
        global: ban.isGlobal,
        roomName: ban.roomName,
      );
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() => _unbanning.remove(ban.identity));
    if (ok) {
      setState(() => _bans = _bans.where((b) => b.id != ban.id).toList());
    } else {
      _showError(UTDRoomScope.of(context).strings.actionFailed);
    }
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(strings.banManagement,
                style: TextStyle(
                    color: theme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
          if (_error != null) UTDSheetInlineError(_error!),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (_bans.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(strings.noBans,
                  style:
                      TextStyle(color: theme.onSurface.withValues(alpha: 0.7))),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _bans.length,
                itemBuilder: (context, i) {
                  final ban = _bans[i];
                  final name = (ban.name?.isNotEmpty ?? false)
                      ? ban.name!
                      : ban.identity;
                  return ListTile(
                    leading: UTDDefaultAvatar(
                      url: ban.attributes?.avatar,
                      name: name,
                      fallbackId: ban.identity,
                      size: 40,
                      theme: theme,
                    ),
                    title: Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: theme.onSurface)),
                    subtitle: ban.reason != null
                        ? Text(ban.reason!,
                            style: TextStyle(
                                color: theme.onSurface.withValues(alpha: 0.6)))
                        : null,
                    trailing: _unbanning.contains(ban.identity)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: () => _unban(ban),
                            child: Text(strings.unban),
                          ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
