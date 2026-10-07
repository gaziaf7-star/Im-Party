import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../controller/utd_room_controller.dart';
import '../models/minimize_config.dart';
import '../theme/utd_room_theme.dart';
import 'live_avatar_waves.dart';

/// Compact, view-only content rendered inside the Android system PiP window
/// while [UTDRoomController.pip] reports `isInPip == true`.
///
/// Live composition is "host video only": full-bleed host camera
/// ([UTDMinimizeConfig.hostIdentity]) when on, otherwise a placeholder. The OS
/// ignores touches in a PiP window, so there are no buttons here.
class UTDPipView extends StatelessWidget {
  final UTDRoomController controller;

  const UTDPipView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final config = controller.minimize.config;
    final hostId = config?.hostIdentity;

    // Rebuild when the host's track / camera / speaking state changes.
    final listenable = Listenable.merge([
      controller.roomManager.videoTracksNotifier,
      controller.cameraOnParticipants,
      controller.activeSpeakers,
      controller.mediaController.isCameraEnabled,
      controller.mediaController.isPreviewing,
    ]);

    return Material(
      color: Colors.black,
      child: AnimatedBuilder(
        animation: listenable,
        builder: (context, _) {
          final showVideo = config?.showHostVideoInMini ?? true;
          final track = hostId == null ? null : controller.cameraTrackFor(hostId);
          final on = hostId != null && controller.cameraOnFor(hostId);
          if (showVideo && on && track != null) {
            return VideoTrackRenderer(track, fit: VideoViewFit.cover);
          }
          return _placeholder(context, config, hostId);
        },
      ),
    );
  }

  Widget _placeholder(
      BuildContext context, UTDMinimizeConfig? config, String? hostId) {
    if (config?.videoPlaceholderBuilder != null) {
      return config!.videoPlaceholderBuilder!(context);
    }
    final roomImage = config?.roomImage;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (roomImage != null && roomImage.isNotEmpty)
          Image.network(
            roomImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
          ),
        const ColoredBox(color: Color(0x73000000)),
        // Camera off: host profile image + sound waves.
        if (hostId != null)
          Center(
            child: UTDAvatarWaves(
              url: controller.avatarUrlFor(hostId),
              name: controller.displayNameFor(hostId),
              size: 64,
              theme: const UTDRoomTheme(),
              isSpeaking: controller.activeSpeakers.value.contains(hostId),
            ),
          )
        else
          const Center(
            child: Icon(Icons.videocam_off, color: Colors.white70, size: 32),
          ),
      ],
    );
  }
}
