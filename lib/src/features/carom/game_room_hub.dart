import 'package:flutter/widgets.dart';

import '../ludo/ludo_room_controller.dart';
import '../ludo/widgets/ludo_room_view.dart';
import 'carom_room_controller.dart';
import 'widgets/carom_room_view.dart';

/// One switch for the room's in-room games (Ludo, Carrom): the seat grid is
/// replaced while either is active, and the room shows whichever one it is.
class GameRoomHub {
  GameRoomHub._();

  static final ValueNotifier<bool> _active = ValueNotifier<bool>(false);
  static bool _wired = false;

  /// True while a Ludo or Carrom game owns the room layout.
  static ValueNotifier<bool> get active {
    if (!_wired) {
      _wired = true;
      void sync() => _active.value =
          LudoRoomController.instance.activeNotifier.value ||
          CaromRoomController.instance.activeNotifier.value;
      LudoRoomController.instance.activeNotifier.addListener(sync);
      CaromRoomController.instance.activeNotifier.addListener(sync);
      sync();
    }
    return _active;
  }

  static Widget buildView({
    required int seatCount,
    required double seatSize,
    required Widget Function(int index) seatCreator,
  }) {
    if (CaromRoomController.instance.isActive) {
      return CaromRoomView(
        seatCount: seatCount,
        seatSize: seatSize,
        seatCreator: seatCreator,
      );
    }
    return LudoRoomView(
      seatCount: seatCount,
      seatSize: seatSize,
      seatCreator: seatCreator,
    );
  }
}
