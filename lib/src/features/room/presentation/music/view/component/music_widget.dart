import 'package:awesome_ripple_animation/awesome_ripple_animation.dart';
import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:general/src/features/room/presentation/music/controller/music_controller.dart';
import 'package:general/src/features/room/room.dart';
part '../widgets/draggable_float_widget.dart';
part 'dialog_widget.dart';

class MusicWidget extends StatefulWidget {
  final EnterRoomModel? room;

  const MusicWidget({
    super.key,
    this.room,
  });

  @override
  State<MusicWidget> createState() => _MusicWidgetState();
}

class _MusicWidgetState extends State<MusicWidget>
    with TickerProviderStateMixin {
  // Owned by this State (NOT a RoomData global): when the widget remounts,
  // the new State's initState used to overwrite the shared controller before
  // the old State's dispose() ran, killing the new controller and crashing
  // the next build with "stop() called after dispose()".
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicRoomBloc, MusicRoomStates>(
      bloc: di<MusicRoomBloc>(),
      buildWhen: (prev, curr) =>
          prev.isPlayingSongFloatAnimation !=
              curr.isPlayingSongFloatAnimation ||
          prev.isSongPlaying != curr.isSongPlaying,
      builder: (context, state) {
        final show = state.isPlayingSongFloatAnimation;

        if (show) {
          _controller.repeat();
        } else {
          _controller.stop();
        }

        return show
            ? CustmDraggableFloatWidget(turns: _controller)
            : const SizedBox();
      },
    );
  }
}
