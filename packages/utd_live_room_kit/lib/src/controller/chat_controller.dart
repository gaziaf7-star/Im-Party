import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/room_manager.dart';
import '../models/chat_message.dart';

class UTDChatController {
  final UTDRoomManager _roomManager;
  StreamSubscription<Map<String, dynamic>>? _dataSub;
  bool _disposed = false;

  final ValueNotifier<List<UTDChatMessage>> messages = ValueNotifier([]);

  /// Cap on retained chat messages. In long-lived rooms the list otherwise
  /// grows unbounded, leaking memory and slowing every list rebuild.
  static const int _maxMessages = 300;

  UTDChatController(this._roomManager);

  /// Appends [msg], trimming the oldest entries past [_maxMessages].
  void _appendMessage(UTDChatMessage msg) {
    // Data-channel retries/replays retain the sender-generated messageID.
    // Reject only that exact event; two separate gift sends receive distinct
    // IDs and therefore remain two legitimate comment bubbles.
    if (messages.value.any((existing) => existing.messageID == msg.messageID)) {
      return;
    }
    final next = [...messages.value, msg];
    messages.value = next.length > _maxMessages
        ? next.sublist(next.length - _maxMessages)
        : next;
  }

  Future<void> sendMessage(String text, {Map<String, dynamic>? userData}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final local = _roomManager.localParticipant;
    if (local == null) return;

    final msg = UTDChatMessage(
      senderUserId: local.identity,
      senderName: local.name.isNotEmpty ? local.name : local.identity,
      text: trimmed,
      timestamp: DateTime.now(),
      userData: userData ?? {},
    );

    _appendMessage(msg);

    await _roomManager.sendData({'roomChat': msg.toJson()});
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
    messages.dispose();
  }
}
