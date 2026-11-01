import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/cache/image_cache_manager.dart';
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
import 'package:general/src/features/room/presentation/component/profile/widgets/profile_sheet_parts.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_state.dart';
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
  /// Share of the full-card frame artwork that hangs above the card (its
  /// transparent top + ornament tips). Every frame is drawn differently --
  /// SVIP 6/8 have far taller wings than SVIP 1 -- so it is measured per
  /// frame in [_measureFrameBand]; 0.345 (SVIP 1) until that lands.
  double _frameClearTop = 0.345;
  String? _measuredFrame;

  String vipImage = '';
  String vipType = '';
  String vipId = '';
  bool? halfImageProfile;
  ValueNotifier<Color?> backgroundColor =
      ValueNotifier<Color?>(ColorManager.black);
  late final GetUserBadgesBloc getUserBadgesBloc;
  late final FollowBloc _followBloc;
  late final FetchExtraDataBloc _fetchExtraDataBloc;

  /// Top gift senders for the "Gift Sender Top3" card.
  late final GetSupporterBloc _supporterBloc;
  StreamSubscription<GetVipFramesState>? _vipFramesSub;

  @override
  void initState() {
    super.initState();
    _resolveVipFrame();
    _ensureVipFramesCached();
    _fetchExtraDataBloc = di<FetchExtraDataBloc>();
    _fetchExtraDataBloc.add(FetchExtraDataProfile(userId: widget.userId));
    _supporterBloc = di<GetSupporterBloc>()
      ..add(GetUserSupporterEvent(userId: widget.userId));
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
    _supporterBloc.close();
    super.dispose();
  }

  void _openFullProfile() {
    final int? targetId = widget.userData.id;
    if (targetId == null || targetId == 0) return;
    context.popRoute();
    Methods().userProfileNavigator(
      context: context,
      user_: const UserEntity(),
      comesFromRoom: true,
      userId: targetId.toString(),
    );
  }

  void _gift() {
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
  }

  void _mention() {
    final name = widget.userData.name?.replaceAll(' ', '_') ?? '';
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(AudioRoomInRoomMessageInputBoard(mention: '@$name'));
  }

  void _message() {
    di<FetchUsersChatBloc>().add(
      UpdateTotalMessages(
        userId: widget.userData.id.toString(),
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
        userId: '${widget.userData.id ?? 0}',
      ),
    );
  }

  /// Received / followers / following, compact.
  Widget _statsRow(BuildContext context, {required bool onDark}) {
    final valueColor = onDark ? ColorManager.white : ColorManager.momentPostTextColor;
    final labelColor = onDark
        ? ColorManager.white.withValues(alpha: 0.85)
        : const Color(0xFF8E8F96);
    Widget stat(String value, String label) => Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            2.hBox,
            Text(
              label,
              style: TextStyle(color: labelColor, fontSize: 11.sp),
            ),
          ],
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        stat(
          Methods.formatCompactNumber(
            int.tryParse(widget.userData.receiverExp?.toString() ?? '0') ?? 0,
          ),
          StringManager.received.tr(),
        ),
        stat('${widget.userData.numberOfFriends ?? 0}',
            StringManager.followers.tr()),
        stat('${widget.userData.numberOfFollowings ?? 0}',
            StringManager.followings.tr()),
      ],
    );
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
        _measureFrameBand();
        return;
      }
    }
    Methods.printLog(
        '🖼️ [ProfileCardFrame] no match for id=$wantedId among ${decoded.length} cached frames '
        '(ids=${decoded.map((e) => VipFramesModel.fromJson(e).id).toList()})');
  }

  /// Finds where the frame's body starts (the gold band) and puts the card's
  /// top edge just above it, so the avatar sits the same ~20px under the band
  /// on every frame -- SVIP 1, 6, 8... all have differently tall ornaments.
  /// Still images are decoded; .svga frames are drawn once off-screen.
  Future<void> _measureFrameBand() async {
    final src = vipImage;
    if (src.isEmpty || _measuredFrame == src) return;
    _measuredFrame = src;
    if (Methods.isVideoFile(src) ||
        vipType == 'mp4' ||
        vipType == 'vap' ||
        vipType == 'alpha') {
      return;
    }
    try {
      final ui.Image? image = Methods().isSvgaFile(src)
          ? await _rasterSvgaFrame(src)
          : await _decodeStill(src);
      if (image == null) return;
      final body = await _bodyStart(image);
      image.dispose();
      if (body == null) return;
      final clear = (body - 0.022).clamp(0.0, 0.75).toDouble();
      Methods.printLog(
          '🖼️ [ProfileCardFrame] body at ${body.toStringAsFixed(3)} → clearTop=${clear.toStringAsFixed(3)}');
      if (mounted && (clear - _frameClearTop).abs() > 0.002) {
        setState(() => _frameClearTop = clear);
      }
    } catch (e) {
      Methods.printLog('🖼️ [ProfileCardFrame] band measure failed: $e');
    }
  }

  Future<ui.Image?> _decodeStill(String src) async {
    final file =
        await AssetCacheManager().getCachedAsset(EndPoints.getImage(src));
    if (file == null) return null;
    final codec = await ui.instantiateImageCodec(
      await file.readAsBytes(),
      targetWidth: 120,
    );
    return (await codec.getNextFrame()).image;
  }

  /// Draws the middle frame of an .svga (bitmap sprites, same transform as
  /// the player) into a small 120px-wide image.
  Future<ui.Image?> _rasterSvgaFrame(String src) async {
    final movie =
        await SvgaMovieCache.instance.loadFromUrl(EndPoints.getImage(src));
    if (movie == null) return null;
    final vbW = movie.params.viewBoxWidth;
    final vbH = movie.params.viewBoxHeight;
    if (vbW <= 0 || vbH <= 0) return null;
    final frames = movie.params.frames;
    final frame = frames > 1 ? frames ~/ 2 : 0;
    const outW = 120.0;
    final scale = outW / vbW;
    final outH = (vbH * scale).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(scale);
    final paint = Paint();
    for (final sprite in movie.sprites) {
      final bitmap = movie.bitmapCache[sprite.imageKey];
      if (bitmap == null || frame >= sprite.frames.length) continue;
      final f = sprite.frames[frame];
      if (f.hasAlpha() && f.alpha <= 0.05) continue;
      canvas.save();
      if (f.hasTransform()) {
        final t = f.transform;
        canvas.transform(Float64List.fromList(<double>[
          t.a, t.b, 0, 0, //
          t.c, t.d, 0, 0, //
          0, 0, 1, 0, //
          t.tx, t.ty, 0, 1,
        ]));
      }
      canvas.drawImageRect(
        bitmap,
        Rect.fromLTWH(0, 0, bitmap.width.toDouble(), bitmap.height.toDouble()),
        Rect.fromLTWH(0, 0, f.layout.width, f.layout.height),
        paint,
      );
      canvas.restore();
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(outW.toInt(), outH);
    picture.dispose();
    return image;
  }

  /// Fraction of the height where the frame's solid body starts: the first
  /// row from which the next 20% of rows all stay >=95% opaque. (Plain "first
  /// wide row" fails on SVIP 8, whose wings span almost the full width.)
  Future<double?> _bodyStart(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final w = image.width, h = image.height;
    if (data == null || w == 0 || h == 0) return null;
    final full = List<bool>.generate(h, (y) {
      var opaque = 0;
      for (var x = 0; x < w; x++) {
        if (data.getUint8((y * w + x) * 4 + 3) > 200) opaque++;
      }
      return opaque >= w * 0.95;
    });
    final win = (h * 0.2).round();
    for (var y = 0; y + win < h; y++) {
      var ok = true;
      for (var k = y; k < y + win; k++) {
        if (!full[k]) {
          ok = false;
          y = k; // skip ahead past the gap
          break;
        }
      }
      if (ok) return y / h;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasProfileFrame = (widget.userData.profileFrameId != null &&
        widget.userData.profileFrameId != "" &&
        widget.userData.profileFrameId != "0");
    final screenWidth = ScreenUtil().screenWidth;
    // A full-card profile frame is dark artwork: text on it must be white.
    final fullFrame = hasProfileFrame && halfImageProfile == false;
    final onDark = fullFrame || backgroundColor.value == ColorManager.black;
    // Full frame: band ends ~4% of the art height below the card top
    // (~32px on a typical card), then ~20px of breathing room.
    final avatarGap = fullFrame ? 54.h : 50.h;
    // Where the avatar block starts inside the card (padding + gap).
    final avatarTop = (fullFrame ? 0.0 : 35.h) + avatarGap;
    final actionLabel = onDark ? ColorManager.white : const Color(0xFF6B6C74);
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

    Widget buildProfileFrame({required bool ignorePointer, double? height}) {
      // No VIP frame: render nothing. An empty-url image here would fire
      // detectError and flip backgroundColor to black (black-on-black button).
      if (vipImage.isEmpty) return const SizedBox.shrink();
      final Widget frameWidget = Methods().isSvgaFile(vipImage)
          ? CacheSvgaWidget(
              url: vipImage,
              boxFit: BoxFit.fill,
              width: screenWidth,
              height: height,
              detectError: () {
                backgroundColor.value = ColorManager.black;
              },
            )
          : vipType == 'mp4'
              ? CacheVideoWidget(
                  videoUrl: vipImage,
                  width: screenWidth,
                  height: height,
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
                      height: height,
                      detectError: () {
                        backgroundColor.value = ColorManager.black;
                      },
                    )
                  : vipType == 'alpha'
                      ? CacheAlphaWidget(
                          url: vipImage,
                          width: screenWidth,
                          height: height,
                          isLoop: true,
                          detectError: () {
                            backgroundColor.value = ColorManager.black;
                          },
                        )
                      : ImageViewWidget(
                          url: vipImage,
                          boxFit: height != null ? BoxFit.fill : BoxFit.cover,
                          width: screenWidth,
                          height: height,
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
      return frameWidget;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.95,
        minHeight: 300.h,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Full-card frame. The profile-frame artwork is mostly transparent
          // at the top: its ornaments start at ~34.5% of its height and the
          // gold band ends at ~38.3% (measured on the 750x1437 art). So the
          // art is sized so that transparent part hangs ABOVE the card, the
          // band lands right at the card's top edge, and the avatar (placed
          // by avatarGap) sits ~20px under the band, inside the frame.
          if (fullFrame)
            Positioned.fill(
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final frameH = box.maxHeight / (1 - _frameClearTop);
                    return OverflowBox(
                      alignment: Alignment.bottomCenter,
                      minWidth: box.maxWidth,
                      maxWidth: box.maxWidth,
                      minHeight: frameH,
                      maxHeight: frameH,
                      child: buildProfileFrame(
                        ignorePointer: true,
                        height: frameH,
                      ),
                    );
                  },
                ),
              ),
            ),
          ValueListenableBuilder(
              valueListenable: backgroundColor,
              builder: (context, value, child) {
                return Container(
                  decoration: BoxDecoration(
                    // Soft pink-to-white sheet when there is no full-card
                    // profile frame behind it.
                    color: value == ColorManager.whiteGrey ? null : value,
                    gradient: value == ColorManager.whiteGrey
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFE1E8), Colors.white],
                            stops: [0, .45],
                          )
                        : null,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(18.r)),
                  ),
                  child: SingleChildScrollView(
                    // Card grows with its content; nothing scrolls inside.
                    physics: const NeverScrollableScrollPhysics(),
                    padding: context.paddingOnly(
                      start: 0,
                      top: fullFrame ? 0 : 35,
                      end: 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Gap above the avatar: on a full frame it clears
                        // the frame's top border by ~20px.
                        SizedBox(height: avatarGap),
                        BlocBuilder<FetchExtraDataBloc, FetchExtraDataStates>(
                          bloc: _fetchExtraDataBloc,
                          buildWhen: (prev, curr) =>
                              prev.extraProfileData != curr.extraProfileData,
                          builder: (context, extra) => ProfileAvatarPair(
                            image: widget.userData.image ?? '',
                            name: widget.userData.name ?? '',
                            frame: widget.userData.frame,
                            frameType: widget.userData.frameType,
                            cp: extra.extraProfileData?.cp,
                            onTap: _openFullProfile,
                          ),
                        ),
                        8.hBox,
                        // Bigger name with a light shine sweeping over it.
                        NameShine(
                          child: GradientTextVip(
                          width: 220.w,
                          isVip: widget.userData.vipColorName != null &&
                              (widget.userData.vipColorName ?? '')
                                  .startsWith('#'),
                          text: widget.userData.name ?? '',
                          color: Methods.safeHexColor(
                                  widget.userData.vipColorName) ??
                              ColorManager.blackColor,
                          mainAxisAlignment: MainAxisAlignment.start,
                          textAlign: TextAlign.center,
                          textStyle: context.bodyMedium.w700.size(22).colorExt(
                              Methods.safeHexColor(
                                      widget.userData.vipColorName) ??
                                  ColorManager.blackColor),
                          ),
                        ),
                        5.hBox,
                        Row(
                          children: [
                            const Spacer(),
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
                              idColor: onDark
                                  ? ColorManager.white
                                  : ColorManager.greyTextColor,
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
                                          : onDark
                                              ? ColorManager.white
                                              : ColorManager.black)
                                  .copyWith(height: 0.1, fontSize: 13.sp),
                            ),
                            const Spacer(),
                          ],
                        ),
                        10.hBox,
                        // Level / VIP / gender, then badges, then medals.
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (widget.userData.isCountryHidden != true &&
                                (widget.userData.countryImage ?? '')
                                    .isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3.r),
                                child: ImageViewWidget(
                                  url: widget.userData.countryImage ?? "",
                                  height: 16.h,
                                  width: 22.w,
                                  boxFit: BoxFit.cover,
                                ),
                              ),
                            GenderWidget(
                              age: widget.userData.age ?? 0,
                              gender: widget.userData.gender ?? 0,
                              widthSize: 40,
                            ),
                            if (widget.userData.senderLevelImage?.isNotEmpty ==
                                true)
                              LevelContainer(
                                image: widget.userData.senderLevelImage ?? '',
                              ),
                            if (widget.userData.receiverLevelImage
                                    ?.isNotEmpty ==
                                true)
                              LevelContainer(
                                image:
                                    widget.userData.receiverLevelImage ?? '',
                              ),
                            if (widget.userData.vipImage?.isNotEmpty == true)
                              VipContainer(
                                vip: widget.userData.vipImage ?? '',
                                height: 20.h,
                                width: 38.w,
                              ),
                          ],
                        ),
                        8.hBox,
                        BlocBuilder<GetUserBadgesBloc, GetUserBadgesState>(
                          bloc: getUserBadgesBloc,
                          buildWhen: (prev, curr) =>
                              prev.userBadge != curr.userBadge,
                          builder: (context, state) {
                            final badges = [
                              ...(state.userBadge?.top ?? []),
                              ...(state.userBadge?.regular ?? []),
                            ];
                            if (badges.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Wrap(
                                spacing: 6.w,
                                runSpacing: 4.h,
                                alignment: WrapAlignment.center,
                                children: [
                                  for (final b in badges)
                                    b.imageType == 'svga'
                                        ? CacheSvgaWidget(
                                            url: EndPoints.getImage(b.image),
                                            boxFit: BoxFit.fill,
                                            height: 22.h,
                                            width: 60.h,
                                          )
                                        : CacheImageWidget(
                                            url: EndPoints.getImage(b.image),
                                            height: 22.h,
                                            width: 60.w,
                                            boxFit: BoxFit.fill,
                                          ),
                                ],
                              ),
                            );
                          },
                        ),
                        BlocBuilder<FetchExtraDataBloc, FetchExtraDataStates>(
                          bloc: _fetchExtraDataBloc,
                          buildWhen: (prev, curr) =>
                              prev.extraProfileData != curr.extraProfileData,
                          builder: (context, extra) {
                            final medals =
                                extra.extraProfileData?.achievementImages ??
                                    const <String>[];
                            if (medals.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Wrap(
                              spacing: 10.w,
                              runSpacing: 4.h,
                              alignment: WrapAlignment.center,
                              children: [
                                for (final m in medals)
                                  m.contains('.svg')
                                      ? CacheSvgaWidget(
                                          url: EndPoints.getImage(m),
                                          boxFit: BoxFit.cover,
                                          height: 54.h,
                                          width: 54.h,
                                        )
                                      : CacheImageWidget(
                                          url: EndPoints.getImage(m),
                                          height: 54.h,
                                          width: 54.h,
                                          boxFit: BoxFit.cover,
                                        ),
                              ],
                              ),
                            );
                          },
                        ),
                        12.hBox,
                        _statsRow(context, onDark: onDark),
                        12.hBox,
                        // Gift Sender Top3 + agency cards.
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: BlocBuilder<GetSupporterBloc,
                                    GetUserSupporterState>(
                                  bloc: _supporterBloc,
                                  builder: (context, state) {
                                    final support = state.topSupport;
                                    final top = [
                                      ...?support?.topUser,
                                      ...?support?.otherUsers,
                                    ].take(3).toList();
                                    return ProfileTopSendersCard(top: top);
                                  },
                                ),
                              ),
                              if (widget.userData.myAgency != null &&
                                  widget.userData.myAgency?.id != null &&
                                  widget.userData.myAgency?.id != 0) ...[
                                10.wBox,
                                Expanded(
                                  child: ProfileAgencyCard(
                                    image: widget.userData.myAgency?.img ?? '',
                                    name: widget.userData.myAgency?.name ?? '',
                                    id: '${widget.userData.myAgency?.id ?? ''}',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        16.hBox,
                        // Actions: follow (heart), @, message, gift -- or
                        // profile / leave seat on your own sheet.
                        Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                        initialIsFollow:
                                            state.extraProfileData?.isFollow ??
                                                false,
                                        followBloc: _followBloc,
                                        heartStyle: true,
                                      );
                                    } else if (state.requestState.isError ||
                                        state.requestState ==
                                            RequestState.offline) {
                                      return const SizedBox();
                                    }
                                    return SizedBox(
                                      width: 46.w,
                                      height: 46.w,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: ColorManager.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              if (widget.userData.id !=
                                  MyDataModel.getInstance().id) ...[
                                ProfileRoundAction(
                                  icon: Icons.alternate_email_rounded,
                                  color: const Color(0xFF1FBF8F),
                                  onTap: _mention,
                                ),
                                ProfileRoundAction(
                                  icon: Icons.chat_bubble_rounded,
                                  color: const Color(0xFF2F8CFF),
                                  onTap: _message,
                                ),
                                ProfileRoundAction(
                                  icon: Icons.card_giftcard_rounded,
                                  color: const Color(0xFFF5A623),
                                  onTap: _gift,
                                ),
                              ],
                              if (widget.userData.id ==
                                  MyDataModel.getInstance().id)
                                ProfileRoundAction(
                                  icon: Icons.person_rounded,
                                  color: const Color(0xFF7B61FF),
                                  label: StringManager.profile.tr(),
                                  labelColor: actionLabel,
                                  onTap: _openFullProfile,
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
                                          titleColor: actionLabel,
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
                        ),
                      ],
                    ),
                  ),
                );
              }),
          // Right edge, level with the name: Gift Wall, and the family
          // straight underneath it.
          Positioned(
            right: 0,
            top: avatarTop + 168.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ProfileGiftWallChip(
                  userId: widget.userId,
                  name: widget.userData.name ?? '',
                ),
                BlocBuilder<FetchExtraDataBloc, FetchExtraDataStates>(
                  bloc: _fetchExtraDataBloc,
                  buildWhen: (prev, curr) =>
                      prev.extraProfileData != curr.extraProfileData,
                  builder: (context, extra) {
                    final family = extra.extraProfileData?.familyData;
                    if (family == null || (family.id ?? 0) == 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: ProfileFamilyChip(family: family),
                    );
                  },
                ),
              ],
            ),
          ),
          if (MyDataModel.getInstance().id != widget.userData.id)
            Positioned(
              right: 30.w,
              top: fullFrame ? avatarTop : 15.h,
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
    Color? titleColor,
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
          style: context.bodySmall
              .colorExt(titleColor ?? ColorManager.momentPostTextColor),
        ),
      ],
    ),
  );
}



