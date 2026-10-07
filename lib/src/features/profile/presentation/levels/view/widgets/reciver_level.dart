part of '../level_page.dart';

class ReciverLevel extends StatelessWidget {
  const ReciverLevel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingAll(20),
      margin: context.paddingOnly(start: 12,end: 12,top: 12),

      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: 15.radius,
        boxShadow: [
          BoxShadow(
            color: ColorManager.grey.withValues(alpha: (0.1 )),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              TextWidget(
                StringManager.anchorLevel.tr(),
                style: context.bodyLarge,
              ),
              4.wBox,
              LevelContainer(
                // width: 59.w,
                // height: 26.h,
                image: MyDataModel.getInstance().level?.receiverImage,
              ),
            ],
          ),
          10.hBox,
          Padding(
            padding: context.paddingAll(20),
            child: CircularPercentIndicator(
              curve: Curves.ease,
              animateFromLastPercent: true,
              addAutomaticKeepAlive: true,
              progressColor: ColorManager.primary,
              backgroundColor: ColorManager.levelColor,
              percent:MyDataModel.getInstance().level?.reciverPer?? 0.0 ,
              radius: 55.r,
              lineWidth: 14.w,
              center: TextWidget(
                  "${((MyDataModel.getInstance().level?.reciverPer ?? 0.0) * 100).toInt()}%",
                  style: context.bodyMedium),
            ),
          ),
          10.hBox,
          TextWidget(
              "${StringManager.incomeLevel.tr()} ${MyDataModel.getInstance().level?.reciverNum}",
              style: context.bodyMedium),
          TextWidget(
            StringManager.levelUnplaced.tr(),
            style: context.bodyMedium,
          ),
          TextWidget(
              "${StringManager.textRecevierLevel.tr()} ${MyDataModel.getInstance().level?.nextReciverNum}${StringManager.coinsLevel.tr()}",
              style: context.bodyMedium)
        ],
      ),
    );
  }
}
