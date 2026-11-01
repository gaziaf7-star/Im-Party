part of '../manger_family_page.dart';

class _FormWidget extends StatelessWidget {
  const _FormWidget({this.showFamilyEntity});

  final ShowFamilyEntity? showFamilyEntity;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagerFamilyBloc, ManagerFamilyStates>(
      bloc: di<ManagerFamilyBloc>(),
      buildWhen: (prev, curr) => prev.formKey != curr.formKey || prev.name != curr.name || prev.bio != curr.bio,
      builder: (context, state) {
        return Form(
          key: state.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextInputWidget(

                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: (0.2 ))),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.redAccount),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.primary),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.redAccount),
                ),
                StringManager.enterFamilyName.tr(),
                controller: state.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return StringManager.fieldIsRequired.tr();
                  }  else if (value.length > 30) {
                    return StringManager.familyNameTooLong.tr();
                  }
                  return null;
                },
                maxLines: 6,
                label: TextWidget(
                  StringManager.familyName.tr(),
                  style: context.bodyLarge.colorExt(
                    ColorManager.grey,
                  ),
                ),
                contentPadding: context.paddingOnly(
                  start: 10,
                  end: 10,
                  bottom: 15,
                  top: 7.5,
                ),
                textStyle: context.bodyLarge,
              ),
              10.hBox,
              TextInputWidget(
                StringManager.familyDescription.tr(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: (0.2 ))),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.redAccount),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.primary),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.redAccount),
                ),
                
                 label: TextWidget(
                  StringManager.pleaseEnterFamilyDescription.tr(),
                  style: context.bodyLarge.colorExt(
                    ColorManager.grey,
                  ),
                ),
                controller: state.bio,
                maxLines: 6,
                // minLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return StringManager.fieldIsRequired.tr();
                  } else if (value.length > 120) {
                    return StringManager.familyDescriptionTooLong.tr();
                  }
                  return null;
                },
                hintStyle: context.bodyLarge.colorExt(
                  ColorManager.grey,
                ),
                 contentPadding: context.paddingOnly(
                  start: 10,
                  end: 10,
                  bottom: 15,
                  top: 7.5,
                ),
                textStyle: context.bodyLarge,
              )
            ],
          ),
        );
      },
    );
  }
}
