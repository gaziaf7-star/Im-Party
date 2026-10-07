part of '../edit_profile_screen.dart';

class _SelectImageDialog extends StatelessWidget {
  const _SelectImageDialog({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextWidget(
          StringManager.uploadProfilePhoto.tr(),
          style: context.bodyMedium.colorExt(ColorManager.black).size(16),
        ),
        10.hBox,
        TextWidget(
          StringManager.profilePhotoHint.tr(),
          style: context.bodyMedium.colorExt(ColorManager.black).size(13),
        ),
        10.hBox,
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ImageWidget(
            image: AssetsManager.profileHintImage,
            width: double.infinity,
            height: 40,
            boxFit: BoxFit.contain,
          ),
        ),
        10.hBox,
        Padding(
          padding: context.paddingSymmetric(horizontal: 20),
          child: ButtonWidget(
            title: StringManager.takePhoto.tr(),
            height: 45.h,
            fontSize: 14.sp,
            titleColor: ColorManager.onDark,
            radius: 50,
            fontWeight: FontWeight.w400,
            borderColor: ColorManager.primary,
            backgroundColor: ColorManager.primary,
            onPressed: () {
              Navigator.pop(context);

              di<EditInformationBloc>()
                  .add(const PickImageEvent(fromCamera: true));
            },
          ),
        ),
        10.hBox,
        Padding(
          padding: context.paddingSymmetric(horizontal: 20),
          child: ButtonWidget(
            title: StringManager.selectFromAlbum.tr(),
            height: 45.h,
            fontSize: 14.sp,
            titleColor: ColorManager.onDark,
            radius: 50,
            fontWeight: FontWeight.w400,
            borderColor: ColorManager.primary,
            backgroundColor: ColorManager.primary,
            onPressed: () {
              Navigator.pop(context);

              di<EditInformationBloc>()
                  .add(const PickImageEvent(fromCamera: false));
            },
          ),
        ),
      ],
    );
  }
}