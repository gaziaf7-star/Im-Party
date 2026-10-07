import 'dart:async';
import 'dart:convert';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/presentation/splash/get_vip_frames_bloc/get_vip_frames_bloc.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/cache/cache_alpha_widget.dart';
import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
import 'package:general/src/core/widgets/cache/cache_video_widget.dart';
import 'package:general/src/core/widgets/gender_widget.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/auth/data/model/vip_frames_model.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_event.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_state.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/domain/profile_use_case/follow_unfollow_use_case.dart';
import 'package:general/src/features/room/presentation/component/profile/widgets/follow_button.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/component/messages/messages_button/input_board.dart';

import '../../../room.dart';
import 'bloc/extra_data_profile_bloc.dart';
import 'component/profile_permission_menu.dart';
import 'component/second_card_body.dart';

class ProfileBody extends StatefulWidget {
  final EnterRoomModel roomData;
  final UserInRoomModel userData;
  final bool isMyProfile;
  final String userId;

  const ProfileBody({
    super.key,
    required this.roomData,
    required this.userData,
    required this.isMyProfile,
    required this.userId,
  });

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  String vipImage = '';
  String vipType = '';
  String vipId = '';
  bool? halfImageProfile;
  ValueNotifier<Color?> backgroundColor =
  ValueNotifier<Color?>(ColorManager.black);
  late final GetUserBadgesBloc getUserBadgesBloc;
  late final FollowBloc _followBloc;
  late final FetchExtraDataBloc _fetchExtraDataBloc;
  StreamSubscription<GetVipFramesState>? _vipFramesSub;

  @override
  void initState() {
    super.initState();
    _resolveVipFrame();
    _ensureVipFramesCached();
    _fetchExtraDataBloc = di<FetchExtraDataBloc>();
    _fetchExtraDataBloc.add(FetchExtraDataProfile(userId: widget.userId));
    getUserBadgesBloc = di<GetUserBadgesBloc>();
    getUserBadgesBloc.add(GetUserBadgesData(id: int.tryParse(widget.userId) ?? 0));
    _followBloc = FollowBloc(
      makeFollowUseCase: di<MakeFollowUseCase>(),
      makeUnFollowUseCase: di<MakeUnFollowUseCase>(),
    );
  }

  @override
  void didUpdateWidget(covariant ProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // UserRoomProfile shows a cached UserInRoomModel instantly, then swaps in
    // a freshly-fetched one once it lands (same State is reused, so initState
    // does not run again). Without this, a profile-card frame equipped AFTER
    // the cache snapshot was taken never appeared here even though the plain
    // avatar frame (read directly off widget.userData in build) updated fine.
    if (oldWidget.userData.profileFrameId != widget.userData.profileFrameId) {
      _resolveVipFrame();
    }
  }

  @override
  void dispose() {
    _vipFramesSub?.cancel();
    _followBloc.close();
    super.dispose();
  }

  /// The VIP/profile-frame catalog is fetched once at splash and cached to
  /// Hive (see GetVipFramesBloc) — this sheet only ever READS that cache. If
  /// the sheet is opened before that one-time fetch has landed (e.g. right
  /// after a fresh install/login, or the request was still in flight), the
  /// cache is empty and no profile-card frame can ever resolve even though
  /// the user genuinely has one equipped. Kick a fetch here too and re-resolve
  /// once it completes, instead of leaving the frame permanently blank for
  /// the rest of this session.
  void _ensureVipFramesCached() {
    final jsonData = HiveManager().getData(
      KeysManager.FRAMES_BOX,
      KeysManager.VIP_FRAMES_KEY,
    );
    if (jsonData != null) return;

    final bloc = di<GetVipFramesBloc>();
    _vipFramesSub = bloc.stream.listen((state) {
      if (state.requestState.isLoaded) {
        _vipFramesSub?.cancel();
        _vipFramesSub = null;
        if (mounted) setState(_resolveVipFrame);
      }
    });
    if (!bloc.state.requestState.isLoading) {
      bloc.add(GetVipFramesEvent());
    }
  }

