// Phase 4 — chat push-notification routing + active-room suppression.
//
// Locks the testable surface of the Phase-4 fixes:
//   * #84 — RemoteNotificationModel.fromJson preserves real absence (null) for
//     control-flow fields instead of coercing to '' (which defeated the
//     null-type inference fallback + parsed ids to a bogus 0), and now carries
//     chatRoomId so a chat tap can deep-link into the conversation.
//   * #10 — chatRoomId is parsed from any of the common backend keys.
//   * #11 — the readiness-gated launch dispatch decides dispatch / retry / drop
//     purely from (navigatorReady, attempts) — no fixed delay, never lost on a
//     slow boot nor looping forever on a stuck one.
//   * #41 — InAppChatNotifier targeted clears (clearActivePeerIfMatches /
//     clearActiveGroupIfMatches) only drop the marker when it still points at
//     the closing conversation, so a fast A→B switch never wipes B's marker.

import 'package:flutter_test/flutter_test.dart';

import 'package:general/src/core/realtime/in_app_chat_notifier.dart';
import 'package:general/src/core/services/notification/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteNotificationModel.fromJson (#84 null preservation)', () {
    test('missing message-type stays null (not "") so inference can fire', () {
      final m = RemoteNotificationModel.fromJson(<String, dynamic>{});
      expect(m.type, isNull);
    });

    test('present message-type is preserved verbatim', () {
      final m = RemoteNotificationModel.fromJson({'message-type': 'chat-payload'});
      expect(m.type, 'chat-payload');
    });

    test('missing control fields stay null (channelId/userName/toUserId)', () {
      final m = RemoteNotificationModel.fromJson(<String, dynamic>{});
      expect(m.channelId, isNull);
      expect(m.userName, isNull);
      expect(m.toUserId, isNull);
    });

    test('control fields read snake_case + camelCase aliases', () {
      final snake = RemoteNotificationModel.fromJson({
        'channel_id': 'c1',
        'user_name': 'Sara',
        'to_user_id': '42',
      });
      expect(snake.channelId, 'c1');
      expect(snake.userName, 'Sara');
      expect(snake.toUserId, '42');

      final camel = RemoteNotificationModel.fromJson({
        'channelId': 'c2',
        'userName': 'Omar',
        'toUserId': '7',
      });
      expect(camel.channelId, 'c2');
      expect(camel.userName, 'Omar');
      expect(camel.toUserId, '7');
    });
  });

  group('RemoteNotificationModel.fromJson (#10 chatRoomId parsing)', () {
    test('chat_room_id is parsed', () {
      final m = RemoteNotificationModel.fromJson({'chat_room_id': 123});
      expect(m.chatRoomId, '123');
    });

    test('chatRoomId camelCase is parsed', () {
      final m = RemoteNotificationModel.fromJson({'chatRoomId': '456'});
      expect(m.chatRoomId, '456');
    });

    test('room_id fallback is parsed', () {
      final m = RemoteNotificationModel.fromJson({'room_id': 789});
      expect(m.chatRoomId, '789');
    });

    test('absent chatRoomId stays null', () {
      final m = RemoteNotificationModel.fromJson(<String, dynamic>{});
      expect(m.chatRoomId, isNull);
    });

    test('chat_room_id wins over the camelCase / room_id aliases', () {
      final m = RemoteNotificationModel.fromJson({
        'chat_room_id': 1,
        'chatRoomId': 2,
        'room_id': 3,
      });
      expect(m.chatRoomId, '1');
    });

    test('chatRoomId is round-tripped through toJson for logging', () {
      final m = RemoteNotificationModel.fromJson({'chat_room_id': 55});
      expect(m.toJson()['chat_room_id'], '55');
    });
  });

  group('NotificationService.dispatchReadiness (#11 readiness gate)', () {
    test('dispatches as soon as the navigator is ready', () {
      expect(
        NotificationService.dispatchReadiness(navigatorReady: true, attempts: 0),
        DispatchReadiness.dispatch,
      );
      // Even at a high attempt count, a ready navigator dispatches now.
      expect(
        NotificationService.dispatchReadiness(navigatorReady: true, attempts: 99),
        DispatchReadiness.dispatch,
      );
    });

    test('retries while the navigator is not ready and attempts remain', () {
      expect(
        NotificationService.dispatchReadiness(navigatorReady: false, attempts: 0),
        DispatchReadiness.retry,
      );
      expect(
        NotificationService.dispatchReadiness(navigatorReady: false, attempts: 39),
        DispatchReadiness.retry,
      );
    });

    test('drops once the attempt cap is reached (never loops forever)', () {
      expect(
        NotificationService.dispatchReadiness(navigatorReady: false, attempts: 40),
        DispatchReadiness.drop,
      );
      expect(
        NotificationService.dispatchReadiness(
            navigatorReady: false, attempts: 40, maxAttempts: 40),
        DispatchReadiness.drop,
      );
    });
  });

  group('InAppChatNotifier targeted clears (#41 A→B switch race)', () {
    final notifier = InAppChatNotifier.instance;

    tearDown(() => notifier.reset());

    test('clearActivePeerIfMatches only clears when the peer matches', () {
      notifier.setActivePeer(10);
      // A non-matching close (the OLD chat closing after B opened) is a no-op.
      notifier.clearActivePeerIfMatches(99);
      expect(notifier.activePeerUserId, 10);
      // The matching close clears it.
      notifier.clearActivePeerIfMatches(10);
      expect(notifier.activePeerUserId, isNull);
    });

    test('A→B peer switch: A.close does NOT wipe B once B is active', () {
      // A opens.
      notifier.setActivePeer(1);
      // B opens (overwrites the single marker), then A's dispose runs.
      notifier.setActivePeer(2);
      notifier.clearActivePeerIfMatches(1); // A closing
      // B's marker survives — banners for B stay suppressed.
      expect(notifier.activePeerUserId, 2);
    });

    test('clearActiveGroupIfMatches only clears when the group matches', () {
      notifier.setActiveGroup(20);
      notifier.clearActiveGroupIfMatches(77);
      expect(notifier.activeGroupRoomId, 20);
      notifier.clearActiveGroupIfMatches(20);
      expect(notifier.activeGroupRoomId, isNull);
    });

    test('A→B group switch: A.close does NOT wipe B once B is active', () {
      notifier.setActiveGroup(100);
      notifier.setActiveGroup(200);
      notifier.clearActiveGroupIfMatches(100); // A closing
      expect(notifier.activeGroupRoomId, 200);
    });

    test('null id is a safe no-op', () {
      notifier.setActivePeer(5);
      notifier.clearActivePeerIfMatches(null);
      expect(notifier.activePeerUserId, 5);
    });
  });
}
