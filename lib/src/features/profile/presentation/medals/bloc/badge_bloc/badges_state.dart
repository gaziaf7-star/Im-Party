part of 'badges_bloc.dart';

class GetBadgesStates extends Equatable {
  final List<AchievementLevelEntity> rechargeBadge;
  final RequestState rechargeBadgeRequest;
  final String rechargeBadgeMessage;

  final List<AchievementLevelEntity> roomBadge;
  final RequestState roomBadgeRequest;
  final String roomBadgeMessage;

  final List<AchievementLevelEntity> activityBadge;
  final RequestState activityBadgeRequest;
  final String activityBadgeMessage;

  final List<AchievementLevelEntity> giftBadge;
  final RequestState giftBadgeRequest;
  final String giftBadgeMessage;

  final List<ImageData> myAllBadge;
  final RequestState myAllBadgeState;
  final String errorMyAllBadge;
  final String? lastLoadedBadgeUserId;
  final int tabBarIndex;
  final int myMedalsTabBarIndex;
  final int selectedBadgeAchieve;
  final int selectedBadgeActivity;
  final int selectedBadgeRoom;

  const GetBadgesStates({
    this.rechargeBadge = const [],
    this.rechargeBadgeRequest = RequestState.loading,
    this.rechargeBadgeMessage = "",
    this.roomBadge = const [],
    this.roomBadgeRequest = RequestState.loading,
    this.roomBadgeMessage = "",
    this.giftBadge = const [],
    this.giftBadgeRequest = RequestState.loading,
    this.giftBadgeMessage = "",
    this.activityBadge = const [],
    this.activityBadgeRequest = RequestState.loading,
    this.activityBadgeMessage = "",
    this.myAllBadge = const [],
    this.myAllBadgeState = RequestState.loading,
    this.errorMyAllBadge = "",
    this.lastLoadedBadgeUserId,
    this.tabBarIndex = 0,
    this.myMedalsTabBarIndex = 0,
    this.selectedBadgeAchieve = 0,
    this.selectedBadgeActivity = 0,
    this.selectedBadgeRoom = 0,
  });

  GetBadgesStates copyWith({
    List<AchievementLevelEntity>? rechargeBadge,
    RequestState? rechargeBadgeRequest,
    String? rechargeBadgeMessage,
    List<AchievementLevelEntity>? giftBadge,
    RequestState? giftBadgeRequest,
    String? giftBadgeMessage,
    List<AchievementLevelEntity>? roomBadge,
    RequestState? roomBadgeRequest,
    String? roomBadgeMessage,
    List<AchievementLevelEntity>? activityBadge,
    RequestState? activityBadgeRequest,
    String? activityBadgeMessage,
    List<ImageData>? myAllBadge,
    RequestState? myAllBadgeState,
    String? errorMyAllBadge,
    String? lastLoadedBadgeUserId,
    int? tabBarIndex,
    int? myMedalsTabBarIndex,
    int? selectedBadgeAchieve,
    int? selectedBadgeActivity,
    int? selectedBadgeRoom,
  }) {
    return GetBadgesStates(
      rechargeBadge: rechargeBadge ?? this.rechargeBadge,
      rechargeBadgeRequest: rechargeBadgeRequest ?? this.rechargeBadgeRequest,
      rechargeBadgeMessage: rechargeBadgeMessage ?? this.rechargeBadgeMessage,
      giftBadge: giftBadge ?? this.giftBadge,
      giftBadgeRequest: giftBadgeRequest ?? this.giftBadgeRequest,
      giftBadgeMessage: giftBadgeMessage ?? this.giftBadgeMessage,
      roomBadge: roomBadge ?? this.roomBadge,
      roomBadgeRequest: roomBadgeRequest ?? this.roomBadgeRequest,
      roomBadgeMessage: roomBadgeMessage ?? this.roomBadgeMessage,
      activityBadge: activityBadge ?? this.activityBadge,
      activityBadgeRequest: activityBadgeRequest ?? this.activityBadgeRequest,
      activityBadgeMessage: activityBadgeMessage ?? this.activityBadgeMessage,
      myAllBadge: myAllBadge ?? this.myAllBadge,
      myAllBadgeState: myAllBadgeState ?? this.myAllBadgeState,
      errorMyAllBadge: errorMyAllBadge ?? this.errorMyAllBadge,
      lastLoadedBadgeUserId:
          lastLoadedBadgeUserId ?? this.lastLoadedBadgeUserId,
      tabBarIndex: tabBarIndex ?? this.tabBarIndex,
      myMedalsTabBarIndex: myMedalsTabBarIndex ?? this.myMedalsTabBarIndex,
      selectedBadgeAchieve: selectedBadgeAchieve ?? this.selectedBadgeAchieve,
      selectedBadgeActivity:
          selectedBadgeActivity ?? this.selectedBadgeActivity,
      selectedBadgeRoom: selectedBadgeRoom ?? this.selectedBadgeRoom,
    );
  }

  @override
  List<Object?> get props => [
        rechargeBadge,
        rechargeBadgeRequest,
        rechargeBadgeMessage,
        roomBadge,
        roomBadgeRequest,
        roomBadgeMessage,
        giftBadge,
        giftBadgeRequest,
        giftBadgeMessage,
        activityBadge,
        activityBadgeRequest,
        activityBadgeMessage,
        errorMyAllBadge,
        myAllBadgeState,
        myAllBadge,
        lastLoadedBadgeUserId,
        tabBarIndex,
        myMedalsTabBarIndex,
        selectedBadgeAchieve,
        selectedBadgeActivity,
        selectedBadgeRoom,
      ];
}
