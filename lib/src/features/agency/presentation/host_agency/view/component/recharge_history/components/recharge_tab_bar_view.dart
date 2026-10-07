part of 'package:general/src/features/agency/presentation/host_agency/view/component/recharge_history/recharge_history_page.dart';

class RechargeHistoryTabBarView extends StatelessWidget {
  final List<UserGoogleCoinsHistoryEntity>? googleCoinsHistoryModelList;
  final List<UerChargeCoinsHistoryEntity>? receivedCoinsHistoryModelList;
  final bool isGoogle;
  final Future<void> Function() onRefresh;

  const RechargeHistoryTabBarView({
    this.googleCoinsHistoryModelList,
    this.receivedCoinsHistoryModelList,
    required this.isGoogle,
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicatorWidget(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: isGoogle
              ? List.generate(
                  googleCoinsHistoryModelList?.length ?? 0,
                  (__) => GoogleCoinsRechargeHistoryItem(
                    coinsHistoryModel: googleCoinsHistoryModelList?[__] ??
                        const UserGoogleCoinsHistoryEntity(),
                  ),
                  growable: true,
                )
              : List.generate(
                  receivedCoinsHistoryModelList?.length ?? 0,
                  (__) => ReceivedCoinsRechargeHistoryItem(
                    uerChargeCoinsHistoryModel:
                        receivedCoinsHistoryModelList?[__] ??
                            const UerChargeCoinsHistoryEntity(),
                  ),
                  growable: true,
                ),
        ),
      ),
    );
  }
}
