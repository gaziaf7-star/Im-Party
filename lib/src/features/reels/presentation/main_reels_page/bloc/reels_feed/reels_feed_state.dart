part of 'reels_feed_bloc.dart';

class ReelsFeedState extends Equatable {
  final List<ReelsEntity> reels;
  final int currentIndex;
  final int currentPagination;
  final int lastPage;
  final RequestState requestState;
  final String message;
  final PageController scrollCtrl;
  final Map<int, VideoPlayerController> videoControllers;
  final Duration videoPosition;
  final Duration videoDuration;
  final bool isSeeking;
  final bool isDisposed;

  /// Indices whose controller failed to initialize or errored mid-playback.
  /// Surfaced by the pool's `onError` callback. UI overlay/retry is WF3.
  final Set<int> erroredIndices;

  const ReelsFeedState({
    this.reels = const <ReelsEntity>[],
    this.currentIndex = 0,
    this.currentPagination = 1,
    this.lastPage = 1,
    this.requestState = RequestState.idle,
    this.message = '',
    required this.scrollCtrl,
    this.videoControllers = const {},
    this.videoPosition = Duration.zero,
    this.videoDuration = Duration.zero,
    this.isSeeking = false,
    this.isDisposed = false,
    this.erroredIndices = const {},
  });

  ReelsFeedState copyWith({
    List<ReelsEntity>? reels,
    int? currentIndex,
    int? currentPagination,
    int? lastPage,
    RequestState? requestState,
    String? message,
    PageController? scrollCtrl,
    Map<int, VideoPlayerController>? videoControllers,
    Duration? videoPosition,
    Duration? videoDuration,
    bool? isSeeking,
    bool? isDisposed,
    Set<int>? erroredIndices,
  }) {
    return ReelsFeedState(
      reels: reels ?? this.reels,
      currentIndex: currentIndex ?? this.currentIndex,
      currentPagination: currentPagination ?? this.currentPagination,
      lastPage: lastPage ?? this.lastPage,
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      scrollCtrl: scrollCtrl ?? this.scrollCtrl,
      videoControllers: videoControllers ?? this.videoControllers,
      videoPosition: videoPosition ?? this.videoPosition,
      videoDuration: videoDuration ?? this.videoDuration,
      isSeeking: isSeeking ?? this.isSeeking,
      isDisposed: isDisposed ?? this.isDisposed,
      erroredIndices: erroredIndices ?? this.erroredIndices,
    );
  }

  @override
  List<Object?> get props => [
        reels,
        currentIndex,
        currentPagination,
        lastPage,
        requestState,
        message,
        scrollCtrl,
        videoControllers,
        videoPosition,
        videoDuration,
        isSeeking,
        isDisposed,
        erroredIndices,
      ];
}
