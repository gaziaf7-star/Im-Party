// Realtime outside-room routing invariants (Centrifugo + drift offline-first).
//
// Locks the receive-side contract for the events that ride user:#{id} / the
// server-side socket but are NOT chat messages, plus the reconnect catch-up:
//
//   1. A peer delete-for-everyone (`delete-message`) is routed to drift: it
//      flips the affected EXISTING row to deletedForAll and inserts NOTHING
//      (never dropped, never a phantom row).
//   2. A peer reaction toggle (`react-event`) is routed to drift: it replaces
//      the reactions JSON on the EXISTING row by server id, inserting NOTHING.
//   3. A genuine message arriving on the user channel with a seq HOLE triggers
//      SyncEngine.fillGap (group/closed-DM messages have no positioned-recovery
//      _ChatChannel, so this is their only gap-fill path).
//   4. A reconnect re-runs SyncEngine.syncRoomsList (groups + closed DMs that
//      changed during the gap surface even when Centrifugo recovery was lost).
//   5. A WAVE-2 banner (`win.lucky.gift.event` / `baishun.game.event` /
//      `room.comment.event`) is routed to nonChatEvents and NEVER to the message
//      path (no message row, no phantom room).
//
// Everything runs through the production routing entry points
// (RealtimeClient.debugRouteOutsideRoomPublication = the live user:#{id} /
// server-publication pipeline, and debugReconnectCatchUp = the connected
// listener's catch-up), so this exercises real code, not a copy. A spy
// SyncEngine records fillGap / syncRoomsList without any network.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/daos/messages_dao.dart';
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/daos/sync_state_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/network/dio_factory.dart';
import 'package:general/src/core/realtime/realtime_client.dart';
import 'package:general/src/core/realtime/realtime_token_service.dart';
import 'package:general/src/core/realtime/sync_engine.dart';
import 'package:general/src/features/auth/data/model/my_data_model.dart';

import 'support/fake_realtime_http.dart';

/// SyncEngine spy: records fillGap / syncRoomsList invocations so the routing
/// wiring can be asserted without a live socket or any real HTTP. fillGap is
/// stubbed to a no-op (returns 0) so the routing under test doesn't depend on a
/// scripted response; syncRoomsList delegates to the real implementation (which
/// hits the injected FakeRealtimeHttp) so its single-flight + apply contract
/// still runs.
class _SpySyncEngine extends SyncEngine {
  _SpySyncEngine({
    required super.http,
    required super.messagesDao,
    required super.roomsDao,
    required super.syncStateDao,
    required super.sinceSeqUrl,
    super.roomsListUrl,
  });

  final List<
      ({
        int roomLocalId,
        int serverRoomId,
        int expectedAfterSeq,
        int beforeMax
      })> fillGapCalls = [];
  int syncRoomsListCalls = 0;

  @override
  Future<int> fillGap({
    required int roomLocalId,
    required int serverRoomId,
    required int expectedAfterSeq,
    required int beforeMax,
  }) async {
    fillGapCalls.add((
      roomLocalId: roomLocalId,
      serverRoomId: serverRoomId,
      expectedAfterSeq: expectedAfterSeq,
      beforeMax: beforeMax,
    ));
    return 0;
  }

