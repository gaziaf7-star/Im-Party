part of '../music_page.dart';

class CustomItemWidget extends StatelessWidget {
  const CustomItemWidget(
      {super.key,
      required this.id,
      this.musicName,
      this.artistName,
      required this.index,
      this.onLongPress,
      this.audioQuery});

  final bool? onLongPress;
  final OnAudioQuery? audioQuery;
  final int id;
  final int index;
  final String? musicName;
  final String? artistName;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 10, vertical: 5),
      margin: context.paddingOnly(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xffECF6FF),
        borderRadius: 10.radius,
      ),
      child: GestureDetector(
        onLongPress: () {
          if (onLongPress != null) {
            showDialog(
              context: context,
              builder: (_) {
                return AnimatedDialog(
                    title: StringManager.removeSong.tr(),
                    child: TextWidget(
                      StringManager.areYouSureDeleteMusic.tr(),
                    ),
                    onTap: () async {
                      di<MusicRoomBloc>()
                          .add(DeleteMusicRoomFromCacheEvent(index));
                      context.popRoute();
                    });
              },
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              constraints: BoxConstraints(minHeight: 80.h, minWidth: 80.w),
              child: QueryArtworkWidget(
                artworkBorder: 10.radius,
                controller: audioQuery,
                id: id,
                artworkHeight: 80.h,
                artworkWidth: 80.w,
                type: ArtworkType.AUDIO,
              ),
            ),
            5.wBox,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180.w,
                  child: TextWidget(
                    musicName ?? '',
                    style: context.bodyMedium.bold.colorExt(
                      ColorManager.blackColor,
                    ),
                    maxLines: 2,
                  ),
                ),
                10.hBox,
                SizedBox(
                  width: 180.w,
                  child: TextWidget(
                    '${StringManager.artist.tr()}: $artistName',
                    style: context.bodyMedium.colorExt(
                        ColorManager.blackColor.withValues(alpha: (0.7))),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () async {
                di<MusicRoomBloc>().add(PlayMusicRoomEvent(index: index));
              },
              icon: (di<MusicRoomBloc>().state.isSongPlaying &&
                      (di<MusicRoomBloc>().state.nowPlaying == index))
                  ? Icon(
                      Icons.pause_circle_outline,
                      color: ColorManager.primary,
                      size: 30.sp,
                    )
                  : Icon(
                      Icons.play_circle_outline,
                      size: 30.sp,
                      color: ColorManager.primary,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
