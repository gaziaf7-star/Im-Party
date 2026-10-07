part of 'upload_reel_bloc.dart';

abstract class BaseUploadReelEvent extends Equatable {
  const BaseUploadReelEvent();

  @override
  List<Object?> get props => [];
}

class GetPreSignedUrlEvent extends BaseUploadReelEvent {
  final UploadReelParam param;

  const GetPreSignedUrlEvent(this.param);

  @override
  List<Object?> get props => [param];
}

class UploadFileToStorageEvent extends BaseUploadReelEvent {
  final UploadReelParam param;

  const UploadFileToStorageEvent(this.param);

  @override
  List<Object?> get props => [param];
}

class NotifyBackendEvent extends BaseUploadReelEvent {
  const NotifyBackendEvent();

  @override
  List<Object?> get props => [];
}

class UpdateUploadProgressEvent extends BaseUploadReelEvent {
  final double progress;

  const UpdateUploadProgressEvent(this.progress);

  @override
  List<Object?> get props => [progress];
}

class RetryUploadEvent extends BaseUploadReelEvent {
  const RetryUploadEvent();

  @override
  List<Object?> get props => [];
}

class ResetUploadStateEvent extends BaseUploadReelEvent {
  const ResetUploadStateEvent();

  @override
  List<Object?> get props => [];
}

class UpdateUploadStageEvent extends BaseUploadReelEvent {
  final UploadStage stage;

  const UpdateUploadStageEvent(this.stage);

  @override
  List<Object?> get props => [stage];
}
