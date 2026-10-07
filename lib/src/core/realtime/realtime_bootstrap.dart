import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/realtime/realtime_client.dart';
import 'package:general/src/core/realtime/outbox_worker.dart';
import 'package:general/src/core/realtime/media_upload_worker.dart';

/// Single entry point for bringing up the offline-first realtime layer
/// (Centrifugo socket + outbox/media drain). Called from EVERY layout shell so
/// the new and legacy paths can never diverge. Idempotent + crash-safe.
void startRealtimeBootstrap() {
  try {
    Methods.printLog('[Realtime] bootstrap fired');
    unawaited(di<RealtimeClient>().start().catchError((e) {
      Methods.printLog('[Realtime] start() future error: $e');
    }));
    di<OutboxWorker>().start();
    di<MediaUploadWorker>().start();
  } catch (e) {
    Methods.printLog('[Realtime] bootstrap threw: $e');
  }
}
