part of 'get_super_bombs_theme_bloc.dart';

abstract class SuperBombsThemeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetRoomBoomThemesEvent extends SuperBombsThemeEvent {
  final bool getFromCache;
  GetRoomBoomThemesEvent({required this.getFromCache});
}

class ThemeAssetsDownloadedEvent extends SuperBombsThemeEvent {
  final Map<int, File> cachedLevelBoomFiles;
  final Map<int, File> cachedProgressAnimationFiles;
  final Map<int, File> cachedBackgroundFiles;

  ThemeAssetsDownloadedEvent({
    required this.cachedLevelBoomFiles,
    required this.cachedProgressAnimationFiles,
    required this.cachedBackgroundFiles,
  });

  @override
  List<Object?> get props => [
        cachedLevelBoomFiles,
        cachedProgressAnimationFiles,
        cachedBackgroundFiles
      ];
}
