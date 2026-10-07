import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/top.dart';

class ItemSupportCardWidget extends StatelessWidget {
  final Top? userTopEntity;
  final String frameImage;

  final bool? isUpper;

  const ItemSupportCardWidget({
    this.userTopEntity,
    required this.frameImage,
    this.isUpper,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (userTopEntity != null && userTopEntity!.id != 0) {
              Methods().userProfileNavigator(
                context: context,
                userId: '${userTopEntity?.id}',
              );
            }
          },
          child: UserImage(
            image: '${userTopEntity?.image}',
            displayName: userTopEntity?.name ?? '',
            frame: frameImage,
            imageSize: 75.w,
            uniquId: '${userTopEntity?.id}',
            frameSize: 125.w,
            isAsset: true,
            boxFit: BoxFit.cover,
          ),
        ),
        SizedBox(
          width: 104.w,

          child: IntrinsicHeight(
            child: SizedBox(
              width: 120.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  10.hBox,
                  Flexible(
                    child: TextWidget(
                      userTopEntity?.name ?? '',
                      style: context.bodyMedium.colorExt(ColorManager.textPrimary).size(14),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  5.hBox,
                  if ((userTopEntity?.total ?? '') != '')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWidget(
                          userTopEntity?.total ?? '0',
                          style: context.bodyMedium
                              .colorExt(ColorManager.orange),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        5.wBox,
                        ImageWidget(
                          height: 20.h,
                          width: 20.w,
                          image: AssetsManager.coinsVip,
                        )
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
