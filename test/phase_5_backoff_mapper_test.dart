// Phase 5 — pure-logic unit tests for the realtime infrastructure helpers:
//   * OutboxBackoff: exponential growth, cap clamp, full-jitter bounds,
//     deterministic schedule under a seeded Random, overflow guard.
//   * RealtimeMessageMapper: JSON -> drift MessagesCompanion translation,
//     dedup-identity guard, content-type/kind/epoch parsing.

import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/realtime/outbox_backoff.dart';
import 'package:general/src/core/realtime/realtime_message_mapper.dart';

void main() {
  group('OutboxBackoff', () {
    const backoff = OutboxBackoff(
      base: Duration(seconds: 2),
      cap: Duration(minutes: 5),
    );

    test('full jitter keeps every delay within [0, exp window]', () {
      final rnd = Random(42);
      for (var attempt = 0; attempt < 10; attempt++) {
        final windowMs = (2000 * (1 << (attempt > 20 ? 20 : attempt)))
            .clamp(0, 5 * 60 * 1000);
        for (var i = 0; i < 50; i++) {
          final d = backoff.nextDelay(attempt, rnd).inMilliseconds;
          expect(d, greaterThanOrEqualTo(0));
          expect(d, lessThanOrEqualTo(windowMs));
        }
      }
    });

    test('delay window is clamped to cap for large attempt counts', () {
      // A fixed Random that always returns the max draw so we hit the ceiling.
      final maxRnd = _MaxRandom();
      final d = backoff.nextDelay(30, maxRnd).inMilliseconds;
      expect(d, lessThanOrEqualTo(const Duration(minutes: 5).inMilliseconds));
      // attempt 30 would overflow without the shift guard; assert it didn't.
      expect(d, greaterThan(0));
    });

    test('nextRetryAt offsets from now by the jittered delay', () {
      final rnd = Random(7);
      const now = 1000000;
      final at = backoff.nextRetryAt(2, now, Random(7));
      final delay = backoff.nextDelay(2, rnd).inMilliseconds;
      expect(at, now + delay);
    });

    test('attempt 0 grows from the base window, attempt 3 is larger', () {
      final lowSeed = _MaxRandom();
      final a0 = backoff.nextDelay(0, lowSeed).inMilliseconds; // <= 2000
      final a3 = backoff.nextDelay(3, lowSeed).inMilliseconds; // <= 16000
      expect(a0, lessThanOrEqualTo(2000));
      expect(a3, greaterThan(a0));
    });
  });

  group('RealtimeMessageMapper', () {
    const mapper = RealtimeMessageMapper();

    test('maps a full server message to a delivered companion', () {
      final c = mapper.toCompanion(
        {
          'id': 555,
          'client_uuid': 'uuid-1',
          'server_seq': 42,
          'user_id': 9,
          'kind': 'user',
          'type': 'image',
          'message': 'hello',
          'reply_to_client_uuid': 'uuid-0',
          'created_at': '2026-06-01T10:00:00Z',
        },
        roomLocalId: 3,
      );

      expect(c, isNotNull);
      expect(c!.serverMessageId, const Value(555));
      expect(c.clientUuid, const Value('uuid-1'));
      expect(c.serverSeq, const Value(42));
      expect(c.senderId, const Value(9));
      expect(c.roomId, const Value(3));
      expect(c.kind, const Value(MessageKind.user));
      expect(c.type, const Value(MessageContentType.image));
      expect(c.body, const Value('hello'));
      expect(c.replyToClientUuid, const Value('uuid-0'));
      expect(c.state, const Value(MessageState.delivered));
      expect(c.serverCreatedAt.present, isTrue);
    });

    test('returns null when neither client_uuid nor id is present', () {
      final c = mapper.toCompanion({'message': 'x'}, roomLocalId: 1);
      expect(c, isNull);
    });

    test('defaults unknown content type to text and missing kind to user', () {
      final c = mapper.toCompanion(
        {'id': 1, 'type': 'sticker'},
        roomLocalId: 1,
      );
      expect(c!.type, const Value(MessageContentType.text));
      expect(c.kind, const Value(MessageKind.user));
    });

    test('system kind is recognized', () {
      final c = mapper.toCompanion(
        {'id': 2, 'kind': 'system', 'system_event': 'member_joined'},
        roomLocalId: 1,
      );
      expect(c!.kind, const Value(MessageKind.system));
      expect(c.systemEvent, const Value('member_joined'));
    });

    test('serverRoomId reads chat_room_id then room_id', () {
      expect(mapper.serverRoomId({'chat_room_id': 77}), 77);
      expect(mapper.serverRoomId({'room_id': 88}), 88);
      expect(mapper.serverRoomId({'x': 1}), isNull);
    });

    test('epoch parses both int and ISO string timestamps', () {
      final fromInt =
          mapper.toCompanion({'id': 1, 'created_at': 1700000000000}, roomLocalId: 1);
      expect(fromInt!.serverCreatedAt, const Value(1700000000000));

      final fromIso = mapper.toCompanion(
        {'id': 1, 'created_at': '2026-06-01T00:00:00Z'},
        roomLocalId: 1,
      );
      expect(fromIso!.serverCreatedAt.present, isTrue);
      expect(fromIso.serverCreatedAt.value, isNotNull);
    });
  });
}

/// Random stub whose nextInt always returns the maximum value (max - 1),
/// pushing the jittered delay to the top of its window for ceiling assertions.
class _MaxRandom implements Random {
  @override
  int nextInt(int max) => max <= 0 ? 0 : max - 1;

  @override
  bool nextBool() => true;

  @override
  double nextDouble() => 1.0;
}
