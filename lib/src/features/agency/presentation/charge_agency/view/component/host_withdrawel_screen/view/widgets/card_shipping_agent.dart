part of 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/host_withdrawel_screen.dart';

class CardShippingAgent extends StatelessWidget {
  final ShippingAgentsFullDataEntity shippingAgentsFullDataEntity;
  final bool isDollarsValue;
  final void Function()? withdrawelOnPressed;
  final bool stopTransferButton;
  final bool? isFromSearchScreens;

  const CardShippingAgent(
      {super.key,
        required this.shippingAgentsFullDataEntity,
        this.withdrawelOnPressed,
        required this.isDollarsValue,
        required this.stopTransferButton,
        this.isFromSearchScreens});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        di<GetChargeAgencyBloc>().add(
          GetChargeAgencyEvent(
              agencyId: shippingAgentsFullDataEntity.id, isFirstLoading: true),
        );
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return ShowShippingAgency(
              agencyData: null,
              isProfile: true,
              id: shippingAgentsFullDataEntity.id,
            );
          },
        ));
      },
      child: Container(
        margin: context.paddingSymmetric(
          vertical: 3,
        ),
        padding: context.paddingSymmetric(
          horizontal: 5,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: 15.radius,
          border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: ColorManager.black.withValues(alpha: 0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                if (isFromSearchScreens == false) {
                  Methods().userProfileNavigator(
                    context: context,
                    userId: shippingAgentsFullDataEntity.ownerId.toString(),
                  );
                }
              },
              child: UserImage(
                image: shippingAgentsFullDataEntity.image ?? '',
                displayName: shippingAgentsFullDataEntity.name ?? '',
                boxFit: BoxFit.cover,
                borderRadius: 50.radius,
                imageSize: 54.r,
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            10.wBox,
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 170.w),
                  child: Text(
                    shippingAgentsFullDataEntity.name ?? '',
                    style:
                    context.bodyMedium.w700.size(14).colorExt(ColorManager.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IdWithCopyIcon(
                    userId: shippingAgentsFullDataEntity.id.toString(),
                    isNeedCopyIcon: true,
                    isSpecial: (shippingAgentsFullDataEntity.specialId != '' &&
                        (shippingAgentsFullDataEntity.specialId ?? '') != ''),
                    specialImg: shippingAgentsFullDataEntity.idImage ?? '',
                    color: shippingAgentsFullDataEntity.imageColorEntity?.color,
                    img: shippingAgentsFullDataEntity.imageColorEntity?.image,
                    mainAxisAlignment: MainAxisAlignment.start,
                    idColor: ColorManager.black,
                    idStyle: context.bodyMedium.size(11).w500.colorExt(
                        ColorManager.black)),
                Text(
                  '${StringManager.successfulOperation.tr()}: ${shippingAgentsFullDataEntity.chargeCount}',
                  style: context.bodyMedium.w400
                      .size(14)
                      .colorExt(ColorManager.black),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (shippingAgentsFullDataEntity
                        .paymentGetaway?.isNotEmpty ==
                        true)
                      PaymentGetawaysBody(
                        payments:
                        shippingAgentsFullDataEntity.paymentGetaway ?? [],
                      ),
                    5.wBox,
                    if (shippingAgentsFullDataEntity.countries?.isNotEmpty ==
                        true)
                      CountriesBody(
                        countries: shippingAgentsFullDataEntity.countries ?? [],
                      ),
                  ],
                ),
              ],
            ),
            const Spacer(
              flex: 5,
            ),
            SizedBox(
              width: ScreenUtil().screenWidth * 0.20,
              child: Column(
                children: [
                  if (shippingAgentsFullDataEntity.ownerId !=
                      MyDataModel.getInstance().id)
                    CommunicationButtonBody(
                      data: shippingAgentsFullDataEntity,
                      isFromSearchScreens: isFromSearchScreens,
                    ),
                  if (!stopTransferButton &&
                      (isDollarsValue ||
                          ((
                              // shippingAgentsFullDataEntity.id !=
                              //     MyDataModel.getInstance().id &&
                              shippingAgentsFullDataEntity.ownerId !=
                                  MyDataModel.getInstance().id)))) ...[
                    5.hBox,
                    WithdrawalButtonBody(
                      data: shippingAgentsFullDataEntity,
                      onPressed: withdrawelOnPressed,
                    ),
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}