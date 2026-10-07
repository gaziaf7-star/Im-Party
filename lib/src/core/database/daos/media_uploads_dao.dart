import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/chat_tables.dart';

part 'media_uploads_dao.g.dart';

@DriftAccessor(tables: [MediaUploads])
class MediaUploadsDao extends DatabaseAccessor<AppDatabase>
    with _$MediaUploadsDaoMixin {
  MediaUploadsDao(super.db);

  /// Insert or replace the upload record for a message (keyed by client_uuid).
  Future<void> upsert(MediaUploadsCompanion entry) {
    return into(mediaUploads).insertOnConflictUpdate(entry);
  }

  Future<MediaUpload?> findByClientUuid(String clientUuid) {
    return (select(mediaUploads)
          ..where((m) => m.clientUuid.equals(clientUuid)))
        .getSingleOrNull();
  }

  Stream<MediaUpload?> watchByClientUuid(String clientUuid) {
    return (select(mediaUploads)
          ..where((m) => m.clientUuid.equals(clientUuid)))
        .watchSingleOrNull();
  }

  /// Uploads still in flight or waiting — drained by the media worker (Phase 5).
  Future<List<MediaUpload>> pendingUploads({int limit = 20}) {
    return (select(mediaUploads)
          ..where((m) =>
              m.uploadState.equalsValue(MediaUploadState.queued) |
              m.uploadState.equalsValue(MediaUploadState.uploading))
          ..limit(limit))
        .get();
  }

  Future<void> updateProgress({
    required String clientUuid,
    required int bytesSent,
    MediaUploadState? state,
  }) {
    return (update(mediaUploads)
          ..where((m) => m.clientUuid.equals(clientUuid)))
        .write(MediaUploadsCompanion(
      bytesSent: Value(bytesSent),
      uploadState: state == null ? const Value.absent() : Value(state),
    ));
  }

  Future<void> markDone({
    required String clientUuid,
    required String remoteUrl,
    String? thumbRemoteUrl,
  }) {
    return (update(mediaUploads)
          ..where((m) => m.clientUuid.equals(clientUuid)))
        .write(MediaUploadsCompanion(
      remoteUrl: Value(remoteUrl),
      thumbRemoteUrl:
          thumbRemoteUrl == null ? const Value.absent() : Value(thumbRemoteUrl),
      uploadState: const Value(MediaUploadState.done),
    ));
  }

  Future<void> markFailed(String clientUuid) {
    return (update(mediaUploads)
          ..where((m) => m.clientUuid.equals(clientUuid)))
        .write(const MediaUploadsCompanion(
      uploadState: Value(MediaUploadState.failed),
    ));
  }

  Future<int> remove(String clientUuid) {
    return (delete(mediaUploads)..where((m) => m.clientUuid.equals(clientUuid)))
        .go();
  }
}
