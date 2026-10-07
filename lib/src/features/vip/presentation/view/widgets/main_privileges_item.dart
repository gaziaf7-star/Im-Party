import 'package:general/src/features/vip/vip.dart';

class MainPrivilegesItem extends StatelessWidget {
  final String image1;
  final String image2;
  final String title;
  final bool isActive;
  const MainPrivilegesItem({
    super.key,
    required this.image2,
    required this.image1,
    required this.isActive,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Plain privilege icon — no card/background color behind it
        // anymore (on request: "frame ar kono bg color thakba nah"),
        // shown FULL size (not shrunk) and a bit bigger than before,
        // matching the reference image exactly. boxFit.contain (instead
        // of the widget's default .cover) so a non-square image — like
        // the wide chat-bubble frame — is never cropped, on request
        // ("chat babul ar image ta kata jassa... full vaba dhakba").
        ImageViewWidget(
          url: isActive ? image1 : image2,
          width: 56.w,
          height: 56.w,
          boxFit: BoxFit.contain,
          //color: ColorManager.primary,
        ),
        5.hBox,
        Padding(
          padding: context.paddingSymmetric(horizontal: 5),
          child: TextWidget(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.bodySmall.bold.colorExt(
              ColorManager.defaultTextVip,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}