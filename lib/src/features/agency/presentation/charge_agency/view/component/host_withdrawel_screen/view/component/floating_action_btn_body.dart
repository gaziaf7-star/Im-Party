part of 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/host_withdrawel_screen.dart';

class FloatingActionBtnBody extends StatelessWidget {
  const FloatingActionBtnBody({super.key, required this.bloc});

  final GetShippingAgentsFullDataModelBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: ColorManager.primary,
        borderRadius: 30.radius,
      ),
      child: IconButton(
        icon: Image.asset(
          AssetsManager.searchIcon,
          scale: 3,
          color: ColorManager.white,
        ),
        // const Icon(
        //   CupertinoIcons.search,
        //   color: ColorManager.white,
        // ),
        onPressed: () => bloc.add(
          const GetAgentsFullData(
            param: FetchShippingAgentsFullDataModelParam(
              countryId:
              //CountriesOuterBodyState.country.value.id ??
                  0,
              paymentId:
          //    PaymentBodyState.payment.value.id ??
                  0,
            ),
          ),
        ),
      ),
    );
  }
}
