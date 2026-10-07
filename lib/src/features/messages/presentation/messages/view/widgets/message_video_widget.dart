part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class MessageVideoWidget extends StatefulWidget {
  const MessageVideoWidget({
    super.key,
    required this.entity,
    required this.params,
    required this.isLastMessage,
  });

  final MessagesEntity entity;
  final MessagesParameter params;
  final bool isLastMessage;

  @override
  State<MessageVideoWidget> createState() => MessageVideoWidgetState();
}

class MessageVideoWidgetState extends State<MessageVideoWidget> {
  VideoPlayerController? _controller;
  static Map<String, int> currentTime = {};
  static ValueNotifier<Map<int, double>> videoProgressNotifier =
      ValueNotifier({});
  late ValueNotifier<bool> isPlaying;
  late ValueNotifier<double> videoSeeker;
  late ValueNotifier<bool> isControllerReady;

  /// Unique key to identify which video this widget is for
  String get _videoKey =>
      '${widget.entity.id}_${widget.entity.albums?.file ?? widget.entity.albums?.videoFile?.path ?? ''}';
  String? _currentVideoKey;

  /// Guards against overlapping/late initialize() calls: a tap can fire while a
  /// previous initialize() is still awaiting, and the widget can unmount mid-
  /// init. We await this in dispose() so the native player is never used or
  /// leaked after teardown (the C8 VideoPlayer PlatformException source).
  Future<void>? _initFuture;
  bool _disposed = false;

  // late ValueNotifier<Duration> videoDuration;
  // late Duration videoDuration;

