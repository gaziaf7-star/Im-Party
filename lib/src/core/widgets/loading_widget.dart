import 'package:general/src/core/index.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.color, this.size});
  final Color? color;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size?.h ?? 25.h,
        width: size?.h ?? 25.h,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor:
          AlwaysStoppedAnimation<Color>(color ?? ColorManager.white),
        ),
      ),
    );
  }
}