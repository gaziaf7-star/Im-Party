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
        // Was sized to `MediaQuery.of(context).size` (the full, un-inset
        // screen height) instead of whatever space this background slot
        // actually has. Opening the bottom "say hi" comment bar brings up
        // the keyboard, which shrinks the room's own body (Scaffold
        // resizes to avoid the keyboard) -- but this image kept demanding
        // the original full screen height, so it visibly overflowed and
        // jumped upward instead of staying put. `SizedBox.expand` instead
        // just fills whatever box this widget is actually given, so it
        // stays fixed while the comment bar animates open/closed.
        return SizedBox.expand(
          child: ImageViewWidget(
            boxFit: BoxFit.cover,
            url: RoomBackground.imgBackground.value == ""
                ? RoomData.instance.room.roomBackground == null ||
                RoomData.instance.room.roomBackground?.isEmpty == true
                ? (di<ConfigAppBloc>().state.config?.roomBG ?? "")
                : (RoomData.instance.room.roomBackground ?? "")
                : RoomBackground.imgBackground.value,
          ),
        );
      },
    );
  }
}