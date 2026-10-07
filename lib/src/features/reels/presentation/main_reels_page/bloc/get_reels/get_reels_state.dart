part of 'get_reels_bloc.dart';

class GetReelsState extends Equatable {
  // for you reels
  final String message;
  final RequestState requestState;
  final List<ReelsEntity> reelsList;
  final ReelsEntity? currentReel;
  final int currentIndex;
  final int currentPagination;
  final int lastPage;
  final PageController scrollCtrl;

  // following reels
  final String followingMessage;
  final RequestState requestFollowingState;
  final List<ReelsEntity> followingReelsList;
  final ReelsEntity? currentFollowingReel;
  final int currentFollowingIndex;
  final int currentFollowingPagination;
  final int lastFollowingPage;
  final PageController followingScrollCtrl;

  // userReels
  final String myReelMessage;
  final RequestState requestMyReelsState;
  final RequestState updateReelsState;
  final RequestState deleteReelsState;
  final List<ReelsEntity> myReelsList;
  final int currentMyReelsIndex;
  final int currentMyReelsPagination;
  final int lastMyReelsPage;
  final PageController myReelsScrollCtrl;
  final ReelsEntity? currentMyReel;

  final Duration videoPosition;
  final Duration followingVideoPosition;
  final Duration myReelsVideoPosition;
  final Duration videoDuration;
  final Duration followingVideoDuration;
  final Duration myReelsVideoDuration;
  final bool isSeeking;
  final bool isCommentsOpened;
  final ReelsEntity? currentReelCommentsViewed;

  final bool isMute;
  final bool isDisposed;
  final bool readMore;
  final double? height;
  final double bottomPadding;
  final Map<int, VideoPlayerController> videoControllers;
  final Map<int, VideoPlayerController> followingVideoControllers;
  final Map<int, VideoPlayerController> myReelsVideoControllers;
  // Indices of reels that failed to play, mirrored from each feed so the viewer
  // rebuilds (via buildWhen) and hides/overlays a broken reel immediately.
  final Set<int> erroredIndices;
  final Set<int> followingErroredIndices;
  final Set<int> myReelsErroredIndices;
  final ScrollController myReelsGrideViewScrollController;

  const GetReelsState({
    // for you reels
    required this.scrollCtrl,
    this.message = '',
    this.currentIndex = 0,
    this.currentPagination = 1,
    this.lastPage = 1,
    this.requestState = RequestState.idle,
    this.reelsList = const <ReelsEntity>[],
    this.currentReel,

    // following reels
    required this.followingScrollCtrl,
    this.followingMessage = '',
    this.currentFollowingIndex = 0,
    this.currentFollowingPagination = 1,
    this.lastFollowingPage = 1,
    this.requestFollowingState = RequestState.idle,
    this.followingReelsList = const <ReelsEntity>[],
    this.currentFollowingReel,
    // user reels
    required this.myReelsScrollCtrl,
    this.myReelMessage = '',
    this.currentMyReelsIndex = 0,
    this.currentMyReelsPagination = 1,
    this.lastMyReelsPage = 1,
    this.requestMyReelsState = RequestState.idle,
    this.updateReelsState = RequestState.idle,
    this.deleteReelsState = RequestState.idle,
    this.myReelsList = const <ReelsEntity>[],
    this.currentMyReel,

////////////////////////////////
    this.bottomPadding = 0.0,
    this.isCommentsOpened = false,
    this.currentReelCommentsViewed,
    required this.isSeeking,
    required this.isMute,
    this.isDisposed=false,
    required this.readMore,
    required this.height,
    required this.videoControllers,
    required this.followingVideoControllers,
    required this.myReelsVideoControllers,
    this.erroredIndices = const <int>{},
    this.followingErroredIndices = const <int>{},
    this.myReelsErroredIndices = const <int>{},
    this.videoPosition = const Duration(seconds: 0),
    this.myReelsVideoPosition = const Duration(seconds: 0),
    this.followingVideoPosition = const Duration(seconds: 0),
    this.videoDuration = const Duration(seconds: 0),
    this.followingVideoDuration = const Duration(seconds: 0),
    this.myReelsVideoDuration = const Duration(seconds: 0),
    required this.myReelsGrideViewScrollController,
  });

