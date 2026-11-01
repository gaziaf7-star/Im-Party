import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/get_youtube_videos/get_youtube_videos_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/get_youtube_videos/get_youtube_videos_event.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/get_youtube_videos/get_youtube_videos_state.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_event.dart';
import 'package:general/src/features/room/presentation/youtube/view/privacy_dialog.dart'
    show kYoutubeLogo;
import 'package:general/src/features/room/presentation/youtube/view/youtube_video_item.dart';
import 'package:general/src/features/room/room.dart';

/// YouTube picker sheet: white, YouTube-app style. Search or pick from
/// Trending; tapping a video starts it for the whole room and closes the
/// sheet.
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
  static const Color _ink = Color(0xFF16161A);
  static const Color _muted = Color(0xFF6B6C74);

  late TextEditingController youtubeSearchController;

  /// Waits until typing stops before searching. Each YouTube search costs
  /// 100 units of the API key's daily quota, and searching on every letter
  /// used it up within a few searches ("Quota exceeded").
  Timer? _debounce;

  /// The last query actually sent, so the same text is never searched twice.
  String _lastQuery = '';

  String get _region => MyDataModel.getInstance().country?.iso ?? "EG";

  @override
  void initState() {
    youtubeSearchController = TextEditingController();
    di<GetYoutubeVideosBloc>().add(GetYoutubeVideoEvent(regionCode: _region));
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    youtubeSearchController.dispose();
    super.dispose();
  }

  void _play(String url) {
    di<YoutubeBloc>().add(const InitialViewYoutubeVideoEvent());
    Future.delayed(const Duration(milliseconds: 300), () {
      di<YoutubeBloc>().add(ViewYoutubeVideoEvent(videoId: url));
      sendRoomData(data: {
        "message": 'youtube_url',
        "url": url,
        "status": "play",
      });
    });
    // The video starts in the room; get the sheet out of the way.
    Navigator.of(context).maybePop();
  }

  /// Search once typing has paused: skips very short and repeated queries;
  /// an emptied box goes back to Trending (cheap, 1 unit).
  void _search() {
    final q = youtubeSearchController.text.trim();
    if (q == _lastQuery) return;
    if (q.isNotEmpty && q.length < 2) return;
    _lastQuery = q;
    _reload();
  }

  /// The video id in a pasted YouTube link (watch?v=, youtu.be/, shorts/,
  /// embed/, live/), or null. A link plays straight away -- no search call,
  /// so it works even when the key's daily search limit is used up.
  static String? _videoIdFromLink(String text) {
    final m = RegExp(
      r'(?:youtu\.be/|[?&]v=|/shorts/|/embed/|/live/)([A-Za-z0-9_-]{11})',
    ).firstMatch(text);
    return m?.group(1);
  }

  void _showTrending() {
    youtubeSearchController.clear();
    _lastQuery = '';
    _reload();
  }

  void _reload() {
    final q = youtubeSearchController.text.trim();
    final linkId = _videoIdFromLink(q);
    if (linkId != null) {
      _play('https://www.youtube.com/watch?v=$linkId');
      return;
    }
    di<GetYoutubeVideosBloc>().add(q.isEmpty
        ? GetYoutubeVideoEvent(regionCode: _region)
        : GetYoutubeVideoEvent(search: q));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * .75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle.
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD9DAE0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          // Header.
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 6.w, 4.h),
            child: Row(
              children: [
                Image.asset(kYoutubeLogo, height: 26.h),
                8.wBox,
                Text(
                  'YouTube',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(Icons.close_rounded, color: _ink, size: 24.sp),
                ),
              ],
            ),
          ),
          // Search.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: youtubeSearchController,
              textInputAction: TextInputAction.search,
              style: TextStyle(color: _ink, fontSize: 15.sp),
              cursorColor: _ink,
              onSubmitted: (_) {
                _debounce?.cancel();
                _lastQuery = youtubeSearchController.text.trim();
                _reload();
              },
              onChanged: (_) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 900), _search);
              },
              decoration: InputDecoration(
                hintText: 'Search or paste a YouTube link',
                hintStyle: TextStyle(color: _muted, fontSize: 15.sp),
                prefixIcon: Icon(Icons.search_rounded, color: _muted),
                filled: true,
                fillColor: const Color(0xFFF2F3F5),
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // How it works, in one line.
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 4.h),
            child: Row(
              children: [
                Icon(Icons.groups_rounded, size: 16.sp, color: _muted),
                6.wBox,
                Expanded(
                  child: Text(
                    'Tap a video — everyone in the room watches it with you',
                    style: TextStyle(color: _muted, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 8.h),
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 18.sp, color: const Color(0xFFFF0033)),
                4.wBox,
                Text(
                  StringManager.trendingTab.tr(),
                  style: TextStyle(
                    color: _ink,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<GetYoutubeVideosBloc, GetYoutubeState>(
              bloc: di<GetYoutubeVideosBloc>(),
              buildWhen: (prev, curr) =>
                  prev.runtimeType != curr.runtimeType ||
                  (prev is GetVideosYoutubeSuccessState &&
                      curr is GetVideosYoutubeSuccessState &&
                      prev.results != curr.results),
              builder: (context, state) {
                if (state is GetVideosYoutubeSuccessState) {
                  if (state.results.isEmpty) {
                    return _message('No videos found');
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.results.length,
                    separatorBuilder: (_, __) => 16.hBox,
                    itemBuilder: (context, index) {
                      final video = state.results[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () => _play(video.url),
                        child: VideoItem(youTubeVideo: video),
                      );
                    },
                  );
                } else if (state is GetYoutubeStateLoading) {
                  return const LoadingWidget();
                } else if (state is GetYoutubeStateError) {
                  // Search has its own small daily limit on the API key;
                  // when it runs out, Trending and pasted links still work.
                  return youtubeSearchController.text.trim().isEmpty
                      ? _message('Couldn\'t load videos. Tap to retry.',
                          onTap: _reload)
                      : _message(
                          'Search is unavailable right now (daily limit '
                          'reached).\nTap here to see Trending, or paste a '
                          'YouTube video link in the search box.',
                          onTap: _showTrending);
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(String text, {VoidCallback? onTap}) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 14.sp),
          ),
        ),
      ),
    );
  }
}
