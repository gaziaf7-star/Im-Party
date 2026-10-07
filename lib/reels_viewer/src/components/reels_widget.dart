part of 'package:general/reels_viewer/src/reels_viewer.dart';

class _ReelsWidget extends StatefulWidget {
  final VideoPlayerController? controller;
  final ReelsEntity reelData;
  final ReelViewerBloc reelViewerBloc;
  final int reelIndex;
  final ReelsType reelsType;

  /// The resolved feed for this reels tab. Used to read per-index error state
  /// (`erroredIndices` / `pool.hasError`) and to drive retry (`retryReel`).
  final ReelsFeedBloc feed;

  /// Toggle play/pause for the active reel (single tap).
  final VoidCallback onTogglePlay;

  /// Dispatched on a double-tap like (keeps the existing onLike + AnimateLike
  /// flow owned by the caller in reels_viewer.dart).
  final VoidCallback onDoubleTapLike;

  const _ReelsWidget({
    required this.controller,
    required this.reelData,
    required this.reelViewerBloc,
    required this.reelIndex,
    required this.reelsType,
    required this.feed,
    required this.onTogglePlay,
    required this.onDoubleTapLike,
  });

  @override
  State<_ReelsWidget> createState() => _ReelsWidgetState();
}

class _ReelsWidgetState extends State<_ReelsWidget>
    with TickerProviderStateMixin {
  bool _showVideo = false;
  bool _fadeComplete = false;

  /// Surfaced for WF3 overlays from the controller value listener.
  bool _isBuffering = false;
  bool _hasError = false;

  /// 2x speed pill visibility, set while the user holds the screen.
  bool _isFastForward = false;

  /// Last double-tap position, captured by [onDoubleTapDown] so the heart burst
  /// spawns exactly where the user tapped.
  Offset? _lastTapPosition;

  /// Active heart bursts. Multiple may animate concurrently — each owns its
  /// controller and is removed when its animation completes.
  final List<_HeartBurstEntry> _hearts = [];
  int _heartSeq = 0;

  @override
  void initState() {
    super.initState();
    _attachListener(widget.controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyDesiredState(widget.reelViewerBloc.state);
    });
  }

  @override
  void didUpdateWidget(covariant _ReelsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detachListener(oldWidget.controller);
      _attachListener(widget.controller);

      final ctrl = widget.controller;
      if (ctrl != null && ctrl.value.isInitialized && _isReadyToShow(ctrl)) {
        _showVideo = true;
        _fadeComplete = false;
        _scheduleFadeComplete();
      } else if (ctrl == null) {
        _showVideo = false;
        _fadeComplete = false;
      }

      // A new controller landed on this slot: re-apply desired play/pause and
      // volume so the active reel honours the current viewer state.
      _applyDesiredState(widget.reelViewerBloc.state);
    }
  }

  bool _isReadyToShow(VideoPlayerController ctrl) {
    if (!ctrl.value.isInitialized) return false;
    if (ctrl.value.isBuffering && ctrl.value.buffered.isEmpty) return false;
    return true;
  }

  void _scheduleFadeComplete() {
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted && _showVideo) {
        setState(() => _fadeComplete = true);
      }
    });
  }

  void _onControllerUpdated() {
    final ctrl = widget.controller;
    if (ctrl == null) return;

    if (!_showVideo && _isReadyToShow(ctrl)) {
      setState(() => _showVideo = true);
      _scheduleFadeComplete();
      // Play the active reel as soon as the controller is ready (no swipe-back).
      _applyDesiredState(widget.reelViewerBloc.state);
    }

    // Surface buffering/error signals for WF3 overlays.
    final buffering = ctrl.value.isInitialized && ctrl.value.isBuffering;
    final errored = ctrl.value.hasError;
    if (buffering != _isBuffering || errored != _hasError) {
      setState(() {
        _isBuffering = buffering;
        _hasError = errored;
      });
    }

    // Controller-ready / late-init auto-play: when this slot is the active reel
    // and the viewer wants playback, the widget — the SOLE applier — starts the
    // controller as soon as it is ready.
    _applyDesiredState(widget.reelViewerBloc.state);
  }

  void _attachListener(VideoPlayerController? controller) {
    if (controller == null) return;
    // Guard: addListener on a disposed controller throws in debug mode.
    // Root cause is cleared by pool.disposeAll() now clearing the map before
    // calling dispose(), but keep this as a safety net for any edge case.
    if (controller.value.hasError) return;
    try {
      controller.addListener(_onControllerUpdated);
    } catch (_) {
      // Controller was disposed between the pool clearing and this frame.
      return;
    }
    if (controller.value.isInitialized) {
      _showVideo = true;
    }
  }

  void _detachListener(VideoPlayerController? controller) {
    controller?.removeListener(_onControllerUpdated);
  }

  /// The ONE place that drives play/pause and volume for the feed.
  void _applyDesiredState(ReelViewerState state) {
    final controller = widget.controller;
    if (controller == null || !controller.value.isInitialized) return;
    // A controller that errored (or was swapped/disposed under us) throws on
    // play/pause/setVolume — never drive it.
    if (controller.value.hasError) return;

    final stillActive = state.activeReelIndex == widget.reelIndex &&
        state.reelsType == widget.reelsType;

    // Wrap every native call: the pool can dispose this controller between the
    // guard above and the call below (use-after-dispose throws in debug).
    try {
      if (!stillActive) {
        if (controller.value.isPlaying) controller.pause();
        controller.setVolume(0.0);
        // A non-active slot must never keep a temporary fast-forward speed.
        if (controller.value.playbackSpeed != 1.0) {
          controller.setPlaybackSpeed(1.0);
        }
        return;
      }

      // Active slot: honour the viewer's mute choice.
      final desiredVolume = state.isMute ? 0.0 : 1.0;
      if (controller.value.volume != desiredVolume) {
        controller.setVolume(desiredVolume);
      }

      if (state.isPlaying && !controller.value.isPlaying) {
        controller.play();
      } else if (!state.isPlaying && controller.value.isPlaying) {
        controller.pause();
      }
    } catch (_) {
      // Controller disposed mid-frame; the pool will surface the error/rebuild.
    }
  }

  bool get _isActive {
    final s = widget.reelViewerBloc.state;
    return s.activeReelIndex == widget.reelIndex &&
        s.reelsType == widget.reelsType;
  }

  // ── Gestures ────────────────────────────────────────────────────────────

  void _onDoubleTapDown(TapDownDetails details) {
    _lastTapPosition = details.localPosition;
  }

  void _onDoubleTap() {
    // Keep the existing like dispatch (onLike + AnimateLike) owned by caller.
    widget.onDoubleTapLike();
    HapticFeedback.lightImpact();
    _spawnHeart(_lastTapPosition);
  }

  void _spawnHeart(Offset? at) {
    final size = context.size;
    final position = at ??
        (size != null
            ? Offset(size.width / 2, size.height / 2)
            : Offset.zero);

    final id = _heartSeq++;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Small alternating tilt so concurrent hearts fan out.
    final angle = (id.isEven ? 1 : -1) * (0.12 + (id % 3) * 0.06);
    final entry = _HeartBurstEntry(
      heart: _BurstHeart(id: id, position: position, angle: angle),
      controller: controller,
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) {
          controller.dispose();
          return;
        }
        setState(() => _hearts.removeWhere((e) => e.heart.id == id));
        controller.dispose();
      }
    });

    setState(() => _hearts.add(entry));
    controller.forward(from: 0.0);
  }

  void _onLongPressStart(LongPressStartDetails _) {
    final controller = widget.controller;
    if (!_isActive || controller == null || !controller.value.isInitialized) {
      return;
    }
    controller.setPlaybackSpeed(2.0);
    HapticFeedback.lightImpact();
    setState(() => _isFastForward = true);
  }

  void _onLongPressEnd(LongPressEndDetails _) {
    final controller = widget.controller;
    if (controller != null && controller.value.isInitialized) {
      controller.setPlaybackSpeed(1.0);
    }
    if (_isFastForward) setState(() => _isFastForward = false);
  }

  @override
  void dispose() {
    _detachListener(widget.controller);
    for (final entry in _hearts) {
      entry.controller.dispose();
    }
    _hearts.clear();
    super.dispose();
  }

  // ── Visual pieces ───────────────────────────────────────────────────────

  /// Full-bleed cover thumbnail (no black bars) so the fade to video is
  /// seamless. Falls back to the asset placeholder when there is no subFrame.
  Widget _buildThumbnail() {
    final subFrame = widget.reelData.subFrame;
    if (subFrame != null && subFrame.isNotEmpty) {
      return Positioned.fill(
        child: ImageViewWidget(
          url: subFrame,
          boxFit: BoxFit.cover,
          width: ScreenUtil().screenWidth,
          height: ScreenUtil().screenHeight,
        ),
      );
    }
    return Positioned.fill(
      child: ImageWidget(
        image: AssetsManager.reelPlaceholder,
        boxFit: BoxFit.cover,
        height: ScreenUtil().screenHeight,
        width: ScreenUtil().screenWidth,
      ),
    );
  }

  /// Edge-to-edge video rendered with BoxFit.cover. The video is sized to its
  /// own aspect ratio inside a FittedBox(cover) that fills the screen, so the
  /// frame is cropped to fill — never letterboxed.
  Widget _buildCoverVideo(VideoPlayerController controller) {
    final ratio = controller.value.aspectRatio;
    // Clamp extreme ratios so a malformed stream can't blow up layout.
    final safeRatio = (ratio.isFinite && ratio > 0)
        ? ratio.clamp(0.2, 5.0)
        : (9 / 16);
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: safeRatio,
          height: 1,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  /// Blurred + shimmering placeholder for the no-thumbnail case: a soft
  /// shimmer over a dark base instead of a bare spinner on black.
  Widget _buildShimmerLoading() {
    return Positioned.fill(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Shimmer.fromColors(
          baseColor: ColorManager.black,
          highlightColor: ColorManager.grayMouce.withValues(alpha: 0.6),
          period: const Duration(milliseconds: 1400),
          child: Container(color: ColorManager.grayMouce),
        ),
      ),
    );
  }

  Widget _buildBufferingSpinner() {
    return Center(
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: ColorManager.offWhite.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  /// "couldn't play — retry or skip" overlay. Retry re-initializes via the
  /// feed; skip advances immediately to the next reel.
  Widget _buildErrorOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: ColorManager.black.withValues(alpha: 0.55),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.feed.retryReel(widget.reelIndex),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: ColorManager.offWhite,
                      size: 44.w,
                    ),
                    12.hBox,
                    TextWidget(
                      StringManager.someThingWentWrong,
                      style: context.bodyMedium.colorExt(ColorManager.offWhite),
                    ),
                    4.hBox,
                    TextWidget(
                      StringManager.tryAgain,
                      style: context.bodySmall
                          .colorExt(ColorManager.offWhite.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              20.hBox,
              // Skip button — advance to the next reel without waiting for retry.
              GestureDetector(
                onTap: () {
                  final ctrl = widget.feed.state.scrollCtrl;
                  // positions.length==1 (not hasClients): the singleton
                  // PageController can be briefly attached to >1 live PageView,
                  // and nextPage -> _positions.single throws "Too many elements".
                  if (ctrl.positions.length == 1) {
                    ctrl.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: ColorManager.offWhite.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: TextWidget(
                    StringManager.skip.tr(),
                    style: context.bodySmall.colorExt(ColorManager.offWhite),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedPill() {
    return PositionedDirectional(
      top: 70.h,
      start: 0,
      end: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: context.paddingSymmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: ColorManager.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fast_forward_rounded,
                  color: ColorManager.offWhite, size: 16.w),
              6.wBox,
              TextWidget(
                '2x',
                style: context.bodyMedium.bold
                    .colorExt(ColorManager.offWhite),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReelViewerBloc, ReelViewerState>(
      bloc: widget.reelViewerBloc,
      listenWhen: (prev, curr) =>
          prev.isPlaying != curr.isPlaying ||
          prev.activeReelIndex != curr.activeReelIndex ||
          prev.reelsType != curr.reelsType ||
          prev.isMute != curr.isMute,
      listener: (context, state) => _applyDesiredState(state),
      buildWhen: (prev, curr) =>
          prev.isPlaying != curr.isPlaying ||
          prev.activeReelIndex != curr.activeReelIndex ||
          prev.reelsType != curr.reelsType,
      builder: (context, viewerState) {
        final isActive = viewerState.activeReelIndex == widget.reelIndex &&
            viewerState.reelsType == widget.reelsType;
        final controller = widget.controller;
        final isInitialized =
            controller != null && controller.value.isInitialized;
        final isPlaying = viewerState.isPlaying;
        final showVideo = _showVideo && isActive && isInitialized;

        // Errored if either the pool flagged it or the controller value did.
        final isErrored = isActive &&
            (_hasError || widget.feed.pool.hasError(widget.reelIndex));
        final showBuffering = isActive && !isErrored && _isBuffering;

        final hasThumb = widget.reelData.subFrame != null &&
            widget.reelData.subFrame!.isNotEmpty;
        // Pre-video loading: nothing decoded yet and no error.
        final showLoadingPlaceholder = !showVideo && !isErrored;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTogglePlay,
          onDoubleTapDown: _onDoubleTapDown,
          onDoubleTap: _onDoubleTap,
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
              // Cover thumbnail beneath the video until the fade completes.
              if (!_fadeComplete) _buildThumbnail(),

              // Shimmer/blur only when there is no thumbnail to show.
              if (showLoadingPlaceholder && !hasThumb) _buildShimmerLoading(),

              if (isInitialized)
                AnimatedOpacity(
                  opacity: showVideo ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _buildCoverVideo(controller),
                ),

              if (showBuffering) _buildBufferingSpinner(),

              if (isErrored) _buildErrorOverlay(),

              if (isActive && isInitialized && !isPlaying && !isErrored)
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: ColorManager.offWhite.withValues(alpha: 0.6),
                    size: 90.w,
                  ),
                ),

              if (_isFastForward) _buildSpeedPill(),

              // Multi-heart burst layer (above the video, below the rail).
              Positioned.fill(child: _HeartBurstLayer(hearts: _hearts)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Snappier vertical paging for the reels feed. A stiffer spring than the
/// default [PageScrollPhysics] so swipes settle faster (TikTok-like), while
/// still composing with the parent [AlwaysScrollableScrollPhysics] so the
/// top over-scroll reaches the surrounding [RefreshIndicator] for pull-to-
/// refresh — it does NOT consume the gesture itself.
class _SnappyPageScrollPhysics extends PageScrollPhysics {
  const _SnappyPageScrollPhysics({super.parent});

  @override
  _SnappyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnappyPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 1,
        stiffness: 150,
        damping: 22,
      );
}
