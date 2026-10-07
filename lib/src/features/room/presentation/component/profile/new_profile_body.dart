import 'dart:async';
import 'dart:convert';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/auth/presentation/splash/get_vip_frames_bloc/get_vip_frames_bloc.dart';
import 'package:general/src/core/widgets/cache/cache_alpha_widget.dart';
import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
import 'package:general/src/core/widgets/cache/cache_video_widget.dart';
import 'package:general/src/core/widgets/gender_widget.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/auth/data/model/vip_frames_model.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_event.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_state.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/presentation/component/profile/component/new_profile_permission_menu.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/domain/profile_use_case/follow_unfollow_use_case.dart';
import 'package:general/src/features/room/presentation/component/profile/widgets/new_follow_button.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';

import 'package:general/src/features/room/presentation/component/messages/messages_button/input_board.dart';
import '../../../room.dart';
import 'bloc/extra_data_profile_bloc.dart';

class NewProfileBody extends StatefulWidget {
  final EnterRoomModel roomData;
  final UserInRoomModel userData;
  final bool isMyProfile;
  final String userId;

  const NewProfileBody({
    super.key,
    required this.roomData,
    required this.userData,
    required this.isMyProfile,
    required this.userId,
  });

  @override
  State<NewProfileBody> createState() => _NewProfileBodyState();
}

