import 'package:general/src/core/widgets/gradient_name.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:readmore/readmore.dart';
import '../../bloc/moment_likes_bloc/get_moment_likes_event.dart';
import '../../bloc/moment_likes_bloc/moment_likes_bloc_bloc.dart';
import '../component/moment_content/moment_content_screen.dart';
import '../component/moment_details/moment_details_screen.dart';

class MomentContentItem extends StatelessWidget {
  final MomentEntity moment;
  final int currentMomentIndex;
  final MomentType type;
  final MomentBloc momentBloc;

  const MomentContentItem(
      {super.key,
        required this.momentBloc,
        required this.moment,
        required this.currentMomentIndex,
        required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.scaffoldBg,
        borderRadius: 7.radius,
      ),
      padding: context.paddingOnly(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              GestureDetector(
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
                    GradientName(child: TextWidget(
                      moment.userName,
                      // Fixed light-black — was ColorManager.white sitting on
                      // this card's own scaffoldBg background (white on a
                      // light theme), which made the name invisible. Matches
                      // the same fix already applied to the post card lower
                      // down the feed.
                      style: context.bodySmall
                          .colorExt(ColorManager.momentPostTextColor)
                          .size(14),
                    )),
                    3.hBox,
                    TextWidget(
                      Methods().formatMomentPostedDateTime(moment.creeatedTime),
                      style: context.bodyLarge
                          .colorExt(ColorManager.greyTextColor)
                          .size(12),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!moment.isFollow &&
                  MyDataModel.getInstance().id.toString() !=
                      moment.userId.toString())
                InkWell(
                  onTap: () {
                    momentBloc.add(
                      MomentFollowEvent(
                        momentId: moment.momentId,
                        currentMoment: moment,
                        userID: moment.userId,
                      ),
                    );
                  },
                  child: Container(
                    padding: context.paddingSymmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    margin: context.paddingSymmetric(
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      // Brand gradient (was the flat panel-driven
                      // ColorManager.primary) — matches every other button on
                      // this page.
                      gradient: ColorManager.brandGradient,
                      shape: BoxShape.rectangle,
                      borderRadius: 20.radius,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWidget(
                          StringManager.followings.tr(),
                          style: context.bodyMedium
                              .size(14)
                              .colorExt(ColorManager.white),
                        ),
                      ],
                    ),
                  ),
                )
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
                    // Fixed light-black (was the panel-driven textPrimary) —
                    // requested for the post text on the Status Details page.
                    style: TextStyle(
                        fontSize: 15.sp,
                        color: ColorManager.momentPostTextColor,
                        fontWeight: FontWeight.w400),
                    trimCollapsedText: StringManager.showMore,
                    trimExpandedText: StringManager.showLess,
                  ),
                ),
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
                            type: type,
                            imageIndex: 0,
                            momentBloc: momentBloc,
                          ),
                        ),
                      );
                    },
                    child: ImageViewWidget(
                      url: EndPoints.getImage(
                        moment.images[0].image,
                      ),
                      maxHeight: 400.h,
                      radius: 4.r,
                      boxFit: BoxFit.cover,
                    ),
                  )
                      : SizedBox(
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: context.paddingZero(),
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
                                      momentBloc: momentBloc,
                                      currentMomentIndex: currentMomentIndex,
                                      momentId: moment.momentId,
                                      type: type,
                                      imageIndex: index,
                                    ),
                              ),
                            );
                          },
                          child: ImageViewWidget(
                            url: EndPoints.getImage(
                              moment.images[index].image,
                            ),
                            radius: 13.r,
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
                        momentBloc.add(
                          LikeMomentData(
                            momentId: moment.momentId.toString(),
                          ),
                        );
                        if (moment.isLike) {
                          momentBloc.add(
                            UpdateIsLikeEvent(
                              momentId: moment.momentId,
                              type: type,
                              isLike: false,
                              likeNum: moment.likeNum - 1,
                            ),
                          );
                        } else {
                          momentBloc.add(
                            UpdateIsLikeEvent(
                              type: type,
                              momentId: moment.momentId,
                              isLike: true,
                              likeNum: moment.likeNum + 1,
                            ),
                          );
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
                              type: type,
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
              if (MyDataModel.getInstance().id.toString() !=
                  moment.userId.toString())
                Container(
                  padding:
                  context.paddingSymmetric(horizontal: 10, vertical: 5),
                  margin: context.paddingSymmetric(
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    // Brand gradient (was the flat panel-driven
                    // ColorManager.primary) — matches the Say Hi button
                    // everywhere else in Moment.
                    gradient: ColorManager.brandGradient,
                    shape: BoxShape.rectangle,
                    borderRadius: 20.radius,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.messages,
                        arguments: MessagesParameter(
                          hasColorName: false,
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
                          color: ColorManager.white,
                        ),
                        1.wBox,
                        TextWidget(
                          StringManager.sayHi.tr(),
                          style: context.bodyMedium
                              .size(14)
                              .colorExt(ColorManager.white),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }
}