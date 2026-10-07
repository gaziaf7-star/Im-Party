
import '../../../../core/index.dart';

Future<dynamic> customModalBottomSheet(
    BuildContext context, {
      bool isDismissible = true,
      double? height,
      double? radius,
      required Widget child,
    }) {
  return showModalBottomSheet(
    context: context,
    clipBehavior: Clip.hardEdge,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radius??12.r),
        topRight: Radius.circular(radius??12.r),
      ),
    ),
    builder: (context) => SizedBox(
      height: height ?? ScreenUtil().screenHeight * 0.48,
      child: child,
    ),
  );
}