class _NewProfileBodyState extends State<NewProfileBody> {
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
  void didUpdateWidget(covariant NewProfileBody oldWidget) {
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
      // No VIP frame: render nothing. An empty-url image here would fire
      // detectError and flip backgroundColor to black (black-on-black button).
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
              : vipType == 'vap' && Methods.isVideoFile(vipImage)
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

      if (!ignorePointer) {
        return frameWidget;
      }
      return Positioned(
        top: -70.h,
        left: 0,
        right: 0,
        bottom: 0,
        child: IgnorePointer(child: frameWidget),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        minHeight: 300.h,
      ),
      child: Stack(
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
                  child: SingleChildScrollView(
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
                        // Nudged further down on request.
                        60.verticalSpace,
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
                        10.hBox,
                        GradientTextVip(
                          width: 150.w,
                          isVip: widget.userData.vipColorName != null &&
                              (widget.userData.vipColorName ?? '')
                                  .startsWith('#'),
                          text: widget.userData.name ?? '',
                          color: Methods.safeHexColor(
                                  widget.userData.vipColorName) ??
                              ColorManager.blackColor,
                          mainAxisAlignment: MainAxisAlignment.start,
                          textAlign: TextAlign.center,
                          textStyle: context.bodyMedium.w500.size(18).colorExt(
                              Methods.safeHexColor(
                                      widget.userData.vipColorName) ??
                                  ColorManager.blackColor),
                        ),
                        5.hBox,
                        Row(
                          children: [
                            const Spacer(),
                            if (widget.userData.isCountryHidden != true)
                              if (widget.userData.countryImage != null)
                                ImageViewWidget(
                                  url: widget.userData.countryImage ?? "",
                                  height: 20.h,
                                  width: 25.w,
                                  boxFit: BoxFit.cover,
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
                                          ? Color(int.tryParse((widget
                                                          .userData
                                                          .imageColorEntity
                                                          ?.color ??
                                                      '')
                                                  .replaceAll('#', '0xff')) ??
                                              0xFF000000)
                                          : ColorManager.black)
                                  .copyWith(height: 0.1, fontSize: 11.sp),
                            ),
                            const Spacer(),
                          ],
                        ),
                        BlocBuilder<FetchExtraDataBloc, FetchExtraDataStates>(
                          bloc: _fetchExtraDataBloc,
                          buildWhen: (prev, curr) =>
                              prev.extraProfileData != curr.extraProfileData,
                          builder: (context, extraDataState) {
                            return BlocBuilder<GetUserBadgesBloc,
                                GetUserBadgesState>(
                              bloc: getUserBadgesBloc,
                              buildWhen: (prev, curr) =>
                                  prev.userBadge != curr.userBadge,
                              builder: (context, state) {
                                final userBadgesData = [
                                  ...(state.userBadge?.top ?? []),
                                  ...(state.userBadge?.regular ?? []),
                                ];
                                final userMedals = [
                                  ...(extraDataState.extraProfileData
                                          ?.achievementImages ??
                                      []),
                                ];
                                return SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.8,
                                  child: Wrap(
                                    spacing: 5.w,
                                    runSpacing: 3.h,
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      if (userMedals.isNotEmpty)
                                        ...userMedals.map(
                                          (badgeData) {
                                            return badgeData.contains(".svg")
                                                ? CacheSvgaWidget(
                                                    url: EndPoints.getImage(
                                                        badgeData),
                                                    boxFit: BoxFit.cover,
                                                    height: 25.h,
                                                    width: 25.h,
                                                  )
                                                : CacheImageWidget(
                                                    url: EndPoints.getImage(
                                                        badgeData),
                                                    height: 25.h,
                                                    width: 25.w,
                                                    boxFit: BoxFit.cover,
                                                  );
                                          },
                                        ),
                                      // VIP Container
                                      if (widget.userData.vipImage?.isNotEmpty == true)
                                        VipContainer(
                                          vip: widget.userData.vipImage ?? "",
                                          height: 20.h,
                                          width: 38.w,
                                        ),

                                      // Sender Level Container
                                      if (widget.userData.senderLevelImage?.isNotEmpty == true)
                                        LevelContainer(
                                          image: widget
                                                  .userData.senderLevelImage ??
                                              "",
                                        ),

                                      // Receiver Level Container
                                      if (widget.userData.receiverLevelImage?.isNotEmpty == true)
                                        LevelContainer(
                                          image: widget.userData
                                                  .receiverLevelImage ??
                                              "",
                                        ),

                                      GenderWidget(
                                        age: widget.userData.age ?? 0,
                                        gender: widget.userData.gender ?? 0,
                                        widthSize: 40,
                                      ),
                                      // User badges from BlocBuilder
                                      if (userBadgesData.isNotEmpty)
                                        ...userBadgesData.map(
                                          (badgeData) {
                                            return badgeData.imageType == "svga"
                                                ? CacheSvgaWidget(
                                                    url: EndPoints.getImage(
                                                        badgeData.image),
                                                    boxFit: BoxFit.fill,
                                                    height: 20.h,
                                                    width: 60.h,
                                                  )
                                                : CacheImageWidget(
                                                    url: EndPoints.getImage(
                                                        badgeData.image),
                                                    height: 20.h,
                                                    width: 60.w,
                                                    boxFit: BoxFit.fill,
                                                  );
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        Padding(
                          padding: context.paddingSymmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      TextWidget(
                                        Methods.formatCompactNumber(
                                          int.tryParse(
                                            widget.userData.receiverExp
                                                    ?.toString() ??
                                                '0',
                                          ) ?? 0,
                                        ),
                                        style: context.bodyMedium.bold
                                            .colorExt(ColorManager.momentPostTextColor),
                                      ),
                                      5.hBox,
                                      TextWidget(
                                        StringManager.received.tr(),
                                        style: context.bodySmall
                                            .colorExt(ColorManager.momentPostTextColor),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      TextWidget(
                                        widget.userData.numberOfFriends
                                                ?.toString() ??
                                            '0',
                                        style: context.bodyMedium.bold
                                            .colorExt(ColorManager.momentPostTextColor),
                                      ),
                                      5.hBox,
                                      TextWidget(
                                        StringManager.followers.tr(),
                                        style: context.bodySmall
                                            .colorExt(ColorManager.momentPostTextColor),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      TextWidget(
                                        widget.userData.numberOfFollowings
                                                ?.toString() ??
                                            '0',
                                        style: context.bodyMedium.bold
                                            .colorExt(ColorManager.momentPostTextColor),
                                      ),
                                      5.hBox,
                                      TextWidget(
                                        StringManager.followings.tr(),
                                        style: context.bodySmall
                                            .colorExt(ColorManager.momentPostTextColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              10.hBox,
                              if (widget.userData.myAgency != null &&
                                  widget.userData.myAgency?.id != null &&
                                  widget.userData.myAgency?.id != 0)
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        AssetsManager.agencyRoomProfileBG,
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(7),
                                    child: Row(
                                      children: [
                                        CacheImageWidget(
                                          url: EndPoints.getImage(
                                              widget.userData.myAgency?.img ??
                                                  ''),
                                          displayName:
                                              widget.userData.myAgency?.name ??
                                                  '',
                                          height: 60.h,
                                          width: 60.w,
                                          radius: 8.r,
                                          boxFit: BoxFit.cover,
                                        ),
                                        10.wBox,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextWidget(
                                              widget.userData.myAgency?.name ??
                                                  '',
                                              style: context.bodyMedium.bold
                                                  .colorExt(Colors.brown),
                                            ),
                                            5.hBox,
                                            IdWithCopyIcon(
                                              userId: widget
                                                      .userData.myAgency?.id
                                                      .toString() ??
                                                  '',
                                              isNeedCopyIcon: false,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              idColor: Colors.brown,
                                              idStyle: context.bodyMedium.w300
                                                  .colorExt(Colors.brown)
                                                  .copyWith(
                                                      height: 0.1,
                                                      fontSize: 11.sp),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              10.hBox,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  if (widget.userData.id !=
                                      MyDataModel.getInstance().id)
                                    BlocBuilder<FetchExtraDataBloc,
                                        FetchExtraDataStates>(
                                      bloc: _fetchExtraDataBloc,
                                      builder: (context, state) {
                                        if (state.extraProfileData != null) {
                                          return NewFollowButton(
                                            userData: widget.userData,
                                            initialIsFollow: state
                                                    .extraProfileData
                                                    ?.isFollow ??
                                                false,
                                            followBloc: _followBloc,
                                          );
                                        } else if (state.requestState.isError || state.requestState == RequestState.offline) {
                                          return const SizedBox();
                                        } else {
                                          return SizedBox(
                                            width: 100.w,
                                            height: 35.h,
                                            child: const Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: ColorManager.black,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  if (widget.userData.id !=
                                      MyDataModel.getInstance().id)
                                    ProfileButtomWidget(
                                      context: context,
                                      title: StringManager.gift.tr(),
                                      onTap: () {
                                        Navigator.pop(context);
                                        bottomDailog(
                                          context: context,
                                          barrierColor:
                                              ColorManager.transparent,
                                          widget: GiftScreen(
                                            roomData: widget.roomData,
                                            userId:
                                                widget.userData.id.toString(),
                                            myDataModel:
                                                MyDataModel.getInstance(),
                                            userImage:
                                                widget.userData.image ?? '',
                                            userName:
                                                widget.userData.name ?? '',
                                            users: null,
                                            isSingleUser: true,
                                            isAudioRoom: true,
                                          ),
                                        );
                                      },
                                      image: AssetsManager.roomProfileSendGift,
                                    ),
                                  if (widget.userData.id ==
                                      MyDataModel.getInstance().id)
                                    ProfileButtomWidget(
                                      context: context,
                                      title: StringManager.profile.tr(),
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
                                      image: AssetsManager.homeNew,
                                    ),
                                  if (widget.userData.id !=
                                      MyDataModel.getInstance().id)
                                    ProfileButtomWidget(
                                      context: context,
                                      title: "Ta@",
                                      onTap: () {
                                        String name = widget.userData.name
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
                                      image: AssetsManager.mentionNew,
                                    ),
                                  if (widget.userData.id !=
                                      MyDataModel.getInstance().id)
                                    ProfileButtomWidget(
                                      context: context,
                                      title: StringManager.message.tr(),
                                      onTap: () {
                                        di<FetchUsersChatBloc>().add(
                                          UpdateTotalMessages(
                                            userId:
                                                widget.userData.id.toString(),
                                            isIncreased: false,
                                          ),
                                        );
                                        Navigator.pop(context);
                                        Navigator.pushNamed(
                                          context,
                                          Routes.messages,
                                          arguments: MessagesParameter(
                                            hasColorName: false,
                                            isNotFriend: true,
                                            name: widget.userData.name ?? '',
                                            image: widget.userData.image ?? '',
                                            userId:
                                                '${widget.userData.id ?? 0}',
                                          ),
                                        );
                                      },
                                      image: AssetsManager.messageNew,
                                    ),
                                  if (((widget.roomData.ownerId ==
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
                                                  (RoomData
                                                          .instance.adminsInRoom
                                                          .containsKey(
                                                        widget.userData.id
                                                            .toString(),
                                                      )) ==
                                                      false) &&
                                              widget.userData.id !=
                                                  widget.roomData.ownerId)) &&
                                      isOnSeat)
                                    Row(
                                      children: [
                                        10.wBox,
                                        ProfileButtomWidget(
                                          context: context,
                                          title:
                                              StringManager.leaveSeat.tr(),
                                          onTap: () async {
                                            if (widget.userData.id ==
                                                MyDataModel.getInstance()
                                                    .id) {
                                              final controller = RoomData.instance.utdController;
                                              if (controller != null) {
                                                // Leaving is best-effort here;
                                                // leaveSeat returns false on
                                                // rejection (no longer throws).
                                                await controller.seatController.leaveSeat(
                                                  MyDataModel.getInstance().id.toString(),
                                                );
                                              }
                                              // The await gap can outlive the
                                              // sheet (Crashlytics: null check
                                              // on dead context, 1.0.29).
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
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
                                          image: AssetsManager.downArrowNew,
                                          size: 20,
                                        )
                                      ],
                                    ),
                                ],
                              ),
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
              right: 30.w,
              top:
                  (hasProfileFrame && halfImageProfile == false) ? 110.h : 15.h,
              child: NewProfilePermissionMenu(
                roomData: widget.roomData,
                halfImageProfile: halfImageProfile,
                userData: widget.userData,
              ),
            ),
          if (hasProfileFrame && halfImageProfile == true)
            Positioned(
              top: -100.h,
              child: SizedBox(
                  height: 400.h,
                  child:
                      Center(child: buildProfileFrame(ignorePointer: false))),
            ),
        ],
      ),
    );
  }
}

Widget ProfileButtomWidget(
    {required BuildContext context,
    required String title,
    int? size,
    required VoidCallback onTap,
    required String image}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Image.asset(
          image,
          height: size?.h ?? 30.h,
          width: size?.w ?? 30.w,
          fit: BoxFit.cover,
        ),
        5.hBox,
        Text(
          title,
          style: context.bodySmall.colorExt(ColorManager.momentPostTextColor),
        ),
      ],
    ),
  );
}



