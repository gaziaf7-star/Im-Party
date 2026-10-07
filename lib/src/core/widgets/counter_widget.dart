import 'package:general/src/core/index.dart';

class CounterWidget extends StatelessWidget {
  const CounterWidget({
    super.key,
    this.rightPadding,
    this.padding,
    this.fontSize,
    this.topPadding,
    required this.child,
    required this.count,
     this.isMyProfile=true,
  });

  final Widget child;
  final String count;
  final double? rightPadding;
  final double? topPadding;
  final double? padding;
  final double? fontSize;
  final bool isMyProfile;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior: Clip.none,
      children: [
        child,
        if (count != '0'&&isMyProfile==true)
          Positioned(
            top: topPadding ?? 0,
            right: rightPadding ?? 0,
            child: Container(

              padding: context.paddingAll(padding ?? 5),
              decoration: BoxDecoration(
                color: ColorManager.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count,

                  style: context.bodySmall
                      .colorExt(ColorManager.textPrimary)
                      .size(fontSize ?? 12).copyWith(height: 0.0),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
