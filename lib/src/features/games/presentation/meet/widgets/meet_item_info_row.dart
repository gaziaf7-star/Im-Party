import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';

class MeetItemInfoRow extends StatelessWidget {
  const MeetItemInfoRow(
      {super.key, required this.name, required this.bio, required this.image});

  final String? name;
  final String? bio;
  final String? image;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserImage(
          image: image ?? '',
          displayName: name ?? '',
          imageSize: 55.h,
        ),
        10.wBox,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                name ?? '',
                style: context.bodyLarge.colorExt(ColorManager.textPrimary),
              ),
              TextWidget(
                bio ?? '',
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium
                    .colorExt(ColorManager.greyTextColor.withValues(alpha: (0.7 ))),
              ),
            ],
          ),
        ),
        // const Spacer(),
        Container(
          padding: context.paddingAll(3),
          decoration: BoxDecoration(
            color: ColorManager.primary,
            borderRadius: 20.radius,
          ),
          child: Row(
            children: [
              ShowSVGA(
                svgaAssetPath: AssetsManager.hiMeetUser,
                height: 20.h,
                width: 20.w,

              ),
              3.wBox,
              TextWidget(
                StringManager.sayHi.tr(),
                style: context.bodyMedium.w400.colorExt(ColorManager.buttonTextColor),
              ),
              2.wBox,
            ],
          ),
        ),
      ],
    );
  }
}
