import 'dart:convert';
import 'dart:developer';

import 'package:animated_icon/animated_icon.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_state.dart';
import 'package:general/src/features/room/presentation/youtube/view/privacy_dialog.dart';
import 'package:general/src/features/room/presentation/youtube/view/youtube_search_dialog.dart';
import 'package:general/src/features/room/room.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../../core/index.dart';
import 'package:http/http.dart' as http;

class YoutubeView extends StatefulWidget {
  final String roowOwnerId;
  final String roomId;
  const YoutubeView({
    super.key,
    required this.roowOwnerId,
    required this.roomId,
  });

  @override
  State<YoutubeView> createState() => YoutubeViewState();
}

class YoutubeViewState extends State<YoutubeView> {
  final ValueNotifier<bool> _showOverlay = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasShownOverlay = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.33,
      child: BlocBuilder<YoutubeBloc, YoutubeState>(
        bloc: di<YoutubeBloc>(),
        buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
        builder: (context, state) {
          if (state is GetViewYoutubeSuccessState) {
            _hasShownOverlay.value = false;
            if (MyDataModel.getInstance().id?.toString() ==
                widget.roowOwnerId) {
              return SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  children: [
                    IconButton.filled(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            ColorManager.white.withValues(alpha: 0.3),
                        maximumSize: Size(25.w, 25.h),
                        minimumSize: Size(25.w, 25.h),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        if (HiveManager().getData<bool>(KeysManager.USER_BOX,
                                KeysManager.ACCEPT_YOUTUBE_TERMS_KEY) ==
                            null) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return PrivacyDialog(
                                isFromCinema: true,
                                roomId: RoomData.instance.room.id.toString(),
                              );
                            },
                          );
                        } else {
                          bottomDailog(
                            context: context,
                            widget: YoutubeAPISearchDialog(
                              roomData: RoomData.instance.room,
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.add,
                        size: 15.h,
                        color: ColorManager.white,
                      ),
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height * 0.265,
                          child: YoutubePlayer(
                            controller: state.controller,
                          ),
                        ),
                        PositionedDirectional(
                          start: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              if (!_hasShownOverlay.value) {
                                _showOverlay.value = true;
                                _hasShownOverlay.value = true;

                                Future.delayed(
                                  const Duration(seconds: 3),
                                  () {
                                    if (mounted) {
                                      _showOverlay.value = false;
                                      _hasShownOverlay.value = false;
                                    }
                                  },
                                );
                              }
                            },
                            child: Container(
                              color: ColorManager.transparent,
                              height: 60.h,
                              width: ScreenUtil().screenWidth * 0.15,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          start: 60.w,
                          end: 45.w,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              openYouTubeVideo(state.controller);
                            },
                            child: Container(
                              color: ColorManager.transparent,
                              height: 60.h,
                              width: ScreenUtil().screenWidth * 0.20,
                            ),
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: _showOverlay,
                          builder: (context, showOverlay, child) {
                            return showOverlay
                                ? _OverlayBody(controller: state.controller)
                                : const SizedBox();
                          },
                        ),
                        Positioned(
                          right: 0,
                          bottom: 5.h,
                          child: GestureDetector(
                            onTap: () => openYouTubeVideo(state.controller),
                            child: Container(
                              color: ColorManager.transparent,
                              height: 35.h,
                              width: ScreenUtil().screenWidth * 0.215,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.only(top: 15.h),
                child: Stack(
                  children: [
                    IgnorePointer(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height * 0.29,
                        child: YoutubePlayer(
                          controller: state.controller,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => openYouTubeChannel(state.controller),
                        child: Container(
                          color: ColorManager.transparent,
                          height: 50.h,
                          width: ScreenUtil().screenWidth * 0.20,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 5.h,
                      child: GestureDetector(
                        onTap: () => openYouTubeVideo(state.controller),
                        child: Container(
                          color: ColorManager.transparent,
                          height: 30.h,
                          width: ScreenUtil().screenWidth * 0.20,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          } else {
            if (widget.roowOwnerId == MyDataModel.getInstance().id.toString()) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          ColorManager.white.withValues(alpha: 0.3),
                      maximumSize: Size(25.w, 25.h),
                      minimumSize: Size(25.w, 25.h),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () async {
                      if (HiveManager().getData<bool>(KeysManager.USER_BOX,
                              KeysManager.ACCEPT_YOUTUBE_TERMS_KEY) ==
                          null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return PrivacyDialog(
                              isFromCinema: true,
                              roomId: RoomData.instance.room.id.toString(),
                            );
                          },
                        );
                      } else {
                        bottomDailog(
                          context: context,
                          widget: YoutubeAPISearchDialog(
                            roomData: RoomData.instance.room,
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.add,
                      size: 15.h,
                      color: ColorManager.white,
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        AssetsManager.cinemaScreen,
                        fit: BoxFit.fill,
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height * 0.265,
                      ),
                      Column(
                        children: [
                          RotatedBox(
                            quarterTurns: 2,
                            child: AnimateIcon(
                              key: UniqueKey(),
                              height: 20.h,
                              width: 40.w,
                              onTap: () {},
                              iconType: IconType.continueAnimation,
                              color: ColorManager.white,
                              animateIcon: AnimateIcons.downArrow,
                            ),
                          ),
                          Text(
                            StringManager.tabToAddVideo.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: ColorManager.whiteColor),
                          ),
                          SizedBox(
                            height: 180.h,
                            child: Image.asset(
                              AssetsManager.cinemaLogo2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  50.hBox,
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        AssetsManager.cinemaScreen,
                        fit: BoxFit.fill,
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height * 0.265,
                      ),
                      SizedBox(
                        height: 180.h,
                        child: Image.asset(
                          AssetsManager.cinemaLogo2,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}

class _OverlayBody extends StatelessWidget {
  const _OverlayBody({required this.controller});

  final YoutubePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 5.w,
      right: 5.w,
      top: 10.h,
      child: GestureDetector(
        onTap: () => openYouTubeChannel(controller),
        child: Container(
          padding: context.paddingSymmetric(horizontal: 5, vertical: 2.5),
          decoration: BoxDecoration(
            color: ColorManager.black.withValues(alpha: (0.9)),
            borderRadius: 4.radius,
          ),
          child: Row(
            children: [
              ImageViewWidget(
                url:
                    'https://img.youtube.com/vi/${controller.metadata.videoId}/hqdefault.jpg',
                width: 50.h,
                height: 50.h,
                radius: 30.r,
                boxFit: BoxFit.cover,
              ),
              10.wBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      controller.metadata.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodySmall.copyWith(
                        color: ColorManager.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextWidget(
                      controller.metadata.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodySmall.copyWith(
                        color: ColorManager.whiteColor.withValues(alpha: (0.8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> openYouTubeLink(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'could_not_launch $url';
  }
}

Future<void> openYouTubeChannel(YoutubePlayerController controller) async {
  final videoId = controller.metadata.videoId;
  if (videoId.isNotEmpty) {
    final channelId = await getChannelIdFromVideo(videoId);
    if (channelId != null) {
      final channelUrl = 'https://www.youtube.com/channel/$channelId';
      await Methods.safeLaunchUrl(channelUrl,
          mode: LaunchMode.externalApplication);
    } else {
      log('channel_id_not_found');
    }
  } else {
    log('video_id_is_not_available');
  }
}

Future<String?> getChannelIdFromVideo(String videoId) async {
  final url =
      'https://www.googleapis.com/youtube/v3/videos?part=snippet&id=$videoId&key=$youtubeApiKey';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'].isNotEmpty) {
        return data['items'][0]['snippet']['channelId'];
      }
    }
  } catch (e) {
    log('Error fetching channel ID: $e');
  }
  return null;
}

Future<void> openYouTubeVideo(YoutubePlayerController controller) async {
  final videoId = controller.metadata.videoId;

  if (videoId.isNotEmpty) {
    await Methods.safeLaunchUrl(
      'https://www.youtube.com/watch?v=$videoId',
      mode: LaunchMode.externalApplication,
    );
  } else {
    log('video_id_is_not_available');
  }
}
