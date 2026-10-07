import 'package:equatable/equatable.dart';

abstract class LevelsEvent extends Equatable {
  const LevelsEvent();

  @override
  List<Object> get props => [];
}

// class SenderEvent extends LevelsEvent {
//
//   const SenderEvent();
// }
//
// class ReseverEvent extends LevelsEvent {
//
//   const ReseverEvent();
// }
class ChangeBackgroundEvent extends LevelsEvent {
  final int selectedIndex;
  const ChangeBackgroundEvent(this.selectedIndex);
}

class ChangeTabEvent extends LevelsEvent {
  final int selectedIndex;
  const ChangeTabEvent(this.selectedIndex);
}

class GetLevelsBadges extends LevelsEvent {
  final int type;
  const GetLevelsBadges({required this.type});
}

class GetUserLevels extends LevelsEvent {}

class GetRoomLevelBadges extends LevelsEvent {}

class ChangeValueEvent extends LevelsEvent {
  final bool changeImage;
  const ChangeValueEvent(this.changeImage);
}

//
// class FetchLevelsDataEvent extends LevelsEvent {
//   const FetchLevelsDataEvent();
// }
