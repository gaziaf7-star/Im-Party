part of '../edit_profile_screen.dart';

class EditInfoScreen extends StatelessWidget {
  const EditInfoScreen({super.key, required this.params});

  final EditProfileParameter params;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditInformationBloc, EditInformationState>(
      bloc: di<EditInformationBloc>(),
      buildWhen: (prev, curr) => prev.formKey != curr.formKey || prev.name != curr.name || prev.bio != curr.bio || prev.isSaveButtonActive != curr.isSaveButtonActive,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0.sp)),
          ),
          child: Form(
            key: state.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      params.isUsername
                          ? StringManager.changeTheUsername.tr()
                          : StringManager.editPersonalizedSignature.tr(),
                      style: context.bodyMedium.bold
                          .colorExt(ColorManager.black)
                          .size(18),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorManager.lightGray1,
                          borderRadius: 5.radius,
                        ),
                        height: 25,
                        width: 25,
                        child: const Icon(
                          Icons.close,
                          color: ColorManager.grayMain,
                        ),
                      ),
                    ),
                  ],
                ),
                10.hBox,
                TextWidget(
                  params.isUsername
                      ? StringManager.username.tr()
                      : StringManager.status.tr(),
                  style: context.bodyMedium.bold
                      .size(14)
                      .colorExt(ColorManager.black),
                ),
                Form(
                  key: key,
                  child: TextInputWidget(
                    '', // params.isUsername
                    //     ? StringManager.nickname.tr()
                    //     : StringManager.personalizedSignature.tr(),
                    title: params.isUsername
                        ? StringManager.nickname.tr()
                        : StringManager.personalizedSignature.tr(),
                    onChanged: (text) {
                      di<EditInformationBloc>().add(
                        ActiveSaveButtonEvent(isUserName: params.isUsername),
                      );
                    },
                    maxLines: params.isUsername ? 1 : 2,
                    maxLength: params.isUsername ? 30 : 200,
                    showMaxLength: true,
                    minLines: 1,
                    contentPadding: EdgeInsets.zero,
                    border: const UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: ColorManager.primary, width: 1),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: ColorManager.primary, width: 1),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: ColorManager.primary, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: ColorManager.primary, width: 1),
                    ),
                    controller: params.isUsername ? state.name : state.bio,
                    validator: (value) {
                      // return null;
                      if (value == null || value.isEmpty == true) {
                        return StringManager.requiredField.tr();
                      } else {
                        return null;
                      }
                    },
                    hintStyle: context.bodyMedium.w400.colorExt(
                      ColorManager.secondaryText,
                    ),
                    textColor: ColorManager.black,
                    fillColor: ColorManager.white,
                  ),
                ),
                20.hBox,
                Align(
                  alignment: Alignment.bottomRight,
                  child: AbsorbPointer(
                    absorbing: state.isSaveButtonActive == true ? false : true,
                    child: GestureDetector(
                      onTap: () {
                        if (state.formKey.currentState?.validate() == false) {
                          return;
                        } else {
                          di<EditInformationBloc>().add(
                            const EditInformationEvent(),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.isSaveButtonActive
                              ? ColorManager.primary
                              : ColorManager.lightGray1,
                        ),
                        padding: context.paddingAll(12),
                        child: const Icon(Icons.check,
                            color: ColorManager.white, size: 28.0),
                      ),
                    ),
                  ),
                ),
                16.hBox,
              ],
            ),
          ),
        );
      },
    );
  }
}

/*
part of '../edit_profile_screen.dart';

class EditInfoScreen extends StatelessWidget {
  const EditInfoScreen({super.key, required this.params});

  final EditProfileParameter params;
  // final GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        //shadow: ColorManager.greyLight,
        title: params.isUsername
            ? StringManager.nickname.tr()
            : StringManager.personalizedSignature.tr(),

        titleStyle: context.bodyMedium.w600
            .colorExt(ColorManager.appBarTitlegrey)
            .size(18),
      ),
      body: BlocBuilder<EditInformationBloc, EditInformationState>(
          bloc: di<EditInformationBloc>(),
          builder: (context, state) {
            return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  8.hBox,
                  Form(
                    key: key,
                    child: TextInputWidget(
                      params.isUsername
                          ? StringManager.nickname.tr()
                          : StringManager.personalizedSignature.tr(),
                      title: params.isUsername
                          ? StringManager.nickname.tr()
                          : StringManager.personalizedSignature.tr(),

                      maxLines: params.isUsername ? 1 : 5,
                      maxLength: params.isUsername ? 30 : 200,
                      minLines: params.isUsername ? 1 : 5,
                      // contentPadding: context.paddingSymmetric(
                      //     vertical: 10, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: 5.radius,
                        borderSide: const BorderSide(
                          width: 1.5,
                          color: ColorManager.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: 5.radius,
                        borderSide: const BorderSide(
                          width: 1.5,
                          color: ColorManager.white,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: 5.radius,
                        borderSide: const BorderSide(
                          width: 1.5,
                          color: ColorManager.white,
                        ),
                      ),
                      controller: params.isUsername ? state.name : state.bio,
                      validator: (value) {
                        if (value == null || value.isEmpty == true) {
                          return StringManager.requiredField.tr();
                        } else {
                          return null;
                        }
                      },
                      hintStyle: context.bodyMedium.w400.colorExt(
                        ColorManager.grey,
                      ),
                      textColor: ColorManager.black.withValues(alpha:0.5),
                      fillColor: ColorManager.white,
                    ),
                  ),
                  50.hBox,
                  Center(
                    child: ButtonWidget(
                      isLoading: state.requestState.isLoading,
                      onPressed: () {
                        if (state.formKey.currentState?.validate() == false) {
                          return;
                        }
                        di<EditInformationBloc>().add(
                          const EditInformationEvent(),
                        );
                      },
                      height: 45.h,
                      width: 250.w,
                      radius: 30.r,
                      backgroundColor: ColorManager.primary,
                      titleColor: ColorManager.white,
                      title: StringManager.save,
                    ),
                  ),
                  20.hBox,
                ],
              ),
            );
          }),
    );
  }
}

*/