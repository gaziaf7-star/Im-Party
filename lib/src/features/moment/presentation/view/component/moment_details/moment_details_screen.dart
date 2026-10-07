import 'package:general/src/core/widgets/gradient_name.dart';
import 'package:general/src/core/widgets/gender_widget.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:readmore/readmore.dart';
import '../../../../../../core/index.dart';

class MomentDetailstScreen extends StatefulWidget {
  final int momentId;
  final int currentMomentIndex;
  final int? imageIndex;
  final MomentEntity currentMoment;
  final MomentType type;
  final MomentBloc momentBloc;

  const MomentDetailstScreen(
      {super.key,
        required this.momentBloc,
        required this.momentId,
        required this.type,
        this.imageIndex,
        required this.currentMoment,
        required this.currentMomentIndex});

  @override
  State<MomentDetailstScreen> createState() => _MomentDetailstScreenState();
}

class _MomentDetailstScreenState extends State<MomentDetailstScreen>
    with TickerProviderStateMixin {
  int currentPage = 0;
  @override
  initState() {
    currentPage = widget.imageIndex ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MomentBloc, MomentStates>(
      bloc: widget.momentBloc,
      buildWhen: (prev, curr) =>
      prev.moments != curr.moments ||
          prev.followMoments != curr.followMoments ||
          prev.myMoments != curr.myMoments ||
          prev.latestMoments != curr.latestMoments,
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            // White page (was the immersive black gallery shell) + light-black
            // text below — requested directly so this matches the rest of the
            // app's light theme instead of the old dark image-viewer look.
            backgroundColor: ColorManager.white,
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                SizedBox(
                  height: ScreenUtil().screenHeight * 0.95,
                  child: PageView.builder(
                    itemCount: widget.currentMoment.images.length,
                    controller:
                    PageController(initialPage: widget.imageIndex ?? 0),
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        child: ImageViewWidget(
                          url: widget.currentMoment.images[index].image,
                          boxFit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 50.h,
                  child: AppBarWidget(
                    title:
                    '${currentPage + 1}/${widget.currentMoment.images.length}',
                    // Brand gradient app bar (was flat transparent) —
                    // requested so every app bar shares the one accent.
                    backgroundGradient: ColorManager.brandGradient,
                    titleStyle: context.bodyMedium
                        .colorExt(ColorManager.white)
                        .size(16),
                    iconColor: ColorManager.white,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: ScreenUtil().screenWidth,
                    padding: context.paddingSymmetric(
                        vertical: 10, horizontal: 15),
                    // Solid white card behind the caption/username — keeps
                    // the new light-black text readable over whatever the
                    // photo underneath happens to be, and reads as a
                    // deliberate caption panel instead of loose floating text.
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.r),
                        topRight: Radius.circular(18.r),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Methods().userProfileNavigator(
                              context: context,
                              userId: '${widget.currentMoment.userId}',
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              UserImage(
                                image: widget.currentMoment.userImage,
                                displayName: widget.currentMoment.userName,
                                frame: widget.currentMoment.frame,
                                frameSize: 75.w,
                                imageSize: 50.w,
                                // positionedBottom: 13,
                                boxFit: BoxFit.fill,
                              ),
                              10.wBox,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GradientName(child: TextWidget(
                                    widget.currentMoment.userName,
                                    style: context.bodySmall.w600
                                        .colorExt(ColorManager.momentPostTextColor)
                                        .size(16),
                                  )),
                                  10.hBox,
                                  GenderWidget(
                                    age: widget.currentMoment.age,
                                    gender: widget.currentMoment.gender,
                                  )
                                ],
                              ),
                              const Spacer(),
                              if (widget.type != MomentType.myMoment)
                                if (!(widget.type == MomentType.recommend
                                    ? state.moments[
                                widget.currentMomentIndex]
                                    : widget.type == MomentType.follow
                                    ? state.followMoments[
                                widget.currentMomentIndex]
                                    : widget.type ==
                                    MomentType.myMoment
                                    ? state.myMoments[widget
                                    .currentMomentIndex]
                                    : state.latestMoments[widget
                                    .currentMomentIndex])
                                    .isFollow &&
                                    MyDataModel.getInstance().id.toString() !=
                                        widget.currentMoment.userId.toString())
                                  InkWell(
                                    onTap: () {
                                      widget.momentBloc.add(MomentFollowEvent(
                                          momentId:
                                          widget.currentMoment.momentId,
                                          currentMoment: widget.currentMoment,
                                          userID: widget.currentMoment.userId));
                                    },
                                    child: Container(
                                      padding: context.paddingSymmetric(
                                          horizontal: 10, vertical: 5),
                                      margin: context.paddingSymmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        // Brand gradient (was the flat
                                        // panel-driven ColorManager.primary) —
                                        // requested for every button on this
                                        // page.
                                        gradient: ColorManager.brandGradient,
                                        shape: BoxShape.rectangle,
                                        borderRadius: 20.radius,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          TextWidget(StringManager.follow.tr(),
                                              style: context.bodyMedium
                                                  .size(14)
                                                  .colorExt(
                                                  ColorManager.whiteColor))
                                        ],
                                      ),
                                    ),
                                  )
                            ],
                          ),
                        ),
                        10.hBox,
                        ReadMoreText(
                          widget.currentMoment.moment,
                          trimMode: TrimMode.Line,
                          trimLines: 2,
                          style: TextStyle(
                              fontSize: 15.sp,
                              color: ColorManager.momentPostTextColor,
                              fontWeight: FontWeight.w600),
                          trimCollapsedText: StringManager.showMore,
                          trimExpandedText: StringManager.showLess,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}