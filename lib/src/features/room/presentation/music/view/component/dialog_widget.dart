part of 'music_widget.dart';

class MusicDialog extends StatefulWidget {
  const MusicDialog({super.key});

  @override
  State<MusicDialog> createState() => _MusicDialogState();
}

class _MusicDialogState extends State<MusicDialog> {
  final MusicRoomBloc musicBloc = di<MusicRoomBloc>();

  void _pauseMusic() async {
    try {
      if (musicBloc.state.isPlayingSongInnerDialogUi) {
        await musicBloc.state.audioPlayer.pause();
      } else {
        await musicBloc.state.audioPlayer.resume();
      }
    } catch (_) {}
    musicBloc.add(const ControlPlayingMusicRoomEvent());
  }

  void _seekMusic(double seconds) async {
    musicBloc.add(SeekToPositionRoomEvent(Duration(seconds: seconds.toInt())));
  }

  void _playBack() {
    try {
      musicBloc.state.audioPlayer.pause();
    } catch (_) {}
    musicBloc.add(const NextAndPreviousMusicRoomEvent(isNext: false));
  }

  void _playNext() {
    try {
      musicBloc.state.audioPlayer.pause();
    } catch (_) {}
    musicBloc.add(const NextAndPreviousMusicRoomEvent(isNext: true));
  }

  void _repeat() {
    musicBloc.add(const RepeatMusicRoomEvent());
  }

  Future<void> _loadVolume() async {
    // Volume is synced globally by the DJ. Listeners must not override it with
    // their own cached value, so only the DJ loads the cached volume.
    if (!canControlMusic()) return;
    final cachedVol = await MusicController.getCachedVolume();
    musicBloc.add(SetVolumeRoomEvent(cachedVol));
  }

  @override
  void initState() {
    super.initState();
    _loadVolume();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicRoomBloc, MusicRoomStates>(
      bloc: musicBloc,
      buildWhen: (prev, curr) =>
          prev.musicesInRoom != curr.musicesInRoom ||
          prev.nowPlaying != curr.nowPlaying ||
          prev.totalDuration != curr.totalDuration ||
          prev.currentPosition != curr.currentPosition ||
          prev.volume != curr.volume ||
          prev.isPlayingSongInnerDialogUi != curr.isPlayingSongInnerDialogUi ||
          prev.repeatMusic != curr.repeatMusic ||
          prev.audioPlayer != curr.audioPlayer,
      builder: (context, state) => _buildDialog(state),
    );
  }

  Widget _buildDialog(MusicRoomStates state) {
    if (state.musicesInRoom.isEmpty) {
      return const SizedBox.shrink();
    }

    final nowPlaying =
        state.nowPlaying.clamp(0, state.musicesInRoom.length - 1);
    final currentMusic = state.musicesInRoom[nowPlaying];

    // Only the active DJ (the user who started the music) may control it.
    final canControl = canControlMusic();

    return Container(
      height: 320.h,
      width: ScreenUtil().screenWidth,
      padding: context.paddingAll(40),
      decoration: BoxDecoration(
        borderRadius: 20.radius,
        color: ColorManager.transparent,
        image: DecorationImage(
          image: AssetImage(AssetsManager.backgroundMusicDialog),
          fit: BoxFit.fill,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            10.hBox,

            /// Music Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(CupertinoIcons.music_note,
                    color: Colors.white, size: 30.sp),
                SizedBox(
                  width: ScreenUtil().screenWidth - 140.w,
                  child: Text(
                    currentMusic.name,
                    style: TextStyle(
                        color: ColorManager.textPrimary, fontSize: 16.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            /// Music Seek Slider
            Slider(
              min: 0,
              max: state.totalDuration.inSeconds.toDouble(),
              value: state.currentPosition.inSeconds
                  .clamp(0, state.totalDuration.inSeconds)
                  .toDouble(),
              onChanged: canControl ? (value) => _seekMusic(value) : null,
              activeColor: ColorManager.primary,
              inactiveColor: Colors.white.withValues(alpha: 0.5),
            ),

            /// Volume Slider (synced globally — only the DJ may change it)
            Row(
              children: [
                const Icon(CupertinoIcons.speaker_1_fill, color: Colors.white),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 100,
                    value: state.volume,
                    onChanged: canControl
                        ? (value) {
                            musicBloc.state.audioPlayer.setVolume(value / 100);
                            musicBloc.add(SetVolumeRoomEvent(value));
                          }
                        : null,
                    onChangeEnd: canControl
                        ? (value) {
                            MusicController.cacheVolume(value);
                            musicBloc.add(SetVolumeRoomEvent(value));
                          }
                        : null,
                    activeColor: ColorManager.primary,
                    inactiveColor: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const Icon(CupertinoIcons.speaker_3_fill, color: Colors.white),
              ],
            ),

            /// Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.backward_fill,
                      color: Colors.white, size: 30),
                  onPressed: canControl ? _playBack : null,
                ),
                IconButton(
                  icon: Icon(
                    state.isPlayingSongInnerDialogUi
                        ? CupertinoIcons.pause_fill
                        : CupertinoIcons.play_fill,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: canControl ? _pauseMusic : null,
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.forward_fill,
                      color: Colors.white, size: 30),
                  onPressed: canControl ? _playNext : null,
                ),
                IconButton(
                  icon: Icon(
                    CupertinoIcons.arrow_2_circlepath,
                    color: state.repeatMusic
                        ? ColorManager.primary
                        : Colors.white,
                    size: 30,
                  ),
                  onPressed: canControl ? _repeat : null,
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.shuffle,
                      color: Colors.white, size: 30),
                  onPressed: canControl
                      ? () => musicBloc.add(const PlayRandomMusicRoomEvent())
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app,
                      color: Colors.white, size: 30),
                  onPressed: () {
                    // The DJ stops the music for everyone; a listener just
                    // closes the dialog.
                    if (canControl) {
                      musicBloc.add(const DestroyMusicRoomListEvent());
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            10.hBox,
          ],
        ),
      ),
    );
  }
}
