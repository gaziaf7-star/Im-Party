import 'dart:async';
import 'dart:io';

import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/daos/media_uploads_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

/// Resumable attachment uploader (Plan section 7.7).
///
/// The optimistic local thumbnail is shown immediately by the send path (next
/// task); this worker performs the actual resumable upload behind it:
///
///   queued -> uploading -> (presign + PUT bytes) -> done(remote_url)
///
/// On `done` the [OutboxWorker] picks up the message op, reads the `remote_url`
/// from media_uploads, and sends the message — so the attachment URL is never
/// baked into the queue before the bytes are actually on storage.
///
/// Failures mark the record `failed` and leave it for a later retry; the bytes
/// already sent are tracked in `bytes_sent` for resumability.
class MediaUploadWorker {
  MediaUploadWorker({
    required MediaUploadsDao mediaUploadsDao,
    required BaseMessagesRemoteDataSource remote,
    OutboxKick? onUploadDone,
    int Function()? clock,
    Duration tickInterval = const Duration(seconds: 3),
  }) : _dao = mediaUploadsDao,
       _remote = remote,
       _onUploadDone = onUploadDone,
       _tickInterval = tickInterval;

  final MediaUploadsDao _dao;
  final BaseMessagesRemoteDataSource _remote;
  final OutboxKick? _onUploadDone;
  final Duration _tickInterval;

  Timer? _timer;
  bool _draining = false;

  void start() {
    _timer ??= Timer.periodic(_tickInterval, (_) => drainOnce());
    unawaited(drainOnce());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Process every pending upload once. Re-entrancy guarded so overlapping
  /// ticks don't double-upload the same record.
  Future<int> drainOnce() async {
    if (_draining) return 0;
    _draining = true;
    try {
      final pending = await _dao.pendingUploads();
      var done = 0;
      for (final record in pending) {
        final ok = await _uploadOne(record);
        if (ok) done++;
      }
      if (done > 0) _onUploadDone?.call();
      return done;
    } finally {
      _draining = false;
    }
  }

  Future<bool> _uploadOne(MediaUpload record) async {
    final file = File(record.localPath);
    if (!file.existsSync()) {
      await _dao.markFailed(record.clientUuid);
      return false;
    }

    try {
      await _dao.updateProgress(
        clientUuid: record.clientUuid,
        bytesSent: 0,
        state: MediaUploadState.uploading,
      );

      // Reuse the existing presigned-URL pipeline (S3/GCS-style PUT).
      final presign = await _remote.getPreSignedUrl(
        SendVideoParam(video: file),
      );
      final uploadUrl = presign['upload_url'];
      final storedName = presign['name'];
      if (uploadUrl == null || uploadUrl.isEmpty) {
        await _dao.markFailed(record.clientUuid);
        return false;
      }

      final status = await _remote.uploadFileToStorage(
        SendVideoParam(video: file, preSignedUrl: uploadUrl),
      );
      if (status < 200 || status >= 300) {
        await _dao.markFailed(record.clientUuid);
        return false;
      }

      final remoteUrl = _publicUrl(storedName ?? '', uploadUrl);
      await _dao.markDone(
        clientUuid: record.clientUuid,
        remoteUrl: remoteUrl,
        thumbRemoteUrl: record.thumbRemoteUrl,
      );
      return true;
    } catch (_) {
      await _dao.markFailed(record.clientUuid);
      return false;
    }
  }

  /// Derive the canonical public URL for the stored object. Prefers the
  /// configured storage bucket + object name; falls back to the presigned URL
  /// with its query string stripped.
  String _publicUrl(String storedName, String uploadUrl) {
    if (storedName.isNotEmpty) {
      return EndPoints.getImage(storedName);
    }
    final q = uploadUrl.indexOf('?');
    return q == -1 ? uploadUrl : uploadUrl.substring(0, q);
  }
}

/// Callback the worker fires after at least one upload completes, so the outbox
/// can immediately attempt the now-sendable message(s).
typedef OutboxKick = void Function();
