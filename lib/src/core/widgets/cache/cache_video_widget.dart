import 'dart:io';
import 'package:general/src/core/cache/video_cache_manager.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/widgets/show_entro_widget.dart';
import 'package:general/src/features/room/presentation/gifts/controller/gift_controller.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:video_player/video_player.dart';

class CacheVideoWidget extends StatefulWidget {
  final String videoUrl;
  final double? height, width;
  final bool isShowGift, isReels;
  static final ValueNotifier<VideoPlayerController?> videoPlayerController =
      ValueNotifier(null);
  final void Function()? detectError;

  const CacheVideoWidget({
    required this.videoUrl,
    this.height,
    this.width,
    this.detectError,
    this.isShowGift = false,
    this.isReels = false,
    super.key,
  });

  @override
  CacheVideoWidgetState createState() => CacheVideoWidgetState();
}

class CacheVideoWidgetState extends State<CacheVideoWidget> {
  final VideoAssetCacheManager _videoCacheManager = VideoAssetCacheManager();
  late final ValueNotifier<bool> _isLoading;
  late final ValueNotifier<String?> _isError;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isLoading = ValueNotifier(false);
    _isError = ValueNotifier(null);
    _loadVideo();
  }

  @override
  void didUpdateWidget(CacheVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      _loadVideo();
    }
  }

  Future<void> _loadVideo() async {
    final url = EndPoints.getImage(widget.videoUrl);

    _isLoading.value = true;
    _isError.value = null;
    File? videoFile;

    try {
      videoFile = await _videoCacheManager.getCachedAsset(url);

      if (_isDisposed) return;

      if (videoFile != null) {
        await _initializeVideoPlayer(videoFile);
      } else {
        if (GiftController().normalGiftsToShow.isNotEmpty) {
          Future.delayed(
            const Duration(seconds: 3),
            () {
              if (GiftController().normalGiftsToShow.isNotEmpty) {
                GiftController().normalGiftsToShow.removeAt(0);
              }
              if (GiftController().normalGiftsToShow.isNotEmpty &&
                  GiftController().normalGiftsToShow[0]['wappel']
                          ['wappelImage'] !=
                      '') {
                ShowEntroWidget.showEntro.value =
                    GiftController().normalGiftsToShow[0]['wappel'];
              }
            },
          );

          Future.delayed(
            const Duration(seconds: 4),
            () {
              if (GiftController().normalGiftsToShow.isEmpty) {
                di<GiftBloc>().add(
                  const ShowGiftsEvent(
                    pathGift: '',
                    isShowGift: false,
                    giftType: ShowGiftType.mp4,
                  ),
                );
                return;
              }
              _showNextQueuedGift(GiftController().normalGiftsToShow[0]);
            },
          );
        }
        widget.detectError?.call();

        _isError.value = "video_file_not_found.";
      }
    } catch (error) {
      if (GiftController().normalGiftsToShow.isNotEmpty) {
        GiftController().normalGiftsToShow.removeAt(0);
        if (GiftController().normalGiftsToShow.isEmpty) {
          di<GiftBloc>().add(
            const ShowGiftsEvent(
              pathGift: '',
              isShowGift: false,
              giftType: ShowGiftType.mp4,
            ),
          );
        } else {
          _showNextQueuedGift(GiftController().normalGiftsToShow[0]);
        }
      }
      widget.detectError?.call();

      _isError.value = "failed_to_load_video_file.";
      Methods.printLog("error_loading_video_file: $error");
    } finally {
      _isLoading.value = false;
    }
  }

  /// Plays the next queued gift from values captured synchronously at the
  /// call site. The queue can be mutated by the cleanup timer or another
  /// cache widget while the delay is pending, so the delayed callback must
  /// never re-read `normalGiftsToShow[0]` (RangeError on empty queue).
  void _showNextQueuedGift(Map<String, dynamic> next) {
    final type = next['giftType'];
    final path = next['pathGift'];
    final isFamous = next['isFamousGift'];
    final wappel = next['wappel'];
    final delayMs =
        (type == 'alpha' || type == 'vap' || type == 'mp4') ? 100 : 650;

    Future.delayed(
      Duration(milliseconds: delayMs),
      () {
        if (type == 'alpha') {
          di<AlphaGiftManagerBloc>().add(
            ShowAlphaGift(imgFile: path, isFamousGift: isFamous),
          );
        } else {
          di<GiftBloc>().add(
            ShowGiftsEvent(
              isShowGift: true,
              pathGift: path,
              isFamousGift: isFamous,
              giftType: {
                    'vap': ShowGiftType.vap,
                    'mp4': ShowGiftType.mp4,
                  }[type] ??
                  ShowGiftType.svga,
            ),
          );
        }
        if (wappel['wappelImage'] != '') {
          ShowEntroWidget.showEntro.value = wappel;
        }
      },
    );
  }

  Future<void> _initializeVideoPlayer(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    if (widget.isReels == true) {
      controller.seekTo(Duration.zero);
      controller.setLooping(true);
    }
    if (!mounted) return;

    CacheVideoWidget.videoPlayerController.value = controller;
    controller.play();

    if (widget.isShowGift) {
      controller.addListener(_handleVideoPlayback);
    }
  }

  void _handleVideoPlayback() {
    final controller = CacheVideoWidget.videoPlayerController.value;
    if (controller == null || !mounted) return;

    if (controller.value.position >= controller.value.duration) {
      _onVideoEnd(controller);
    }
  }

  Future<void> _onVideoEnd(VideoPlayerController controller) async {
    controller.pause();

    await Future.microtask(() {
      di<GiftBloc>().add(const SetVideoVisibilityEvent(isVisible: false));
      di<GiftBloc>().add(
        const ShowGiftsEvent(
          pathGift: '',
          isShowGift: false,
          giftType: ShowGiftType.mp4,
        ),
      );

      if (GiftController().normalGiftsToShow.isNotEmpty) {
        GiftController().normalGiftsToShow.removeAt(0);
        if (GiftController().normalGiftsToShow.isEmpty) {
          di<GiftBloc>().add(
            const ShowGiftsEvent(
              pathGift: '',
              isShowGift: false,
              giftType: ShowGiftType.mp4,
            ),
          );
        } else {
          _showNextQueuedGift(GiftController().normalGiftsToShow[0]);
        }
      }
      di<GiftBloc>().add(
        const ShowGiftsEvent(
          pathGift: "",
          isShowGift: false,
          giftType: ShowGiftType.mp4,
        ),
      );
    });

    setState(() {
      CacheVideoWidget.videoPlayerController.value = null;
    });
  }

  /// Method to play the video
  void play() {
    final controller = CacheVideoWidget.videoPlayerController.value;
    if (controller != null && controller.value.isInitialized) {
      controller.play();
    }
  }

  /// Method to pause the video
  void pause() {
    final controller = CacheVideoWidget.videoPlayerController.value;
    if (controller != null && controller.value.isInitialized) {
      controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const SizedBox();
        }

        return ValueListenableBuilder<String?>(
          valueListenable: _isError,
          builder: (context, isError, child) {
            if (isError != null) {
              return const SizedBox();
            }
            return ValueListenableBuilder<VideoPlayerController?>(
              valueListenable: CacheVideoWidget.videoPlayerController,
              builder: (context, controller, child) {
                if (controller == null || !controller.value.isInitialized) {
                  return const SizedBox();
                }
                return SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: (widget.isReels == true)
                        ? VideoPlayer(controller, key: widget.key)
                        : VideoPlayer(controller),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    CacheVideoWidget.videoPlayerController.value
        ?.removeListener(_handleVideoPlayback);

    if (widget.isShowGift && widget.isReels) {
      final controller = CacheVideoWidget.videoPlayerController.value;
      _onVideoEnd(controller!);
    }

    _isLoading.dispose();
    _isError.dispose();
    _isDisposed = true;
    super.dispose();
  }
}
