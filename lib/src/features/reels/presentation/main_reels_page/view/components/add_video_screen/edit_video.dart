import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:general/reels_viewer/reels_viewer.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/send_message/send_messages_bloc.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/toggle_app_bar/toggle_app_bar_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';
import 'package:video_compress/video_compress.dart';

import '../../../../../../../core/widgets/GradientLoader.dart';
import '../../../../../../messages/presentation/messages/view/messages_page.dart';

class EditVideo extends StatefulWidget {
  final SendVideoParam sendVideoMessageParam;

  const EditVideo({
    super.key,
    required this.sendVideoMessageParam,
  });

  @override
  EditVideoState createState() => EditVideoState();
}

class EditVideoState extends State<EditVideo> {
  /// Max allowed video length; mirrors the 120s server-side rule.
  static const Duration _maxVideoDuration = Duration(seconds: 120);

  /// Max allowed upload size after compression (50 MB).
  static const int _maxUploadBytes = 50 * 1024 * 1024;

  /// Compression quality used for reel uploads.
  static const VideoQuality _compressionQuality = VideoQuality.MediumQuality;

  final Trimmer _trimmer = Trimmer();
  late TextEditingController subTitleController;
  StreamSubscription<TrimmerEvent>? _trimmerSubscription;

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _isTrimmerReady = false;
  bool _isProcessing = false;
  bool _progressVisibility = false;

