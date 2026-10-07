part of 'edit_profile_screen.dart';

class AddMultiPicture extends StatelessWidget {
  final bool? isInProfile;

  const AddMultiPicture({super.key, this.isInProfile});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditInformationBloc, EditInformationState>(
      bloc: di<EditInformationBloc>(),
      listener: (context, state) {
        if (!context.mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
          return;
        }
        if (state.requestState.isLoaded) {
          di<FetchUserDataBloc>().add(const FetchMyDataEvent(isLoading: false));
          Methods.showToast(context, message: state.message);
          di<EditInformationBloc>().add(const InitialStateEvent());
        }

        if (state.requestState == RequestState.error) {
          Methods.showToast(context, message: state.message, isError: true);
        }
      },
      builder: (context, state) {
        final selectedImages = state.multiImages;
        return BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
          bloc: di<FetchUserDataBloc>(),
          buildWhen: (prev, curr) =>
          prev.userEntity?.multiImages != curr.userEntity?.multiImages,
          builder: (context, state) {
            final profileImages = state.userEntity?.multiImages ?? [];
            return PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, result) async {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (isInProfile ?? false) {
                    context.popRoute();
                  } else {}
                });
              },
              child: Scaffold(
                extendBodyBehindAppBar: false,
                backgroundColor: ColorManager.white,
                appBar: AppBarWidget(
                  backgroundColor: ColorManager.white,
                  iconColor: Colors.black,
                  titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
                  title: StringManager.personalInformation.tr(),
                  onLeadingPressed: () async {
                    if (isInProfile ?? false) {
                      context.popRoute();
                    } else {
                      context.popRoute();
                    }
                  },
                ),
                body: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: ImageTile(
                                      index: 0,
                                      topThreeCards: true,
                                      label: StringManager.coverPhoto.tr(),
                                      isFile: selectedImages.isNotEmpty,
                                      isUrl: profileImages.isNotEmpty,
                                      imageFile: selectedImages.isNotEmpty
                                          ? selectedImages[0]
                                          : null,
                                      imageUrl: profileImages.isNotEmpty
                                          ? profileImages[0].img
                                          : null,
                                      multiImagesEntity:
                                      profileImages.isNotEmpty
                                          ? profileImages[0]
                                          : null,
                                      isLarge: true,
                                    ),
                                  ),
                                  8.wBox,
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ImageTile(
                                            index: 1,
                                            topThreeCards: true,
                                            isFile: selectedImages.length > 1,
                                            isUrl: profileImages.length > 1,
                                            imageFile: selectedImages.length > 1
                                                ? selectedImages[1]
                                                : null,
                                            imageUrl: profileImages.length > 1
                                                ? profileImages[1].img
                                                : null,
                                            multiImagesEntity:
                                            profileImages.length > 1
                                                ? profileImages[1]
                                                : null,
                                            label: StringManager.life.tr(),
                                            isLarge: false,
                                          ),
                                        ),
                                        8.hBox,
                                        Expanded(
                                          child: ImageTile(
                                            index: 2,
                                            topThreeCards: true,
                                            isFile: selectedImages.length > 2,
                                            isUrl: profileImages.length > 2,
                                            imageFile: selectedImages.length > 2
                                                ? selectedImages[2]
                                                : null,
                                            imageUrl: profileImages.length > 2
                                                ? profileImages[2].img
                                                : null,
                                            multiImagesEntity:
                                            profileImages.length > 2
                                                ? profileImages[2]
                                                : null,
                                            label: StringManager.travel.tr(),
                                            isLarge: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            8.hBox,
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ImageTile(
                                      index: 3,
                                      topThreeCards: false,
                                      isFile: selectedImages.length > 3,
                                      isUrl: profileImages.length > 3,
                                      imageFile: selectedImages.length > 3
                                          ? selectedImages[3]
                                          : null,
                                      imageUrl: profileImages.length > 3
                                          ? profileImages[3].img
                                          : null,
                                      multiImagesEntity:
                                      profileImages.length > 3
                                          ? profileImages[3]
                                          : null,
                                      label: '',
                                      isLarge: false,
                                    ),
                                  ),
                                  8.wBox,
                                  Expanded(
                                    child: ImageTile(
                                      index: 4,
                                      topThreeCards: false,
                                      isFile: selectedImages.length > 4,
                                      isUrl: profileImages.length > 4,
                                      imageFile: selectedImages.length > 4
                                          ? selectedImages[4]
                                          : null,
                                      imageUrl: profileImages.length > 4
                                          ? profileImages[4].img
                                          : null,
                                      multiImagesEntity:
                                      profileImages.length > 4
                                          ? profileImages[4]
                                          : null,
                                      label: '',
                                      isLarge: false,
                                    ),
                                  ),
                                  8.wBox,
                                  Expanded(
                                    child: ImageTile(
                                      index: 5,
                                      topThreeCards: false,
                                      isFile: selectedImages.length > 5,
                                      isUrl: profileImages.length > 5,
                                      imageFile: selectedImages.length > 5
                                          ? selectedImages[5]
                                          : null,
                                      imageUrl: profileImages.length > 5
                                          ? profileImages[5].img
                                          : null,
                                      multiImagesEntity:
                                      profileImages.length > 5
                                          ? profileImages[5]
                                          : null,
                                      label: '',
                                      isLarge: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      15.hBox,
                      TextWidget(
                        StringManager.basicInformation.tr(),
                        style: context.bodyMedium
                            .colorExt(ColorManager.black)
                            .size(14),
                      ),
                      8.hBox,
                      GestureDetector(
                        onTap: () {
                          context.pushNamedRoute(
                            Routes.editProfile,
                            arguments: MyDataModel.getInstance(),
                          );
                        },
                        child: Card(
                          color: ColorManager.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: ColorManager.grey2.withValues(alpha: 0.3)),
                          ),
                          elevation: 0.5,
                          child: Padding(
                            padding: context.paddingAll(12),
                            child: Row(
                              children: [
                                10.wBox,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      5.hBox,
                                      Row(
                                        children: [
                                          ImageViewWidget(
                                            url: MyDataModel.getInstance()
                                                .profile
                                                ?.image ??
                                                '',
                                            height: 50.w,
                                            width: 50.w,
                                            shape: BoxShape.circle,
                                          ),
                                          12.wBox,
                                          Expanded(
                                            child: Text(
                                              MyDataModel.getInstance().name ??
                                                  '',
                                              style: context.bodyMedium.bold
                                                  .colorExt(ColorManager.black)
                                                  .size(15),
                                            ),
                                          ),
                                        ],
                                      ),
                                      15.hBox,
                                      TextWidget(
                                        (MyDataModel.getInstance().bio ?? '') !=
                                            ''
                                            ? MyDataModel.getInstance().bio ??
                                            ''
                                            : StringManager.bio.tr(),
                                        style: context.bodyMedium
                                            .colorExt(
                                          (MyDataModel.getInstance().bio ??
                                              '') !=
                                              ''
                                              ? ColorManager.black
                                              : ColorManager.lightGray99,
                                        )
                                            .size(15),
                                      ),
                                      5.hBox,
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: ColorManager.lightGray99,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ImageTile extends StatelessWidget {
  const ImageTile({
    super.key,
    required this.label,
    required this.isLarge,
    this.imageUrl,
    this.imageFile,
    required this.isFile,
    required this.isUrl,
    required this.index,
    this.multiImagesEntity,
    required this.topThreeCards,
  });

  final String label;
  final MultiImagesEntity? multiImagesEntity;
  final String? imageUrl;
  final File? imageFile;
  final bool isLarge;
  final bool isFile;
  final bool isUrl;
  final int index;
  final bool topThreeCards;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AnimatedDialog(
            titleDivider: false,
            isHideConfirm: true,
            isUpdateDialog: false,
            horizontalPadding: 45.w,
            // White dialog card with a tighter corner radius, on request.
            dialogBackgroundColor: ColorManager.white,
            radius: 12,
            child: _SelectCoverImageDialog(
              title: "",
              isDelete: isUrl,
              imageUrl: imageUrl ?? '',
              index: index,
              multiImagesEntity: multiImagesEntity,
            ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: 8.radius,
            child: Container(
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: 8.radius,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: isUrl
                  ? ColorFiltered(
                colorFilter: ColorFilter.mode(
                  ColorManager.black.withValues(alpha: (0.30)),
                  BlendMode.darken,
                ),
                child: ImageViewWidget(
                  url: EndPoints.getImage(
                    imageUrl,
                  ),
                  boxFit: BoxFit.cover,
                ),
              )
                  : isFile
                  ? ColorFiltered(
                colorFilter: ColorFilter.mode(
                  ColorManager.black.withValues(alpha: (0.30)),
                  BlendMode.darken,
                ),
                child: Image.file(
                  File(imageFile!.path),
                  fit: BoxFit.cover,
                ),
              )
                  : Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: topThreeCards
                        ? ColorManager.transparent
                        : ColorManager.offWhite,
                    borderRadius: 5.radius,
                  ),
                  child: ImageWidget(
                    image: AssetsManager.plusIcon2,
                    width: 25,
                    height: 25,
                    color: topThreeCards
                        ? ColorManager.primary
                        : ColorManager.lightGray99
                        .withValues(alpha: (0.45)),
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          if (topThreeCards)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.only(
                    topRight: 8.radiusCircular,
                    bottomLeft: 8.radiusCircular,
                  ),
                ),
                child: Padding(
                  padding: context.paddingSymmetric(horizontal: 5, vertical: 3),
                  child: TextWidget(
                    label,
                    style: context.bodyMedium
                        .colorExt(
                      ColorManager.onDark,
                    )
                        .size(10),
                  ),
                ),
              ),
            ),
          if (isLarge && topThreeCards)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 30.h,
                width: 10.w,
                decoration: BoxDecoration(
                  color: ColorManager.lightRed,
                  borderRadius: BorderRadius.only(
                    topRight: 8.radiusCircular,
                    bottomLeft: 8.radiusCircular,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}