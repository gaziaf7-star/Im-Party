import 'package:flutter/material.dart';

import '../ludo_room_controller.dart';

/// Fixed purple-to-magenta gradient shown behind the room while a Ludo game is
/// active. Fades in over the normal room background and out again afterwards.
class LudoAnimatedBackground extends StatelessWidget {
  const LudoAnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LudoRoomController.instance.activeNotifier,
      builder: (context, active, _) => IgnorePointer(
        child: AnimatedOpacity(
          opacity: active ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5E1B9E), Color(0xFF9C2A8E), Color(0xFF6A1B7A)],
              ),
            ),
            child: SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
