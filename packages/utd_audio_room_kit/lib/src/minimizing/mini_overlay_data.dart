import '../controller/utd_room_controller.dart';

class UTDMinimizeData {
  final UTDRoomController controller;
  final String? routeName;
  final Object? routeArguments;

  const UTDMinimizeData({
    required this.controller,
    this.routeName,
    this.routeArguments,
  });
}
