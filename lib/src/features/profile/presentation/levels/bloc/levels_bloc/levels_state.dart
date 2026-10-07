import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/domain/entities/user_levels_entity.dart';

import '../../../../../../core/constants/enums.dart';
import '../../../../domain/entities/level_badges_entity.dart';

class AllLevelsState extends Equatable {
  final int selectedBg;
  final int selectedTab;
  final BadgesEntity? levelsBadges;
  final UserLevelsEntity? userLevels;
  final RequestState levelsBadgesRequest;
  final RequestState userLevelsRequest;
  final bool changeImage;
  final List<RoomLevelBadgeEntity> roomLevelBadges;
  final RequestState roomLevelBadgesRequest;

  const AllLevelsState({
    this.selectedBg = 0,
    this.selectedTab = 0,
    this.levelsBadges,
    this.userLevels,
    this.levelsBadgesRequest = RequestState.loading,
    this.userLevelsRequest = RequestState.loading,
    this.changeImage = false,
    this.roomLevelBadges = const [],
    this.roomLevelBadgesRequest = RequestState.loading,
  });

  AllLevelsState copyWith({
    int? selectedBg,
    int? selectedTab,
    BadgesEntity? levelsBadges,
    UserLevelsEntity? userLevels,
    RequestState? levelsBadgesRequest,
    RequestState? userLevelsRequest,
    bool? changeImage,
    List<RoomLevelBadgeEntity>? roomLevelBadges,
    RequestState? roomLevelBadgesRequest,
  }) {
    return AllLevelsState(
      selectedBg: selectedBg ?? this.selectedBg,
      selectedTab: selectedTab ?? this.selectedTab,
      levelsBadges: levelsBadges ?? this.levelsBadges,
      userLevels: userLevels ?? this.userLevels,
      levelsBadgesRequest: levelsBadgesRequest ?? this.levelsBadgesRequest,
      userLevelsRequest: userLevelsRequest ?? this.userLevelsRequest,
      changeImage: changeImage ?? this.changeImage,
      roomLevelBadges: roomLevelBadges ?? this.roomLevelBadges,
      roomLevelBadgesRequest:
          roomLevelBadgesRequest ?? this.roomLevelBadgesRequest,
    );
  }

  @override
  List<Object?> get props => [
        selectedBg,
        selectedTab,
        levelsBadges,
        userLevels,
        levelsBadgesRequest,
        userLevelsRequest,
        changeImage,
        roomLevelBadges,
        roomLevelBadgesRequest,
      ];
}
//  final List<AllLevels>? senderDataLevels;
 //  final RequestState senderDataLevelsRequest;
 //  final String senderDataLevelskMessage;
 //
 //
 //  final List<AllLevels>? reseverLevel;
 //  final RequestState reseverLevelRequest;
 //  final String reseverLevelkMessage;
 //
 //  final List<AllLevels>? chargeLevel;
 //  final RequestState chargeLevelRequest;
 //  final String chargeLevelkMessage;
 //
 //
 //
 // const AllLevelsState({
 //    this.senderDataLevels,
 //    this.senderDataLevelsRequest = RequestState.loading,
 //    this.senderDataLevelskMessage = "",
 //
 //    this.reseverLevel,
 //    this.reseverLevelRequest = RequestState.loading,
 //    this.reseverLevelkMessage = "",
 //
 //    this.chargeLevel,
 //    this.chargeLevelRequest = RequestState.loading,
 //    this.chargeLevelkMessage = "",
 //  });
 //
 //  AllLevelsState copyWith({
 //    List<AllLevels>? senderDataLevels,
 //    RequestState? senderDataLevelsRequest,
 //    String? senderDataLevelskMessage,
 //    List<AllLevels>? reseverLevel,
 //    RequestState? reseverLevelRequest,
 //    String? reseverLevelkMessage,
 //
 //    List<AllLevels>? chargeLevel,
 //    RequestState? chargeLevelRequest,
 //    String? chargeLevelkMessage,
 //  }) {
 //    return AllLevelsState(
 //      senderDataLevels: senderDataLevels ?? this.senderDataLevels,
 //      senderDataLevelsRequest:
 //      senderDataLevelsRequest ?? this.senderDataLevelsRequest,
 //      senderDataLevelskMessage:
 //      senderDataLevelskMessage ?? this.senderDataLevelskMessage,
 //      reseverLevel: reseverLevel ?? this.reseverLevel,
 //      reseverLevelRequest: reseverLevelRequest ?? this.reseverLevelRequest,
 //      reseverLevelkMessage: reseverLevelkMessage ?? this.reseverLevelkMessage,
 //
 //      chargeLevel: chargeLevel ?? this.chargeLevel,
 //      chargeLevelRequest: chargeLevelRequest ?? this.chargeLevelRequest,
 //      chargeLevelkMessage: chargeLevelkMessage ?? this.chargeLevelkMessage,
 //    );
 //  }
 //
 //  @override
 //  List<Object?> get props =>
 //      [
 //        senderDataLevels,
 //        senderDataLevelsRequest,
 //        senderDataLevelskMessage,
 //        reseverLevel,
 //        reseverLevelRequest,
 //        reseverLevelkMessage,
 //        chargeLevel,
 //        chargeLevelRequest,
 //        chargeLevelkMessage
 //      ];

