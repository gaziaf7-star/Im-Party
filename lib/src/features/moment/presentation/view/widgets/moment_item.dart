import 'package:general/src/core/index.dart';
import 'package:general/src/core/services/dynamic_link_handler.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:general/src/features/moment/presentation/view/component/moment_details/moment_details_screen.dart';
import 'package:general/src/features/moment/presentation/view/component/report_moment/report_moment_dialog.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/widgets/level_container.dart';
import '../../bloc/moment_likes_bloc/get_moment_likes_event.dart';
import '../../bloc/moment_likes_bloc/moment_likes_bloc_bloc.dart';
import '../component/moment_content/moment_content_screen.dart';

class MomentItem extends StatelessWidget {
  final MomentEntity moment;
  final int currentMomentIndex;
  final String type;
  final bool isProfile;
  final MomentType momentType;
  final MomentBloc momentBloc;

  const MomentItem({
    super.key,
    required this.moment,
    required this.currentMomentIndex,
    required this.isProfile,
    required this.momentType,
    required this.type,
    required this.momentBloc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.transparent,
        borderRadius: 8.0.radius,
      ),
      padding: context.paddingSymmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isProfile) ...[
                Padding(
                  padding: context.paddingOnly(start: 15),
                  child: TextWidget(
                    "${StringManager.postBy.tr()} ${DateFormat("MM-dd-yyyy hh:mm", Methods().getAppLanguage(context)).format(DateTime.parse(moment.creeatedTime).toLocal())}",
                    style: context.bodyLarge
                        .colorExt(ColorManager.greyTextColor)
                        .size(12),
                  ),
                )
              ] else ...[
                GestureDetector(
                  onTap: () {
                    Methods().userProfileNavigator(
                      context: context,
                      userId: '${moment.userId}',
                    );
                  },
                  child: SizedBox(
                    width: 75.w,
                    height: 75.w,
                    child: UserImage(
                      image: moment.userImage,
                      displayName: moment.userName,
                      frame: moment.frame,
                      positionedBottom: 13,
                      frameSize: 75.w,
                      imageSize: 45.w,
                      boxFit: BoxFit.fill,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Methods().userProfileNavigator(
                        context: context,
                        userId: '${moment.userId}',
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GradientTextVip(
                            isVip: moment.colorName.isNotEmpty,
                            width: 130.w,
                            text: moment.userName,
                            // Fixed black fallback (was the panel-driven
                            // textPrimary) — requested to match the caption
                            // text fix below; a colorName override (VIP name
                            // colour) still takes priority when set.
                            color: moment.colorName != '' &&
                                moment.colorName != "NULL" &&
                                moment.colorName.isNotEmpty
                                ? Color((int.parse(
                                moment.colorName.replaceAll('#', '0xff'))))
                                : ColorManager.momentPostTextColor,
                            mainAxisAlignment: MainAxisAlignment.center,
                            textAlign: TextAlign.center,
                            textStyle:
                            context.bodyMedium.size(16).w400.colorExt(
                              moment.colorName != '' &&
                                  moment.colorName != "NULL" &&
                                  moment.colorName.isNotEmpty
                                  ? Color((int.parse(moment.colorName
                                  .replaceAll('#', '0xff'))))
                                  : ColorManager.momentPostTextColor,
                            )),
                        5.hBox,
                        Row(
                          children: [
                            if (momentType == MomentType.follow)
                              Flexible(
                                child: TextWidget(
                                  "${StringManager.postBy.tr()} ${Methods.formatDate(moment.creeatedTime, locale: context.locale.languageCode)}",
                                  style: context.bodyLarge
                                      .colorExt(ColorManager.greyTextColor)
                                      .size(12),
                                ),
                              ),
                            if (moment.senderImage != "0")
                              LevelContainer(
                                image: moment.senderImage,
                                // Requested: this badge image should be circular.
                                isCircle: true,
                              ),
                            if (moment.receiverImage != "0")
                              LevelContainer(
                                image: moment.receiverImage,
                                isCircle: true,
                              ),
                            if (moment.vip != 0)
                              VipContainer(
                                vip: moment.vipNew?.img1 ?? '',
                                width: 35.w,
                                height: 15.h,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              PopupMenuButton<int>(
                icon: Icon(
                  Icons.more_horiz,
                  size: 22.sp,
                  // Fixed light-black instead of a faint 50%-alpha grey — the
                  // old value was hard to see, requested to match the post
                  // text's fixed colour below.
                  color: ColorManager.momentPostTextColor,
                ),
                onSelected: (value) {
                  if (value == 1) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MomentReportDialog(
                              momentId: moment.momentId.toString(),
                            )));
                  } else if ((value == 2)) {
                    momentBloc.add(DeleteMomentData(
                        type: momentType,
                        momentId: moment.momentId.toString(),
                        context: context));
                  }
                },
                itemBuilder: (context) => [
                  if (MyDataModel.getInstance().uuid != moment.uuid)
                    PopupMenuItem(
                      value: 1,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              AssetsManager.dangerIcon,
                              height: 20.w,
                              width: 20.w,
                              color: ColorManager.white,
                            ),
                            5.wBox,
                            TextWidget(
                              StringManager.flag.tr(),
                              textAlign: TextAlign.center,
                              style: context.bodyMedium
                                  .colorExt(ColorManager.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (MyDataModel.getInstance().uuid == moment.uuid)
                    PopupMenuItem(
                      value: 2,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              AssetsManager.trashIcon,
                              height: 20.w,
                              width: 20.w,
                              color: ColorManager.white,
                            ),
                            5.wBox,
                            TextWidget(
                              StringManager.delete.tr(),
                              textAlign: TextAlign.center,
                              style: context.bodyMedium
                                  .colorExt(ColorManager.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                offset: const Offset(50, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: 6.radius,
                ),
                color: ColorManager.black.withValues(alpha: (0.69)),
                elevation: 2,
              ),
            ],
          ),
          Padding(
            padding: context.paddingSymmetric(horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: 280.w,
                    child: ReadMoreText(
                      moment.moment,
                      trimMode: TrimMode.Line,
                      trimLines: 2,
                      // Fixed light-black instead of the panel-driven
                      // textPrimary — requested directly, so the post text
                      // always reads the same regardless of the admin's
                      // colour settings.
                      style: TextStyle(
                          fontSize: 15.sp,
                          color: ColorManager.momentPostTextColor,
                          fontWeight: FontWeight.w400),
                      trimCollapsedText: StringManager.showMore,
                      trimExpandedText: StringManager.showLess,
                    )),
                15.hBox,
                if (moment.images.isNotEmpty) ...[
                  5.hBox,
                  moment.images.length == 1
                      ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MomentDetailstScreen(
                            currentMoment: moment,
                            currentMomentIndex: currentMomentIndex,
                            momentId: moment.momentId,
                            type: momentType,
                            momentBloc: momentBloc,
                            imageIndex: 0,
                          ),
                        ),
                      );
                    },
                    child: ImageViewWidget(
                      key: ValueKey(moment.images[0].image),
                      url: moment.images[0].image,
                      radius: 5.r,
                      boxFit: BoxFit.cover,
                      height: 300.h,
                    ),
                  )
                      : SizedBox(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: moment.images.length > 2
                            ? 3
                            : moment.images.length == 2
                            ? 2
                            : 1,
                        mainAxisSpacing: 5,
                        childAspectRatio: 1,
                        crossAxisSpacing: 5,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MomentDetailstScreen(
                                      currentMoment: moment,
                                      currentMomentIndex: currentMomentIndex,
                                      momentId: moment.momentId,
                                      type: momentType,
                                      imageIndex: index,
                                      momentBloc: momentBloc,
                                    ),
                              ),
                            );
                          },
                          child: ImageViewWidget(
                            key: ValueKey(moment.images[index].image),
                            url: moment.images[index].image,
                            radius: 6,
                            boxFit: BoxFit.cover,
                          ),
                        );
                      },
                      itemCount: moment.images.isNotEmpty
                          ? moment.images.length
                          : 0,
                    ),
                  ),
                ],
                if (momentType == MomentType.latest) ...[
                  10.hBox,
                  TextWidget(
                    "${StringManager.publishedOn} ${Methods.formatDate(moment.creeatedTime, locale: context.locale.languageCode)}",
                    style: context.bodyLarge
                        .colorExt(ColorManager.greyTextColor)
                        .size(12),
                  )
                ]
              ],
            ),
          ),
          15.hBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: context.paddingSymmetric(horizontal: 15.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        momentBloc.add(LikeMomentData(
                            momentId: moment.momentId.toString()));
                        if (moment.isLike) {
                          momentBloc.add(UpdateIsLikeEvent(
                              momentId: moment.momentId,
                              type: momentType,
                              isLike: false,
                              likeNum: moment.likeNum - 1));
                        } else {
                          momentBloc.add(UpdateIsLikeEvent(
                            type: momentType,
                            momentId: moment.momentId,
                            isLike: true,
                            likeNum: moment.likeNum + 1,
                          ));
                        }
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            moment.isLike
                                ? AssetsManager.loveHeartIcon2
                                : AssetsManager.loveHeartIcon,
                            height: 25.w,
                            width: 25.w,
                            color: moment.isLike
                                ? ColorManager.pink
                                : ColorManager.grey,
                          ),
                          3.wBox,
                          TextWidget(
                            Methods.formatCompactNumber(moment.likeNum),
                            style: context.bodySmall.w500
                                .colorExt(ColorManager.greyTextColor)
                                .size(14),
                          ),
                        ],
                      ),
                    ),
                    40.wBox,
                    GestureDetector(
                      onTap: () {
                        di<MomentCommentBloc>().add(FetchMomentComment(
                            momentId: moment.momentId.toString(), page: "1"));
                        di<GetMomentLikesBloc>().add(GetMomentLikesEvent(
                            momentId: moment.momentId.toString(), page: "1"));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MomentContentScreen(
                              currentMoment: moment,
                              momentBloc: momentBloc,
                              currentMomentIndex: currentMomentIndex,
                              momentId: moment.momentId,
                              type: momentType,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            AssetsManager.commentIcon2,
                            height: 25.w,
                            width: 25.w,
                            color: ColorManager.grey,
                          ),
                          3.wBox,
                          TextWidget(
                            Methods.formatCompactNumber(moment.commentNum),
                            style: context.bodySmall.w500
                                .colorExt(ColorManager.greyTextColor)
                                .size(14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      try {
                        final Map<String, dynamic> map_ = {
                          'type': 'moment',
                          'id': moment.momentId.toString(),
                          'data': MomentModel.fromEntity(moment),
                          'path': 'moment',
                        };

                        final String dynamicLink = await DynamicLinkHandler
                            .instance
                            .createProductLink(map_, 'moment');

                        await SharePlus.instance.share(
                          ShareParams(
                            uri: Uri.parse(dynamicLink),
                            subject: StringManager.amazingMoment.tr(),
                          ),
                        );
                      } catch (error) {
                        Methods.showToast(
                          context,
                          message: StringManager.unableToShareMoment.tr(),
                          isError: true,
                        );
                      }
                    },
                    child: ImageWidget(
                      image: AssetsManager.shareMoment,
                      height: 20.h,
                      width: 20.h,
                      color: ColorManager.greyTextColor,
                    ),
                  ),
                  30.wBox,
                  isProfile ||
                      (MyDataModel.getInstance().id.toString() ==
                          moment.userId.toString())
                      ? const SizedBox()
                      : Container(
                    padding: context.paddingSymmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      // Brand pink->purple gradient (was the flat
                      // panel-driven ColorManager.primary) — requested
                      // to match the app's own established accent.
                        gradient: ColorManager.brandGradient,
                        shape: BoxShape.rectangle,
                        borderRadius: 20.radius),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.messages,
                          arguments: MessagesParameter(
                            hasColorName: false,
                            //isNotFriend: moment.isFriend == true ? false:true,
                            name: moment.userName,
                            image: moment.userImage,
                            userId: moment.userId.toString(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageWidget(
                            height: 18,
                            width: 20,
                            boxFit: BoxFit.fill,
                            image: AssetsManager.profileMsgIcon,
                            // Light white — was buttonTextColor (panel
                            // driven, could be dark) which could go
                            // unreadable against the new gradient.
                            color: ColorManager.onBrandGradient,
                          ),
                          1.wBox,
                          TextWidget(StringManager.sayHi.tr(),
                              style: context.bodyMedium
                                  .size(14)
                                  .colorExt(ColorManager.onBrandGradient))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}