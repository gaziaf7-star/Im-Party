import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import '../controller/media_controller.dart';
import 'message_input_sheet.dart';

class UTDControlsBar extends StatelessWidget {
  final UTDMediaController? mediaController;
  final UTDChatController? chatController;
  final Widget? customWidget;

  const UTDControlsBar({
    super.key,
    this.mediaController,
    this.chatController,
    this.customWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (customWidget != null) return customWidget!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (chatController != null)
            _ControlButton(
              icon: Icons.chat_bubble_outline,
              color: Colors.white,
              onTap: () => UTDMessageInputSheet.show(context, chatController!),
            ),
          if (mediaController != null) ...[
            ValueListenableBuilder<bool>(
              valueListenable: mediaController!.isMicEnabled,
              builder: (_, isOn, __) => _ControlButton(
                icon: isOn ? Icons.mic : Icons.mic_off,
                color: isOn ? Colors.white : Colors.red,
                onTap: mediaController!.toggleMicrophone,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: mediaController!.isSpeakerOn,
              builder: (_, isOn, __) => _ControlButton(
                icon: isOn ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
                onTap: mediaController!.toggleSpeaker,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
