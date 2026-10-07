import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:general/src/core/index.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

part 'widgets/custom_item_widget.dart';

class MusicPage extends StatefulWidget {
  final String ownerId;

  static bool isOpenDialog = false;
  static bool isOpenMusicPage = false;
  const MusicPage({super.key, required this.ownerId});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<void> getPermission() async {
    await Methods.requestPermission(Permission.audio);
  }

  @override
  void initState() {
    super.initState();
    MusicPage.isOpenDialog = true;
    getPermission();
    di<MusicRoomBloc>().add(const GetMusicRoomListEvent());
  }

  @override
  dispose() {
    super.dispose();
    MusicPage.isOpenDialog = false;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData.fromView(View.of(context)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWidget(
          iconColor: ColorManager.black,
          titleStyle: TextStyle(
            color: ColorManager.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          title: StringManager.localMusic.tr(),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.musicList);
              },
              icon: Icon(
                Icons.add,
                color: ColorManager.black,
                size: 26.sp,
              ),
            ),
          ],
        ),
        body: BlocBuilder<MusicRoomBloc, MusicRoomStates>(
          bloc: di<MusicRoomBloc>(),
          buildWhen: (prev, curr) =>
              prev.musicesInRoom != curr.musicesInRoom ||
              prev.isSongPlaying != curr.isSongPlaying ||
              prev.nowPlaying != curr.nowPlaying,
          builder: (context, state) {
            if (state.musicesInRoom.isEmpty) {
              return Center(
                child: ErrorOrEmptyWidget(
                  image: "",
                  title: StringManager.noMusic.tr(),
                  titleStyle: context.bodyLarge.w500
                      .colorExt(ColorManager.black)
                      .size(18),
                  buttonColor: ColorManager.primary,
                  message: "",
                  buttonTitle: StringManager.addMusic.tr(),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.musicList);
                  },
                ),
              );
            }

            return ListView.builder(
              padding: context.paddingSymmetric(horizontal: 12, vertical: 8),
              itemCount: state.musicesInRoom.length,
              itemBuilder: (context, index) {
                final music = state.musicesInRoom[index];
                return CustomItemWidget(
                  id: music.id,
                  index: index,
                  musicName: music.name,
                  artistName: music.artist,
                  audioQuery: _audioQuery,
                  onLongPress: true,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
