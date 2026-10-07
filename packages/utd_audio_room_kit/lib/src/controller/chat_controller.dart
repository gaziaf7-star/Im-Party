import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/room_manager.dart';
import '../models/chat_message.dart';

class UTDChatController {
  final UTDRoomManager _roomManager;
  StreamSubscription<Map<String, dynamic>>? _dataSub;
  bool _disposed = false;

  final ValueNotifier<List<UTDChatMessage>> messages = ValueNotifier([]);

  /// Outgoing chat gate. When set and it returns `false`, [sendMessage] refuses
  /// to publish (used by the comment-lock feature: locked + not host/admin).
  /// Wired by [UTDRoomController] to `() => canIComment`.
  bool Function()? canSendChat;

  /// Incoming chat gate. When set and it returns `false` for the sender, the
  /// received chat is dropped instead of rendered. Defensive backstop against a
  /// tampered client that publishes chat while comments are locked — wired by
  /// [UTDRoomController] to drop non-privileged senders while locked.
  bool Function(String senderUserId)? canReceiveChatFrom;

  /// Cap on retained chat messages. In long-lived rooms the list otherwise
  /// grows unbounded, leaking memory and slowing every list rebuild.
  static const int _maxMessages = 300;

  UTDChatController(this._roomManager);

  /// Appends [msg], trimming the oldest entries past [_maxMessages].
  void _appendMessage(UTDChatMessage msg) {
    final next = [...messages.value, msg];
    messages.value = next.length > _maxMessages
        ? next.sublist(next.length - _maxMessages)
        : next;
  }

  /// Returns `false` when the message was dropped (empty text, comment-lock
  /// gate, or not yet connected) so callers can keep the input text or retry.
  Future<bool> sendMessage(String text, {Map<String, dynamic>? userData}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    // Comment-lock gate: refuse to publish when chat is locked and the local
    // user is not host/admin. Enforcement lives in the send path (not only the
    // UI) so a hidden composer can never be bypassed.
    if (canSendChat != null && !canSendChat!()) return false;

    final local = _roomManager.localParticipant;
    if (local == null) return false;

    final msg = UTDChatMessage(
      senderUserId: local.identity,
      senderName: local.name.isNotEmpty ? local.name : local.identity,
      text: trimmed,
      timestamp: DateTime.now(),
      userData: userData ?? {},
    );

    _appendMessage(msg);

    await _roomManager.sendData({'roomChat': msg.toJson()});
    return true;
  }

  void startListening() {
    _dataSub?.cancel();
    _dataSub = _roomManager.dataStream.listen(_onDataReceived);
  }

  void _onDataReceived(Map<String, dynamic> data) {
    final content = data['roomChat'] as Map<String, dynamic>?;
    if (content == null || !UTDChatMessage.isChat(content)) return;

    final msg = UTDChatMessage.fromJson(content);

    final localId = _roomManager.localParticipant?.identity;
    if (msg.senderUserId == localId) return;

    // Defensive comment-lock gate: drop chat from non-privileged senders while
    // locked (a well-behaved client won't send it, but a tampered one might).
    if (canReceiveChatFrom != null && !canReceiveChatFrom!(msg.senderUserId)) {
      return;
    }

    _appendMessage(msg);
  }

  void addDisplayMessage(UTDChatMessage message) {
    _appendMessage(message);
  }

  void clearMessages() {
    messages.value = [];
  }

  void stopListening() {
    _dataSub?.cancel();
    _dataSub = null;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    stopListening();
    canSendChat = null;
    canReceiveChatFrom = null;
    messages.dispose();
  }
}
