import 'package:flutter/material.dart';

bool isDialogOpen = false;

Future<void> bottomDailog({
  required BuildContext context,
  required Widget widget,
  Color? color,
  Color? barrierColor,
  double? height,
  bool barrierDismissible = true,
}) async {
  // One bottom dialog at a time. Rapid double taps previously stacked
  // multiple GeneralDialog overlay routes and could end in duplicate
  // _OverlayEntryWidgetState GlobalKeys while the first route was closing.
  if (isDialogOpen || !context.mounted) {
    return;
  }

  isDialogOpen = true;

  try {
    await showGeneralDialog<void>(
      context: context,
      barrierLabel: '',
      barrierDismissible: barrierDismissible,
      transitionDuration:
      const Duration(milliseconds: 260),
      barrierColor:
      barrierColor ??
          Colors.black.withValues(alpha: 0.3),
      useRootNavigator: false,
      transitionBuilder:
          (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        return fromBottom(
          animation,
          secondaryAnimation,
          child,
        );
      },
      pageBuilder:
          (
          dialogContext,
          animation,
          secondaryAnimation,
          ) {
        return SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: Material(
                type: MaterialType.transparency,
                child: widget,
              ),
            ),
          ),
        );
      },
    );
  } finally {
    isDialogOpen = false;
  }
}

Widget fromBottom(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    ) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    ),
    child: child,
  );
}
