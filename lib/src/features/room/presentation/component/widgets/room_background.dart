import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';

class RoomBackground extends StatelessWidget {
  const RoomBackground({super.key});
  static ValueNotifier<String> imgBackground = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: RoomBackground.imgBackground,
      builder: (context, edit, _) {
        final url = RoomBackground.imgBackground.value == ""
            ? RoomData.instance.room.roomBackground == null ||
                    RoomData.instance.room.roomBackground?.isEmpty == true
                ? (di<ConfigAppBloc>().state.config?.roomBG ?? "")
                : (RoomData.instance.room.roomBackground ?? "")
            : RoomBackground.imgBackground.value;
        // Was sized to `MediaQuery.of(context).size` (the full, un-inset
        // screen height) instead of whatever space this background slot
        // actually has. Opening the bottom "say hi" comment bar brings up
        // the keyboard, which shrinks the room's own body (Scaffold
        // resizes to avoid the keyboard) -- but this image kept demanding
        // the original full screen height, so it visibly overflowed and
        // jumped upward instead of staying put. `SizedBox.expand` instead
        // just fills whatever box this widget is actually given, so it
        // stays fixed while the comment bar animates open/closed.
        //
        // Until the image arrives the room shows the dark
        // gradient (it used to be a blank light grey) with a small loader in
        // the middle; the loaded image is painted over both.
        return SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2B156A),
                      Color(0xFF3E136C),
                      Color(0xFF2A0E52),
                    ],
                  ),
                ),
              ),
              if (url.isNotEmpty)
                // Keyed by url: a new background restarts the loader.
                _BriefLoader(key: ValueKey(url)),
              ImageViewWidget(
                boxFit: BoxFit.cover,
                url: url,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Small centred spinner shown under the background image while it loads.
/// The image covers it once painted; it also hides itself after a few
/// seconds so a failed image never leaves it spinning forever.
class _BriefLoader extends StatefulWidget {
  const _BriefLoader({super.key});

  @override
  State<_BriefLoader> createState() => _BriefLoaderState();
}

class _BriefLoaderState extends State<_BriefLoader> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Center(
      child: SizedBox(
        width: 26.h,
        height: 26.h,
        child: const CircularProgressIndicator(
          strokeWidth: 2.4,
          color: Color(0xFFB794FF),
        ),
      ),
    );
  }
}
