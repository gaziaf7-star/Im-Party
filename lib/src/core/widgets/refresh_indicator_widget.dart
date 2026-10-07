import 'package:general/src/core/index.dart';

class RefreshIndicatorWidget extends StatelessWidget {
  const RefreshIndicatorWidget({
    super.key,
    required this.onRefresh,
    required this.child,
  });
  final Future<void> Function() onRefresh;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    // Flutter's RefreshIndicator only accepts a flat Color (no Gradient
    // support), so this uses the darker brand-gradient stop as the closest
    // match to the app's new professional spinner styling everywhere else.
    return RefreshIndicator.adaptive(
      strokeWidth: 2.0,
      color: ColorManager.brandGradientColors.last,
      backgroundColor: ColorManager.white,
      onRefresh: onRefresh,
      child: child,
    );
  }
}