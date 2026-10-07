
import 'package:general/src/core/index.dart';

import '../../../../domain/entities/replace_with_gold_entity.dart';

class RechargeDiamondsItem extends StatelessWidget {
  final ReplaceWithGoldItemEntity? diamondEntity;

  const RechargeDiamondsItem({required this.diamondEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
          height: 50.h,
          margin: context.paddingSymmetric(vertical: 5),
          padding: context.paddingSymmetric(horizontal: 5, vertical: 5),
          decoration: ColorManager.cardDecoration(
            borderRadius: 5.radius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    5.wBox,
                  Image.asset(
                    AssetsManager.diamondsIcon,
                    scale: 3,
                  ),
                 5.wBox,
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(minWidth: 5.w, maxWidth: 180.w),
                    child: TextWidget(
                      diamondEntity?.diamonds.toString()?? "diamond",
                      overflow: TextOverflow.ellipsis,
          
                      style: context.bodyMedium.size(15).w500. colorExt(
                        ColorManager.textTabBar,
          
                      ),
                    ),
                  ),
                  5.wBox,
                  TextWidget(
                    StringManager.diamonds.tr(),
                    style:context.bodyMedium.size(11).w400. colorExt(
                        ColorManager.greyText,
          
                      ),
                    
                     
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 65.w,
                height: 25.h,
                padding:
                    context.paddingSymmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                    color: ColorManager.pink, borderRadius: 10.radius),
                child: Center(
                  child: TextWidget(
                    '${diamondEntity?.coin??1} ${StringManager.coins.tr()}',
                    style: context .bodyMedium.w500.size(10).colorExt(ColorManager.textPrimary),
                  ),
                ),
              )
            ],
          ),
        );
     
  }
}
