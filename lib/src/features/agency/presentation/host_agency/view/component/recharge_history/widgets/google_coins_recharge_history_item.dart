

part of 'package:general/src/features/agency/presentation/host_agency/view/component/recharge_history/recharge_history_page.dart';

class GoogleCoinsRechargeHistoryItem extends StatelessWidget {
  final UserGoogleCoinsHistoryEntity coinsHistoryModel;

  const GoogleCoinsRechargeHistoryItem({required this.coinsHistoryModel, super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: context.paddingAll(10),
      margin: context.paddingSymmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorManager.primary,
        ),
        borderRadius: 20.radius,
      ),
      child: Row(
        children: [
          Image.asset(
            AssetsManager.mallCoin,
            scale: 1.1,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                StringManager.purchasedNumber(coinsHistoryModel.coins.toString()).tr(),
                style: context.bodyMedium.size(14).w600,
              ),
              TextWidget(
                Methods()
                    .formatDateTime(dateTime: coinsHistoryModel.date ?? ''),
                style:  context.bodyMedium.size(12).w400.colorExt(ColorManager.textPrimary),
              ),
            ],
          ),
          const Spacer(
            flex: 10,
          ),
          TextWidget('\$${coinsHistoryModel.usd}'),
          const Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}
