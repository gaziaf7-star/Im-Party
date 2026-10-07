import 'dart:async';
import 'dart:collection';

import '../core/constants.dart';

// 16ms frame-aligned batching + UUID deduplication
class UTDMessageBatcher {
  final Queue<Map<String, dynamic>> _queue = Queue();
  Timer? _batchTimer;
  final void Function(List<Map<String, dynamic>> batch) onBatch;

  // Bounded set for dedup — keeps last 100 message IDs
  final Set<String> _seenIds = {};
  static const _maxSeenIds = 100;

  UTDMessageBatcher({required this.onBatch});

  void enqueue(Map<String, dynamic> message) {
    // UUID dedup — skip if already seen
    final msgId = _extractMessageId(message);
    if (msgId != null) {
      if (_seenIds.contains(msgId)) return;
      _seenIds.add(msgId);
      if (_seenIds.length > _maxSeenIds) {
        _seenIds.remove(_seenIds.first);
      }
    }

    _queue.add(message);
    _startTimerIfNeeded();
  }

  // Extract UUID from message if present
  String? _extractMessageId(Map<String, dynamic> message) {
    final content = message['messageContent'] as Map<String, dynamic>?;
    return content?['_msgId'] as String?;
  }

  void _startTimerIfNeeded() {
    _batchTimer ??= Timer.periodic(
      const Duration(milliseconds: UTDConstants.messageBatchIntervalMs),
      (_) => _processBatch(),
    );
  }

  void _processBatch() {
    if (_queue.isEmpty) {
      _batchTimer?.cancel();
      _batchTimer = null;
      return;
    }

    final batch = <Map<String, dynamic>>[];
    while (_queue.isNotEmpty) {
      batch.add(_queue.removeFirst());
    }
    onBatch(batch);
  }

  void dispose() {
    _batchTimer?.cancel();
    _batchTimer = null;
    _queue.clear();
  }
}
