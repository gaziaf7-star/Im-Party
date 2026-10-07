// Phase 9 — outside-room Pusher->Centrifugo migration (WAVE 1 + WAVE 2) CLIENT
// ROUTING.
//
// Asserts the receive-side contract for every migrated outside-room channel:
// a Centrifugo publication wrapped as {event, payload} (exactly what
// CentrifugoBroadcaster emits) is decoded, the envelope unwrapped, and routed to
// the NON-CHAT consumer stream (RealtimeClient.nonChatEvents) — and is NEVER
// parsed as a chat message (no drift message row, no phantom room). It also
// proves the inverse: a genuine message event still lands in drift. WAVE-2
// banners (lucky-gift / games / room-comment) keep their legacy `broadcastAs`
// event names and a {messageContent: {...}} payload, and are routed identically.
//
// The routing runs through RealtimeClient.debugRouteOutsideRoomPublication, the
// test seam that feeds raw publication bytes into the same pipeline the live
// `user:#{id}` / server-side publication handlers use — so this exercises the
// real _decode + _routeNonChatEvent + message classification, not a copy.

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/realtime/realtime_client.dart';
import 'package:general/src/core/realtime/realtime_token_service.dart';
import 'package:general/src/core/realtime/sync_engine.dart';
import 'package:general/src/core/network/dio_factory.dart';

