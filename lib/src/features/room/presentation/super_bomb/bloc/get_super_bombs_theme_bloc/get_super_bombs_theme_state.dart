part of 'get_super_bombs_theme_bloc.dart';

class GetSuperBombsThemeState extends Equatable {
  final RoomBoomThemeModel? themesData;
  final String themesMessage;
  final RequestState themesState;
  final Map<int, File> cachedLevelBoomFiles;
  final Map<int, File> cachedProgressAnimationFiles;
  final Map<int, File> cachedBackgroundFiles;

  const GetSuperBombsThemeState({
    this.themesData,
    this.themesMessage = '',
    this.themesState = RequestState.idle,
    this.cachedLevelBoomFiles = const {},
    this.cachedProgressAnimationFiles = const {},
    this.cachedBackgroundFiles = const {},
  });

  GetSuperBombsThemeState copyWith({
    RoomBoomThemeModel? themesData,
    String? themesMessage,
    RequestState? themesState,
    Map<int, File>? cachedLevelBoomFiles,
    Map<int, File>? cachedProgressAnimationFiles,
    Map<int, File>? cachedBackgroundFiles,
  }) {
    return GetSuperBombsThemeState(
      themesData: themesData ?? this.themesData,
      themesMessage: themesMessage ?? this.themesMessage,
      themesState: themesState ?? this.themesState,
      cachedLevelBoomFiles: cachedLevelBoomFiles ?? this.cachedLevelBoomFiles,
      cachedProgressAnimationFiles:
          cachedProgressAnimationFiles ?? this.cachedProgressAnimationFiles,
      cachedBackgroundFiles:
          cachedBackgroundFiles ?? this.cachedBackgroundFiles,
    );
  }

  /// Get the cached boom file for a given level (1-based)
  File? getCachedLevelBoomFile(int level) {
    return cachedLevelBoomFiles[level];
  }

  /// Get the cached progress animation file for a given percentage
  File? getCachedProgressAnimationFile(double progressValue) {
    final closest = _closestProgressBreakpoint(progressValue);
    if (closest == null) return null;
    return cachedProgressAnimationFiles[closest];
  }

  int? _closestProgressBreakpoint(double progressValue) {
    if (cachedProgressAnimationFiles.isEmpty) return null;
    final breakpoints = cachedProgressAnimationFiles.keys.toList()..sort();
    final numValue = progressValue.clamp(0, 100);
    return breakpoints.reduce(
        (a, b) => (numValue - a).abs() < (numValue - b).abs() ? a : b);
  }

  /// Same idea as [_closestProgressBreakpoint], but for the URL/type getters
  /// below, which read [themesData] directly and are meant to work over the
  /// network before the background asset download ever finishes (see their
  /// doc comments). Sourcing the breakpoint list from
  /// [cachedProgressAnimationFiles] instead -- as [_closestProgressBreakpoint]
  /// does for the file-cache getter -- made them return '' for the whole
  /// window between the dialog opening and that download completing: the
  /// progress overlay art (drawn ON TOP of the level art in the dialog's main
  /// preview) would then fail to resolve and fall back to
  /// [ImageViewWidget]'s broken-image placeholder, while the same call for
  /// the LV.1-5 strip below -- built moments later, often after the download
  /// map had already populated -- looked fine. Reading straight from the
  /// declared data removes that race entirely.
  int? _closestDeclaredProgressBreakpoint(double progressValue) {
    final animations = themesData?.progressAnimations;
    if (animations == null || animations.isEmpty) return null;
    final breakpoints = animations.map((e) => e.percentage).toList()..sort();
    final numValue = progressValue.clamp(0, 100);
    return breakpoints.reduce(
        (a, b) => (numValue - a).abs() < (numValue - b).abs() ? a : b);
  }

  /// The asset type the backend DECLARED for a level's boom art, lowercased --
  /// 'svga' or 'image'. The cached maps hold only files, and a PNG and an SVGA
  /// are indistinguishable by File alone, so the drawing side has to ask.
  /// Anything but 'svga' is treated as a still image.
  String getLevelBoomType(int level) {
    final levels = themesData?.levels;
    if (levels == null) return '';
    for (final entry in levels) {
      if (entry.level == level) return entry.boom.type.toLowerCase();
    }
    return '';
  }

  /// Same question for the progress overlay, resolved against the SAME
  /// breakpoint [getCachedProgressAnimationFile] picked.
  String getProgressAnimationType(double progressValue) {
    final closest = _closestDeclaredProgressBreakpoint(progressValue);
    final animations = themesData?.progressAnimations;
    if (closest == null || animations == null) return '';
    for (final entry in animations) {
      if (entry.percentage == closest) return entry.imageType.toLowerCase();
    }
    return '';
  }

  /// Raw (relative) URL for a level's boom art, straight from the API
  /// response -- used to render via [ImageViewWidget] instead of the
  /// locally-cached [File], since a partial/corrupt cache write showed a
  /// broken-image icon that a fresh network fetch (with its own retry and
  /// fallback) does not.
  String getLevelBoomUrl(int level) {
    final levels = themesData?.levels;
    if (levels == null) return '';
    for (final entry in levels) {
      if (entry.level == level) return entry.boom.url;
    }
    return '';
  }

  /// Same as [getLevelBoomUrl] but for the progress overlay at the SAME
  /// breakpoint [getCachedProgressAnimationFile]/[getProgressAnimationType]
  /// resolve.
  String getProgressAnimationUrl(double progressValue) {
    final closest = _closestDeclaredProgressBreakpoint(progressValue);
    final animations = themesData?.progressAnimations;
    if (closest == null || animations == null) return '';
    for (final entry in animations) {
      if (entry.percentage == closest) return entry.image;
    }
    return '';
  }

  /// Same as [getLevelBoomUrl] but for the dialog's full-height background
  /// art -- straight from the API instead of the theme bloc's locally cached
  /// [File], which showed a crash (`FileImage` on an empty fallback `File("")`
  /// when the cache write hadn't landed yet) rather than just a blank box.
  String getLevelBackgroundUrl(int level) {
    final levels = themesData?.levels;
    if (levels == null) return '';
    for (final entry in levels) {
      if (entry.level == level) return entry.background.url;
    }
    return '';
  }

  /// Get the cached background file for a given level (1-based)
  File? getCachedBackgroundFile(int level) {
    return cachedBackgroundFiles[level];
  }

  @override
  List<Object?> get props => [
        themesData,
        themesMessage,
        themesState,
        cachedLevelBoomFiles,
        cachedProgressAnimationFiles,
        cachedBackgroundFiles,
      ];
}
