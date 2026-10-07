import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:general/src/features/room/presentation/music/view/music_page.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

part 'check_permission.dart';

class MusicListWidget extends StatefulWidget {
  const MusicListWidget({super.key});

  @override
  State<MusicListWidget> createState() => _MusicListWidget();
}

class _MusicListWidget extends State<MusicListWidget> {
  late Map<String, dynamic> mapChachedMusic;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  bool _hasPermission = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    MusicPage.isOpenMusicPage = true;
    indexMusic = di<MusicRoomBloc>().state.nowPlaying;
    LogConfig logConfig = LogConfig(logType: LogType.DEBUG);
    _audioQuery.setLogConfig(logConfig);
    checkAndRequestPermissions();
  }

  @override
  dispose() {
    _searchController.dispose();
    super.dispose();
    MusicPage.isOpenMusicPage = false;
  }

  checkAndRequestPermissions({bool retry = false}) async {
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );
    _hasPermission ? setState(() {}) : null;
  }

  int indexMusic = 0;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicRoomBloc, MusicRoomStates>(
      bloc: di<MusicRoomBloc>(),
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        return MediaQuery(
          data: MediaQueryData.fromView(View.of(context)),
          child: Scaffold(
            backgroundColor: ColorManager.surfaceCardColor,
            appBar: AppBarWidget(
              titleStyle: TextStyle(
                color: ColorManager.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              iconColor: ColorManager.black,
              title: StringManager.localMusic.tr(),
            ),
            body: !_hasPermission
                ? _CheckPermission(
                    onPressed: () => checkAndRequestPermissions(retry: true))
                : FutureBuilder<List<SongModel>>(
                    // Default values:
                    future: _audioQuery.querySongs(
                      sortType: null,
                      orderType: OrderType.ASC_OR_SMALLER,
                      uriType: UriType.EXTERNAL,
                      ignoreCase: true,
                    ),
                    builder: (context, item) {
                      if (item.hasError) {
                        return Text(item.error.toString());
                      }
                      if (item.data == null) {
                        return const LoadingWidget();
                      }

                      // Filter songs to only include valid audio extensions
                      const validAudioExtensions = [
                        'aac',
                        'midi',
                        'mp3',
                        'wav',
                        'm4a',
                        'flac',
                        'wma',
                        'opus',
                        'amr',
                      ];
                      final List<SongModel> filteredSongs =
                          item.data?.where((song) {
                                final uri = song.data;
                                if (uri.isEmpty) return false;
                                final extension =
                                    uri.split('.').last.toLowerCase();
                                return validAudioExtensions.contains(extension);
                              }).toList() ??
                              [];

                      // Apply search filter for the alternate build variant
                      final List<SongModel> finalSongs =
                          (_searchQuery.isEmpty || !ConstantsManager.isVariantBuildA)
                              ? filteredSongs
                              : filteredSongs
                                  .where((song) => song.title
                                      .toLowerCase()
                                      .contains(_searchQuery.toLowerCase()))
                                  .toList();

                      if (finalSongs.isEmpty == true &&
                          !ConstantsManager.isVariantBuildA) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Image.asset(
                                AssetsManager.noData,
                                scale: 3,
                              ),
                            ),
                            10.hBox,
                            Center(
                              child: TextWidget(
                                _searchQuery.isNotEmpty &&
                                        ConstantsManager.isVariantBuildA
                                    ? 'No results found'
                                    : StringManager.noMusic.tr(),
                                style: context.bodyMedium.w700
                                    .colorExt(ColorManager.textPrimary),
                              ),
                            ),
                          ],
                        );
                      }
                      if (di<MusicRoomBloc>().state.isSongPlaying == true &&
                          di<MusicRoomBloc>().state.musicesInRoom.isNotEmpty) {
                        for (int i = 0; i < (finalSongs.length); i++) {
                          if (di<MusicRoomBloc>()
                                  .state
                                  .musicesInRoom[
                                      di<MusicRoomBloc>().state.nowPlaying]
                                  .id ==
                              finalSongs[i].id) {
                            indexMusic = i;
                            break;
                          }
                        }
                      }

                      return Column(
                        children: [
                          if (ConstantsManager.isVariantBuildA)
                            Padding(
                              padding: EdgeInsets.all(16.w),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: StringManager.searchMusic.tr(),
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchQuery = '';
                                            });
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor:
                                      ColorManager.grey.withValues(alpha: 0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 14.h),
                                ),
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: finalSongs.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onLongPress: () {
                                    for (int i = 0;
                                        i <
                                            di<MusicRoomBloc>()
                                                .state
                                                .musicesInRoom
                                                .length;
                                        i++) {
                                      if (di<MusicRoomBloc>()
                                              .state
                                              .musicesInRoom[i]
                                              .id ==
                                          finalSongs[index].id) {
                                        showDialog(
                                          context: context,
                                          builder: (_) {
                                            return AnimatedDialog(
                                                title: StringManager.removeSong
                                                    .tr(),
                                                child: TextWidget(
                                                  StringManager
                                                      .areYouSureDeleteMusic
                                                      .tr(),
                                                ),
                                                onTap: () async {
                                                  di<MusicRoomBloc>().add(
                                                      DeleteMusicRoomFromCacheEvent(
                                                          i));
                                                  context.popRoute();
                                                  if (di<MusicRoomBloc>()
                                                      .state
                                                      .musicesInRoom
                                                      .isNotEmpty) {
                                                    di<MusicRoomBloc>().add(
                                                        const SetIndexSongPlayingRoomEvent(
                                                            0));
                                                  }
                                                });
                                          },
                                        );

                                        break;
                                      }
                                    }
                                  },
                                  child: ListTile(
                                    title: Text(
                                      finalSongs[index].title,
                                      style: context.bodyMedium
                                          .colorExt(ColorManager.textPrimary),
                                      maxLines: 2,
                                    ),
                                    subtitle: Text(
                                      '${StringManager.artist.tr()}: ${finalSongs[index].artist ?? "N/A"} ',
                                      style: context.bodyMedium.colorExt(
                                          ColorManager.blackColor
                                              .withValues(alpha: (0.7))),
                                      maxLines: 1,
                                    ),
                                    trailing: state.musicesInRoom.any((music) =>
                                            music.id == finalSongs[index].id)
                                        ? IconButton(
                                            onPressed: () async {
                                              for (int i = 0;
                                                  i <
                                                      di<MusicRoomBloc>()
                                                          .state
                                                          .musicesInRoom
                                                          .length;
                                                  i++) {
                                                if (di<MusicRoomBloc>()
                                                        .state
                                                        .musicesInRoom[i]
                                                        .id ==
                                                    finalSongs[index].id) {
                                                  setState(() {
                                                    indexMusic = index;
                                                  });
                                                  if (di<MusicRoomBloc>()
                                                              .state
                                                              .isSongPlaying ==
                                                          false ||
                                                      di<MusicRoomBloc>()
                                                              .state
                                                              .nowPlaying !=
                                                          i) {
                                                    di<MusicRoomBloc>().add(
                                                        PlayMusicRoomEvent(
                                                            index: i));
                                                  } else {
                                                    try {
                                                      if (di<MusicRoomBloc>()
                                                          .state
                                                          .isPlayingSongInnerDialogUi) {
                                                        await di<MusicRoomBloc>()
                                                            .state
                                                            .audioPlayer
                                                            .pause();
                                                      } else {
                                                        await di<MusicRoomBloc>()
                                                            .state
                                                            .audioPlayer
                                                            .resume();
                                                      }
                                                    } catch (_) {}
                                                    di<MusicRoomBloc>().add(
                                                        const ControlPlayingMusicRoomEvent());
                                                  }
                                                  break;
                                                }
                                              }
                                            },
                                            icon: indexMusic == index &&
                                                    di<MusicRoomBloc>()
                                                            .state
                                                            .isSongPlaying ==
                                                        true
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
                                          )
                                        : InkWell(
                                            borderRadius: 15.radius,
                                            onTap: () async {
                                              di<MusicRoomBloc>().add(
                                                AddMusicRoomToCacheEvent(
                                                    model: finalSongs[index]),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color:
                                                      ColorManager.transparent,
                                                  borderRadius: 15.radius,
                                                  border: Border.all(
                                                      color: ColorManager
                                                          .primary)),
                                              padding: context.paddingSymmetric(
                                                  vertical: 6, horizontal: 20),
                                              child: TextWidget(
                                                StringManager.add.tr(),
                                                style: context.bodySmall.w700
                                                    .colorExt(
                                                        ColorManager.primary),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                    leading: QueryArtworkWidget(
                                      artworkBorder: 8.radius,
                                      controller: _audioQuery,
                                      id: finalSongs[index].id,
                                      artworkFit: BoxFit.fill,
                                      artworkHeight: 80.h,
                                      artworkWidth: 80.w,
                                      type: ArtworkType.AUDIO,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
