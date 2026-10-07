import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';

/// Pure translation from a server message JSON object to a drift
/// [MessagesCompanion], plus the parsing helpers shared by the realtime client
/// and the REST sync engine.
///
/// Kept side-effect free (no DB, no network) so the mapping is unit-testable in
/// isolation and identical regardless of whether the message arrived over the
/// WebSocket (Centrifugo publication) or over REST (gap-fill / recovery).
class RealtimeMessageMapper {
  const RealtimeMessageMapper();

  /// Builds the companion for an inserted/updated message.
  ///
  /// [roomLocalId] is resolved by the caller (the server JSON only carries
  /// `chat_room_id`, which maps to `rooms.server_room_id`).
  ///
  /// Returns null when the payload has no usable identity (neither a
  /// `client_uuid` nor a `server_message_id`), since [MessagesDao.upsertFromServer]
  /// relies on one of them to dedup.
  MessagesCompanion? toCompanion(
    Map<String, dynamic> json, {
    required int roomLocalId,
    int? myUserId,
  }) {
    final clientUuid = _str(json['client_uuid']);
    final serverMessageId = _int(json['id'] ?? json['server_message_id']);
    if ((clientUuid == null || clientUuid.isEmpty) && serverMessageId == null) {
      return null;
    }
    // The drift `client_uuid` column is NOT NULL + UNIQUE (it is the dedup key).
    // Server-originated rows (system events like group_renamed, or legacy
    // messages) arrive without a client_uuid; derive a stable synthetic key from
    // the server id so the row still inserts and stays idempotent on re-apply.
    final effectiveUuid = (clientUuid != null && clientUuid.isNotEmpty)
        ? clientUuid
        : 'srv:$serverMessageId';

    final serverSeq = _int(json['server_seq']);
    final senderId = _int(json['user_id'] ?? json['sender_id']);
    final kind = _kind(_str(json['kind']));
    final contentType = _contentType(_str(json['type']));
    final body = _str(json['message'] ?? json['body']);
    final replyTo = _str(json['reply_to_client_uuid']);
    final serverCreatedAt = _epochMs(json['created_at'] ?? json['server_created_at']);
    final serverStatus = _str(json['status']);

    // Reflect server-side deletions so they survive resync / cold reinstall.
    // Both-sides set → deletedForAll (unambiguous).
    // One-side set + myUserId matches that side → deletedForMe (current user
    // chose "delete for me"). We resolve this from myUserId so we never
    // wrongly hide a message the other party can still see (their side is not
    // deleted). On live (non-reinstall) upserts myUserId may be omitted —
    // Value.absent() then preserves the already-applied local state.
    final senderDeleted = _truthy(json['sender_deleted']);
    final receiverDeleted = _truthy(json['receiver_deleted']);
    final deletedForAll = senderDeleted && receiverDeleted;
    final deletedForMe = !deletedForAll && myUserId != null && (
      (senderDeleted && senderId != null && senderId == myUserId) ||
      (receiverDeleted && senderId != null && senderId != myUserId)
    );

    return MessagesCompanion(
      clientUuid: Value(effectiveUuid),
      serverMessageId:
          serverMessageId == null ? const Value.absent() : Value(serverMessageId),
      roomId: Value(roomLocalId),
      serverSeq: serverSeq == null ? const Value.absent() : Value(serverSeq),
      senderId: senderId == null ? const Value.absent() : Value(senderId),
      kind: Value(kind),
      systemEvent: Value(_str(json['system_event'])),
      type: Value(contentType),
      body: Value(body),
      replyToClientUuid:
          replyTo == null ? const Value.absent() : Value(replyTo),
      // For server-originated rows we keep created_at_client aligned with the
      // server clock so ordering is stable even before server_seq lands. This
      // column is NOT NULL, so fall back to the device clock when the server row
      // carries no timestamp (common for system events) — never leave it absent.
      createdAtClient:
          Value(serverCreatedAt ?? DateTime.now().millisecondsSinceEpoch),
      serverCreatedAt:
          serverCreatedAt == null ? const Value.absent() : Value(serverCreatedAt),
      state: Value(_stateFromStatus(serverStatus)),
      deleteState: deletedForAll
          ? const Value(MessageDeleteState.deletedForAll)
          : deletedForMe
              ? const Value(MessageDeleteState.deletedForMe)
              : const Value.absent(),
      // Feature-parity columns: normalized to the canonical camelCase shape the
      // UI bridge (DriftMessageMapper) reads, regardless of server key casing.
      serverStatus: Value(serverStatus),
      reactsJson: Value(_reactsJson(json['reacts'] ?? json['reactions'])),
      attachmentJson:
          Value(_attachmentJson(json['albums'] ??
              json['message_albums'] ??
              json['attachments'] ??
              json['attachment'])),
      replyPreviewJson: Value(_replyJson(
          json['replay'] ?? json['reply'] ?? json['reply_preview'])),
    );
  }