  void _resolveVipFrame() {
    final wantedId = (widget.userData.profileFrameId ?? '0').toString();
    final jsonData = HiveManager().getData(
      KeysManager.FRAMES_BOX,
      KeysManager.VIP_FRAMES_KEY,
    );
    if (jsonData == null) {
      Methods.printLog(
          '🖼️ [ProfileCardFrame] no cached VIP_FRAMES_KEY at all — wanted id=$wantedId');
      return;
    }
    final List decoded;
    try {
      final result = jsonDecode(jsonData);
      if (result is! List) {
        Methods.printLog(
            '🖼️ [ProfileCardFrame] cached VIP_FRAMES_KEY is not a List — wanted id=$wantedId');
        return;
      }
      decoded = result;
    } catch (e) {
      Methods.printLog(
          '🖼️ [ProfileCardFrame] failed to decode VIP_FRAMES_KEY: $e');
      return;
    }
    for (var item in decoded) {
      final vipFrame = VipFramesModel.fromJson(item);
      if (vipFrame.id.toString() == wantedId) {
        vipImage = vipFrame.image ?? '';
        halfImageProfile = vipFrame.isHalfFrame ?? false;
        vipType = vipFrame.imageType ?? '';
        vipId = '${vipFrame.id ?? '0'}';
        Methods.printLog(
            '🖼️ [ProfileCardFrame] matched id=$wantedId → image=$vipImage type=$vipType half=$halfImageProfile');
        return;
      }
    }
    Methods.printLog(
        '🖼️ [ProfileCardFrame] no match for id=$wantedId among ${decoded.length} cached frames '
        '(ids=${decoded.map((e) => VipFramesModel.fromJson(e).id).toList()})');
  }

