part of '../bill_page.dart';

class BillItemRow extends StatelessWidget {
  const BillItemRow({super.key, required this.billEntityList});

  final BillEntity billEntityList;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 0, vertical: 15),
      margin: context.paddingAll(5),
      decoration: ColorManager.cardDecoration(
          borderRadius: 5.radius,
          border: Border.all(width: 1, color: ColorManager.whiteGrey5)),
      child: Row(
        children: [
          Image.asset(
            AssetsManager.starCoinsIcon,
           height: 37.h,
           width: 56.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                '${StringManager.successfulOperation.tr()} :${billEntityList.operationNum}',
                style: context.bodyMedium.w500
                    .size(12)
                    .colorExt(ColorManager.textTabBar),
              ),
              12.hBox,
              TextWidget(
                billEntityList.createdAt,
                style: context.bodySmall.colorExt(ColorManager.whiteGrey4),
              ),
            ],
          ),
          const Spacer(),
          TextWidget(
            billEntityList.diamonds.toString(),
            style: context.bodyMedium.w600
                .colorExt(ColorManager.appBarTitlegrey)
                .size(13),
                
          ),
          10.wBox
        ],
      ),
    );
  }
}
