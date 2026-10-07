part of 'upload_reel_bloc.dart';

enum UploadStage {
  idle,
  compressing,
  uploading,
  processing,
  completed,
  failed,
}

class UploadReelState extends Equatable {
  final RequestState requestState;
  final File? reelVideo;
  final String? message;
  final String? backendName;
  final String? preSignedUrl;
  final String? descreption;
  final UploadStage uploadStage;
  final double uploadProgress;
  final String? failureReason;
  final File? pendingFile;

  const UploadReelState({
    this.requestState = RequestState.idle,
    this.message,
    this.backendName,
    this.preSignedUrl,
    this.descreption,
    this.reelVideo,
    this.uploadStage = UploadStage.idle,
    this.uploadProgress = 0.0,
    this.failureReason,
    this.pendingFile,
  });

  UploadReelState copyWith({
    RequestState? requestState,
    String? message,
    String? backendName,
    String? preSignedUrl,
    String? descreption,
    File? reelVideo,
    UploadStage? uploadStage,
    double? uploadProgress,
    String? failureReason,
    File? pendingFile,
  }) {
    return UploadReelState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      backendName: backendName ?? this.backendName,
      preSignedUrl: preSignedUrl ?? this.preSignedUrl,
      descreption: descreption ?? this.descreption,
      reelVideo: reelVideo ?? this.reelVideo,
      uploadStage: uploadStage ?? this.uploadStage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      failureReason: failureReason ?? this.failureReason,
      pendingFile: pendingFile ?? this.pendingFile,
    );
  }

  @override
  List<Object?> get props => [
        requestState,
        message ?? '',
        backendName ?? '',
        preSignedUrl ?? '',
        descreption ?? '',
        reelVideo,
        uploadStage,
        uploadProgress,
        failureReason ?? '',
        pendingFile,
      ];
}
