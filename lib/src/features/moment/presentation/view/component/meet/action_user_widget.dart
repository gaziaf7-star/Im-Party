import 'package:general/src/core/index.dart';

class ActionUserWidget extends StatelessWidget {
  const ActionUserWidget({
    super.key,
    this.width,
    this.height,
    this.borderColor,
    this.bgColor,
    required this.icon,
    this.iconColor,
    required this.onTap,
    this.reqState = RequestState.idle,
    this.padding,
  });
  final double? height, width, padding;
  final Color? bgColor;
  final Color? borderColor;
  final Color? iconColor;
  final IconData icon;
  final VoidCallback onTap;
  final RequestState reqState;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height?.h ?? 50.h,
        width: width?.w ?? 50.h,
        decoration: BoxDecoration(
          // color: ColorManager.white,
          borderRadius: 100.radius,
        ),
        child: Container(
          padding: context.paddingAll(padding ?? 10),
          decoration: BoxDecoration(
            color: bgColor ?? ColorManager.white,
            borderRadius: 100.radius,
            border: Border.all(
                color: borderColor ?? bgColor ?? ColorManager.white, width: 1),
          ),
          child: reqState.isLoading
              ? const LoadingWidget(
                  color: ColorManager.black,
                )
              : Icon(
                  icon,
                  size: 25.h,
                  color: iconColor,
                ),
        ),
      ),
    );
  }
}
