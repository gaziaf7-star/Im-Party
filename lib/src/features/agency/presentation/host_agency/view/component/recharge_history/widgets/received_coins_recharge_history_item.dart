part of 'package:general/src/features/agency/presentation/host_agency/view/component/recharge_history/recharge_history_page.dart';

class ReceivedCoinsRechargeHistoryItem extends StatelessWidget {
  final UerChargeCoinsHistoryEntity uerChargeCoinsHistoryModel;

  const ReceivedCoinsRechargeHistoryItem(
      {required this.uerChargeCoinsHistoryModel, super.key});

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
          (uerChargeCoinsHistoryModel.sender?.img == null ||
                  uerChargeCoinsHistoryModel.sender?.img == '')
              ? const SizedBox()
              : ImageViewWidget(
                  url: (uerChargeCoinsHistoryModel.sender!.img) ?? '',
                  height: 20.h,
                  width: 20.w,
                ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                StringManager.receivedNumber(
                        uerChargeCoinsHistoryModel.coins.toString())
                    .tr(),
                style: context.bodyMedium.w600.size(14),
              ),
              TextWidget(
                Methods().formatDateTime(
                    dateTime: uerChargeCoinsHistoryModel.time ?? ''),
                style: context.bodyMedium.w400
                    .size(12)
                    .colorExt(ColorManager.secondaryText),
              ),
            ],
          ),
          const Spacer(
            flex: 10,
          ),
          TextWidget('\$${uerChargeCoinsHistoryModel.usd}'),
          const Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}
