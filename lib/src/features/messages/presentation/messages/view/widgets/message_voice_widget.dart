part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class _MessageVoiceWidget extends StatelessWidget {
  const _MessageVoiceWidget({
    required this.entity,
    required this.params,
    required this.isLastMessage,
  });

  final MessagesEntity entity;
  final MessagesParameter params;
  final bool isLastMessage;

  @override
  Widget build(BuildContext context) {
    final bool isMe = Methods.isMe('${entity.userId}');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // No per-message avatar in 1:1 chats (groups-only affordance).
        10.wBox,
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: !isMe && isLastMessage
                    ? 10.radius.copyWith(bottomLeft: 0.radiusCircular)
                    : isMe && isLastMessage
                    ? 10.radius.copyWith(bottomRight: 0.radiusCircular)
                    : 10.radius,
                // Brand gradient for my bubble; fixed white for theirs (was
                // primary/surfaceCardColor — flat panel-driven colors).
                color: isMe ? null : ColorManager.white,
                gradient: isMe ? ColorManager.brandGradient : null,
              ),
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.end,
                children: [
                  if (entity.replay != null)
                    _ReplayWidget(
                      entity: entity,
                      isMe: isMe,
                      params: params,
                    ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: entity.replay == null
                          ? 4.radius
                          : BorderRadius.only(
                        bottomLeft: 6.radiusCircular,
                        bottomRight: 6.radiusCircular,
                      ),
                      // color: isMe
                      //     ? ColorManager.secondaryColor.withValues(alpha:0.6)
                      //     : const Color(0xFFCC6600),
                    ),
                    child: _VoiceBody(
                      url: entity.albums?.isLocal == true
                          ? entity.albums?.file ?? ""
                          : EndPoints.getImage(entity.albums?.file),
                      createAt: entity.createdAt,
                      isMe: isMe,
                      isLocal: (entity.albums?.isLocal ?? false),
                    ),
                  ),
                  //3.hBox,
                  _SeenWidget(entity: entity),
                  3.hBox,
                ],
              ),
            ),
            entity.reacts == null
                ? const SizedBox.shrink()
                : _EmojisWidget(isMe: isMe, entity: entity),
          ],
        ),
        // No per-message avatar in 1:1 chats (groups-only affordance).
        10.wBox,
      ],
    );
  }
}

class _VoiceBody extends StatefulWidget {
  const _VoiceBody({
    required this.url,
    required this.isMe,
    this.isLocal = false,
    this.createAt,
  });
  final String url;
  final String? createAt;
  final bool isLocal, isMe;

  @override
  State<_VoiceBody> createState() => _VoiceBodyState();
}

class _VoiceBodyState extends State<_VoiceBody> {
  late VoiceController _controller;

  @override
  void initState() {
    _controller = VoicePlayerManager().voiceCtrl(widget.url, widget.isLocal);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _VoiceBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      // Release the OLD entry through the manager so the static map drops it
      // (calling _controller.dispose() directly would strand a disposed
      // controller in the cache, handed out on the next lookup of that URL).
      VoicePlayerManager().disposeCtrl(oldWidget.url);
      _controller = VoicePlayerManager().voiceCtrl(widget.url, widget.isLocal);
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Tie the cached controller's lifetime to the on-screen bubble; without
    // this the manager's static map grows unbounded for the whole session
    // (native audio + file handles never freed).
    VoicePlayerManager().disposeCtrl(widget.url);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.none,
      alignment: widget.isMe
          ? AlignmentDirectional.topStart
          : AlignmentDirectional.topEnd,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: 10.radiusCircular,
          topRight: 10.radiusCircular,
        ),
        child: VoiceMessageView(
          // Fixed brand purple / white player background per side (was
          // primary/dark-green flat colors); every accent below now switches
          // with it so nothing goes invisible on the "their" white side.
          notActiveSliderColor: widget.isMe
              ? ColorManager.onBrandGradient.withValues(alpha: 0.35)
              : ColorManager.momentPostTextColor.withValues(alpha: 0.2),
          backgroundColor: widget.isMe
              ? ColorManager.brandGradientColors.last
              : ColorManager.white,
          circlesColor: widget.isMe
              ? ColorManager.onBrandGradient
              : ColorManager.brandGradientColors.last,
          activeSliderColor: widget.isMe
              ? ColorManager.onBrandGradient
              : ColorManager.brandGradientColors.last,
          counterTextStyle: context.bodySmall.copyWith(
            color: widget.isMe
                ? ColorManager.onBrandGradient
                : ColorManager.momentPostTextColor,
          ),
          circlesTextStyle: context.bodySmall.copyWith(
            color: widget.isMe
                ? ColorManager.onBrandGradient
                : ColorManager.momentPostTextColor,
          ),
          playPauseButtonLoadingColor: widget.isMe
              ? ColorManager.onBrandGradient
              : ColorManager.brandGradientColors.last,
          playIcon: Icon(
            Icons.play_arrow_rounded,
            color: widget.isMe
                ? ColorManager.onBrandGradient
                : ColorManager.momentPostTextColor,
          ),
          pauseIcon: Icon(
            Icons.pause_rounded,
            color: widget.isMe
                ? ColorManager.onBrandGradient
                : ColorManager.momentPostTextColor,
          ),
          refreshIcon: Icon(
            Icons.refresh,
            color: widget.isMe
                ? ColorManager.onBrandGradient
                : ColorManager.momentPostTextColor,
          ),
          controller: _controller,
          innerPadding: 2.h,
          cornerRadius: 0.r,
        ),
      ),
    );
  }
}

class VoicePlayerManager {
  static final VoicePlayerManager _instance = VoicePlayerManager._internal();

  factory VoicePlayerManager() => _instance;

  VoicePlayerManager._internal();

  final Map<String, VoiceController> _controllers = {};

  VoiceController voiceCtrl(String url, bool isFile) {
    if (_controllers.containsKey(url)) {
      return _controllers[url]!;
    }

    final controller = VoiceController(
      audioSrc: url,
      isFile: isFile,
      maxDuration: const Duration(seconds: 60),
      onComplete: () {},
      onPause: () {},
      onPlaying: () async {
        for (var entry in _controllers.entries) {
          if (entry.key != url && entry.value.isPlaying) {
            await entry.value.stopPlaying();
          }
        }
      },
    );

    _controllers[url] = controller;
    controller.init();

    return controller;
  }

  Future<void> stopAll() async {
    for (var controller in _controllers.values) {
      if (controller.isPlaying) {
        await controller.stopPlaying();
      }
    }
  }

  Future<void> disposeCtrl(String url) async {
    if (_controllers.containsKey(url)) {
      final controller = _controllers[url];
      if (controller != null) {
        if (controller.isInit || controller.isPlaying) {
          await controller.stopPlaying();
        }
        await controller.dispose();
      }
      _controllers.remove(url);
    }
  }

  Future<void> disposeAll() async {
    for (var controller in _controllers.values) {
      await controller.stopPlaying();
      await controller.dispose();
    }
    _controllers.clear();
  }
}