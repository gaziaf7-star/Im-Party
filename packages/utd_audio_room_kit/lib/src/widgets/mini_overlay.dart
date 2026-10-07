import 'package:flutter/material.dart';

import '../controller/utd_room_controller.dart';

class UTDMiniPopScope extends StatelessWidget {
  final UTDRoomController? controller;
  final Widget child;

  const UTDMiniPopScope({
    super.key,
    this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (controller == null) return child;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (controller!.isConnected) {
          controller!.minimize.startMinimize(context);
        } else {
          Navigator.of(context).maybePop();
        }
      },
      child: child,
    );
  }
}
