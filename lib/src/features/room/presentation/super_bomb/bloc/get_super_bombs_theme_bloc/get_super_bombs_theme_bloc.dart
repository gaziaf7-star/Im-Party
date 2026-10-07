import 'dart:convert';
import 'dart:io';

import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/cache/svga_cache_manager.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

part 'get_super_bombs_theme_event.dart';

part 'get_super_bombs_theme_state.dart';

class GetSuperBombsThemeBloc
    extends Bloc<SuperBombsThemeEvent, GetSuperBombsThemeState> {
  final GetRoomBoomThemesUC getRoomBoomThemesUC;

  static const String _hiveBoomThemeBox = 'boom_theme_cache';
  static const String _hiveBoomThemeKey = 'boom_theme_data';

  GetSuperBombsThemeBloc(this.getRoomBoomThemesUC)
      : super(const GetSuperBombsThemeState()) {
    on<GetRoomBoomThemesEvent>((event, emit) async {
      // Try loading from Hive cache first
      final cachedData = await _loadFromHive();
      if (cachedData != null && event.getFromCache) {
        emit(
          state.copyWith(
            themesState: RequestState.loaded,
            themesData: cachedData,
          ),
        );
        // Download and cache all theme assets
        _downloadThemeAssets(cachedData);
        return;
      }

      emit(state.copyWith(themesState: RequestState.loading));

      final result = await getRoomBoomThemesUC();

      result.fold(
        (left) {
          emit(
            state.copyWith(
              themesState: handleErrorResponse(left),
              themesMessage: NetworkExceptions.getErrorMessage(left),
            ),
          );
        },
        (right) {
          emit(
            state.copyWith(
              themesState: handleLoadedResponse(right.data),
              themesData: right.data,
            ),
          );
          Methods().saveCurrentUtcTimeToCache(TypesCache.boomTheme);

          // Save response to Hive
          _saveToHive(right.data);

          // Download and cache all theme assets
          _downloadThemeAssets(right.data);
        },
      );
    });

    on<ThemeAssetsDownloadedEvent>((event, emit) {
      emit(state.copyWith(
        cachedLevelBoomFiles: event.cachedLevelBoomFiles,
        cachedProgressAnimationFiles: event.cachedProgressAnimationFiles,
        cachedBackgroundFiles: event.cachedBackgroundFiles,
      ));
    });
  }

  /// Fire-and-forget asset prefetch. The downloads can outlive the room
  /// session (the bloc is resetLazySingleton'd on room exit), so every
  /// post-await step re-checks [isClosed] — adding to a closed bloc is the
  /// "Bad state: Cannot add new events after calling close" fatal.
  Future<void> _downloadThemeAssets(RoomBoomThemeModel? themeData) async {
    if (themeData == null) return;

    final Map<int, File> cachedLevelBoomFiles = {};
    final Map<int, File> cachedProgressAnimationFiles = {};
    final Map<int, File> cachedBackgroundFiles = {};

    // Download level boom SVGA files and background images
    for (final level in themeData.levels) {
      if (isClosed) return;
      if (level.boom.url.isNotEmpty) {
        final url = EndPoints.getImage(level.boom.url);
        // Route by the DECLARED type, the way the progress loop below already
        // does. This install's boom art is PNG, and pulling a PNG through the
        // SVGA cache manager produced a file no SVGA parser could open -- the
        // meter downloaded fine and then drew nothing.
        final file = level.boom.type.toLowerCase() == 'svga'
            ? await SVGAAssetCacheManager().downloadWithProgress(url)
            : await AssetCacheManager().downloadWithProgress(url);
        if (file != null) {
          cachedLevelBoomFiles[level.level] = file;
        }
      }
      if (level.background.url.isNotEmpty) {
        final url = EndPoints.getImage(level.background.url);
        final file = await AssetCacheManager().downloadWithProgress(url);
        if (file != null) {
          cachedBackgroundFiles[level.level] = file;
        }
      }
    }

    // Download progress animation files
    for (final animation in themeData.progressAnimations) {
      if (isClosed) return;
      if (animation.image.isNotEmpty) {
        final url = EndPoints.getImage(animation.image);
        File? file;
        if (animation.imageType.toLowerCase() == 'svga') {
          file = await SVGAAssetCacheManager().downloadWithProgress(url);
        } else {
          file = await AssetCacheManager().downloadWithProgress(url);
        }
        if (file != null) {
          cachedProgressAnimationFiles[animation.percentage] = file;
        }
      }
    }

    if (isClosed) return;
    add(ThemeAssetsDownloadedEvent(
      cachedLevelBoomFiles: cachedLevelBoomFiles,
      cachedProgressAnimationFiles: cachedProgressAnimationFiles,
      cachedBackgroundFiles: cachedBackgroundFiles,
    ));
  }

  Future<void> _saveToHive(RoomBoomThemeModel? themeData) async {
    if (themeData == null) return;
    try {
      final jsonString = jsonEncode(themeData.toJson());
      await HiveManager.instance.deleteData(
        _hiveBoomThemeBox,
        _hiveBoomThemeKey,
      );
      await HiveManager.instance.saveData(
        _hiveBoomThemeBox,
        _hiveBoomThemeKey,
        jsonString,
      );
    } catch (e) {
      Methods.printLog('Error saving boom theme to Hive: $e');
    }
  }

  Future<RoomBoomThemeModel?> _loadFromHive() async {
    try {
      final box = await HiveManager.instance.openBox(_hiveBoomThemeBox);
      final jsonString = box.get(_hiveBoomThemeKey) as String?;
      if (jsonString != null && jsonString.isNotEmpty) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return RoomBoomThemeModel.fromJson(jsonMap);
      }
    } catch (e) {
      Methods.printLog('Error loading boom theme from Hive: $e');
    }
    return null;
  }
}
