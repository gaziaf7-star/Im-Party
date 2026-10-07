import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;

import 'package:general/src/core/database/app_database.dart' as db;
import 'package:general/src/core/database/tables/chat_tables.dart' as db;
import 'package:general/src/features/messages/messages.dart';
import 'package:general/src/core/index.dart' show MessageState;

/// Bridges the new offline-first drift layer to the legacy 1:1 chat UI.
///
/// The realtime/offline rebuild stores messages in drift ([db.Message]); the
/// existing message widgets render [MessagesEntity]. This mapper translates a
/// drift row into the entity the UI already consumes, so the screens stay
/// untouched while the transport underneath them switches from legacy realtime to the
/// Centrifugo/drift stack.
///
/// It also defines the canonical JSON shapes the engine persists into the
/// parity columns (`reactsJson`, `attachmentJson`, `replyPreviewJson`) so the
/// realtime mapper writing them and this mapper reading them never drift apart.
class DriftMessageMapper {
  const DriftMessageMapper._();

  /// drift row -> UI entity. [currentUserId] decides the side of a
  /// delete-for-me marker; [chatId] is the server conversation id the screen
  /// already knows (the row itself only carries the local room id).
  static MessagesEntity toEntity(
    db.Message m, {
    required int currentUserId,
    int? chatId,
  }) {
    final isMine = m.senderId == currentUserId;
    if (m.type == db.MessageContentType.image) {
      debugPrint(
          '[ChatImage] drift row sid=${m.serverMessageId} attachmentJson=${m.attachmentJson}');
    }
    final deletedForAll = m.deleteState == db.MessageDeleteState.deletedForAll;
    final deletedForMe = m.deleteState == db.MessageDeleteState.deletedForMe;

    return MessagesEntity(
      id: m.serverMessageId,
      clientUuid: m.clientUuid,
      userId: m.senderId,
      chatId: chatId,
      status: _statusOf(m),
      type: _typeOf(m.type),
      message: m.body,
      createdAt: _isoOf(m.serverCreatedAt ?? m.createdAtClient),
      // delete-for-all hides it for everyone; delete-for-me hides it on the
      // owning side only, matching the legacy sender/receiver flags.
      senderDeleted: deletedForAll || (deletedForMe && isMine),
      receiverDeleted: deletedForAll || (deletedForMe && !isMine),
      albums: _albumsOf(m.attachmentJson),
      reacts: _reactsOf(m.reactsJson),
      replay: _replyOf(m.replyPreviewJson),
      messageState: _uiStateOf(m.state),
    );
  }

  /// drift content type -> legacy `type` string the widgets switch on. The
  /// legacy app labels audio messages "voice".
  static String _typeOf(db.MessageContentType t) {
    switch (t) {
      case db.MessageContentType.image:
        // The bubble/reply widgets switch on the legacy "img" label.
        return 'img';
      case db.MessageContentType.video:
        return 'video';
      case db.MessageContentType.audio:
        return 'voice';
      case db.MessageContentType.cp:
        return 'CP';
      case db.MessageContentType.text:
        return 'text';
    }
  }

  /// drift lifecycle state -> legacy UI [MessageState]. The new stack has a
  /// richer lifecycle (delivered/read) the old enum lacks; both collapse to
  /// `sent` for rendering, while the read receipt rides on [status] = 'seen'.
  static MessageState _uiStateOf(db.MessageState s) {
    switch (s) {
      case db.MessageState.pending:
        return MessageState.sending;
      case db.MessageState.failed:
        return MessageState.error;
      case db.MessageState.sent:
      case db.MessageState.delivered:
      case db.MessageState.read:
        return MessageState.sent;
    }
  }

