import 'package:general/src/core/index.dart';

class LiveCard extends StatelessWidget {
  final String roomImage;
  final String roomName;
  final String roomType;

  const LiveCard(
      {required this.roomImage,
      required this.roomName,
      required this.roomType,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ImageViewWidget(
      width: 120.w,
      height: 120.w,
      padding: context.paddingAll(10),
      url: roomImage,
      displayName: roomName,
      radius: 15.r,
      boxFit: BoxFit.fill,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                AssetsManager.soundIcon,
                height: 17.sp,
                width: 20.sp,
              ),
              if (roomType != '')
                Container(
                  padding: EdgeInsets.all(5.sp),
                  decoration: BoxDecoration(
                    color: ColorManager.grey.withValues(alpha: (0.5)),
                    borderRadius: BorderRadius.all(Radius.circular(10.sp)),
                  ),
                  child: Center(
                    child: TextWidget(
                      roomType,
                      style: context.bodyMedium
                          .size(8)
                          .colorExt(ColorManager.textPrimary),
                    ),
                  ),
                )
            ],
          ),
          TextWidget(
            roomName,
            style: context.bodyMedium
                .size(14)
                .colorExt(ColorManager.textPrimary)
                .w600,
          )
        ],
      ),
    );
  }
}
