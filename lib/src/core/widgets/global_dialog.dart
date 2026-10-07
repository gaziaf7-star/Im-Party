import 'package:general/src/core/index.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required Widget widget,
  bool? isFromRight,
}) {
  return showGeneralDialog(
    context: context,
    barrierLabel: "",
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 400),
    barrierColor: ConstantsManager.isTheme1
        ? ColorManager.transparent
        :ColorManager.black.withValues(alpha: 0.4),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return isFromRight == true
          ? fromRight(animation, secondaryAnimation, child)
          : fromBottom(animation, secondaryAnimation, child);
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: const Alignment(0, 1),
        child: Material(
          type: MaterialType.transparency,
          child: widget,
        ),
      );
    },
  );
}

fromBottom(Animation<double> animation, Animation<double> secondaryAnimation,
    Widget child) {
  return SlideTransition(
    position: Tween<Offset>(end: Offset.zero, begin: const Offset(0.0, 1.0))
        .animate(animation),
    child: child,
  );
}

fromRight(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}
