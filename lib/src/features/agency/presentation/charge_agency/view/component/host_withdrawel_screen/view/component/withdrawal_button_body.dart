part of 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/host_withdrawel_screen.dart';

class WithdrawalButtonBody extends StatelessWidget {
  const WithdrawalButtonBody({
    super.key,
    required this.data,
    required this.onPressed,
  });

  final ShippingAgentsFullDataEntity data;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      onPressed: onPressed ??
          () {
            Navigator.pushNamed(
              context,
              Routes.withdrawalRequestScreen,
              arguments: data,
            );
          },
      title: StringManager.transfer.tr(),
      padding: context.paddingSymmetric(vertical: 2),
      paddingButton: context.paddingZero(),
      // width: ScreenUtil().screenWidth * 0.25,
      height: ScreenUtil().screenHeight * 0.035,
      radius: 20.r,
      backgroundColor: ColorManager.primary,
      isFittedBox: false,
      fontSize: 9,
    );
  }
}
