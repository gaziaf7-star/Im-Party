import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_bloc/get_super_bombs_bloc.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_theme_bloc/get_super_bombs_theme_bloc.dart';
import 'package:general/src/features/room/presentation/super_bomb/view/super_bomb_dialog.dart';
import 'package:general/src/features/room/room.dart';

class SuperBombWidget extends StatelessWidget {
  /// The live boom level and fill, passed IN rather than read from
  /// [SuperBoomController] inside `build`.
  ///
  /// They used to be read from the notifiers here while the call site mounted
  /// `const RepaintBoundary(child: SuperBombWidget())` inside two
  /// ValueListenableBuilders. A const widget is the identical instance on every
  /// rebuild, so Flutter short-circuits the subtree and `build` never ran again
  /// — the notifiers fired, the builders rebuilt, and the meter kept drawing
  /// its first frame for the whole session. Taking them as fields makes each
  /// rebuild a different widget, which is what actually redraws.
  final int level;
  final int progress;

  const SuperBombWidget({
    super.key,
    required this.level,
    required this.progress,
  });

  static const double _size = 80;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Same floor on the tap: level 0 would index -1 into the list.
        final level = SuperBoomController.roomBoomLevel.value;
        di<GetSuperBombsBloc>().add(SelectSuperBomb((level < 1 ? 1 : level) - 1));
        bottomDailog(
          context: context,
          widget: const SuperBombDialog(),
        );
      },
      // BlocBuilder, not a plain Builder: this read the theme bloc's state ONCE
      // and never listened. That was invisible while the meter only appeared
      // after a boom started -- by then the theme had long since loaded. Now
      // that it is mounted from room entry it builds BEFORE the theme arrives,
      // and without listening it would stay empty for the whole session.
      child: BlocBuilder<GetSuperBombsThemeBloc, GetSuperBombsThemeState>(
        bloc: di<GetSuperBombsThemeBloc>(),
        builder: (context, themeState) {
          // Level 0 means "no boom session running". There is no artwork for
          // it, so the meter shows the FIRST level's art as its idle state --
          // an empty boom waiting to be filled. Without this the always-on
          // meter would be an invisible gap between sessions.
          final artLevel = level < 1 ? 1 : level;
          // Was hardcoded to 100, so the meter always looked full. The real
          // figure now arrives on roomBoomProgress.
          final fill = progress.toDouble();

          // Straight from the API, not the theme bloc's local cache file: that
          // cache is written by the RAW `downloadWithProgress()` path with no
          // corruption/zero-byte detection, and a partial write here showed
          // the bundled placeholder forever even after the real art finished
          // downloading elsewhere. ImageViewWidget resolves the URL itself
          // (svga/raster + retry), same as the dialog's boom/progress art.
          final levelUrl = themeState.getLevelBoomUrl(artLevel);
          final progressUrl = themeState.getProgressAnimationUrl(fill);

          // Bundled placeholder removed on request -- when the admin hasn't
          // configured/uploaded boom art (both URLs genuinely empty), the
          // meter now shows nothing instead of the default asset icon.
          if (levelUrl.isEmpty && progressUrl.isEmpty) {
            return const SizedBox.shrink();
          }

          return Stack(
            children: [
              _BoomLayer(url: levelUrl),
              _BoomLayer(url: progressUrl),
            ],
          );
        },
      ),
    );
  }
}

/// One layer of the meter, loaded straight from its API URL.
///
/// Used to go through [ShowSVGA] unconditionally on the theme bloc's locally
/// cached [File]. That broke two ways: an SVGA parser handed back null for
/// admin-uploaded PNGs (empty box, no error), and the raw, corruption-blind
/// download path behind the cache could leave a partial file that never
/// resolved to real art. [ImageViewWidget] sidesteps both -- it sniffs
/// svga/raster from the URL itself and fetches over the network with its own
/// retry/fallback, same as the dialog's boom/progress art.
class _BoomLayer extends StatelessWidget {
  final String url;

  const _BoomLayer({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();

    return ImageViewWidget(
      url: url,
      height: SuperBombWidget._size.h,
      width: SuperBombWidget._size.w,
      boxFit: BoxFit.contain,
    );
  }
}