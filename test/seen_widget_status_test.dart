// Pure-Dart unit tests for the delivery-status mapping (Jo Live, package `general`).
//
// `_SeenWidget` lives inside messages_page.dart (a `part` file) and depends on
// the Flutter widget tree, so this file follows the project convention of
// crash_fix_helpers_test.dart: the testable rule (messageState + legacy
// `status` -> which icon to show) is replicated as a pure function and pinned
// against the four UX states the spec calls for: clock / single check / double
// check / red error. If production drifts, update this replica in lockstep.

import 'package:flutter_test/flutter_test.dart';

enum MessageState { loading, sent, sending, error, none }

enum DeliveryIcon { clock, singleCheck, doubleCheck, error }

// Replica of _SeenWidget._statusIcon / _fromStatus reduced to its decision.
DeliveryIcon iconFor({required MessageState state, String? legacyStatus}) {
  switch (state) {
    case MessageState.sending:
      return DeliveryIcon.clock;
    case MessageState.error:
      return DeliveryIcon.error;
    case MessageState.sent:
      return DeliveryIcon.singleCheck;
    case MessageState.loading:
    case MessageState.none:
      // Server-pushed messages don't set messageState, only the legacy string.
      if (legacyStatus == 'sended') return DeliveryIcon.singleCheck;
      if (legacyStatus == 'received') return DeliveryIcon.doubleCheck;
      return DeliveryIcon.doubleCheck;
  }
}

void main() {
  group('iconFor — local-first state wins', () {
    test('MessageState.sending -> clock (ignores legacy status)', () {
      expect(
        iconFor(state: MessageState.sending, legacyStatus: 'sended'),
        DeliveryIcon.clock,
      );
      expect(
        iconFor(state: MessageState.sending, legacyStatus: null),
        DeliveryIcon.clock,
      );
    });

    test('MessageState.error -> red error mark (the retry signal)', () {
      expect(
        iconFor(state: MessageState.error, legacyStatus: 'sended'),
        DeliveryIcon.error,
      );
    });

    test('MessageState.sent -> single check', () {
      expect(
        iconFor(state: MessageState.sent, legacyStatus: null),
        DeliveryIcon.singleCheck,
      );
    });
  });

  group('iconFor — legacy status used when state has no signal', () {
    test('loading + status=sended -> single check (server-pushed mine)', () {
      expect(
        iconFor(state: MessageState.loading, legacyStatus: 'sended'),
        DeliveryIcon.singleCheck,
      );
    });

    test('loading + status=received -> double check (the recipient saw it)', () {
      expect(
        iconFor(state: MessageState.loading, legacyStatus: 'received'),
        DeliveryIcon.doubleCheck,
      );
    });

    test('loading + unknown/null status falls back to double check', () {
      expect(
        iconFor(state: MessageState.loading, legacyStatus: null),
        DeliveryIcon.doubleCheck,
      );
      expect(
        iconFor(state: MessageState.loading, legacyStatus: ''),
        DeliveryIcon.doubleCheck,
      );
      expect(
        iconFor(state: MessageState.loading, legacyStatus: 'garbage'),
        DeliveryIcon.doubleCheck,
      );
    });

    test('none + status=received -> double check', () {
      expect(
        iconFor(state: MessageState.none, legacyStatus: 'received'),
        DeliveryIcon.doubleCheck,
      );
    });
  });

  group('iconFor — the four UX states are all reachable', () {
    test('every DeliveryIcon variant maps from at least one input', () {
      final reachable = <DeliveryIcon>{};
      for (final state in MessageState.values) {
        for (final status in const <String?>[null, 'sended', 'received']) {
          reachable.add(iconFor(state: state, legacyStatus: status));
        }
      }
      // Locks in: no UX state silently went missing after refactors.
      expect(reachable, DeliveryIcon.values.toSet());
    });
  });
}
