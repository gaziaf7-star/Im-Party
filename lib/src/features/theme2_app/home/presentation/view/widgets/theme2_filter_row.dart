import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/presentation/country/bloc/countries_bloc.dart';

import '../../../../../home/presentation/home/view/widgets/CountryFilterPage.dart';

class Theme2FilterRow extends StatefulWidget {
  final VoidCallback? onViewToggled;
  const Theme2FilterRow({super.key, this.onViewToggled});

  @override
  State<Theme2FilterRow> createState() => _Theme2FilterRowState();
}

class _Theme2FilterRowState extends State<Theme2FilterRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          // Globe + arrow - opens country filter dialog
          GestureDetector(
            onTap: () {
              // Was bottomDailog(CountriesDialog()) — a slide-up panel — now
              // a real full page (on request).
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CountryFilterPage(),
                ),
              );
            },
            child: Container(
              padding: context.paddingSymmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ColorManager.theme2FilterBg,
                borderRadius: 20.radius,
              ),
              child: BlocBuilder<CountriesBloc, CountriesState>(
                bloc: di<CountriesBloc>(),
                buildWhen: (prev, curr) =>
                prev.countryEntity != curr.countryEntity,
                builder: (context, state) {
                  final countryName = state.countryEntity != null
                      ? (Methods.getLang() == "ar"
                      ? Methods.safeText(state.countryEntity?.name)
                      : Methods.safeText(state.countryEntity?.nameEn))
                      : null;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_drop_down,
                        color: ColorManager.theme2TextPrimary,
                        size: 18.h,
                      ),
                      4.wBox,
                      if (countryName != null && countryName.isNotEmpty) ...[
                        Text(
                          countryName,
                          style: TextStyle(
                            color: ColorManager.theme2TextPrimary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        4.wBox,
                      ],
                      Icon(
                        Icons.public,
                        color: ColorManager.theme2AccentLight,
                        size: 18.h,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const Spacer(),
          // توصية label
          Text(
            StringManager.theme2Recommend.tr(),
            style: TextStyle(
              color: ColorManager.theme2TextPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}