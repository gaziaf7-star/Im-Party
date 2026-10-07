import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/presentation/country/bloc/countries_bloc.dart';
import 'package:general/src/features/home/presentation/home/view/components/countries_dialog.dart';

import '../../../../../home/presentation/home/view/widgets/CountryFilterPage.dart';

class Theme2DiscoverFilterTabs extends StatelessWidget {
  const Theme2DiscoverFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      StringManager.theme2Broadcast.tr(),
      StringManager.theme2Party.tr(),
      StringManager.theme2Game.tr(),
      StringManager.theme2P.tr(),
      StringManager.theme2Singing.tr(),
    ];

    return Padding(
      padding: context.paddingSymmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          // Globe icon - opens country filter dialog
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
              padding: context.paddingSymmetric(horizontal: 8, vertical: 4),
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
                      Icon(Icons.arrow_drop_down,
                          color: ColorManager.iconColor, size: 16.h),
                      if (countryName != null && countryName.isNotEmpty) ...[
                        Text(
                          countryName,
                          style: TextStyle(
                            color: ColorManager.theme2TextPrimary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        2.wBox,
                      ],
                      Icon(Icons.public,
                          color: ColorManager.theme2AccentLight, size: 16.h),
                    ],
                  );
                },
              ),
            ),
          ),
          8.wBox,
          // Filter tabs
          Expanded(
            child: SizedBox(
              height: 30.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                reverse: true,
                itemCount: tabs.length,
                separatorBuilder: (_, __) => 8.wBox,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                    context.paddingSymmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: index == 0
                          ? ColorManager.theme2FilterActive
                          : ColorManager.theme2FilterBg,
                      borderRadius: 15.radius,
                    ),
                    child: Center(
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: ColorManager.theme2TextPrimary,
                          fontSize: 12.sp,
                          fontWeight:
                          index == 0 ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}