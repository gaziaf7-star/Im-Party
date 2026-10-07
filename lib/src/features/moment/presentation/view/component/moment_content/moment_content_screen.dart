import 'package:general/src/core/services/dynamic_link_handler.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/cache/cache_alpha_widget.dart';
import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
import 'package:general/src/core/widgets/cache/cache_video_widget.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_gift_bloc/moment_gift_bloc.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_likes_bloc/get_moment_likes_event.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_likes_bloc/moment_likes_bloc_bloc.dart';
import 'package:general/src/features/moment/presentation/bloc/send_moment_gift_bloc/send_moment_gift_bloc.dart';
import 'package:general/src/features/moment/presentation/view/component/gift_list/gift_list.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_state.dart';
import 'package:general/src/features/room/room.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../core/index.dart';
import '../../../../../../core/widgets/md_indicator.dart';
import '../../widgets/moment_comments_view.dart';
import '../../widgets/moment_content_item.dart';
import '../../widgets/moment_likes_view.dart';
import '../report_moment/report_moment_dialog.dart';

class MomentContentScreen extends StatefulWidget {
  final int momentId;
  final int currentMomentIndex;
  final MomentEntity currentMoment;
  final MomentType type;
  final MomentBloc momentBloc;

  const MomentContentScreen(
      {super.key,
        required this.momentId,
        required this.type,
        required this.currentMoment,
        required this.currentMomentIndex,
        required this.momentBloc});

  static String currentMomentId = "";

  @override
  State<MomentContentScreen> createState() => _MomentContentScreenState();
}

