import 'package:flutter/widgets.dart';

import '../controller/utd_room_controller.dart';
import 'utd_room_strings.dart';
import 'utd_room_theme.dart';

/// Carries the room's [theme], [strings], [controller] and a few config flags
/// down to the package's built-in default widgets via the element tree.
///
/// NOTE: modal bottom sheets / dialogs are pushed as **separate routes** that do
/// not inherit this scope. Each `.show()` helper for a default sheet captures
/// `UTDRoomScope.of(context)` BEFORE showing and re-wraps the sheet body in a
/// fresh [UTDRoomScope] so nested default UI can still read theme/strings.
class UTDRoomScope extends InheritedWidget {
  final UTDRoomTheme theme;
  final UTDRoomStrings strings;
  final UTDRoomController controller;

  /// Seat index that maps to the host tile (always 0 in live).
  final int hostSeatIndex;

  /// The room owner's identity (owner-only actions like promote/demote gate on
  /// this).
  final String roomOwnerId;

  const UTDRoomScope({
    super.key,
    required this.theme,
    required this.strings,
    required this.controller,
    required this.hostSeatIndex,
    required this.roomOwnerId,
    required super.child,
  });

  static UTDRoomScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UTDRoomScope>();

  static UTDRoomScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No UTDRoomScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(UTDRoomScope oldWidget) =>
      theme != oldWidget.theme ||
      strings != oldWidget.strings ||
      controller != oldWidget.controller ||
      hostSeatIndex != oldWidget.hostSeatIndex ||
      roomOwnerId != oldWidget.roomOwnerId;
}