  GetReelsState copyWith({
    // for you reels
    String? message,
    RequestState? requestState,
    List<ReelsEntity>? reelsList,
    int? currentIndex,
    int? currentPagination,
    int? lastPage,
    ReelsEntity? currentReel,
    PageController? scrollCtrl,
    // following reels
    String? followingMessage,
    RequestState? requestFollowingState,
    List<ReelsEntity>? followingReelsList,
    int? currentFollowingIndex,
    int? currentFollowingPagination,
    int? lastFollowingPage,
    ReelsEntity? currentFollowingReel,
    PageController? followingScrollCtrl,
    // user reels
    String? myReelMessage,
    RequestState? requestMyReelsState,
    RequestState? updateReelsState,
    RequestState? deleteReelsState,
    List<ReelsEntity>? myReelsList,
    int? currentMyReelsIndex,
    int? currentMyReelsPagination,
    int? lastMyReelsPage,
    ReelsEntity? currentMyReel,
    PageController? myReelsScrollCtrl,
    ////////////////

    ReelsEntity? currentReelCommentsViewed,
    bool? isMute,
    bool? isDisposed,
    bool? isSeeking,
    bool? isCommentsOpened,
    bool? readMore,
    double? height,
    double? bottomPadding,
    Map<int, VideoPlayerController>? videoControllers,
    Map<int, VideoPlayerController>? followingVideoControllers,
    Map<int, VideoPlayerController>? myReelsVideoControllers,
    Set<int>? erroredIndices,
    Set<int>? followingErroredIndices,
    Set<int>? myReelsErroredIndices,
    Duration? videoPosition,
    Duration? followingVideoPosition,
    Duration? myReelsVideoPosition,
    Duration? videoDuration,
    Duration? followingVideoDuration,
    Duration? myReelsVideoDuration,
    ScrollController? myReelsGrideViewScrollController,
  }) {
    return GetReelsState(
      // for you reels
      message: message ?? this.message,
      requestState: requestState ?? this.requestState,
      currentReel: currentReel ?? this.currentReel,
      currentReelCommentsViewed:
          currentReelCommentsViewed ?? this.currentReelCommentsViewed,
      reelsList: reelsList ?? this.reelsList,
      currentIndex: currentIndex ?? this.currentIndex,
      currentPagination: currentPagination ?? this.currentPagination,
      lastPage: lastPage ?? this.lastPage,
      scrollCtrl: scrollCtrl ?? this.scrollCtrl,
      // following reels
      followingMessage: followingMessage ?? this.followingMessage,
      requestFollowingState:
          requestFollowingState ?? this.requestFollowingState,
      followingReelsList: followingReelsList ?? this.followingReelsList,
      currentFollowingIndex:
          currentFollowingIndex ?? this.currentFollowingIndex,
      followingScrollCtrl: followingScrollCtrl ?? this.followingScrollCtrl,
      currentFollowingPagination:
          currentFollowingPagination ?? this.currentFollowingPagination,
      currentFollowingReel: currentFollowingReel ?? this.currentFollowingReel,
      lastFollowingPage: lastFollowingPage ?? this.lastFollowingPage,
      // user reels
      myReelMessage: myReelMessage ?? this.myReelMessage,
      requestMyReelsState: requestMyReelsState ?? this.requestMyReelsState,
      updateReelsState: updateReelsState ?? this.updateReelsState,
      deleteReelsState: deleteReelsState ?? this.deleteReelsState,
      myReelsList: myReelsList ?? this.myReelsList,
      currentMyReelsIndex: currentMyReelsIndex ?? this.currentMyReelsIndex,
      currentMyReelsPagination:
          currentMyReelsPagination ?? this.currentMyReelsPagination,
      lastMyReelsPage: lastMyReelsPage ?? this.lastMyReelsPage,
      currentMyReel: currentMyReel ?? this.currentMyReel,
      myReelsScrollCtrl: myReelsScrollCtrl ?? this.myReelsScrollCtrl,

      ///

      isMute: isMute ?? this.isMute,
      isDisposed: isDisposed ?? this.isDisposed,
      isSeeking: isSeeking ?? this.isSeeking,
      isCommentsOpened: isCommentsOpened ?? this.isCommentsOpened,
      readMore: readMore ?? this.readMore,
      height: height ?? this.height,
      bottomPadding: bottomPadding ?? this.bottomPadding,
      videoControllers: videoControllers ?? this.videoControllers,
      followingVideoControllers:
          followingVideoControllers ?? this.followingVideoControllers,
      erroredIndices: erroredIndices ?? this.erroredIndices,
      followingErroredIndices:
          followingErroredIndices ?? this.followingErroredIndices,
      myReelsErroredIndices:
          myReelsErroredIndices ?? this.myReelsErroredIndices,
      videoPosition: videoPosition ?? this.videoPosition,
      myReelsVideoControllers:
          myReelsVideoControllers ?? this.myReelsVideoControllers,
      followingVideoPosition:
          followingVideoPosition ?? this.followingVideoPosition,
      videoDuration: videoDuration ?? this.videoDuration,
      followingVideoDuration:
          followingVideoDuration ?? this.followingVideoDuration,
      myReelsVideoDuration: myReelsVideoDuration ?? this.myReelsVideoDuration,
      myReelsVideoPosition: myReelsVideoPosition ?? this.myReelsVideoPosition,
      myReelsGrideViewScrollController: myReelsGrideViewScrollController ??
          this.myReelsGrideViewScrollController,
    );
  }

  @override
  List<Object?> get props => [
        message,
        requestState,
        reelsList,
        currentIndex,
        currentPagination,
        lastPage,
        scrollCtrl,
        currentReel,
        followingMessage,
        requestFollowingState,
        followingReelsList,
        myReelsVideoPosition,
        currentFollowingIndex,
        followingScrollCtrl,
        currentFollowingPagination,
        currentFollowingReel,
        lastFollowingPage,
        // user reels
        myReelMessage,
        requestMyReelsState,
        updateReelsState,
        deleteReelsState,
        myReelsList,
        currentMyReelsIndex,
        currentMyReelsPagination,
        lastMyReelsPage,
        currentMyReel,
        myReelsScrollCtrl,

        //
        currentReelCommentsViewed,
        isMute,
        isDisposed,
        isSeeking,
        isCommentsOpened,
        readMore,
        height,
        bottomPadding,
        videoControllers,
        followingVideoControllers,
        videoPosition,
        videoDuration,
        followingVideoDuration,
        followingVideoPosition,
        myReelsVideoControllers,
        myReelsVideoDuration,
        erroredIndices,
        followingErroredIndices,
        myReelsErroredIndices,
        myReelsGrideViewScrollController
      ];
}