  /// Normalize a server reactions array (the `react-event` payload's `reacts` /
  /// `reactions` field) into the canonical reactions JSON the UI bridge reads.
  /// Public so the realtime client can persist a peer's reaction onto an existing
  /// row by server id without re-running the full message mapping.
  String? reactsJson(dynamic raw) => _reactsJson(raw);

  /// Normalize the server `reacts` array into the canonical reactions JSON.
  static String? _reactsJson(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    final out = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final ur = e['userReact'] ?? e['user_react'] ?? e['user'];
      out.add({
        'id': _int(e['id']),
        'react': (e['react'] ?? e['reaction'] ?? '').toString(),
        if (ur is Map)
          'userReact': {
            'userId': _int(ur['userId'] ?? ur['user_id'] ?? ur['id']),
            'userName':
                (ur['userName'] ?? ur['user_name'] ?? ur['name'] ?? '').toString(),
            'userImage': (ur['userImage'] ??
                    ur['user_image'] ??
                    ur['image'] ??
                    '')
                .toString(),
            'hasColorName': ur['hasColorName'] ?? ur['has_color_name'],
          },
      });
    }
    return out.isEmpty ? null : jsonEncode(out);
  }

  /// Normalize a server album/attachment object into canonical attachment JSON.
  static String? _attachmentJson(dynamic raw) {
    // The server sends `albums` as a LIST of attachments; the UI shows the
    // first one. A single object is accepted too.
    if (raw is List) {
      raw = raw.firstWhere((e) => e is Map, orElse: () => null);
    }
    if (raw is! Map) return null;
    final file = raw['file'] ?? raw['url'];
    if (file == null) return null;
    return jsonEncode({
      'id': _int(raw['id']),
      'userId': _int(raw['userId'] ?? raw['user_id']),
      'file': file.toString(),
      'type': (raw['type'] ?? raw['mime'])?.toString(),
      'firstFrame':
          (raw['firstFrame'] ?? raw['first_frame'] ?? raw['thumb'])?.toString(),
      'duration': (raw['duration'] ?? '').toString(),
    });
  }

  /// Normalize a server reply/replay object into canonical reply-preview JSON.
  static String? _replyJson(dynamic raw) {
    if (raw is! Map) return null;
    final album = raw['albums'] ?? raw['album'] ?? raw['attachment'];
    return jsonEncode({
      'messageId': _int(raw['messageId'] ?? raw['message_id'] ?? raw['id']),
      'messageUserId':
          _int(raw['messageUserId'] ?? raw['message_user_id'] ?? raw['user_id']),
      'message': (raw['message'] ?? raw['body'])?.toString(),
      'messageType':
          (raw['messageType'] ?? raw['message_type'] ?? raw['type'])?.toString(),
      'page': _int(raw['page']),
      if (album is Map)
        'albums': {
          'file': (album['file'] ?? album['url'])?.toString(),
          'type': (album['type'] ?? album['mime'])?.toString(),
          'firstFrame':
              (album['firstFrame'] ?? album['first_frame'])?.toString(),
        },
    });
  }

  /// Server `chat_room_id` for the message (maps to `rooms.server_room_id`).
  int? serverRoomId(Map<String, dynamic> json) =>
      _int(json['chat_room_id'] ?? json['room_id']);

  /// Map the raw server delivery `status` onto the local lifecycle state for an
  /// incoming/confirmed row. 'seen'/'read' => read, 'delivered'/'received' =>
  /// delivered, anything else (including absent) => delivered as the safe
  /// baseline for a server-confirmed message.
  MessageState _stateFromStatus(String? status) {
    switch (status) {
      case 'seen':
      case 'read':
        return MessageState.read;
      case 'delivered':
      case 'received':
        return MessageState.delivered;
      case 'sent':
        return MessageState.sent;
      default:
        return MessageState.delivered;
    }
  }

  MessageKind _kind(String? raw) =>
      raw == 'system' ? MessageKind.system : MessageKind.user;

  MessageContentType _contentType(String? raw) {
    switch (raw) {
      // The server labels pictures "img" (and animated ones "gif"); the app's
      // own optimistic rows use "image". All of them are image content.
      case 'image':
      case 'img':
      case 'gif':
        return MessageContentType.image;
      case 'audio':
      case 'voice':
        return MessageContentType.audio;
      case 'video':
        return MessageContentType.video;
      case 'CP':
        return MessageContentType.cp;
      default:
        return MessageContentType.text;
    }
  }

  /// Server booleans arrive as bool, 0/1, or "0"/"1"/"true"/"false" depending on
  /// the field. Treat all truthy encodings uniformly.
  static bool _truthy(dynamic v) =>
      v == true || v == 1 || v == '1' || v == 'true';

  static String? _str(dynamic v) => v?.toString();

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  /// Accepts either an epoch (int/num) or an ISO-8601 timestamp string and
  /// normalizes to ms-since-epoch. Returns null if unparseable.
  static int? _epochMs(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final parsed = DateTime.tryParse(v.toString());
    return parsed?.millisecondsSinceEpoch;
  }
}
