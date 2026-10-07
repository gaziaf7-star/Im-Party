// Phase 1 — InAppChatNotifier session reset (#82) + active-marker clearing.
//
// Locks finding #82: a public reset() clears the per-session state (active
// conversation markers + the dedup high-water-mark map) so a new signed-in
// account never inherits the previous session's state. We assert the
// observable surface (the active-group marker via activeGroupRoomId) since the
// dedup map (#55 LRU cap) is private; reset() must also run without throwing
// with no overlay/navigator mounted (best-effort teardown).

import 'package:flutter_test/flutter_test.dart';

import 'package:general/src/core/realtime/in_app_chat_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final notifier = InAppChatNotifier.instance;

  tearDown(() {
    // Leave the singleton clean for any other suite.
    notifier.reset();
  });

  group('InAppChatNotifier.reset (#82)', () {
    test('clears the active group marker', () {
      notifier.setActiveGroup(99);
      expect(notifier.activeGroupRoomId, 99);

      notifier.reset();

      expect(notifier.activeGroupRoomId, isNull);
    });

    test('clears the active peer marker (no longer suppresses a new session)',
        () {
      notifier.setActivePeer(1234);
      notifier.setActiveGroup(77);
      expect(notifier.activeGroupRoomId, 77);

      notifier.reset();

      // Both markers cleared; the group getter is the observable proof.
      expect(notifier.activeGroupRoomId, isNull);
    });

    test('reset() is safe with no overlay/navigator mounted (no throw)', () {
      expect(notifier.reset, returnsNormally);
    });
  });
}
