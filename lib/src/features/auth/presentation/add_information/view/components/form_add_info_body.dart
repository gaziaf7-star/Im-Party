part of 'package:general/src/features/auth/presentation/add_information/view/add_information_page.dart';

// Requested brand gradient for this screen only: the submit button and every
// "selected" state (country picker highlight, focused field underline) share
// it, so the whole page reads as one coherent accent instead of mixing the
// old ColorManager.primary/green with a new brand pair.
const List<Color> _kBrandGradient = [Color(0xFFEA088C), Color(0xFFA51DF5)];

class _FormAddInfoBody extends StatelessWidget {
  const _FormAddInfoBody({required this.state});

  final AddInformationState state;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.formKey,
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            5.hBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  StringManager.uploadPicture.tr(),
                  textAlign: TextAlign.center,
                  style: context.bodySmall.w500
                      .colorExt(_kTextDark)
                      .size(14),
                ),
                _PickImageBody(
                  state: state,
                ),
              ],
            ),
            10.hBox,
            TextInputWidget(
              label: TextWidget(
                StringManager.fullName.tr(),
                style: context.bodyLarge.colorExt(_kTextDark),
              ),
              border: const UnderlineInputBorder(
                borderSide:
                BorderSide(color: ColorManager.transparent),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFA51DF5), width: 1.4),
              ),
              errorBorder: InputBorder.none,
              textColor: _kTextDark,
              // Fixed dark hint (was the panel-driven secondaryText default).
              hintStyle: context.bodyLarge.colorExt(_kTextDark),
              StringManager.fullName.tr(),
              controller: state.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return StringManager.requiredField.tr();
                }
                return null;
              },
            ),
            /*  GenderPickerWidget(
              controller: state.gender,
              onChanged: (int value) => context.read<AddInformationBloc>().add(
                    SelectedGenderEvent(
                      gender: value == 0
                          ? StringManager.male.tr()
                          : StringManager.female.tr(),
                    ),
                  ),
            ),*/
            20.hBox,
            // Country. Collected here because the home feed filters rooms by
            // the OWNER's country_id -- an account created without one is
            // invisible to every country tab.
            _CountryField(state: state),
            20.hBox,
            DatePickerWidget(
              controller: state.birthday,
              dateTime: state.birthday.text.isNotEmpty
                  ? DateTime.parse(
                Methods().convertNumerals(state.birthday.text,
                    toEnglish: true),
              )
                  : null,
              // Fixed dark text (was the panel-driven textPrimary), matching
              // the Name/Country fields on this page.
              textColor: _kTextDark,
              // Brand accent (was a mismatched plain green), matching the
              // Name/Country fields' focus color on this page.
              accentColor: const Color(0xFFA51DF5),
              onDateTimeChanged: (value) => context
                  .read<AddInformationBloc>()
                  .add(SelectedBirthdayEvent(dateTime: value)),
            ),
            30.hBox,
            TextWidget(
              StringManager.gender.tr(),
              style: context.bodySmall.w500
                  .colorExt(_kTextDark)
                  .size(14),
            ),
            10.hBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.read<AddInformationBloc>().add(
                      SelectedGenderEvent(
                        gender: StringManager.male.tr(),
                      ),
                    ),
                    child: state.gender.text == StringManager.male.tr()
                        ? Container(
                      decoration: BoxDecoration(
                          borderRadius: 10.radius,
                          gradient: const LinearGradient(
                              colors: ColorManager.maleContainer)),
                      padding: context.paddingSymmetric(
                        vertical: 12,
                        horizontal: 13,
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              ImageWidget(
                                  height: 20.h,
                                  width: 20.w,
                                  image: AssetsManager.genderMale),
                              5.wBox,
                              TextWidget(
                                StringManager.male.tr(),
                                style: context.bodyMedium
                                    .size(15)
                                    .copyWith(color: ColorManager.onDark),
                              ),
                            ],
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: 17.r,
                            backgroundColor: Colors.white,
                            child: Image.asset(
                                height: 30.h,
                                width: 30.w,
                                AssetsManager.manInfo),
                          ),
                        ],
                      ),
                    )
                        : Container(
                      decoration: BoxDecoration(
                        borderRadius: 10.radius,
                        // Light grey (was the dark ColorManager.inactiveColor)
                        // so black text stays readable, matching the rest of
                        // this page's fixed-dark-text-on-light look.
                        color: const Color(0xFFF1F1F3),
                      ),
                      padding: context.paddingSymmetric(
                        vertical: 12,
                        horizontal: 13,
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              ImageWidget(
                                  height: 20.h,
                                  width: 20.w,
                                  image: AssetsManager.genderMale),
                              5.wBox,
                              TextWidget(
                                StringManager.male.tr(),
                                style: context.bodyMedium
                                    .size(15)
                                    .copyWith(color: _kTextDark),
                              ),
                            ],
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: 17.r,
                            backgroundColor: Colors.white,
                            child: ColorFiltered(
                                colorFilter: const ColorFilter.matrix([
                                  0.2126,
                                  0.7152,
                                  0.0722,
                                  0,
                                  0,
                                  0.2126,
                                  0.7152,
                                  0.0722,
                                  0,
                                  0,
                                  0.2126,
                                  0.7152,
                                  0.0722,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                ]),
                                child: Image.asset(
                                    height: 30.h,
                                    width: 30.w,
                                    AssetsManager.manInfo)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                10.wBox,
                Expanded(
                  child: GestureDetector(
                      onTap: () => context.read<AddInformationBloc>().add(
                        SelectedGenderEvent(
                          gender: StringManager.female.tr(),
                        ),
                      ),
                      child: state.gender.text == StringManager.female.tr()
                          ? Container(
                        decoration: BoxDecoration(
                            borderRadius: 10.radius,
                            gradient: const LinearGradient(
                                colors: ColorManager.femaleContainer)),
                        padding: context.paddingSymmetric(
                          vertical: 12,
                          horizontal: 13,
                        ),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(-1.0, 1.0), // انعكاس أفقي
                                  child: ImageWidget(
                                      height: 20.h,
                                      width: 20.w,
                                      image:
                                      AssetsManager.genderFemale),
                                ),
                                5.wBox,
                                TextWidget(
                                  StringManager.female.tr(),
                                  style: context.bodyMedium
                                      .size(15)
                                      .copyWith(
                                      color: ColorManager.onDark),
                                ),
                              ],
                            ),
                            const Spacer(),
                            CircleAvatar(
                              radius: 17.r,
                              backgroundColor: Colors.white,
                              child: ImageWidget(
                                  height: 30.h,
                                  width: 30.w,
                                  image: AssetsManager.women),
                            ),
                          ],
                        ),
                      )
                          : Container(
                        decoration: BoxDecoration(
                          // Light grey (was the dark ColorManager.inactiveColor)
                          // so black text stays readable, matching the male
                          // pill and the rest of this page.
                          color: const Color(0xFFF1F1F3),
                          borderRadius: 10.radius,
                        ),
                        padding: context.paddingSymmetric(
                          vertical: 12,
                          horizontal: 13,
                        ),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(-1.0, 1.0), // انعكاس أفقي
                                  child: ImageWidget(
                                      height: 20.h,
                                      width: 20.w,
                                      image:
                                      AssetsManager.genderFemale),
                                ),
                                5.wBox,
                                TextWidget(
                                  StringManager.female.tr(),
                                  style: context.bodyMedium
                                      .size(15)
                                      .copyWith(
                                      color: _kTextDark),
                                ),
                              ],
                            ),
                            const Spacer(),
                            CircleAvatar(
                              radius: 17.r,
                              backgroundColor: Colors.white,
                              child: ColorFiltered(
                                  colorFilter: const ColorFilter.matrix([
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    1,
                                    0,
                                  ]),
                                  child: Image.asset(
                                      height: 30.h,
                                      width: 30.w,
                                      AssetsManager.women)),
                            ),
                          ],
                        ),
                      )),
                ),
              ],
            ),
            70.hBox,
            Align(
              alignment: Alignment.center,
              child: ButtonWidget(
                title: StringManager.submit.tr(),
                height: 55.h,
                width: 200.w,
                elevation: 0,
                backgroundColors: _kBrandGradient,
                // Explicit white (was the panel-driven buttonTextColor,
                // which could resolve dark and read poorly on this vivid
                // gradient) so the label always stays clearly legible.
                titleColor: Colors.white,
                isLoading: state.requestState.isLoading,
                onPressed: () {
                  if (state.image == null) {
                    Methods.showToast(context,
                        message: StringManager.pickImage.tr(), isError: true);
                  } else if (state.name.text.isEmpty) {
                    Methods.showToast(context,
                        message: StringManager.username.tr(), isError: true);
                  } else if (state.gender.text.isEmpty) {
                    Methods.showToast(context,
                        message: StringManager.selectGender.tr(), isError: true);
                  } else if (state.birthday.text.isEmpty) {
                    Methods.showToast(context,
                        message: StringManager.selectBirthday.tr(), isError: true);
                  } else if (state.birthday.text.isNotEmpty) {
                    if (Methods.isUserUnder18(DateTime.parse(
                      Methods().convertNumerals(state.birthday.text,
                          toEnglish: true),
                    ))) {
                      Methods.showToast(context,
                          message: StringManager.userUnder18.tr(),
                          isError: true);
                    } else {
                      context
                          .read<AddInformationBloc>()
                          .add(AddInformationEvent(context: context));
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Country picker for the registration form.
///
/// Reads the REAL backend country list via [CountriesBloc] (the same source
/// the phone-registration `CountriesScreen` uses), so the id it stores is a
/// genuine backend country id.
///
/// This used to read `LocalCountries.all` instead -- that list is built
/// purely for the offline home/explore country FILTER and its own doc
/// comment says its `id` is "a deterministic int derived from the ISO2 code"
/// (A=1..Z=26, l1*100+l2), NOT a real backend id. Submitting one of those
/// synthetic ids as `country_id` here made `/profile/update` reject the
/// whole request with a generic, untranslated validation error for any
/// country whose synthetic id didn't happen to collide with a real one --
/// reproduced with Nigeria (synthetic id 1407) and Uzbekistan (2126), both
/// rejected; nothing about the rest of the form was ever the problem.
class _CountryField extends StatelessWidget {
  const _CountryField({required this.state});

  final AddInformationState state;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: state.country,
          readOnly: true,
          style: context.bodyMedium.colorExt(_kTextDark),
          decoration: InputDecoration(
            labelText: StringManager.country.tr(),
            labelStyle: context.bodySmall
                .w500
                .colorExt(_kTextDark)
                .size(14),
            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
                color: ColorManager.secondaryText),
            enabledBorder: UnderlineInputBorder(
              borderSide:
              BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFA51DF5), width: 1.4),
            ),
          ),
          validator: (value) => (value == null || value.isEmpty)
              ? StringManager.requiredField.tr()
              : null,
        ),
      ),
    );
  }

  /// Country picker, redone as a proper "select" sheet instead of a plain
  /// scrolling list: white card with a drag handle + title + close button,
  /// a live search field, and the currently-picked country highlighted with
  /// the page's brand gradient (matching the submit button) so the selected
  /// state is obvious at a glance.
  void _pick(BuildContext context) {
    final bloc = context.read<AddInformationBloc>();
    final countriesBloc = di<CountriesBloc>();
    if (!countriesBloc.state.requestState.isLoaded) {
      countriesBloc.add(const FetchCountriesEvent());
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        final searchController = TextEditingController();
        return BlocBuilder<CountriesBloc, CountriesState>(
          bloc: countriesBloc,
          buildWhen: (prev, curr) =>
              prev.requestState != curr.requestState ||
              prev.countries != curr.countries,
          builder: (context, countriesState) {
            final countries = countriesState.countries;
            return StatefulBuilder(
          builder: (context, setSheetState) {
            final query = searchController.text.trim().toLowerCase();
            final filtered = query.isEmpty
                ? countries
                : countries
                .where((c) =>
                (c.name ?? '').toLowerCase().contains(query))
                .toList();

            return SizedBox(
              height: MediaQuery.sizeOf(sheetContext).height * 0.75,
              child: Column(
                children: [
                  10.hBox,
                  // Drag handle.
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  16.hBox,
                  Padding(
                    padding: context.paddingSymmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          StringManager.country.tr(),
                          style: context.bodyMedium.bold
                              .size(18)
                              .colorExt(_kTextDark),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(sheetContext),
                          child: Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18.sp,
                              color: ColorManager.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  14.hBox,
                  Padding(
                    padding: context.paddingSymmetric(horizontal: 20),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setSheetState(() {}),
                      style: context.bodyMedium.colorExt(_kTextDark),
                      decoration: InputDecoration(
                        hintText: StringManager.search.tr(),
                        hintStyle:
                        context.bodySmall.colorExt(ColorManager.secondaryText),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: ColorManager.secondaryText, size: 20.sp),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F7),
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  14.hBox,
                  Expanded(
                    child: countriesState.requestState.isLoading &&
                            countries.isEmpty
                        ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : filtered.isEmpty
                        ? Center(
                      child: TextWidget(
                        StringManager.noResults.tr(),
                        style: context.bodySmall
                            .colorExt(ColorManager.secondaryText),
                      ),
                    )
                        : ListView.separated(
                      padding: context.paddingSymmetric(
                          horizontal: 12, vertical: 4),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => 4.hBox,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        final bool isSelected =
                            state.country.text == (c.name ?? '');
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                              colors: _kBrandGradient,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                                : null,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            leading: Text(
                              LocalCountries.flagEmoji(c.iso),
                              style: const TextStyle(fontSize: 22),
                            ),
                            title: TextWidget(
                              c.name ?? '',
                              style: context.bodyMedium.colorExt(
                                isSelected ? Colors.white : _kTextDark,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded,
                                color: Colors.white)
                                : null,
                            onTap: () {
                              bloc.add(SelectedCountryInfoEvent(
                                countryId: c.id ?? 0,
                                countryName: c.name ?? '',
                              ));
                              Navigator.pop(sheetContext);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
          },
        );
      },
    );
  }
}