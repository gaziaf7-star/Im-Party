import 'dart:async';

import 'package:flutter/widgets.dart';

import '../core/room_manager.dart';
import 'message_batcher.dart';

typedef MessageHandler = void Function(
  Map<String, dynamic> data,
  BuildContext context,
);

class UTDMessageRouter {
  final UTDRoomManager _roomManager;
  late final UTDMessageBatcher _batcher;
  StreamSubscription<Map<String, dynamic>>? _dataSub;
  BuildContext Function()? contextSupplier;

  final Map<String, MessageHandler> _handlers = {};

  UTDMessageRouter(this._roomManager) {
    _batcher = UTDMessageBatcher(onBatch: _processBatch);
  }

  void registerHandler(String messageType, MessageHandler handler) {
    _handlers[messageType] = handler;
  }

  void registerHandlers(Map<String, MessageHandler> handlers) {
    _handlers.addAll(handlers);
  }

  void start() {
    _dataSub = _roomManager.dataStream.listen((data) {
      _batcher.enqueue(data);
    });
  }

  void _processBatch(List<Map<String, dynamic>> batch) {
    final ctx = contextSupplier?.call();
    if (ctx == null) return;

    for (final data in batch) {
      _dispatch(data, ctx);
    }
  }

  void _dispatch(Map<String, dynamic> data, BuildContext context) {
    final content = data['messageContent'] as Map<String, dynamic>?;
    if (content == null) return;

    final messageType = content['message'] as String?;
    if (messageType == null) return;

    final handler = _handlers[messageType];
    if (handler != null) {
      handler(data, context);
    }
  }

  void stop() {
    _dataSub?.cancel();
    _dataSub = null;
    _batcher.dispose();
  }

  void dispose() {
    stop();
    _handlers.clear();
  }
}
