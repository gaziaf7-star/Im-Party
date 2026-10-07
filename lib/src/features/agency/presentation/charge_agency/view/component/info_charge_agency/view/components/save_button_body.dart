part of 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/view/info_charge_agency_screen.dart';

class SaveButtonBody extends StatelessWidget {
  const SaveButtonBody({
    super.key,
    required this.bloc,
    required this.state,
  });

  final UpdateChargeAgencyBloc bloc;
  final GetChargeAgencyStates state;

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      onPressed: () {
        if (di<UpdateChargeAgencyBloc>().state.selectedCountries.isNotEmpty ||
            di<UpdateChargeAgencyBloc>().state.selectedPayments.isNotEmpty ||
            (di<UpdateChargeAgencyBloc>().state.pathImg.isNotEmpty)) {
          bloc.add(
            UpdateChargeAgencyEvent(
              context: context,
              agencyId:
                  di<GetChargeAgencyBloc>().state.myChargeAgencyData?.id ?? 0,
            ),
          );
        } else {
          Methods.showToast(context,
              isError: true, message: StringManager.addSomeData2);
        }
      },
      title: StringManager.save.tr(),
      height: 55.h,
      width: 200.w,
      elevation: 0,
      backgroundColor: ColorManager.primary,
    );
  }
}
