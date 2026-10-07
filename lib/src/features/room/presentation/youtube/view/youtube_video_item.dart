import 'package:general/src/core/index.dart';
import 'package:youtube_api/youtube_api.dart';

class VideoItem extends StatelessWidget {
  const VideoItem({super.key, required this.youTubeVideo});
  final YouTubeVideo youTubeVideo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          ImageViewWidget(
            url: youTubeVideo.thumbnail.medium.url.toString(),
            height: MediaQuery.sizeOf(context).height * .2,
            width: MediaQuery.sizeOf(context).width * .8,
          ),
          30.hBox,
          Column(
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .7,
                child: Text(
                  youTubeVideo.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: ColorManager.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
