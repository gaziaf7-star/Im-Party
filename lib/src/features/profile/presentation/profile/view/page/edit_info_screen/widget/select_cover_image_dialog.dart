part of '../edit_profile_screen.dart';

class _SelectCoverImageDialog extends StatelessWidget {
  const _SelectCoverImageDialog({
    required this.title,
    required this.isDelete,
    required this.index,
    required this.imageUrl,
    this.multiImagesEntity,
  });
  final MultiImagesEntity? multiImagesEntity;

  final String title;
  final String imageUrl;
  final int index;
  final bool isDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextWidget(
          StringManager.uploadBackGroundPhoto.tr(),
          style: context.bodyMedium.bold.colorExt(ColorManager.black).size(16),
        ),
        20.hBox,
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

              di<EditInformationBloc>().add(PickCoverImageEvent(
                fromCamera: true,
                isReplace: isDelete,
                previousImageId: isDelete ? multiImagesEntity?.id : null,
              ));
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
              di<EditInformationBloc>().add(PickCoverImageEvent(
                fromCamera: false,
                isReplace: isDelete,
                previousImageId: isDelete ? multiImagesEntity?.id : null,
              ));
            },
          ),
        ),
        if (isDelete) ...[
          10.hBox,
          Padding(
            padding: context.paddingSymmetric(horizontal: 20),
            child: ButtonWidget(
              title: StringManager.delete.tr(),
              height: 45.h,
              fontSize: 14.sp,
              titleColor: ColorManager.onDark,
              radius: 50,
              fontWeight: FontWeight.w400,
              borderColor: ColorManager.primary,
              backgroundColor: ColorManager.primary,
              onPressed: () {
                di<EditInformationBloc>().add(AssignInformationEvent());

                di<EditInformationBloc>().add(DeleteCoverImageEvent(
                    imageIndex: index, imageUrl: imageUrl));
                Navigator.pop(context);
              },
            ),
          ),
        ]
      ],
    );
  }
}