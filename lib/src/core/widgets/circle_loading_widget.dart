import 'package:general/src/core/index.dart';

import 'GradientLoader.dart';

class CircleLoadingWidget extends StatelessWidget {
  const CircleLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: GradientLoader(size: 25.h, strokeWidth: 2.0),
      ),
    );
  }
}