  void _openFullScreenVideo() async {
    // Ensure controller is initialized before opening dialog
    if (_controller == null || !_controller!.value.isInitialized) {
      await _initializeController();
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      Methods.printLog('Video controller failed to initialize');
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: (0.9)),
      builder: (dialogContext) {
        _playVideoWithDelay();
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.black,
              insetPadding: EdgeInsets.zero,
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) return;
                  bool shouldPop = await _handleWillPop();
                  if (shouldPop) {
                    Navigator.of(dialogContext).pop(result);
                  }
                },
                child: Stack(
                  children: [
                    // Fullscreen Video Player
                    if (_controller != null && _controller!.value.isInitialized)
                      GestureDetector(
                        onTap: _toggleVideoPlayback,
                        child: SizedBox.expand(
                          // This makes the video take the full screen
                          child: FittedBox(
                            fit: BoxFit.cover,
                            // Adjust to maintain aspect ratio
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        ),
                      ),

                    // Close Button
                    _buildCloseButton(dialogContext),

                    // Play Button Overlay
                    _buildPlayButton(),
//make the slider take the whole screen later
                    if (_controller != null && _controller!.value.isInitialized)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: ValueListenableBuilder<double>(
                          valueListenable: videoSeeker,
                          builder: (context, value, child) {
                            final maxDuration = _controller
                                    ?.value.duration.inSeconds
                                    .toDouble() ??
                                1.0;
                            final clampedValue = value.clamp(0.0, maxDuration);
                            return Row(
                              children: [
                                TextWidget(
                                  Methods()
                                      .formatDurationFromDouble(clampedValue),
                                  style: context.bodyMedium.w400.colorExt(
                                      ColorManager.textPrimary
                                          .withValues(alpha: (0.8))),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: clampedValue,
                                    min: 0,
                                    max: maxDuration,
                                    activeColor: ColorManager.primary,
                                    inactiveColor:
                                        Colors.white.withValues(alpha: (0.5)),
                                    onChanged: (newValue) {
                                      videoSeeker.value = newValue;
                                      _controller?.seekTo(
                                          Duration(seconds: newValue.toInt()));
                                    },
                                  ),
                                ),
                                TextWidget(
                                  Methods().formatDuration(
                                      widget.entity.albums?.duration ?? ''),
                                  style: context.bodyMedium.w400.colorExt(
                                      ColorManager.textPrimary
                                          .withValues(alpha: (0.8))),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    isPlaying.value = true;
    //isPlaying.notifyListeners();
  }

  void _playVideoWithDelay() {
    Future.delayed(const Duration(milliseconds: 300), () {
      // The dialog may have been dismissed (controller disposed) during the
      // delay; guard before driving the native player.
      if (_disposed || !mounted) return;
      final c = _controller;
      if (c != null && c.value.isInitialized) {
        c.play();
      }
    });
  }

  Future<bool> _handleWillPop() async {
    _controller?.pause();
    // Free the native decoder as soon as the fullscreen viewer closes; the next
    // tap re-initializes lazily. Keeps at most one active player at a time.
    _disposeController();
    isControllerReady.value = false;
    return true;
  }

  void _toggleVideoPlayback() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_controller!.value.isBuffering) {
      Methods.printLog('Video is buffering, waiting...');
      return;
    }

    if (_controller!.value.isPlaying) {
      Methods.printLog('Pausing video...');
      await _controller!.pause();
      isPlaying.value = false;
    } else {
      Methods.printLog('Playing video...');
      await _controller!.play();
      isPlaying.value = true;
    }

    //  isPlaying.notifyListeners();
  }

  Widget _buildCloseButton(BuildContext dialogContext) {
    return Positioned(
      top: 10,
      right: 20,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 30),
        onPressed: () {
          _controller?.pause();
          Navigator.pop(dialogContext);
          // Free the native decoder on close; the next tap re-initializes.
          _disposeController();
          isControllerReady.value = false;
        },
      ),
    );
  }

  Widget _buildPlayButton() {
    return Center(
      child: GestureDetector(
        onTap: _toggleVideoPlayback,
        child: ValueListenableBuilder<bool>(
          valueListenable: isPlaying,
          builder: (context, isPlaying, child) {
            return isPlaying
                ? const SizedBox()
                : const Icon(Icons.play_arrow, size: 80, color: Colors.white);
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // videoDuration = Duration.zero;
    isPlaying = ValueNotifier<bool>(true);
    videoSeeker = ValueNotifier<double>(0.0);
    isControllerReady = ValueNotifier<bool>(false);
    _currentVideoKey = _videoKey;
    // Do NOT eagerly initialize the network controller here: the thumbnail is
    // already rendered from firstFrame, and the full controller is initialized
    // lazily on tap (_openFullScreenVideo). Eager init buffered every scrolled-
    // past video and exhausted native decoders.
  }

  @override
  void didUpdateWidget(covariant MessageVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the entity changed (different video), tear down the old controller and
    // reset lazily — the next tap re-initializes for the new source.
    if (_videoKey != _currentVideoKey) {
      _currentVideoKey = _videoKey;
      videoSeeker.value = 0.0;
      isPlaying.value = true;
      isControllerReady.value = false;
      _disposeController();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    // Ensure any in-flight initialize() completes its teardown before we drop
    // the controller reference, so we never leak a native player or invoke it
    // after disposal.
    final pending = _initFuture;
    if (pending != null) {
      pending.whenComplete(_disposeController);
    } else {
      _disposeController();
    }
    // videoDuration=Duration.zero;
    isPlaying.dispose();
    videoSeeker.dispose();
    isControllerReady.dispose();

    super.dispose();
  }

  /// Listener promoted to a named field so it can be removed (an anonymous
  /// closure added per init could never be detached, leaking on every re-init).
  void _onControllerTick() {
    final c = _controller;
    if (c != null && c.value.isPlaying) {
      videoSeeker.value = c.value.position.inSeconds.toDouble();
    }
  }

  void _disposeController() {
    final c = _controller;
    _controller = null;
    if (c == null) return;
    c.removeListener(_onControllerTick);
    // dispose() returns a Future, but we intentionally fire-and-forget here:
    // callers (dispose/didUpdateWidget/close button) are synchronous teardown
    // paths. The reference is cleared first so nothing touches it meanwhile.
    c.dispose();
  }

  Future<void> _initializeController() {
    // Coalesce concurrent calls so a second tap doesn't spin up a parallel
    // native player while the first is still initializing.
    return _initFuture ??= _doInitializeController().whenComplete(() {
      _initFuture = null;
    });
  }

  Future<void> _doInitializeController() async {
    VideoPlayerController? controller;
    try {
      _disposeController();
      isControllerReady.value = false;

      final albums = widget.entity.albums;
      if (albums == null) {
        Methods.printLog('Video albums is null, cannot initialize controller');
        return;
      }

      // Determine if we should use network URL or local file
      final hasNetworkFile = albums.file != null && albums.file!.isNotEmpty;
      final hasLocalFile = albums.videoFile != null;

      if (hasNetworkFile) {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(EndPoints.getImage(albums.file!)),
        );
      } else if (hasLocalFile) {
        controller = VideoPlayerController.file(albums.videoFile!);
      } else {
        Methods.printLog('No valid video source found');
        return;
      }

      await controller.initialize();

      // The widget can unmount (or another video swap in) while initialize()
      // awaits. Dispose the freshly-created player instead of leaking it or
      // assigning it where a later op would throw a PlatformException.
      if (_disposed || !mounted) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      controller.addListener(_onControllerTick);
      isControllerReady.value = true;
    } catch (e) {
      Methods.printLog('Error initializing video controller: $e');
      // Make sure a partially-created controller is released on failure.
      if (!identical(controller, _controller)) {
        await controller?.dispose();
      }
      if (mounted && !_disposed) isControllerReady.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = Methods.isMe('${widget.entity.userId}');
    final double videoWidth = ScreenUtil().screenWidth * 0.6;
    final double videoHeight = ScreenUtil().screenHeight * 0.4;

    return GestureDetector(
      onTap: _openFullScreenVideo,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) _buildVideoContainer(videoWidth, videoHeight, isMe),
          10.wBox,
          if (isMe) _buildVideoContainer(videoWidth, videoHeight, isMe),
        ],
      ),
    );
  }

  Widget _buildVideoContainer(double width, double height, bool isMe) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ColorManager.black12,
      ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          _buildVideoThumbnail(width, height, isMe),
          _buildProgressIndicator(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: context.paddingSymmetric(horizontal: 5),
              height: height * 0.1,
              decoration: BoxDecoration(
                color: ColorManager.black.withValues(alpha: (0.2)),
                borderRadius: 10.radius,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if ((widget.entity.albums?.duration ?? '') != '')
                    SizedBox(
                      height: height * 0.1,
                      child: Row(
                        children: [
                           Icon(
                            Icons.video_camera_back,
                            color: ColorManager.textPrimary,
                          ),
                          TextWidget(
                            Methods().formatDuration(
                                widget.entity.albums?.duration ?? ''),
                            style: context.bodyMedium.w400.colorExt(
                              ColorManager.textPrimary.withValues(alpha: (0.8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _SeenWidget(entity: widget.entity),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(double width, double height, bool isMe) {
    return widget.entity.albums?.firstFrameFile != null
        ? Image.file(
            widget.entity.albums!.firstFrameFile!,
            width: width,
            height: height,
            fit: BoxFit.cover,
          )
        : ImageViewWidget(
            url: EndPoints.getImage(widget.entity.albums?.firstFrame ?? ''),
            width: width,
            height: height,
          );
  }

  Widget _buildProgressIndicator() {
    return ValueListenableBuilder<Map<int, double>>(
      valueListenable: videoProgressNotifier,
      builder: (context, value, child) {
        Methods.printLog(
            'progressNotifier.progressNotifier ${videoProgressNotifier.value}');

        final progress = (value[widget.entity.id] ?? 0);
        final currentKey =
            widget.params.userId.toString() + widget.entity.id.toString();
        final currentValue = MessageVideoWidgetState.currentTime[currentKey];
        final messageId = widget.entity.id;

        Methods.printLog("🎥 Check current upload progress --- $progress");
        Methods.printLog(
            "Key: $currentKey | Value: $currentValue | MessageID: $messageId");
        //why when 🎥 Check current upload progress --- 0.0 the indicator appears
        if ((progress > 0 && progress < 1.0)) {
          return CircularProgressIndicator(
            value: progress,
            backgroundColor: ColorManager.gray,
            color: ColorManager.primary,
            strokeWidth: 6.0,
          );
        } else {
          return  Icon(
            Icons.play_arrow,
            color: ColorManager.textPrimary,
            size: 30,
          );
        }
      },
    );
  }
}
