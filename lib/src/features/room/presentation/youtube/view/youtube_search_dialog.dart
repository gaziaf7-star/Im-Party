import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/get_youtube_videos/get_youtube_videos_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/get_youtube_videos/get_youtube_videos_event.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/get_youtube_videos/get_youtube_videos_state.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_event.dart';
import 'package:general/src/features/room/presentation/youtube/view/youtube_video_item.dart';
import 'package:general/src/features/room/room.dart';

class YoutubeAPISearchDialog extends StatefulWidget {
  final EnterRoomModel roomData;
  const YoutubeAPISearchDialog({
    required this.roomData,
    super.key,
  });

  @override
  State<YoutubeAPISearchDialog> createState() => _YoutubeAPISearchDialogState();
}

class _YoutubeAPISearchDialogState extends State<YoutubeAPISearchDialog> {
  late TextEditingController youtubeSearchController;

  @override
  void initState() {
    youtubeSearchController = TextEditingController();
    di<GetYoutubeVideosBloc>().add(GetYoutubeVideoEvent(
        regionCode: MyDataModel.getInstance().country?.iso ?? "EG"));
    super.initState();
  }

  @override
  void dispose() {
    youtubeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlurryContainer(
      height: MediaQuery.sizeOf(context).height * .7,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.r),
        topRight: Radius.circular(10.r),
      ),
      color: ColorManager.black.withValues(alpha: (0.5)),
      blur: 10,
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorManager.grey3,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: searchYoutubeVideoTextField(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 10.h,
              ),
              child: info(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  StringManager.trendingTab.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: ColorManager.whiteColor),
                ),
                const Icon(
                  Icons.video_camera_back,
                  color: ColorManager.white,
                ),
              ],
            ),
            Expanded(
                child: BlocBuilder<GetYoutubeVideosBloc, GetYoutubeState>(
              bloc: di<GetYoutubeVideosBloc>(),
              buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType || (prev is GetVideosYoutubeSuccessState && curr is GetVideosYoutubeSuccessState && prev.results != curr.results),
              builder: (context, state) {
                if (state is GetVideosYoutubeSuccessState) {
                  return ListView.builder(
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            String url = state.results[index].url;
                            di<YoutubeBloc>()
                                .add(const InitialViewYoutubeVideoEvent());
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              di<YoutubeBloc>().add(ViewYoutubeVideoEvent(
                                videoId: url,
                              ));
                              sendRoomData(data: {
                                "message": 'youtube_url',
                                "url": url,
                                "status": "play",
                              });
                            });
                          },
                          child: Column(
                            children: [
                              VideoItem(
                                youTubeVideo: state.results[index],
                              ),
                              Divider(
                                thickness: 1,
                                color: Colors.grey.shade300,
                              ),
                            ],
                          ),
                        );
                      });
                } else if (state is GetYoutubeStateLoading) {
                  return const LoadingWidget();
                } else {
                  return const SizedBox();
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringManager.searchOnYouTube.tr(),
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: ColorManager.whiteColor),
        ),
        Text(
          StringManager.pressOnVideo.tr(),
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: ColorManager.whiteColor),
        ),
        Text(
          StringManager.everyOneWatchWithYou.tr(),
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: ColorManager.whiteColor),
        ),
        Text(
          StringManager.ownerCanSwitchVideo.tr(),
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: ColorManager.whiteColor),
        ),
      ],
    );
  }

  Widget searchYoutubeVideoTextField() {
    return TextInputWidget(
      StringManager.search.tr(),
      prefixIcon: Icon(Icons.search, color: ColorManager.gray, size: 20.sp),
      controller: youtubeSearchController,
      onChanged: (_) async {
        Future.delayed(const Duration(milliseconds: 400), () async {
          di<GetYoutubeVideosBloc>()
              .add(GetYoutubeVideoEvent(search: youtubeSearchController.text));
        });
      },
    );
  }
}
