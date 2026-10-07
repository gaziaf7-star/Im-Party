import 'package:general/src/core/index.dart';

class VipContainer extends StatelessWidget {
  final String? vip;
  final int? level;
  final BoxFit? boxFit;
  final double? height;
  final double? width;
  final bool isComment;

  const VipContainer({
    this.vip,
    super.key,
    this.boxFit,
    this.height,
    this.width,
    this.isComment = false,
    this.level,
  });

  @override
  Widget build(BuildContext context) {
    return vip == null || (vip ?? '').isEmpty
        ? const SizedBox()
        : ImageViewWidget(
            url: vip ?? "",
            width: width ?? 35.w,
            height: height ?? 18.h,
            boxFit: boxFit ?? BoxFit.fill,
            radius: 20,
          );
  }
}