  /// Shared tick-status computation for both the message bubble and the chat
  /// list row (#79: single source of truth, delegates from both mappers).
  /// The blue 'seen' tick is highest-priority and must never be swallowed back.
  static String? statusOf({
    required db.MessageState? state,
    required String? serverStatus,
  }) {
    final raw = serverStatus;
    if (state == db.MessageState.read || raw == 'seen' || raw == 'read') {
      return 'seen';
    }
    if (raw != null && raw.isNotEmpty) return raw;
    switch (state) {
      case db.MessageState.delivered:
        return 'delivered';
      case db.MessageState.sent:
        return 'sent';
      case db.MessageState.read:
      case db.MessageState.pending:
      case db.MessageState.failed:
      case null:
        return null;
    }
  }

  static String? _statusOf(db.Message m) => statusOf(
        state: m.state,
        serverStatus: m.serverStatus,
      );

  static String _isoOf(int msEpoch) =>
      DateTime.fromMillisecondsSinceEpoch(msEpoch).toUtc().toIso8601String();

  static List<ReactEntity>? _reactsOf(String? raw) {
    final list = _decodeList(raw);
    if (list == null || list.isEmpty) return null;
    return list.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final ur = map['userReact'];
      return ReactEntity(
        id: _asInt(map['id']),
        react: (map['react'] ?? '').toString(),
        userReact: ur is Map
            ? UserReactEntity(
                userId: _asInt(ur['userId']) ?? 0,
                userName: (ur['userName'] ?? '').toString(),
                userImage: (ur['userImage'] ?? '').toString(),
                hasColorName: ur['hasColorName'] as bool?,
              )
            : null,
      );
    }).toList();
  }

  static AlbumsEntity? _albumsOf(String? raw) {
    final map = _decodeMap(raw);
    if (map == null) return null;
    // Optimistic own-media rows (still uploading) carry isLocal:true with an
    // on-device path in `file`/`firstFrame`. Image/voice bubbles render the local
    // file straight from `file`. The VIDEO bubble is different: it reads File
    // objects (videoFile/firstFrameFile) and would otherwise treat a non-empty
    // `file` as a NETWORK url (breaking the local preview), so for a local video
    // we move the path into videoFile and leave `file` null. The server echo
    // replaces this row with the real remote url (isLocal:false).
    final isLocal = map['isLocal'] == true;
    final type = map['type']?.toString();
    final path = map['file']?.toString();
    final firstFrame = map['firstFrame']?.toString();
    final isLocalVideo = isLocal && type == 'video';
    return AlbumsEntity(
      id: _asInt(map['id']),
      userId: _asInt(map['userId']),
      file: isLocalVideo ? null : path,
      type: type,
      firstFrame: isLocalVideo ? null : firstFrame,
      isLocal: isLocal,
      duration: map['duration']?.toString() ?? '',
      videoFile:
          isLocalVideo && path != null && path.isNotEmpty ? File(path) : null,
      firstFrameFile:
          isLocalVideo && firstFrame != null && firstFrame.isNotEmpty
              ? File(firstFrame)
              : null,
    );
  }

  static ReplayEntity? _replyOf(String? raw) {
    final map = _decodeMap(raw);
    if (map == null) return null;
    final album = map['albums'];
    return ReplayEntity(
      messageId: _asInt(map['messageId']),
      messageUserId: _asInt(map['messageUserId']),
      message: map['message']?.toString(),
      messageType: map['messageType']?.toString(),
      page: _asInt(map['page']),
      albums: album is Map
          ? AlbumsEntity(
              file: album['file']?.toString(),
              type: album['type']?.toString(),
              firstFrame: album['firstFrame']?.toString(),
            )
          : null,
    );
  }

  // --- canonical JSON encoders (engine writes these into the drift columns) ---

  static String encodeReacts(List<Map<String, dynamic>> reacts) =>
      jsonEncode(reacts);

  static String encodeAttachment(Map<String, dynamic> attachment) =>
      jsonEncode(attachment);

  static String encodeReplyPreview(Map<String, dynamic> reply) =>
      jsonEncode(reply);

  static List<dynamic>? _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _decodeMap(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