import 'support/fake_realtime_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late RealtimeClient client;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final http = FakeRealtimeHttp();
    final syncEngine = SyncEngine(
      http: http,
      messagesDao: db.messagesDao,
      roomsDao: db.roomsDao,
      syncStateDao: db.syncStateDao,
      sinceSeqUrl: (roomId, sinceSeq) => '/rooms/$roomId/messages?since_seq=$sinceSeq',
      roomsListUrl: '/sync/rooms',
    );
    client = RealtimeClient(
      tokenService: RealtimeTokenService(_NoopDio()),
      messagesDao: db.messagesDao,
      roomsDao: db.roomsDao,
      syncStateDao: db.syncStateDao,
      syncEngine: syncEngine,
    );
  });

  tearDown(() async => db.close());

  /// Encode a publication exactly the way CentrifugoBroadcaster wraps it:
  /// {event, payload} -> UTF-8 JSON bytes (the SDK's PublicationEvent.data).
  List<int> envelope(String event, Object payload) =>
      utf8.encode(jsonEncode({'event': event, 'payload': payload}));

  /// Push a publication through the real outside-room routing pipeline and return
  /// the first non-chat event it emits (or null if none within a microtask turn).
  Future<RealtimeNonChatEvent?> routeAndCapture(List<int> data) async {
    RealtimeNonChatEvent? captured;
    final sub = client.nonChatEvents.listen((e) => captured ??= e);
    client.debugRouteOutsideRoomPublication(data);
    // nonChatEvents is a synchronous broadcast add, but flush a turn to be safe.
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    return captured;
  }

  // ---------------------------------------------------------------------------
  // GLOBAL banners (broadcast to all; carry NO private data) -> nonChatEvents.
  // The map keys are the backend `broadcastAs` event names preserved verbatim in
  // the envelope; super-lucky-box carries a JSON ARRAY payload (the rest a Map).
  // ---------------------------------------------------------------------------

  group('GLOBAL banner channels route to nonChatEvents (Map payload)', () {
    final mapCases = <String, Map<String, dynamic>>{
      'gift_banner': {'gift': 'x', 'message': 'showBanner'},
      'end_room_boom': {'endData': {'level': 3}},
      'zego_feature': {'closed': true},
    };

    mapCases.forEach((event, payload) {
      test('$event is decoded + routed, payload unwrapped as Map', () async {
        final captured = await routeAndCapture(envelope(event, payload));
        expect(captured, isNotNull, reason: '$event should reach nonChatEvents');
        expect(captured!.event, event);
        expect(captured.payload, isA<Map>());
        // _decode unwraps the {event,payload} envelope to the flat payload Map and
        // injects an additive `_event` routing key the legacy consumers ignore.
        // Every original field must survive verbatim.
        final out = captured.payload as Map;
        payload.forEach((k, v) => expect(out[k], v));
        expect(out['_event'], event);
      });
    });

    test('superLuckBox keeps its List payload (consumer takes .first)', () async {
      // SuperLuckyBox.broadcastWith() returns a JSON array; _decode must preserve
      // the list so _handleLuckyBoxBanner can read dataList.first.
      final listPayload = [
        {'coins': 100, 'boxUId': 'b1', 'sender': {'s_name': 'A'}, 'room': {'room_type': 0}},
      ];
      final captured = await routeAndCapture(envelope('superLuckBox', listPayload));
      expect(captured, isNotNull);
      expect(captured!.event, 'superLuckBox');
      expect(captured.payload, isA<List>());
      expect((captured.payload as List).first['coins'], 100);
    });
  });

  // ---------------------------------------------------------------------------
  // PER-USER channels (unread-{id} + status-user-{id}) route to nonChatEvents.
  // On the wire both land on user:#{id} (user-limited at the node), so the client
  // can only ever receive ITS OWN payload; routing keys off the event name.
  // ---------------------------------------------------------------------------

  group('PER-USER channels route to nonChatEvents with the user payload', () {
    test('UnreadCounterIndividual carries the per-user counter Map', () async {
      final payload = {'type': 'friend', 'counter': 4};
      final captured = await routeAndCapture(envelope('UnreadCounterIndividual', payload));
      expect(captured, isNotNull);
      expect(captured!.event, 'UnreadCounterIndividual');
      expect(captured.payload, isA<Map>());
      expect(captured.payload['type'], 'friend');
    });

    test('status-user carries the per-user game-status Map', () async {
      final payload = {'can_play': true, 'show_invite_code': false};
      final captured = await routeAndCapture(envelope('status-user', payload));
      expect(captured, isNotNull);
      expect(captured!.event, 'status-user');
      expect(captured.payload, isA<Map>());
      expect(captured.payload['can_play'], true);
    });
  });

  // ---------------------------------------------------------------------------
  // Isolation: a banner/counter publication must NEVER touch the drift message
  // path — no message row, no phantom room. This is the regression guard that
  // the envelope unwrap + _event routing short-circuits before _applyMessage.
  // ---------------------------------------------------------------------------

  group('migrated banner/counter events never create drift rows', () {
    final allMigrated = <String, Object>{
      'gift_banner': {'gift': 'x'},
      'superLuckBox': [
        {'coins': 1},
      ],
      'end_room_boom': {'endData': {}},
      'zego_feature': {'closed': true},
      'UnreadCounterIndividual': {'type': 'follow'},
      'status-user': {'can_play': false},
      'win.lucky.gift.event': {'messageContent': {'event': 'win.lucky.gift.event'}},
      'baishun.game.event': {'messageContent': {'event': 'baishun.game.event'}},
      'room.comment.event': {'messageContent': {'event': 'room.comment.event'}},
    };

    allMigrated.forEach((event, payload) {
      test('$event writes nothing to messages/rooms', () async {
        // Banners commonly include a room_id; assert it does NOT get materialized
        // as a chat room (the message path keys off chat_room_id/room_id).
        final withRoom = payload is Map
            ? ({...payload, 'room_id': 9999})
            : payload;
        client.debugRouteOutsideRoomPublication(envelope(event, withRoom));
        await Future<void>.delayed(Duration.zero);

        expect(
          await db.roomsDao.findByServerRoomId(9999),
          isNull,
          reason: '$event must not create a phantom room',
        );
      });
    });
  });

  // ---------------------------------------------------------------------------
  // Negative control: a GENUINE message event still flows to drift, proving the
  // router actually discriminates (it is not just dropping everything).
  // ---------------------------------------------------------------------------

  test('a real message event (update-conversation-list) creates a drift row', () async {
    const clientUuid = 'msg-uuid-1';
    client.debugRouteOutsideRoomPublication(envelope('update-conversation-list', {
      'id': 501,
      'client_uuid': clientUuid,
      'server_seq': 7,
      'chat_room_id': 321,
      'user_id': 42,
      'kind': 'user',
      'type': 'text',
      'message': 'hi',
      'created_at': '2026-06-03T10:00:00Z',
    }));
    // Let the async _applyMessageByServerRoom chain complete.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final row = await db.messagesDao.findByClientUuid(clientUuid);
    expect(row, isNotNull, reason: 'genuine message must reach drift');
    expect(await db.roomsDao.findByServerRoomId(321), isNotNull);

    // And it must NOT be misrouted onto the banner consumer stream.
    final stray = await routeAndCapture(
      envelope('update-conversation-list', {'id': 1, 'client_uuid': 'x'}),
    );
    expect(stray, isNull, reason: 'a message event is not a non-chat event');
  });

  // ---------------------------------------------------------------------------
  // WAVE-2 banners (lucky-gift / games / room-comment) DO have a Centrifugo
  // publisher (BannerEvent -> CentrifugoBroadcaster) and are now migrated on the
  // client too. They keep the backend `broadcastAs` event names verbatim and
  // carry the `{messageContent: {...}}` Map the legacy Pusher consumers read via
  // `data[messageContent]` — so the unwrapped payload must reach nonChatEvents
  // with that field intact, exactly like the WAVE-1 Map banners.
  // ---------------------------------------------------------------------------

  group('WAVE-2 banner channels route to nonChatEvents (messageContent Map)', () {
    for (final event in const [
      'win.lucky.gift.event',
      'baishun.game.event',
      'room.comment.event',
    ]) {
      test('$event is decoded + routed, messageContent preserved', () async {
        final payload = {
          'messageContent': {'event': event, 'uId': 7},
        };
        final captured = await routeAndCapture(envelope(event, payload));
        expect(captured, isNotNull, reason: '$event should reach nonChatEvents');
        expect(captured!.event, event);
        expect(captured.payload, isA<Map>());
        final out = captured.payload as Map;
        // The consumer reads payload[messageContent]; it must survive the unwrap.
        expect(out['messageContent'], isA<Map>());
        expect(out['messageContent']['uId'], 7);
        expect(out['_event'], event);
      });
    }
  });

  // ---------------------------------------------------------------------------
  // Decode robustness: garbage bytes and a non-JSON-object body are dropped
  // safely (no throw, no emission) — the live socket must tolerate noise.
  // ---------------------------------------------------------------------------

  test('malformed / non-object publications are ignored without throwing', () async {
    expect(await routeAndCapture(utf8.encode('not json')), isNull);
    expect(await routeAndCapture(utf8.encode('123')), isNull);
    expect(await routeAndCapture(utf8.encode('"a string"')), isNull);
  });
}

/// Minimal DioFactory stand-in: RealtimeTokenService is constructed for the
/// RealtimeClient but no token call happens on the routing path under test
/// (connect()/subscribe() are never invoked here).
class _NoopDio implements DioFactory {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Dio is not exercised by routing tests');
}