class _MomentContentScreenState extends State<MomentContentScreen>
    with TickerProviderStateMixin {
  TextEditingController controller = TextEditingController();

  late final TabController _controller;
  final ScrollController _scrollController = ScrollController();
  int currentIndex = 0;
  bool isTextEmpty = true;

  // Per-session set of moment ids whose view has already been recorded. Static
  // so re-opening the same moment within one app run never double-counts.
  static final Set<int> _recordedMomentIds = {};

  // Fires POST moment/{id}/view once per session. Fire-and-forget: never
  // awaited, failures are ignored so a lost view count can't affect the screen.
  void _recordMomentView(int momentId) {
    if (!_recordedMomentIds.add(momentId)) return;
    DioFactory().post(EndPoints.momentView(momentId.toString())).ignore();
  }

  @override
  void initState() {
    _controller =
        TabController(length: 2, animationDuration: Duration.zero, vsync: this);

    // listen to text input changes
    controller.addListener(() {
      setState(() {
        isTextEmpty = controller.text.trim().isEmpty;
      });
    });

    _controller.addListener(() {
      currentIndex = _controller.index;
      setState(() {}); // no need to update isTextEmpty here
    });

    MomentContentScreen.currentMomentId = widget.momentId.toString();
    di<MomentCommentBloc>()
        .add(AddListenerCommentEvent(momentId: widget.momentId.toString()));

    di<MomentGiftBloc>().add(GetMomentGifts(userId: widget.momentId));
    di<GetMomentLikesBloc>()
        .add(AddListenerLikeEvent(momentId: widget.momentId.toString()));

    _recordMomentView(widget.momentId);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    MomentContentScreen.currentMomentId = "";
    di<MomentCommentBloc>()
        .add(RemoveListenerCommentEvent(momentId: widget.momentId.toString()));
    di<GetMomentLikesBloc>()
        .add(RemoveListenerLikeEvent(momentId: widget.momentId.toString()));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendMomentGiftBloc, SendMomentGiftStates>(
      bloc: di<SendMomentGiftBloc>(),
      listener: (context, state) {
        if (state is LoadingSendGiftMomentStates) {
          Methods.showToast(context, isLoading: true);
        } else if (state is ErrorSendGiftMomentStates) {
          Methods.showToast(context, message: state.error, isError: true);
        } else if (state is SuccessSendGiftMomentStates) {
          di<MomentGiftBloc>().add(GetMomentGifts(userId: widget.momentId));
          Navigator.pop(context);
          Methods.showToast(context, message: state.message);
        }
      },
      child: BlocBuilder<MomentBloc, MomentStates>(
        bloc: widget.momentBloc,
        buildWhen: (prev, curr) =>
        prev.reqState != curr.reqState ||
            prev.reqFollowState != curr.reqFollowState ||
            prev.myReqState != curr.myReqState ||
            prev.reqLatestState != curr.reqLatestState ||
            prev.moments != curr.moments ||
            prev.followMoments != curr.followMoments ||
            prev.myMoments != curr.myMoments ||
            prev.latestMoments != curr.latestMoments,
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: widget.type == MomentType.recommend
                ? state.reqState
                : widget.type == MomentType.follow
                ? state.reqFollowState
                : widget.type == MomentType.myMoment
                ? state.myReqState
                : state.reqLatestState,
            title: StringManager.noMomentsFound.tr(),
            subTitle: StringManager.noMomentsFoundSubTitle.tr(),
            // Light-black text (was the default panel-driven textPrimary) —
            // requested to match the rest of the Moment redesign — and a
            // filled brand-gradient "Refresh" button instead of the plain
            // outline one.
            titleStyle: context.bodyLarge.w600
                .colorExt(ColorManager.momentPostTextColor),
            subTitleStyle: context.bodyMedium.copyWith(
              color: ColorManager.momentPostTextColor.withValues(alpha: 0.7),
              height: 1.30,
            ),
            buttonBackgroundColors: ColorManager.brandGradientColors,
            buttonBorderColor: ColorManager.transparent,
            onTap: () {
              di<MomentCommentBloc>().add(FetchMomentComment(
                  momentId: widget.momentId.toString(), page: "1"));
              di<GetMomentLikesBloc>().add(GetMomentLikesEvent(
                  momentId: widget.momentId.toString(), page: "1"));
            },
            child: RefreshIndicator(
              onRefresh: () async {
                di<MomentCommentBloc>().add(FetchMomentComment(
                    momentId: widget.momentId.toString(), page: "1"));
                di<GetMomentLikesBloc>().add(GetMomentLikesEvent(
                    momentId: widget.momentId.toString(), page: "1"));
                di<MomentGiftBloc>()
                    .add(GetMomentGifts(userId: widget.momentId));
              },
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: ColorManager.white,
                appBar: AppBarWidget(
                  // Brand gradient app bar (was the flat panel-driven
                  // scaffoldBg) — requested so every app bar shares the one
                  // accent.
                  backgroundGradient: ColorManager.brandGradient,
                  titleStyle: context.titleLarge.w600
                      .size(16)
                      .colorExt(ColorManager.white),
                  iconColor: ColorManager.white,
                  title: StringManager.statusDetails.tr(),
                  actions: [
                    PopupMenuButton<int>(
                      icon: Icon(
                        Icons.more_horiz,
                        size: 28.sp,
                        // White — was textPrimary (often dark), invisible
                        // against the new gradient app bar behind it.
                        color: ColorManager.white,
                      ),
                      onSelected: (value) async {
                        if (value == 1) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MomentReportDialog(
                                    momentId: widget.currentMoment.momentId
                                        .toString(),
                                  )));
                        } else if ((value == 2)) {
                          widget.momentBloc.add(
                            DeleteMomentData(
                              type: widget.type,
                              momentId:
                              widget.currentMoment.momentId.toString(),
                              context: context,
                            ),
                          );
                        } else if ((value == 3)) {
                          try {
                            final Map<String, dynamic> map_ = {
                              'type': 'moment',
                              'id': widget.momentId,
                              'data':
                              MomentModel.fromEntity(widget.currentMoment),
                              'path': 'moment',
                            };
                            final String dynamicLink = await DynamicLinkHandler
                                .instance
                                .createProductLink(
                              map_,
                              'moment',
                            );
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
                        }
                      },
                      itemBuilder: (context) => [
                        if (MyDataModel.getInstance().uuid !=
                            widget.currentMoment.uuid)
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
                        if (MyDataModel.getInstance().uuid ==
                            widget.currentMoment.uuid)
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
                        PopupMenuItem(
                          value: 3,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AssetsManager.shareMoment,
                                  height: 20.w,
                                  width: 20.w,
                                  color: ColorManager.white,
                                ),
                                5.wBox,
                                TextWidget(
                                  StringManager.share.tr(),
                                  textAlign: TextAlign.center,
                                  style: context.bodyMedium
                                      .colorExt(ColorManager.white),
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
                body: Stack(
                  children: [
                    SafeArea(
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: MomentContentItem(
                              type: widget.type,
                              momentBloc: widget.momentBloc,
                              moment: widget.type == MomentType.recommend
                                  ? state.moments[widget.currentMomentIndex]
                                  : widget.type == MomentType.follow
                                  ? state.followMoments[
                              widget.currentMomentIndex]
                                  : widget.type == MomentType.myMoment
                                  ? state.myMoments[
                              widget.currentMomentIndex]
                                  : state.latestMoments[
                              widget.currentMomentIndex],
                              currentMomentIndex: widget.currentMomentIndex,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: 2.hBox,
                          ),
                          const SliverToBoxAdapter(
                            child: GiftListView(),
                          ),
                          SliverToBoxAdapter(
                            child: 5.hBox,
                          ),
                          SliverToBoxAdapter(
                            child: MomentContentTabBar(
                              controller: _controller,
                              likesCount: (widget.type == MomentType.recommend
                                  ? state.moments[widget.currentMomentIndex]
                                  : widget.type == MomentType.follow
                                  ? state.followMoments[
                              widget.currentMomentIndex]
                                  : widget.type == MomentType.myMoment
                                  ? state.myMoments[
                              widget.currentMomentIndex]
                                  : state.latestMoments[
                              widget.currentMomentIndex])
                                  .likeNum,
                              commentsCount: (widget.type ==
                                  MomentType.recommend
                                  ? state.moments[widget.currentMomentIndex]
                                  : widget.type == MomentType.follow
                                  ? state.followMoments[
                              widget.currentMomentIndex]
                                  : widget.type == MomentType.myMoment
                                  ? state.myMoments[
                              widget.currentMomentIndex]
                                  : state.latestMoments[
                              widget.currentMomentIndex])
                                  .commentNum,
                            ),
                          ),
                          if (_controller.index == 0) ...[
                            MomentCommentsView(momentId: widget.momentId),
                            SliverToBoxAdapter(
                              child: 80.hBox,
                            ),
                          ],
                          if (_controller.index == 1)
                            MomentLikesView(momentId: widget.momentId),
                        ],
                      ),
                    ),
                    _controller.index == 0
                        ? Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        // Was 80.h — requested a bit shorter.
                        height: 65.h,
                        width: ScreenUtil().screenWidth,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: ColorManager.white,
                            borderRadius: BorderRadius.only(
                              topLeft: 10.radiusCircular,
                              topRight: 10.radiusCircular,
                            )),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextInputWidget(
                                StringManager.pleaseComment.tr(),
                                controller: controller,
                                fillColor: ColorManager.white,
                                textColor: Colors.black54,
                                enabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.black54
                                ),
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Row(
                              children: [
                                if (!isTextEmpty)
                                  Container(
                                    padding: context.paddingSymmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      // Brand gradient (was the flat
                                      // panel-driven ColorManager.primary)
                                      // — requested for every button on
                                      // this page.
                                      gradient: ColorManager.brandGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (controller.text.isNotEmpty) {
                                          di<MomentCommentBloc>().add(
                                              AddMomentComment(
                                                  type: widget.type,
                                                  momentBloc:
                                                  widget.momentBloc,
                                                  momentId: widget
                                                      .momentId
                                                      .toString(),
                                                  comment:
                                                  controller.text));
                                          controller.clear();
                                        }
                                      },
                                      child: ImageWidget(
                                        height: 18,
                                        width: 20,
                                        boxFit: BoxFit.fill,
                                        image: AssetsManager.sendIcon,
                                        // White — was the panel-driven
                                        // buttonTextColor (often dark),
                                        // which could go invisible on
                                        // the new gradient circle.
                                        color: ColorManager.white,
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 10.w),
                                if (isTextEmpty)
                                  InkWell(
                                    onTap: () {
                                      bottomDailog(
                                        context: context,
                                        barrierColor:
                                        ColorManager.transparent,
                                        widget: GiftScreen(
                                          isAudioRoom: false,
                                          roomData: EnterRoomModel(),
                                          userId: widget
                                              .currentMoment.userId
                                              .toString(),
                                          myDataModel:
                                          MyDataModel.getInstance(),
                                          userImage: widget
                                              .currentMoment.userImage,
                                          userName: widget
                                              .currentMoment.userName,
                                          users: null,
                                          isSingleUser: true,
                                          momentId:
                                          widget.momentId.toString(),
                                        ),
                                      );
                                    },
                                    child: ShowSVGA(
                                      svgaAssetPath:
                                      AssetsManager.giftRoom,
                                      width: 35.w,
                                      height: 35.h,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                        : const SizedBox(),
                    BlocBuilder<SendMomentGiftBloc, SendMomentGiftStates>(
                      bloc: di<SendMomentGiftBloc>(),
                      buildWhen: (prev, curr) => prev != curr,
                      builder: (context, state) {
                        return state is SuccessSendGiftMomentStates
                            ? BlocBuilder<GiftBloc, GiftState>(
                          bloc: di<GiftBloc>(),
                          buildWhen: (prev, curr) =>
                          prev.isShowGift != curr.isShowGift ||
                              prev.gift != curr.gift ||
                              prev.giftType != curr.giftType,
                          builder: (context, state) {
                            if (state.isShowGift == true &&
                                state.gift != "") {
                              if (state.giftType == ShowGiftType.alpha) {
                                return BlocBuilder<AlphaGiftManagerBloc,
                                    AlphaGiftManagerState>(
                                  bloc: di<AlphaGiftManagerBloc>(),
                                  buildWhen: (prev, curr) => prev != curr,
                                  builder: (context, alphaState) {
                                    if (alphaState
                                    is AlphaGiftManagerShowGift) {
                                      return CacheAlphaWidget(
                                        url: EndPoints.getImage(
                                            alphaState.giftPath),
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  },
                                );
                              } else if (state.giftType ==
                                  ShowGiftType.mp4) {
                                return SizedBox(
                                  height:
                                  MediaQuery.of(context).size.height *
                                      0.730,
                                  width:
                                  MediaQuery.of(context).size.width,
                                  child: CacheVideoWidget(
                                    videoUrl:
                                    EndPoints.getImage(state.gift),
                                    isShowGift: true,
                                  ),
                                );
                              } else if (state.giftType ==
                                  ShowGiftType.vap) {
                                return SizedBox(
                                  height:
                                  MediaQuery.of(context).size.height *
                                      0.730,
                                  width:
                                  MediaQuery.of(context).size.width,
                                  child: CachedVapWidget(
                                    url: EndPoints.getImage(state.gift),
                                    height: ScreenUtil().screenHeight,
                                    width: ScreenUtil().screenWidth,
                                  ),
                                );
                              } else {
                                return CacheSvgaWidget(
                                  url: EndPoints.getImage(state.gift),
                                  isShowGift: true,
                                );
                              }
                            } else {
                              return const SizedBox();
                            }
                          },
                        )
                            : const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MomentContentTabBar extends StatelessWidget {
  const MomentContentTabBar({
    super.key,
    required this.likesCount,
    required this.controller,
    required this.commentsCount,
  });

  final TabController controller;
  final int commentsCount;
  final int likesCount;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicatorSize: TabBarIndicatorSize.label,
      dividerHeight: 0,
      tabAlignment: TabAlignment.start,
      indicatorPadding: context.paddingSymmetric(horizontal: 10),
      isScrollable: true,
      indicator: MDIndicator(
        // Fixed light-black (was the panel-driven lightBlack) — requested
        // for this Comments/Likes tab bar specifically.
          indicatorColor: ColorManager.momentPostTextColor,
          indicatorWidth: 17.w,
          indicatorHeight: 4.h,
          radius: 20),
      indicatorColor: ColorManager.momentPostTextColor,
      labelPadding: context.paddingSymmetric(horizontal: 10),
      unselectedLabelStyle: context.bodyMedium
          .colorExt(ColorManager.momentPostTextColor.withValues(alpha: 0.5))
          .size(16),
      labelStyle: context.bodyMedium.w600
          .colorExt(ColorManager.momentPostTextColor)
          .size(16),
      tabs: [
        Text("${StringManager.comments.tr()} $commentsCount"),
        Text("$likesCount ${StringManager.likes.tr()}"),
      ],
    );
  }
}