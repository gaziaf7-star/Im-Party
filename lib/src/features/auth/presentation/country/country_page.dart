import 'dart:developer';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/chats/chats.dart';

import '../../../profile/presentation/profile/view/page/edit_info_screen/bloc/edit_information/edit_information_bloc.dart';

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({
    super.key,
    this.isEditProfile = false,
  });

  final bool isEditProfile;

  static ValueNotifier<int?> countryId = ValueNotifier<int?>(null);

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  static const Color _black = Color(0xFF111111);
  static const Color _subText = Color(0xFF6B6B72);
  static const Color _fieldBg = Color(0xFFF7F7F8);
  static const Color _border = Color(0xFFE7E7EA);

  late final TextEditingController searchController;
  final CountriesBloc _countriesBloc = di<CountriesBloc>();

  String _query = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();

    if (!_countriesBloc.state.requestState.isLoaded) {
      _countriesBloc.add(const FetchCountriesEvent());
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<CountryEntity> _filteredCountries(
      List<CountryEntity> source,
      ) {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) return source;

    return source.where((country) {
      final name = (country.name ?? '').toLowerCase();
      return name.contains(query);
    }).toList();
  }

  void _saveCountry() {
    if (widget.isEditProfile == true) {
      di<EditInformationBloc>().add(
        const EditInformationEvent(),
      );
      return;
    }

    if (CountriesScreen.countryId.value != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.addInformation,
            (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocBuilder<CountriesBloc, CountriesState>(
        bloc: _countriesBloc,
        buildWhen: (prev, curr) =>
        prev.requestState != curr.requestState ||
            prev.countries != curr.countries,
        builder: (context, state) {
          final visibleCountries = _filteredCountries(
            state.countries,
          );

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBarWidget(
              isShowBack: false,
              title: StringManager.country.tr(),
              backgroundColor: Colors.white,
              shadow: Colors.transparent,
              iconColor: _black,
              titleStyle: context.titleLarge
                  .size(19)
                  .bold
                  .colorExt(_black),
            ),
            body: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      18.w,
                      10.h,
                      18.w,
                      0,
                    ),
                    child: TextWidget(
                      StringManager.selectCountry.tr(),
                      style: context.bodyLarge
                          .size(18)
                          .bold
                          .colorExt(_black),
                    ),
                  ),
                  6.hBox,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),
                    child: TextWidget(
                      StringManager
                          .pleaseInputCountryName
                          .tr(),
                      style: context.bodyMedium
                          .size(13)
                          .colorExt(_subText),
                    ),
                  ),
                  16.hBox,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),
                    child: TextField(
                      controller: searchController,
                      cursorColor: _black,
                      style: TextStyle(
                        color: _black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: StringManager.search.tr(),
                        hintStyle: TextStyle(
                          color: Colors.black.withValues(
                            alpha: 0.38,
                          ),
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.black.withValues(
                            alpha: 0.52,
                          ),
                          size: 21.h,
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.black.withValues(
                              alpha: 0.52,
                            ),
                            size: 19.h,
                          ),
                        ),
                        filled: true,
                        fillColor: _fieldBg,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 14.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(16.r),
                          borderSide: const BorderSide(
                            color: _border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(16.r),
                          borderSide: const BorderSide(
                            color: _border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(16.r),
                          borderSide: const BorderSide(
                            color: _black,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  14.hBox,
                  Expanded(
                    child: HandlingDataWidget(
                      reqState: state.requestState,
                      title: StringManager.noCountries.tr(),
                      subTitle:
                      StringManager.noCountriesSubTitle.tr(),
                      onTap: () {
                        _countriesBloc.add(
                          const FetchCountriesEvent(),
                        );
                        log('countries_retry');
                      },
                      child: visibleCountries.isEmpty
                          ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: TextWidget(
                            StringManager.noCountries.tr(),
                            textAlign: TextAlign.center,
                            style: context.bodyMedium
                                .size(14)
                                .colorExt(_subText),
                          ),
                        ),
                      )
                          : ListView.separated(
                        physics:
                        const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          14.w,
                          0,
                          14.w,
                          18.h,
                        ),
                        itemCount:
                        visibleCountries.length,
                        separatorBuilder: (_, __) =>
                        8.hBox,
                        itemBuilder: (context, index) {
                          return _buildCountryCard(
                            country:
                            visibleCountries[index],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18.w,
                  10.h,
                  18.w,
                  14.h,
                ),
                child: ValueListenableBuilder<int?>(
                  valueListenable:
                  CountriesScreen.countryId,
                  builder:
                      (context, selectedCountryId, _) {
                    final enabled =
                        widget.isEditProfile ||
                            selectedCountryId != null;

                    return AnimatedOpacity(
                      duration:
                      const Duration(milliseconds: 160),
                      opacity: enabled ? 1 : 0.45,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap:
                            enabled ? _saveCountry : null,
                            borderRadius:
                            BorderRadius.circular(25.r),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: _black,
                                borderRadius:
                                BorderRadius.circular(
                                  25.r,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(
                                      alpha: 0.12,
                                    ),
                                    blurRadius: 14.r,
                                    offset: Offset(
                                      0,
                                      5.h,
                                    ),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: TextWidget(
                                  StringManager.save.tr(),
                                  style: context.bodyMedium
                                      .size(15)
                                      .bold
                                      .colorExt(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountryCard({
    required CountryEntity country,
  }) {
    return ValueListenableBuilder<int?>(
      valueListenable: CountriesScreen.countryId,
      builder: (context, selectedCountryId, _) {
        final isSelected =
            selectedCountryId == country.id;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              CountriesScreen.countryId.value =
                  country.id;
            },
            borderRadius: BorderRadius.circular(16.r),
            child: AnimatedContainer(
              duration:
              const Duration(milliseconds: 170),
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 11.h,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF3F3F4)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected
                      ? _black
                      : _border,
                  width: isSelected ? 1.2 : 1,
                ),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.035,
                      ),
                      blurRadius: 9.r,
                      offset: Offset(0, 3.h),
                    ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: _fieldBg,
                      borderRadius:
                      BorderRadius.circular(12.r),
                    ),
                    child: ImageViewWidget(
                      url: EndPoints.getImage(
                        country.photo,
                      ),
                    ),
                  ),
                  12.wBox,
                  Expanded(
                    child: TextWidget(
                      country.name ?? '',
                      isTranslate: false,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: context.bodyMedium
                          .size(14)
                          .w600
                          .colorExt(_black),
                    ),
                  ),
                  10.wBox,
                  AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 170,
                    ),
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? _black
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? _black
                            : Colors.black
                            .withValues(
                          alpha: 0.22,
                        ),
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16.h,
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
