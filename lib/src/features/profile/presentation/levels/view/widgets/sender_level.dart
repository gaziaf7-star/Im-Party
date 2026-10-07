part of '../level_page.dart';

class SenderLevel extends StatelessWidget {
  const SenderLevel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingAll(30),
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
              TextWidget(StringManager.userLevel.tr(), style: context.bodyLarge),
              4.wBox,
              //Todo: image of sender_Level
              LevelContainer(
                // width: 59.w,
                // height: 26.h,
                image: MyDataModel.getInstance().level?.senderImage,
              ),
            ],
          ),
          10.hBox,
          Padding(
            padding: context.paddingAll(20),
            child: CircularPercentIndicator(
              backgroundColor: ColorManager.levelColor,
              percent:MyDataModel.getInstance().level?.senderPer?? 0.0 ,
              radius: 55.r,
              lineWidth: 14.w,
              animateFromLastPercent: true,
              addAutomaticKeepAlive: true,
              progressColor: ColorManager.primary,
              curve: Curves.ease,
              center: TextWidget(

                  "${((MyDataModel.getInstance().level?.senderPer ?? 0.0) * 100).toInt()}%",
                  style: context.bodyMedium),
            ),
          ),
          10.hBox,
          TextWidget(
              "${StringManager.consumptionLevel.tr()} ${MyDataModel.getInstance().level?.senderNum}",
              style: context.bodyMedium),

          TextWidget(StringManager.levelUnplaced.tr(),
              style: context.bodyMedium),
          TextWidget(
              "${StringManager.textLevel.tr()} ${MyDataModel.getInstance().level?.nextSenderNum}${StringManager.coinsLevel.tr()}",
              style: context.bodyMedium)
        ],
      ),
    );
  }
}
