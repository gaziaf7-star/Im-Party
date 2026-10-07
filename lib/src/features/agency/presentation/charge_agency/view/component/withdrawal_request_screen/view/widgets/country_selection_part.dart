import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

class CountrySelectionPart extends StatelessWidget {
  final List<CountryEntity> countryList;

  const CountrySelectionPart({required this.countryList, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendWithdrawalRequestBloc, SendWithdrawalRequestState>(
      bloc: di<SendWithdrawalRequestBloc>(),
      buildWhen: (prev, curr) => prev.country != curr.country,
      builder: (context, state) {
        return InkWell(
          onTap: () {
            state.country == null
                ? di<SendWithdrawalRequestBloc>()
                    .add(CountrySelectEvent(country: countryList[0]))
                : null;

            Methods.showCupertinoCountriesPicker(
              context: context,
              isFirstOpen: true,
              onChanged: (value) {
                di<SendWithdrawalRequestBloc>()
                    .add(CountrySelectEvent(country: countryList[value]));
              },
              children: List.generate(
                countryList.length,
                (index) {
                  return TextWidget(
                    countryList[index].name ?? "",
                    style: context.bodyLarge,
                  );
                },
              ),
            );
          },
          child: Container(
            width: ScreenUtil().screenWidth,
            padding: context.paddingSymmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ColorManager.grayMain.withValues(
                    alpha: (0.2),
                  ),
                ),
              ),
            ),
            child: TextWidget(
              ((di<SendWithdrawalRequestBloc>().state.country?.name ?? '') !=
                      '')
                  ? (di<SendWithdrawalRequestBloc>().state.country?.name ?? "")
                  : StringManager.chooseMoneyCountry.tr(),
              style: context.bodyLarge.colorExt(
                ColorManager.secondaryText,
              ),
            ),
          ),
        );
      },
    );
  }
}
