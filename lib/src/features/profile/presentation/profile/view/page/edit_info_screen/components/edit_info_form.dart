part of '../edit_profile_screen.dart';

class EditInfoForm extends StatelessWidget {
  final MyDataEntity data;

  const EditInfoForm({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditInformationBloc, EditInformationState>(
      bloc: di<EditInformationBloc>(),
      buildWhen: (prev, curr) =>
      prev.image != curr.image ||
          prev.name != curr.name ||
          prev.bio != curr.bio ||
          prev.gender != curr.gender,
      builder: (context, state) {
        return Form(
          key: key,
          child: SingleChildScrollView(
            child: SizedBox(
              height: ScreenUtil().screenHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      di<EditInformationBloc>().add(AssignInformationEvent());
                      showDialog(
                        context: context,
                        builder: (_) => AnimatedDialog(
                          titleDivider: false,
                          isHideConfirm: true,
                          isUpdateDialog: false,
                          horizontalPadding: 45.w,
                          // Same white card + tighter radius as the cover
                          // photo dialog, for a consistent look.
                          dialogBackgroundColor: ColorManager.white,
                          radius: 12,
                          child: const _SelectImageDialog(
                            title: "",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: context.paddingSymmetric(
                          horizontal: 10, vertical: 20),
                      margin: context.paddingSymmetric(
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: ColorManager.white,
                        border: Border.all(
                            color: ColorManager.grey2.withValues(alpha: 0.3)),
                        borderRadius: 10.radius,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextWidget(
                              StringManager.changeProfilephoto.tr(),
                              style: context.bodyMedium
                                  .size(16)
                                  .colorExt(ColorManager.black),
                            ),
                          ),
                          5.wBox,
                          PickImageBody(
                            image: data.profile?.image ?? '',
                            bloc: di<EditInformationBloc>(),
                          ),
                          10.wBox,
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          )
                        ],
                      ),
                    ),
                  ),
                  // Cover photos: opens the dedicated cover management screen
                  // (add / change / delete), wired to the same backend field.
                  SizedBox(height: 10,),
                  GestureDetector(
                    onTap: () {
                      context.pushNamedRoute(
                        Routes.addMultiPicture,
                        arguments: false,
                      );
                    },
                    child: Container(
                      padding: context.paddingSymmetric(
                          horizontal: 10, vertical: 20),
                      margin: context.paddingSymmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: ColorManager.white,
                        border: Border.all(
                            color: ColorManager.grey2.withValues(alpha: 0.3)),
                        borderRadius: 10.radius,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextWidget(
                              StringManager.changeCover.tr(),
                              style: context.bodyMedium
                                  .size(16)
                                  .colorExt(ColorManager.black),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                    context.paddingSymmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RowEditInfo(
                          title: data.name,
                          isNeedTranslation: false,
                          hasTrailing: true,
                          subtitle: StringManager.username.tr(),
                          onTap: () {
                            di<EditInformationBloc>()
                                .add(AssignInformationEvent());
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16.0)),
                              ),
                              builder: (context) => EditInfoScreen(
                                params: EditProfileParameter(
                                  content: '${data.name}',
                                  isUsername: true,
                                ),
                              ),
                            );
                          },
                          trailing: '${data.name}',
                        ),
                        10.hBox,
                        _RowEditInfo(
                          title: data.profile?.gender == 1
                              ? StringManager.male.tr()
                              : data.profile?.gender == 0
                              ? StringManager.female.tr()
                              : '',
                          subtitle: StringManager.gender.tr(),
                          hasTrailing: true,
                          onTap: () {
                            Methods.showCupertinoGenderPicker(
                              context: context,
                              titleColor: ColorManager.black,
                              pickerTextColor: ColorManager.black,
                              onChanged: (value) {
                                di<EditInformationBloc>().add(
                                  SelectedGenderEvent(
                                    gender: value == 0
                                        ? StringManager.male.tr()
                                        : StringManager.female.tr(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        10.hBox,
                        _RowEditInfo(
                          hasTrailing: true,
                          title: data.profile?.birthday ?? '',
                          onTap: () {
                            di<EditInformationBloc>()
                                .add(AssignInformationEvent());

                            DateTime selectedDateTime = data
                                .profile?.birthday ==
                                null ||
                                data.profile?.birthday == ''
                                ? DateTime.now()
                                : DateTime.parse('${data.profile?.birthday}');

                            Methods.showCupertinoDatePicker(
                              context: context,
                              initialDateTime: selectedDateTime,
                              titleColor: ColorManager.black,
                              pickerTextColor: ColorManager.black,
                              onConfirm: () {
                                final formattedDate = DateFormat('yyyy-MM-dd')
                                    .format(selectedDateTime);
                                if (Methods.isUserUnder18(selectedDateTime)) {
                                  Methods.showToast(
                                    context,
                                    message: StringManager.userUnder18.tr(),
                                    isError: true,
                                  );
                                } else {
                                  di<EditInformationBloc>().add(
                                    EditInformationEvent(date: formattedDate),
                                  );
                                }

                                Navigator.pop(context);
                              },
                              onDateTimeChanged: (value) {
                                selectedDateTime = value;
                              },
                            );
                          },
                          subtitle: StringManager.birthDay.tr(),
                        ),
                        10.hBox,
                        BlocBuilder<CountriesBloc, CountriesState>(
                          bloc: di<CountriesBloc>(),
                          buildWhen: (prev, curr) =>
                          prev.requestState != curr.requestState ||
                              prev.countryEntity != curr.countryEntity ||
                              prev.countries != curr.countries,
                          builder: (context, state) {
                            return _RowEditInfo(
                              isFlagIcon: true,
                              hasTrailing: true,
                              title: MyDataModel.getInstance().country?.photo ??
                                  '',
                              onTap: () {
                                (state.countryEntity == null &&
                                    state.countries.isNotEmpty)
                                    ? di<CountriesBloc>().add(
                                  SelectedCountryEvent(
                                    countryId: '',
                                    countryEntity: state.countries[0],
                                  ),
                                )
                                    : null;
                                Methods.showCupertinoCountriesPicker(
                                  context: context,
                                  isFirstOpen: true,
                                  titleColor: ColorManager.black,
                                  onChanged: (value) {
                                    di<CountriesBloc>().add(
                                      SelectedCountryEvent(
                                        countryId: '',
                                        countryEntity: state.countries[value],
                                      ),
                                    );
                                  },
                                  children: List.generate(
                                      state.countries.length, (index) {
                                    return TextWidget(
                                      state.countries[index].name ?? "",
                                      style: context.bodyLarge
                                          .colorExt(ColorManager.primary),
                                    );
                                  }),
                                );
                              },
                              subtitle: StringManager.country_,
                            );
                          },
                        ),
                        10.hBox,
                        _RowEditInfo(
                          hasTrailing: true,
                          title: (data.bio),
                          subtitle: StringManager.status.tr(),
                          trailing: '',
                          onTap: () {
                            di<EditInformationBloc>()
                                .add(AssignInformationEvent());
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16.0)),
                              ),
                              builder: (context) => EditInfoScreen(
                                  params: EditProfileParameter(
                                    content: '${data.bio}',
                                    isUsername: false,
                                  )),
                            );
                            //   Navigator.pushNamed(
                            //   context,
                            //   Routes.editProfileNameOrBio,
                            //   arguments: EditProfileParameter(
                            //     content: '${data.bio}',
                            //     isUsername: false,
                            //   ),
                            // );
                          },
                        ),
                      ],
                    ),
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