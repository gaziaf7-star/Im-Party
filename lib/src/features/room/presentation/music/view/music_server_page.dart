import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/music_url.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:general/src/features/room/presentation/music/server_bloc/delete_song/delete_song_bloc.dart';
import 'package:general/src/features/room/presentation/music/server_bloc/upload_song/upload_song_bloc.dart';
import 'package:general/src/features/room/presentation/music/view/component/device_songs_sheet.dart';

/// Server-backed music picker for the AUDIO room. Mirrors the `room_live`
/// upload flow: the owner/admin uploads a song to storage and plays it; the
/// full URL is then broadcast so every user in the room hears the same track.
///
/// Only the user who starts the music (the DJ) can control it. While another
/// user is the DJ, this page is view-only.
class MusicServerPage extends StatefulWidget {
  const MusicServerPage({super.key});

  @override
  State<MusicServerPage> createState() => _MusicServerPageState();
}

class _MusicServerPageState extends State<MusicServerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final UploadSongBloc _uploadBloc = di<UploadSongBloc>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _uploadBloc.add(const GetMyMusicEvent());
    _uploadBloc.add(const GetMusicEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  MusicObjectParam _toParam(MusicUrlEntity song) => MusicObjectParam(
        uri: EndPoints.getImage(song.url),
        name: song.name,
        artist: '',
        id: song.id,
        duration: 0,
      );

  /// Pick from the songs already on the phone rather than opening a file
  /// browser: the media store has them indexed, so there is nothing to go
  /// looking for.
  Future<void> _addFromDevice() async {
    final songs = await DeviceSongsSheet.show(context);
    if (songs == null || songs.isEmpty || !mounted) return;

    _uploadBloc.add(UploadDeviceSongsEvent(
      context: context,
      songs: songs
          .map((song) => (path: song.data, title: song.title))
          .toList(),
    ));
  }

  void _playSong(MusicUrlEntity song, List<MusicUrlEntity> queue) {
    final url = EndPoints.getImage(song.url);
    final musicBloc = di<MusicRoomBloc>();

    // If this exact song is already playing and I'm the DJ, toggle pause/resume.
    if (musicBloc.state.songUrl == url && musicBloc.state.isSongPlaying) {
      musicBloc.add(const ControlPlayingMusicRoomEvent());
      return;
    }

    musicBloc.add(
      AddServerMusicRoomEvent(
        song: _toParam(song),
        // Hand over the whole visible list so the player's next/previous
        // buttons can move through it instead of being stuck on one song.
        playlist: queue.map(_toParam).toList(),
      ),
    );
    Navigator.of(context).maybePop();
  }

  void _confirmDelete(MusicUrlEntity song) {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        title: StringManager.removeSong,
        child: const TextWidget(StringManager.areYouSureDeleteMusic),
        onTap: () {
          di<DeleteSongBloc>().add(DeleteSongEvent(songId: song.id));
          context.popRoute();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This page is pushed from inside the (often immersive/status-bar-hidden)
    // room screen, whose ancestor MediaQuery can report a stale/zeroed
    // padding.top. Scaffold's own AppBar already reserves the correct top
    // inset internally from MediaQuery -- wrapping the WHOLE Scaffold in a
    // SafeArea (as this used to) double-padded the top (AppBar's own inset
    // PLUS SafeArea's) and then ate into the body's height at the bottom,
    // which is what was clipping the song list. Re-deriving MediaQuery from
    // the platform view (same fix SettingScreen already uses) fixes the
    // AppBar icon's positioning; SafeArea now wraps only the body, with
    // `top: false` since the AppBar already handled that side.
    return MediaQuery(
      data: MediaQueryData.fromView(View.of(context)),
      child: Scaffold(
        // Fixed white / black text on request (was following the admin
        // palette, which could go dark).
        backgroundColor: ColorManager.white,
        appBar: AppBarWidget(
          iconColor: ColorManager.black,
          titleStyle: TextStyle(
            color: ColorManager.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          title: StringManager.music.tr(),
          actions: [
            // Upload is available to whoever may start/control the session.
            if (canStartMusic() || canControlMusic())
              IconButton(
                tooltip: StringManager.addMusic.tr(),
                onPressed: _addFromDevice,
                icon: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) =>
                      ColorManager.brandGradient.createShader(bounds),
                  child: Icon(Icons.library_music_outlined,
                      color: ColorManager.white, size: 26.sp),
                ),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: BlocConsumer<UploadSongBloc, UploadSongState>(
          bloc: _uploadBloc,
          listenWhen: (prev, curr) => prev.requestState != curr.requestState,
          listener: (context, state) {
            if (state.requestState.isError && (state.message ?? '').isNotEmpty) {
              Methods.showToast(context,
                  message: state.message ?? '', isError: true);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: ColorManager.black,
                  unselectedLabelColor: ColorManager.black.withValues(alpha: 0.5),
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2.5,
                        color: ColorManager.brandGradientColors.last,
                      ),
                    ),
                  ),
                  tabs: [
                    Tab(text: StringManager.myMusic.tr()),
                    Tab(text: StringManager.musicList.tr()),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _MusicList(
                        songs: state.myMusicListData,
                        reqState: state.myMusicListRequestState,
                        onPlay: (song) =>
                            _playSong(song, state.myMusicListData),
                        onDelete: _confirmDelete,
                        showDelete: true,
                      ),
                      _MusicList(
                        songs: state.musicListData,
                        reqState: state.musicListRequestState,
                        onPlay: (song) => _playSong(song, state.musicListData),
                        onDelete: _confirmDelete,
                        showDelete: false,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }
}

class _MusicList extends StatelessWidget {
  const _MusicList({
    required this.songs,
    required this.reqState,
    required this.onPlay,
    required this.onDelete,
    required this.showDelete,
  });

  final List<MusicUrlEntity> songs;
  final RequestState reqState;
  final void Function(MusicUrlEntity) onPlay;
  final void Function(MusicUrlEntity) onDelete;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    final anotherDjActive = RoomData.instance.musicControllerUserId != null &&
        !canControlMusic();

    return HandlingDataWidget(
      reqState: reqState,
      title: StringManager.noMusic,
      subTitle: StringManager.clickToAddMusic,
      child: Column(
        children: [
          if (anotherDjActive)
            Container(
              width: double.infinity,
              color: ColorManager.primary.withValues(alpha: 0.1),
              padding: context.paddingSymmetric(horizontal: 12, vertical: 8),
              child: TextWidget(
                StringManager.otherUserIsPlayingMusic.tr(),
                style: context.bodySmall.colorExt(ColorManager.primary),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            // Rebuild items when playback state changes so the play/pause
            // icon and the DJ-gating stay in sync.
            child: BlocBuilder<MusicRoomBloc, MusicRoomStates>(
              bloc: di<MusicRoomBloc>(),
              buildWhen: (prev, curr) =>
                  prev.isSongPlaying != curr.isSongPlaying ||
                  prev.songUrl != curr.songUrl,
              builder: (context, musicState) {
                final canInteract = canStartMusic() || canControlMusic();
                return ListView.builder(
                  padding:
                      context.paddingSymmetric(horizontal: 12, vertical: 8),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final url = EndPoints.getImage(song.url);
                    final isThisPlaying =
                        musicState.songUrl == url && musicState.isSongPlaying;
                    return _MusicItem(
                      name: song.name,
                      isPlaying: isThisPlaying,
                      canInteract: canInteract,
                      showDelete: showDelete && canInteract,
                      onPlay: () => onPlay(song),
                      onDelete: () => onDelete(song),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicItem extends StatelessWidget {
  const _MusicItem({
    required this.name,
    required this.isPlaying,
    required this.canInteract,
    required this.showDelete,
    required this.onPlay,
    required this.onDelete,
  });

  final String name;
  final bool isPlaying;
  final bool canInteract;
  final bool showDelete;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 10, vertical: 5),
      margin: context.paddingOnly(bottom: 12),
      decoration: BoxDecoration(
        // Fixed white card / black text on request.
        color: ColorManager.white,
        borderRadius: 10.radius,
        border: Border.all(
          color: ColorManager.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextWidget(
              name,
              // A song title from the user's own library — never a translation
              // key, so it must not go through .tr().
              isTranslate: false,
              style: context.bodyMedium.bold
                  .colorExt(ColorManager.black),
              maxLines: 2,
            ),
          ),
          IconButton(
            onPressed: canInteract ? onPlay : null,
            icon: canInteract
                ? ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) =>
                        ColorManager.brandGradient.createShader(bounds),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      size: 30.sp,
                      color: ColorManager.white,
                    ),
                  )
                : Icon(
                    isPlaying
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 30.sp,
                    color: ColorManager.greyTextColor,
                  ),
          ),
          if (showDelete)
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete,
                  color: ColorManager.redAccount, size: 24.sp),
            ),
        ],
      ),
    );
  }
}