  @override
  Widget build(BuildContext context) {
    final hasProfileFrame = (widget.userData.profileFrameId != null &&
        widget.userData.profileFrameId != "" &&
        widget.userData.profileFrameId != "0");
    final screenWidth = ScreenUtil().screenWidth;
    bool isOnSeat = RoomData.instance.utdController?.seatController
        .isUserOnSeat(widget.userData.id.toString()) ??
        false;
    backgroundColor.value = vipImage.isEmpty
        ? ColorManager.whiteGrey
        : halfImageProfile == true
        ? ColorManager.whiteGrey
        : hasProfileFrame
        ? ColorManager.transparent
        : ColorManager.whiteGrey;

    Widget buildProfileFrame({required bool ignorePointer}) {
      // No VIP frame for this user: render nothing. Rendering an empty-url image
      // here would fire detectError and flip backgroundColor to black, turning
      // the profile sheet's button black-on-black. Keep the light default.
      if (vipImage.isEmpty) return const SizedBox.shrink();
      final Widget frameWidget = Methods().isSvgaFile(vipImage)
          ? CacheSvgaWidget(
        url: vipImage,
        boxFit: BoxFit.fill,
        width: screenWidth,
        detectError: () {
          backgroundColor.value = ColorManager.black;
        },
      )
          : vipType == 'mp4'
          ? CacheVideoWidget(
        videoUrl: vipImage,
        width: screenWidth,
        isReels: true,
        detectError: () {
          backgroundColor.value = ColorManager.black;
        },
      )
          : vipType == 'vap'
          ? CachedVapWidget(
        isLoop: true,
        url: vipImage,
        width: screenWidth,
        detectError: () {
          backgroundColor.value = ColorManager.black;
        },
      )
          : vipType == 'alpha'
          ? CacheAlphaWidget(
        url: vipImage,
        width: screenWidth,
        isLoop: true,
        detectError: () {
          backgroundColor.value = ColorManager.black;
        },
      )
          : ImageViewWidget(
        url: vipImage,
        boxFit: BoxFit.cover,
        width: screenWidth,
        heightLoading: 100.h,
        widthLoading: screenWidth,
        isRoomProfile: true,
        isStopForProfileRoom: false,
        isStopLoadingAndError: false,
        detectError: () {
          Methods.printLog('ProfileFrame detectError ');
          backgroundColor.value = ColorManager.black;
        },
      );

      return Positioned(
        top: ignorePointer ? -150.h : -85.h,
        left: 0,
        right: 0,
        bottom: 0,
        child: ignorePointer ? IgnorePointer(child: frameWidget) : frameWidget,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (hasProfileFrame && halfImageProfile == false)
          buildProfileFrame(ignorePointer: true),
        ValueListenableBuilder(
            valueListenable: backgroundColor,
            builder: (context, value, child) {
              return Container(
                decoration: BoxDecoration(
                  color: value,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(10.r)),
                ),
                child: Padding(
                  padding: context.paddingOnly(
                    start: 0,
                    top: backgroundColor.value != ColorManager.black
                        ? halfImageProfile == true
                        ? 35
                        : (hasProfileFrame && halfImageProfile == false)
                        ? 120
                        : 35
                        : 35,
                    end: 0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nudged further down on request (was 10).
                      20.verticalSpace,
                      InkWell(
                        onTap: () {
                          final int? targetId = widget.userData.id;
                          if (targetId == null || targetId == 0) return;
                          context.popRoute();
                          Methods().userProfileNavigator(
                            context: context,
                            user_: const UserEntity(),
                            comesFromRoom: true,
                            userId: targetId.toString(),
                          );
                        },
                        child: UserImage(
                          image: widget.userData.image ?? '',
                          displayName: widget.userData.name ?? '',
                          imageSize: 80,
                          frame: widget.userData.frame,
                          frameType: widget.userData.frameType,
                          frameSize: 125,
                        ),
                      ),
                      // Was 10.hBox, then 6.hBox -- tightened further on request.
                      3.hBox,
                      GradientTextVip(
                        width: 220.w,
                        // On the light room-profile sheet the old VIP name tint
                        // could become nearly invisible. Keep the shimmer only
                        // on dark framed backgrounds; otherwise force crisp black
                        // text so the name is always readable.
                        isVip: value == ColorManager.black &&
                            widget.userData.vipColorName != null &&
                            (widget.userData.vipColorName ?? '')
                                .startsWith('#'),
                        text: widget.userData.name ?? '',
                        color: value == ColorManager.black
                            ? (Methods.safeHexColor(
                            widget.userData.vipColorName) ??
                            ColorManager.white)
                            : ColorManager.black,
                        mainAxisAlignment: MainAxisAlignment.center,
                        textAlign: TextAlign.center,
                        textStyle: context.bodyMedium.w600.size(18).colorExt(
                          value == ColorManager.black
                              ? (Methods.safeHexColor(
                              widget.userData.vipColorName) ??
                              ColorManager.white)
                              : ColorManager.black,
                        ),
                      ),
                      5.hBox,
                      // ID row: gender + ID only now -- the country flag
                      // moved down into its own row with the level images,
                      // on request.
                      Row(
                        children: [
                          const Spacer(),
                          GenderWidget(
                            age: widget.userData.age ?? 0,
                            gender: widget.userData.gender ?? 0,
                          ),
                          5.wBox,
                          IdWithCopyIcon(
                            userId: widget.userData.uuid ?? '',
                            isNeedCopyIcon: true,
                            isSpecial: (widget.userData.specialId != null &&
                                (widget.userData.specialId ?? '') != ''),
                            specialImg: widget.userData.idImage ?? '',
                            // Wider than the shared default (50.w), to
                            // match the full profile page, on request.
                            specialImgWidth: 80.w,
                            color: widget.userData.imageColorEntity?.color,
                            img: widget.userData.imageColorEntity?.image,
                            mainAxisAlignment: MainAxisAlignment.start,
                            idColor: ColorManager.greyTextColor,
                            idStyle: context.bodyMedium.bold
                                .colorExt(
                                widget.userData.imageColorEntity?.color !=
                                    null &&
                                    widget.userData.imageColorEntity
                                        ?.color?.isNotEmpty ==
                                        true
                                    ? Color(int.tryParse(widget
                                    .userData.imageColorEntity!.color!
                                    .replaceAll('#', '0xff')) ?? 0xFF000000)
                                    : ColorManager.black)
                                .copyWith(height: 0.1, fontSize: 11.sp),
                          ),
                          const Spacer(),
                        ],
                      ),
                      3.hBox,
                      // Level images + country flag, together, on request --
                      // the flag moved down here from the ID row above.
                      Builder(builder: (context) {
                        final hasSender =
                            widget.userData.senderLevelImage != "";
                        final hasReceiver =
                            widget.userData.receiverLevelImage != "";
                        final hasFlag = widget.userData.isCountryHidden !=
                                true &&
                            widget.userData.countryImage != null;
                        if (!hasSender && !hasReceiver && !hasFlag) {
                          return const SizedBox();
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasSender) ...[
                              LevelContainer(
                                image: widget.userData.senderLevelImage ?? "",
                              ),
                              // Tightened to match the badge row right below
                              // (2.wBox), on request -- close together, not
                              // touching with zero gap.
                              2.wBox,
                            ],
                            if (hasReceiver) ...[
                              LevelContainer(
                                image:
                                    widget.userData.receiverLevelImage ?? "",
                              ),
                              2.wBox,
                            ],
                            if (hasFlag)
                              ImageViewWidget(
                                url: widget.userData.countryImage ?? "",
                                height: 20.h,
                                width: 25.w,
                                boxFit: BoxFit.cover,
                              ),
                          ],
                        );
                      }),
                      3.hBox,
                      BlocBuilder<GetUserBadgesBloc, GetUserBadgesState>(
                        bloc: getUserBadgesBloc,
                        buildWhen: (prev, curr) =>
                        prev.userBadge != curr.userBadge,
                        builder: (context, state) {
                          final userBadgesData = [
                            ...(state.userBadge?.top ?? []),
                            ...(state.userBadge?.regular ?? []),
                          ];
                          // SVIP badge + the rest of the badges, one line,
                          // scrollable, gap tightened further and images made
                          // bigger, on request.
                          return SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.8,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // VIP Container
                                  if (widget.userData.vipImage != "") ...[
                                    VipContainer(
                                      vip: widget.userData.vipImage ?? "",
                                      height: 32.h,
                                      width: 58.w,
                                    ),
                                    2.wBox,
                                  ],

                                  // User badges from BlocBuilder
                                  for (final badgeData in userBadgesData) ...[
                                    badgeData.imageType == "svga"
                                        ? CacheSvgaWidget(
                                      url: EndPoints.getImage(
                                          badgeData.image),
                                      boxFit: BoxFit.contain,
                                      height: 40.h,
                                      width: 110.w,
                                    )
                                        : ImageViewWidget(
                                      url: EndPoints.getImage(
                                          badgeData.image),
                                      height: 40.h,
                                      width: 110.w,
                                      boxFit: BoxFit.contain,
                                    ),
                                    if (badgeData != userBadgesData.last)
                                      2.wBox,
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      5.hBox,
                      Padding(
                        padding: context.paddingSymmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SecondCardRoomProfileBody(
                              userData: widget.userData,
                            ),
                            10.hBox,
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: [
                                if (widget.userData.id !=
                                    MyDataModel.getInstance().id)
                                  BlocBuilder<FetchExtraDataBloc,
                                      FetchExtraDataStates>(
                                    bloc: _fetchExtraDataBloc,
                                    builder: (context, state) {
                                      if (state.extraProfileData != null) {
                                        return FollowButton(
                                          userData: widget.userData,
                                          initialIsFollow: state
                                              .extraProfileData?.isFollow ??
                                              false,
                                          followBloc: _followBloc,
                                        );
                                      } else if (state.requestState.isError ||
                                          state.requestState ==
                                              RequestState.offline) {
                                        return const SizedBox();
                                      } else {
                                        return SizedBox(
                                          width: 90.w,
                                          height: 38.h,
                                          // Not const: textPrimary is resolved
                                          // per theme at runtime.
                                          child: Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: ColorManager.textPrimary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                // Mention "@" — quick, always-visible action next
                                // to send-gift (for other users in an audio room),
                                // instead of being buried in the 3-dots menu.
                                if (widget.userData.id !=
                                    MyDataModel.getInstance().id &&
                                    di<RoomStateManager>().isInAudioRoom) ...[
                                  ButtonWidget(
                                    onPressed: () {
                                      final name = widget.userData.name
                                          ?.replaceAll(" ", "_") ??
                                          "";
                                      final nav = Navigator.of(context);
                                      nav.pop();
                                      nav.push(
                                        AudioRoomInRoomMessageInputBoard(
                                          mention: "@$name",
                                        ),
                                      );
                                    },
                                    width: 52.w,
                                    height: 38.h,
                                    radius: 22,
                                    backgroundColors: const [
                                      Color(0xFF6E2BFF),
                                      Color(0xFF22B8FF),
                                    ],
                                    paddingButton: EdgeInsets.zero,
                                    title: Center(
                                      child: TextWidget(
                                        "@",
                                        style: context.bodyLarge.bold
                                            .copyWith(fontSize: 17.sp)
                                            .colorExt(ColorManager.white),
                                      ),
                                    ),
                                  ),
                                ],
                                ButtonWidget(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    bottomDailog(
                                      context: context,
                                      barrierColor: ColorManager.transparent,
                                      widget: GiftScreen(
                                        roomData: widget.roomData,
                                        userId: widget.userData.id.toString(),
                                        myDataModel: MyDataModel.getInstance(),
                                        userImage: widget.userData.image ?? '',
                                        userName: widget.userData.name ?? '',
                                        users: null,
                                        isSingleUser: true,
                                        isAudioRoom: true,
                                      ),
                                    );
                                  },
                                  width: 122.w,
                                  height: 38.h,
                                  radius: 22,
                                  backgroundColors: const [
                                    Color(0xFF7B2FF7),
                                    Color(0xFF3A7BFF),
                                  ],
                                  paddingButton: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        AssetsManager.sendGiftRoom,
                                        height: 20.h,
                                      ),
                                      8.wBox,
                                      TextWidget(
                                        StringManager.sendGift.tr(),
                                        style: context.bodyMedium.bold
                                            .copyWith(fontSize: 12.sp)
                                            .colorExt(ColorManager.white),
                                      ),
                                    ],
                                  ),
                                ),
                                (((widget.roomData.ownerId ==
                                    MyDataModel.getInstance()
                                        .id &&
                                    widget.userData.id !=
                                        MyDataModel.getInstance()
                                            .id) ||
                                    (widget.userData.id ==
                                        MyDataModel.getInstance().id) ||
                                    ((RoomData.instance.adminsInRoom
                                        .containsKey(
                                      MyDataModel.getInstance()
                                          .id
                                          .toString(),
                                    ) &&
                                        (RoomData.instance
                                            .adminsInRoom
                                            .containsKey(
                                          widget.userData.id
                                              .toString(),
                                        )) ==
                                            false) &&
                                        widget.userData.id !=
                                            widget.roomData.ownerId)) &&
                                    isOnSeat)
                                    ? ButtonWidget(
                                  onPressed: () async {
                                    if (widget.userData.id ==
                                        MyDataModel.getInstance()
                                            .id) {
                                      final controller = RoomData.instance.utdController;
                                      if (controller != null) {
                                        // Best-effort leave; leaveSeat
                                        // returns false on rejection
                                        // (no longer throws).
                                        await controller.seatController.leaveSeat(
                                          MyDataModel.getInstance().id.toString(),
                                        );
                                      }
                                      Navigator.pop(context);
                                    } else {
                                      try {
                                        final controller = RoomData.instance.utdController;
                                        if (controller != null) {
                                          final userId = widget.userData.id.toString();
                                          final seatIndex = controller.seatController.getSeatIndexByUserId(userId);
                                          if (seatIndex >= 0) {
                                            await controller.seatController.kickFromSeat(seatIndex, identity: MyDataModel.getInstance().id.toString());
                                          }
                                        }
                                        kickUserfromMic(
                                          userId: widget.userData.id.toString(),
                                        );
                                        if (context.mounted) context.popRoute();
                                      } catch (e) {
                                        if (context.mounted) {
                                          Methods.showToast(context, isError: true, message: e.toString());
                                        }
                                      }
                                    }
                                  },
                                  width: 112.w,
                                  height: 38.h,
                                  radius: 22,
                                  backgroundColors: const [
                                    Color(0xFF2F2F3A),
                                    Color(0xFF505061),
                                  ],
                                  paddingButton:
                                  context.paddingAll(8),
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        AssetsManager.downArrow,
                                        height: 18.h,
                                      ),
                                      8.wBox,
                                      TextWidget(
                                        StringManager.leaveSeat
                                            .tr(),
                                        style: context
                                            .bodyMedium.bold
                                            .copyWith(fontSize: 12.sp)
                                            .colorExt(ColorManager
                                            .white),
                                      ),
                                    ],
                                  ),
                                )
                                    : const SizedBox(),
                              ],
                            ),
                            10.hBox,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        if (MyDataModel.getInstance().id != widget.userData.id)
          Positioned(
            right: 15,
            top: (hasProfileFrame && halfImageProfile == false) ? 105.h : 15.h,
            child: ProfilePermissionMenu(
              roomData: widget.roomData,
              halfImageProfile: halfImageProfile,
              userData: widget.userData,
            ),
          ),
        if (hasProfileFrame && halfImageProfile == true)
          buildProfileFrame(ignorePointer: false),
      ],
    );
  }
}