  @override
  void initState() {
    super.initState();
    subTitleController = TextEditingController();
    _setupTrimmerListener();
    // Delay loadVideo to ensure TrimViewer widget is built and listening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVideo();
    });
  }

  void _setupTrimmerListener() {
    _trimmerSubscription = _trimmer.eventStream.listen((event) {
      if (event == TrimmerEvent.initialized && mounted) {
        Methods.printLog("TrimmerEvent.initialized received");
        setState(() {
          _isTrimmerReady = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _trimmerSubscription?.cancel();
    _trimmer.dispose();
    subTitleController.dispose();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    if (widget.sendVideoMessageParam.video == null) {
      Methods.printLog("Video file is null");
      return;
    }

    try {
      Methods.printLog(
          "Loading video: ${widget.sendVideoMessageParam.video!.path}");
      await _trimmer.loadVideo(videoFile: widget.sendVideoMessageParam.video!);
      Methods.printLog("loadVideo completed");
      // Note: _isTrimmerReady is set by the event stream listener
    } catch (e) {
      Methods.printLog("Error loading video: $e");
      if (mounted) {
        Methods.showToast(context,
            isError: true, message: 'Failed to load video');
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveVideo() async {
    if (!_isTrimmerReady) {
      Methods.showToast(context,
          isError: true, message: 'Please wait, video is still loading...');
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _progressVisibility = true;
    });

    try {
      await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        onSave: (String? outputPath) async {
          if (outputPath == null) {
            Methods.printLog("Video trimming failed - null output");
            if (mounted) {
              setState(() {
                _isProcessing = false;
                _progressVisibility = false;
              });
              Methods.showToast(context,
                  isError: true, message: 'Failed to process video');
            }
            return;
          }

          Methods.printLog("Video trimmed successfully: $outputPath");

          // Get video duration
          final duration = await _getVideoDuration(outputPath);

          // Check if duration exceeds limit
          if (duration != null &&
              duration.inSeconds > _maxVideoDuration.inSeconds) {
            if (mounted) {
              setState(() {
                _isProcessing = false;
                _progressVisibility = false;
              });
              Methods.showToast(context,
                  isError: true, message: StringManager.largeVideo.tr());
            }
            return;
          }

          // Handle reels vs messages
          if (widget.sendVideoMessageParam.isReels == true) {
            await _handleReelUpload(outputPath);
          } else {
            await _handleMessageUpload(outputPath, duration);
          }
        },
      );
    } catch (e, s) {
      Methods.printLog("Error saving video: $e\n$s");
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progressVisibility = false;
        });
        Methods.showToast(context,
            isError: true, message: 'Failed to process video');
      }
    }
  }

  Future<Duration?> _getVideoDuration(String videoPath) async {
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(File(videoPath));
      await controller.initialize();
      return controller.value.duration;
    } catch (e) {
      Methods.printLog("Error getting video duration: $e");
      return null;
    } finally {
      await controller?.dispose();
    }
  }

  Future<void> _handleReelUpload(String videoPath) async {
    File videoFile = File(videoPath);

    di<UploadReelBloc>()
        .add(const UpdateUploadStageEvent(UploadStage.compressing));

    try {
      final info = await VideoCompress.compressVideo(
        videoPath,
        quality: _compressionQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      if (info != null && info.file != null) {
        videoFile = info.file!;
      }
    } catch (e) {
      Methods.printLog("Video compression failed, uploading original: $e");
    }

    if (await videoFile.length() > _maxUploadBytes) {
      di<UploadReelBloc>().add(const ResetUploadStateEvent());
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progressVisibility = false;
        });
        Methods.showToast(context,
            isError: true, message: StringManager.largeVideo.tr());
      }
      return;
    }

    di<UploadReelBloc>().add(
      GetPreSignedUrlEvent(
        UploadReelParam(
          reel: videoFile,
          description: subTitleController.text,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _progressVisibility = false;
      });
      Navigator.pop(context);
    }
  }

  Future<void> _handleMessageUpload(
      String videoPath, Duration? duration) async {
    try {
      final int currentT = DateTime.now().millisecondsSinceEpoch;
      final String videoId =
          (widget.sendVideoMessageParam.userId ?? '') + currentT.toString();

      // Verify file exists
      if (!(await File(videoPath).exists())) {
        Methods.printLog("Video file not found: $videoPath");
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _progressVisibility = false;
          });
        }
        return;
      }

      // Generate first frame thumbnail for the optimistic bubble (carried into
      // the drift row via SendVideoMessagesEvent.firstFramePath).
      final File? firstFrame = await _getFirstFrameAsFile(File(videoPath));

      // Initialize app bar
      di<ToggleAppBarBloc>().add(const InitAppBarEvent());

      // Pop the screen
      if (mounted) {
        Navigator.pop(context);
      }

      // Hand off to the unified send path: SendVideoMessagesEvent pre-uploads the
      // bytes (with the progress ring) then registers through the same durable
      // outbox as text/image/voice. The optimistic bubble is written to drift by
      // ChatRepository.send (no AddMessageLocalEvent → no double bubble).
      Future.microtask(() {
        final key = MessageVideoWidgetState.currentTime[videoId] ?? currentT;
        MessageVideoWidgetState.videoProgressNotifier.value[key] = 0.01;
        MessageVideoWidgetState.currentTime[
        widget.sendVideoMessageParam.userId.toString() +
            currentT.toString()] = currentT;

        di<SendMessagesBloc>().add(
          SendVideoMessagesEvent(
            xFile: File(videoPath),
            duration: duration.toString(),
            userId: widget.sendVideoMessageParam.userId ?? '',
            chatId: widget.sendVideoMessageParam.chatId,
            firstFramePath: firstFrame?.path,
            videoId: videoId,
          ),
        );
      });
    } catch (e, s) {
      Methods.printLog("Error handling message upload: $e\n$s");
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progressVisibility = false;
        });
      }
    }
  }

  Future<File?> _getFirstFrameAsFile(File videoFile) async {
    try {
      if (videoFile.path.isEmpty || !(await videoFile.exists())) {
        Methods.printLog('Invalid video file path: ${videoFile.path}');
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = await FlutterVideoThumbnailPlus.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.png,
        maxHeight: 200,
        quality: 75,
      );

      return filePath != null ? File(filePath) : null;
    } catch (e) {
      Methods.printLog("Error generating thumbnail: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: ColorManager.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorManager.black,
        body: _buildEditor(),
      ),
    );
  }

  Widget _buildEditor() {
    return SafeArea(
      top: true,
      bottom: false,
      left: false,
      right: false,
      child: Stack(
        children: [
          // Video Player
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: VideoViewer(trimmer: _trimmer),
          ),

          // Loading indicator while trimmer initializes
          if (!_isTrimmerReady)
            Container(
              color: ColorManager.black,
              child: Center(
                child: GradientLoader(size: 32),
              ),
            ),

          // Play/Pause Button Overlay
          if (_isTrimmerReady) _buildPlayPauseOverlay(),

          // Controls Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close Button
              _buildCloseButton(),
              10.hBox,

              // Trim Editor
              _buildTrimEditor(),

              const Spacer(),

              // Send Button
              _buildSendSection(),
            ],
          ),

          // Processing Indicator
          if (_progressVisibility) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildPlayPauseOverlay() {
    return InkWell(
      onTap: () async {
        final bool playbackState = await _trimmer.videoPlaybackControl(
          startValue: _startValue,
          endValue: _endValue,
        );
        setState(() {
          _isPlaying = playbackState;
        });
      },
      child: Center(
        child: AnimatedOpacity(
          opacity: _isPlaying ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.4),
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 60.0.h,
              color: ColorManager.offWhite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      margin: context.paddingOnly(start: 25, top: 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.5),
      ),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.close_rounded,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }

  Widget _buildTrimEditor() {
    return Container(
      height: 80, // Fixed height to ensure visibility
      width: MediaQuery.of(context).size.width,
      padding: context.paddingSymmetric(horizontal: 20),
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: TrimViewer(
          trimmer: _trimmer,
          viewerHeight: 50.0,
          viewerWidth: MediaQuery.of(context).size.width - 40,
          maxVideoLength: _maxVideoDuration,
          type: ViewerType.fixed,
          durationStyle: DurationStyle.FORMAT_MM_SS,
          editorProperties: TrimEditorProperties(
            borderPaintColor: ColorManager.primary,
            borderWidth: 4,
            borderRadius: 5,
            circlePaintColor: ColorManager.primary,
          ),
          areaProperties: TrimAreaProperties.fixed(
            thumbnailQuality: 25,
          ),
          onChangeStart: (value) {
            _startValue = value;
          },
          onChangeEnd: (value) {
            _endValue = value;
          },
          onChangePlaybackState: (value) {
            setState(() {
              _isPlaying = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSendSection() {
    if (widget.sendVideoMessageParam.isReels == true) {
      return _buildReelsSendSection();
    } else {
      return _buildMessageSendSection();
    }
  }

  Widget _buildMessageSendSection() {
    return Center(
      child: ButtonWidget(
        isLoading: _isProcessing,
        onPressed: _isProcessing ? null : _saveVideo,
        padding: context.paddingSymmetric(horizontal: 30, vertical: 10),
        height: 70.h,
        title: StringManager.send.tr(),
        fontSize: 14,
        backgroundColor: _isProcessing
            ? ColorManager.primary.withValues(alpha: 0.5)
            : ColorManager.primary,
      ),
    );
  }

  Widget _buildReelsSendSection() {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenWidth * 0.175,
      child: Row(
        children: [
          10.wBox,
          Expanded(
            flex: 2,
            child: TextInputWidget(
              StringManager.addSomeData.tr(),
              textColor: ColorManager.offWhite,
              hintStyle: context.bodyMedium.colorExt(ColorManager.offWhite),
              controller: subTitleController,
              enabledBorder: OutlineInputBorder(
                borderRadius: 30.radius,
                borderSide:
                const BorderSide(width: 1.5, color: ColorManager.grey2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: 30.radius,
                borderSide:
                const BorderSide(width: 1.5, color: ColorManager.grey2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: 30.radius,
                borderSide: const BorderSide(
                    width: 1.5, color: ColorManager.redAccount),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: 30.radius,
                borderSide:
                const BorderSide(width: 1.5, color: ColorManager.grey2),
              ),
            ),
          ),
          10.wBox,
          Expanded(
            child: ButtonWidget(
              isLoading: _isProcessing,
              onPressed: _isProcessing ? null : _saveVideo,
              padding: context.paddingSymmetric(vertical: 10),
              height: 50.h,
              title: StringManager.send.tr(),
              backgroundColor: _isProcessing
                  ? ColorManager.primary.withValues(alpha: 0.5)
                  : ColorManager.primary,
              fontSize: 13,
            ),
          ),
          10.wBox,
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child:  Center(
        child: GradientLoader(size: 32),
      ),
    );
  }
}