import 'package:general/src/core/index.dart';
import 'package:youtube_api/youtube_api.dart';

/// One video in the YouTube picker: 16:9 thumbnail with duration, then the
/// title (black, two lines) and the channel name, like the YouTube app.
class VideoItem extends StatelessWidget {
  const VideoItem({super.key, required this.youTubeVideo});
  final YouTubeVideo youTubeVideo;

  @override
  Widget build(BuildContext context) {
    final duration = youTubeVideo.duration ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImageViewWidget(
                  url: youTubeVideo.thumbnail.medium.url.toString(),
                  boxFit: BoxFit.cover,
                ),
                if (duration.isNotEmpty)
                  Positioned(
                    right: 6.w,
                    bottom: 6.h,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        duration,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        8.hBox,
        Text(
          youTubeVideo.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF16161A),
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        3.hBox,
        Text(
          youTubeVideo.channelTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: const Color(0xFF6B6C74), fontSize: 12.sp),
        ),
      ],
    );
  }
}
