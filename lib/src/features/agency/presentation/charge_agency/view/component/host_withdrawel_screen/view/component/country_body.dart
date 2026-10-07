part of 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/host_withdrawel_screen.dart';

class CountriesBody extends StatelessWidget {
  const CountriesBody({super.key, required this.countries});
  final List<CountryEntity> countries;
  @override
  Widget build(BuildContext context) {
    final int itemCount = countries.length > 4 ? 4 : countries.length;

    return Column(
      children: [
        TextWidget(
          StringManager.availableCountries.tr(),
          style: context.bodyMedium.size(7).w600,
        ),
        5.hBox,
        SizedBox(
          width: _width(itemCount),
          height: 30.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < itemCount; i++)
                Positioned(
                  left: i * 8.w * 1.4,
                  child: CountryIcon(
                    country: countries[i].photo ?? '',
                    imageSize: 10 * 2.5.w,
                    borderRadius: 15.radius,
                    boxFit: BoxFit.fill,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  double _width(int count) {
    if (count == 1) {
      return 10 * 4;
    } else if (count == 2) {
      return 10 * 5.5;
    } else if (count >= 3) {
      return 10 * 7;
    } else {
      return 0;
    }
  }
}
