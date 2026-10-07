part of 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/view/info_charge_agency_screen.dart';

class CountrySelectionBody extends StatelessWidget {
  // final GetChargeAgencyStates? state;
  final bool isWithdrawalScreen;
  final List<CountryEntity> countriesList;

  const CountrySelectionBody({
    super.key,
    this.isWithdrawalScreen = false,
    this.countriesList = const [],
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateChargeAgencyBloc, UpdateChargeAgencyState>(
      bloc: di<UpdateChargeAgencyBloc>(),
      buildWhen: (prev, curr) => prev.showCountries != curr.showCountries,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                di<UpdateChargeAgencyBloc>().add(const ShowCountriesEvent());
              },
              child: Container(
                width: ScreenUtil().screenWidth,
                padding: context.paddingSymmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: (0.2))))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextWidget(
                          StringManager.chooseMoneyCountry.tr(),
                          style: context.bodySmall
                              .colorExt(
                                ColorManager.secondaryText,
                              )
                              .size(12),
                        ),
                        const Spacer(),
                        ...List.generate(
                          ((di<GetChargeAgencyBloc>()
                                          .state
                                          .data
                                          ?.countries
                                          ?.length ??
                                      0) <
                                  4)
                              ? di<GetChargeAgencyBloc>()
                                      .state
                                      .data
                                      ?.countries
                                      ?.length ??
                                  0
                              : 4,
                          (index) {
                            final String country = di<GetChargeAgencyBloc>()
                                    .state
                                    .data
                                    ?.countries?[index]
                                    .photo ??
                                '';
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: UserImage(
                                image: country,
                                imageSize: 25,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    di<UpdateChargeAgencyBloc>().state.showCountries == true
                        ? const ChooseCountryDropDown()
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