  @override
  Future<int> syncRoomsList() async {
    syncRoomsListCalls++;
    return super.syncRoomsList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late MessagesDao messagesDao;
  late RoomsDao roomsDao;
  late SyncStateDao syncStateDao;
  late FakeRealtimeHttp http;
  late _SpySyncEngine syncEngine;
  late RealtimeClient client;

  // The signed-in user. The user-channel message path keys "incoming" off this
  // id; delete/react routing don't depend on it.
  const int myId = 100;
  const int peerId = 200;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    messagesDao = db.messagesDao;
    roomsDao = db.roomsDao;
    syncStateDao = db.syncStateDao;
    http = FakeRealtimeHttp();
    // Default rooms-list response is an empty list so syncRoomsList is a clean
    // no-op unless a test scripts otherwise.
    http.onGet = (_) async => _ok(const <dynamic>[]);

    syncEngine = _SpySyncEngine(
      http: http,
      messagesDao: messagesDao,
      roomsDao: roomsDao,
      syncStateDao: syncStateDao,
      sinceSeqUrl: (roomId, sinceSeq) =>
          '/rooms/$roomId/messages?since_seq=$sinceSeq',
      roomsListUrl: '/sync/rooms',
    );

    client = RealtimeClient(
      tokenService: RealtimeTokenService(_NoopDio()),
      messagesDao: messagesDao,
      roomsDao: roomsDao,
      syncStateDao: syncStateDao,
      syncEngine: syncEngine,
    );

    MyDataModel.fromJson(const {'id': myId});
  });

  tearDown(() async {
    MyDataModel.getInstance().clearInstance();
    await db.close();
  });

  /// Encode a publication the way CentrifugoBroadcaster wraps it on the wire.
  List<int> envelope(String event, Object payload) =>
      utf8.encode(jsonEncode({'event': event, 'payload': payload}));

  // Total message rows across every room (phantom-row guard).
  Future<int> countMessages() async {
    final rows = await db.select(db.messages).get();
    return rows.length;
  }

  /// Seed a 1:1 room with one peer message already stored (server id + seq).
  Future<({int roomLocalId, int messageLocalId})> seedRoomWithPeerMessage({
    required int serverRoomId,
    required int serverMessageId,
    required int serverSeq,
  }) async {
    final roomLocalId = await roomsDao.insertRoom(RoomsCompanion.insert(
      type: RoomType.dm,
      serverRoomId: drift.Value(serverRoomId),
      peerUserId: const drift.Value(peerId),
    ));
    final messageLocalId = await messagesDao.upsertFromServer(
      MessagesCompanion.insert(
        clientUuid: 'peer-$serverMessageId',
        roomId: roomLocalId,
        kind: MessageKind.user,
        type: MessageContentType.text,
        createdAtClient: 1700000000000,
        state: MessageState.delivered,
        serverMessageId: drift.Value(serverMessageId),
        serverSeq: drift.Value(serverSeq),
        senderId: const drift.Value(peerId),
        body: const drift.Value('hello'),
      ),
    );
    return (roomLocalId: roomLocalId, messageLocalId: messageLocalId);
  }

  // ---------------------------------------------------------------------------
  // 1. Peer delete-for-everyone -> drift (existing row flipped, no phantom row).
  // ---------------------------------------------------------------------------

  test('peer delete-message is routed to drift, flips the existing row, no '
      'phantom row', () async {
    const serverRoomId = 321;
    const serverMessageId = 5001;
    final seeded = await seedRoomWithPeerMessage(
      serverRoomId: serverRoomId,
      serverMessageId: serverMessageId,
      serverSeq: 10,
    );
    final before = await countMessages();
    expect(before, 1);

    // Legacy Pusher shape: message_id is a list of (stringified) server ids.
    client.debugRouteOutsideRoomPublication(envelope('delete-message', {
      'message_id': ['$serverMessageId'],
      'chat_room_id': serverRoomId,
    }));
    await Future<void>.delayed(const Duration(milliseconds: 30));

    final row = await messagesDao.findByServerMessageId(serverMessageId);
    expect(row, isNotNull, reason: 'the delete must not drop the row');
    expect(
      row!.deleteState,
      MessageDeleteState.deletedForAll,
      reason: 'delete-message must flip the existing row to deletedForAll',
    );
    expect(row.localId, seeded.messageLocalId);

    expect(await countMessages(), before,
        reason: 'delete-message must never insert a (phantom) row');
    // It is a signal, not a message: no gap-fill, no rooms-list sync.
    expect(syncEngine.fillGapCalls, isEmpty);
  });

  test('peer delete-message for an unknown server id is a safe no-op', () async {
    await seedRoomWithPeerMessage(
      serverRoomId: 1,
      serverMessageId: 1,
      serverSeq: 1,
    );
    final before = await countMessages();

    client.debugRouteOutsideRoomPublication(envelope('delete-message', {
      'message_id': [999999],
    }));
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(await countMessages(), before,
        reason: 'unknown delete target must not insert anything');
    final survivor = await messagesDao.findByServerMessageId(1);
    expect(survivor!.deleteState, MessageDeleteState.none);
  });

  // ---------------------------------------------------------------------------
  // 2. Peer reaction toggle -> drift (existing row updated, no phantom row).
  // ---------------------------------------------------------------------------

  test('peer react-event is routed to drift, replaces reactions on the '
      'existing row, no phantom row', () async {
    const serverRoomId = 654;
    const serverMessageId = 6002;
    await seedRoomWithPeerMessage(
      serverRoomId: serverRoomId,
      serverMessageId: serverMessageId,
      serverSeq: 4,
    );
    final before = await countMessages();
    expect(before, 1);

    client.debugRouteOutsideRoomPublication(envelope('react-event', {
      'id': serverMessageId,
      'chat_room_id': serverRoomId,
      'reacts': [
        {
          'id': 1,
          'react': 'like',
          'userReact': {'userId': peerId, 'userName': 'Peer'},
        },
      ],
    }));
    await Future<void>.delayed(const Duration(milliseconds: 30));

    final row = await messagesDao.findByServerMessageId(serverMessageId);
    expect(row, isNotNull, reason: 'react must not drop the row');
    expect(row!.reactsJson, isNotNull,
        reason: 'react-event must persist the reactions onto the row');
    final decoded = jsonDecode(row.reactsJson!) as List;
    expect(decoded.first['react'], 'like');
    expect(decoded.first['userReact']['userId'], peerId);

    expect(await countMessages(), before,
        reason: 'react-event must never insert a (phantom) row');
    expect(syncEngine.fillGapCalls, isEmpty);
  });

  // ---------------------------------------------------------------------------
  // 3. User-channel message with a seq hole -> SyncEngine.fillGap.
  // ---------------------------------------------------------------------------

  test('a user-channel message with a seq gap triggers fillGap for its room',
      () async {
    const serverRoomId = 777;
    // Local max seq for the room is 3; the next publication jumps to seq 9 -> a
    // hole of 4..8 that only the user-channel fill-gap path can close (these
    // messages ride user:#{id}, which has no positioned-recovery _ChatChannel).
    final seeded = await seedRoomWithPeerMessage(
      serverRoomId: serverRoomId,
      serverMessageId: 30,
      serverSeq: 3,
    );

    // Use an own (outgoing) echo so the gap-fill side path is exercised without
    // tripping the in-app sound/banner (an incoming message), which needs the
    // audioplayers plugin that isn't registered under flutter_test. Gap detection
    // is direction-agnostic — it keys purely off server_seq vs the local max.
    client.debugRouteOutsideRoomPublication(envelope('update-conversation-list', {
      'id': 90,
      'client_uuid': 'gap-msg-1',
      'server_seq': 9,
      'chat_room_id': serverRoomId,
      'user_id': myId,
      'kind': 'user',
      'type': 'text',
      'message': 'after the gap',
      'created_at': '2026-06-03T10:00:00Z',
    }));
    // Let the async _applyMessageByServerRoomAndFillGap chain settle.
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(syncEngine.fillGapCalls.length, 1,
        reason: 'a seq jump on the user channel must trigger exactly one fillGap');
    final call = syncEngine.fillGapCalls.single;
    expect(call.serverRoomId, serverRoomId);
    expect(call.roomLocalId, seeded.roomLocalId,
        reason: 'fillGap must resolve the real local room id for the message');
    expect(call.expectedAfterSeq, 9);
    // Regression (#2): the gap gate + REST cursor must use the PRE-apply local
    // max (3), not the post-apply max (9). Capturing it after the upsert would
    // make `9 <= 9+1` true and silently swallow the 4..8 hole forever.
    expect(call.beforeMax, 3,
        reason: 'fillGap must receive the local max captured BEFORE applying the '
            'jumped publication, so the hole is detected and back-filled');

    // The message itself was still applied to drift (gap-fill is a side path).
    final applied = await messagesDao.findByClientUuid('gap-msg-1');
    expect(applied, isNotNull);
    expect(applied!.serverSeq, 9);
  });

  // ---------------------------------------------------------------------------
  // 4. Reconnect -> SyncEngine.syncRoomsList.
  // ---------------------------------------------------------------------------

  test('a reconnect catch-up triggers a rooms-list resync', () async {
    expect(syncEngine.syncRoomsListCalls, 0);

    client.debugReconnectCatchUp();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(syncEngine.syncRoomsListCalls, 1,
        reason: 'reconnect must resync the chats list (recovery-loss fallback)');
    // And it actually went to the rooms-list endpoint, not somewhere else.
    expect(http.getCalls.where((p) => p.contains('/sync/rooms')), isNotEmpty);
  });

  // ---------------------------------------------------------------------------
  // 5. WAVE-2 banner -> nonChatEvents, NEVER the message path.
  // ---------------------------------------------------------------------------

  group('WAVE-2 banners route to nonChatEvents, never the message path', () {
    for (final event in const [
      'win.lucky.gift.event',
      'baishun.game.event',
      'room.comment.event',
    ]) {
      test('$event is forwarded to nonChatEvents and writes no drift row',
          () async {
        RealtimeNonChatEvent? captured;
        final sub = client.nonChatEvents.listen((e) => captured ??= e);

        final before = await countMessages();
        // Banners often carry a room_id; assert it does NOT materialize a room.
        client.debugRouteOutsideRoomPublication(envelope(event, {
          'messageContent': {'event': event, 'uId': 7},
          'room_id': 424242,
        }));
        await Future<void>.delayed(const Duration(milliseconds: 30));
        await sub.cancel();

        expect(captured, isNotNull,
            reason: '$event must reach the non-chat consumer stream');
        expect(captured!.event, event);
        expect(captured!.payload, isA<Map>());
        expect((captured!.payload as Map)['messageContent'], isA<Map>());

        expect(await countMessages(), before,
            reason: '$event must not create a message row');
        expect(await roomsDao.findByServerRoomId(424242), isNull,
            reason: '$event must not create a phantom room');
        expect(syncEngine.fillGapCalls, isEmpty,
            reason: 'a banner is not a message: no gap-fill');
      });
    }
  });
}

Response<dynamic> _ok(dynamic body) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/'),
      statusCode: 200,
      data: body,
    );

/// Minimal DioFactory stand-in for RealtimeTokenService — the routing paths
/// under test never invoke connect()/subscribe(), so Dio is never exercised.
class _NoopDio implements DioFactory {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Dio is not exercised by routing tests');
}
