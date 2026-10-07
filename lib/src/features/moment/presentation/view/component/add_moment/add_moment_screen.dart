import 'dart:io';
import 'package:general/src/features/moment/moment.dart';
import '../../../../../../core/index.dart';

import 'custom_emoji_picker.dart';

part 'pick_moment_image.dart';

class AddMomentScreen extends StatefulWidget {
  const AddMomentScreen({super.key});

  @override
  State<AddMomentScreen> createState() => _AddMomentScreenState();
}

class _AddMomentScreenState extends State<AddMomentScreen> {
  late TextEditingController createMomentController = TextEditingController();
  @override
  void initState() {
    di<MomentBloc>().add(const RemovePickedImageEvent());
    di<MomentBloc>().add(const ShowEmojiPickerEvent(showEmoji: false));
    createMomentController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MomentBloc, MomentStates>(
      bloc: di<MomentBloc>(),
      listener: (context, state) {
        if (state.addMomentReqState.isLoading) {
          Methods.showToast(context, isLoading: true);
        } else if (state.addMomentReqState.isLoaded) {
          Methods.showToast(
            context,
            message: state.addMomentMessage,
          );
          Navigator.pop(context);
          return;
        } else if (state.addMomentReqState.isError) {
          Methods.showToast(
            context,
            message: state.addMomentMessage,
          );
          return;
        }
      },
      builder: (context, momentState) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (momentState.showEmoji) {
              di<MomentBloc>()
                  .add(const ShowEmojiPickerEvent(showEmoji: false));
            }
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            // White base — the gradient below only paints the top band and
            // fades out, same as Home/Moment, so the rest of the page (and
            // the safe fallback before the gradient paints) is plain white.
            backgroundColor: ColorManager.white,
            // Lets the body's gradient band paint UNDER the (transparent)
            // app bar instead of stopping at its bottom edge — otherwise the
            // gradient and the app bar would visibly seam at that line.
            extendBodyBehindAppBar: true,
            appBar: AppBarWidget(
              backgroundColor: ColorManager.transparent,
              shadow: ColorManager.transparent,
              title: StringManager.postUpdates.tr(),
              titleStyle:
              context.titleLarge.w600.size(16).colorExt(ColorManager.white),
              iconColor: ColorManager.white,
              actions: [
                Container(
                  padding:
                  context.paddingSymmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    // Solid white pill on the gradient header — reads as a
                    // clear, professional call-to-action against the
                    // coloured backdrop instead of blending into it.
                      color: momentState.isFormValid
                          ? ColorManager.white
                          : ColorManager.white.withValues(alpha: 0.35),
                      shape: BoxShape.rectangle,
                      borderRadius: 20.radius),
                  child: InkWell(
                    onTap: momentState.addMomentReqState.isLoading
                        ? null
                        : () async {
                      if (createMomentController.text.isNotEmpty ||
                          momentState.multiImages.isNotEmpty) {
                        di<MomentBloc>().add(
                          AddMomentData(
                            moment: createMomentController.text,
                            context: context,
                            data: FormData.fromMap({
                              "contacts": createMomentController.text,
                              if (momentState.image != null)
                                "img": await MultipartFile.fromFile(
                                    momentState.image!.path,
                                    filename: momentState.image!.path
                                        .split('/')
                                        .last),
                            }),
                          ),
                        );
                      }
                    },
                    child: TextWidget(StringManager.post.tr(),
                        style: context.bodyMedium.size(15).w600.colorExt(
                            momentState.isFormValid
                                ? const Color(0xFF5B4CFF)
                                : ColorManager.white.withValues(alpha: 0.8))),
                  ),
                ),
                10.wBox
              ],
            ),
            body: Stack(
              children: [
                // Fixed home-style purple->blue->violet band, faded
                // vertically to transparent — same technique as the
                // Home/Moment background so this screen visually belongs to
                // the same app instead of a flat grey compose form.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 260.h,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                    ).createShader(bounds),
                    blendMode: BlendMode.dstIn,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                          gradient: ColorManager.homeBackgroundGradient),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        18.h,
                    left: 14.w,
                    right: 14.w,
                    bottom: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Compose card — the image picker + text field now sit
                      // on their own elevated white card over the gradient,
                      // instead of floating directly on the page.
                      Container(
                        width: double.infinity,
                        padding: context.paddingAll(14),
                        decoration: BoxDecoration(
                          color: ColorManager.white,
                          borderRadius: 18.radius,
                          boxShadow: [
                            BoxShadow(
                              color: ColorManager.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 80,
                              child: _PickMomentImageBody(
                                  moment: createMomentController.text),
                            ),
                            15.hBox,
                            TextInputWidget(
                              StringManager.postMomentHint.tr(),
                              maxLines: 20,
                              minLines: 10,
                              contentPadding:
                              context.paddingSymmetric(horizontal: 0),
                              maxLength: 1000,
                              // showMaxLength: true,
                              controller: createMomentController,
                              onChanged: (v) {
                                di<MomentBloc>().add(UpdateValidationEvent(
                                    moment: createMomentController.text));
                              },
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              textSize: 16,
                              textColor: ColorManager.momentPostTextColor,
                              fillColor: ColorManager.white,
                              hintStyle: context.bodyMedium
                                  .size(16)
                                  .colorExt(ColorManager.greyTextColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomSheet: Container(
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            di<MomentBloc>().add(const PickMultiPicEvent());
                          },
                          child: Row(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  // Same fixed home-page gradient as the
                                  // background band above — keeps every
                                  // accent on this screen tied to the one
                                  // palette instead of mixing in the brand
                                  // pink/purple as well.
                                  gradient:
                                  ColorManager.homeBackgroundGradient,
                                  shape: BoxShape.circle,
                                ),
                                padding: context.paddingSymmetric(
                                    horizontal: 8, vertical: 8),
                                child: ImageWidget(
                                    height: 10,
                                    width: 12,
                                    boxFit: BoxFit.fill,
                                    image: AssetsManager.addImasges,
                                    color: ColorManager.white),
                              ),
                              8.wBox,
                              TextWidget(
                                StringManager.addPicture.tr(),
                                style: context.bodyMedium.size(13).w500
                                    .colorExt(ColorManager.momentPostTextColor),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            di<MomentBloc>().add(ShowEmojiPickerEvent(
                                showEmoji: !momentState.showEmoji));
                          },
                          child: Icon(
                            Icons.emoji_emotions,
                            color: ColorManager.momentPostTextColor
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (momentState.showEmoji) ...[
                    10.hBox,
                    CustomEmojiPicker(
                      textController: createMomentController,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}