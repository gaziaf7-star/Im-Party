import 'package:general/src/core/index.dart';
import 'package:general/src/features/games/data/model/user_top_model.dart';

import '../../../../games/domain/entities/ranking_entity.dart';

class RankingRoomState extends Equatable {
  final List<UserTopModel> todayUserTopModel;
  final List<UserTopModel> totalUserTopModel;
  final RequestState todayState;
  final RequestState totalState;
  final String todaymessage;
  final String totalmessage;
  final String backgroundImage;

  final RankingEntity? dayDiamondUsersRank;
  final RequestState dayDiamondState;
  final String? dayDiamondError;

  final RankingEntity? weekDiamondUsersRank;
  final RequestState weekDiamondState;
  final String? weekDiamondError;

  final RankingEntity? monthDiamondUsersRank;
  final RequestState monthDiamondState;
  final String? monthDiamondError;

  final RankingEntity? dayCoinUsersRank;
  final RequestState dayCoinState;
  final String? dayCoinError;

  final RankingEntity? weekCoinUsersRank;
  final RequestState weekCoinState;
  final String? weekCoinError;

  final RankingEntity? monthCoinUsersRank;
  final RequestState monthCoinState;
  final String? monthCoinError;

  final Color colorBackground;

  const RankingRoomState({
    this.todayUserTopModel = const [],
    this.totalUserTopModel = const [],
    this.todayState = RequestState.idle,
    this.totalState = RequestState.idle,
    this.todaymessage = "",
    this.totalmessage = "",
    required this.backgroundImage,
    this.dayDiamondUsersRank,
    this.dayDiamondState = RequestState.idle,
    this.dayDiamondError,
    this.weekDiamondUsersRank,
    this.weekDiamondState = RequestState.idle,
    this.weekDiamondError,
    this.monthDiamondUsersRank,
    this.monthDiamondState = RequestState.idle,
    this.monthDiamondError,
    this.dayCoinUsersRank,
    this.dayCoinState = RequestState.idle,
    this.dayCoinError,
    this.weekCoinUsersRank,
    this.weekCoinState = RequestState.idle,
    this.weekCoinError,
    this.monthCoinUsersRank,
    this.monthCoinState = RequestState.idle,
    this.monthCoinError,
    this.colorBackground = const Color(0xffBC8D28),
  });

  RankingRoomState copyWith({
    List<UserTopModel>? todayUserTopModel,
    List<UserTopModel>? totalUserTopModel,
    RequestState? todayState,
    RequestState? totalState,
    String? todaymessage,
    String? totalmessage,
    String? backgroundImage,
    RankingEntity? dayDiamondUsersRank,
    RequestState? dayDiamondState,
    String? dayDiamondError,
    RankingEntity? weekDiamondUsersRank,
    RequestState? weekDiamondState,
    String? weekDiamondError,
    RankingEntity? monthDiamondUsersRank,
    RequestState? monthDiamondState,
    String? monthDiamondError,
    RankingEntity? dayCoinUsersRank,
    RequestState? dayCoinState,
    String? dayCoinError,
    RankingEntity? weekCoinUsersRank,
    RequestState? weekCoinState,
    String? weekCoinError,
    RankingEntity? monthCoinUsersRank,
    RequestState? monthCoinState,
    String? monthCoinError,
    Color? colorBackground,
  }) {
    return RankingRoomState(
      todayUserTopModel: todayUserTopModel ?? this.todayUserTopModel,
      totalUserTopModel: totalUserTopModel ?? this.totalUserTopModel,
      todayState: todayState ?? this.todayState,
      totalState: totalState ?? this.totalState,
      todaymessage: todaymessage ?? this.todaymessage,
      totalmessage: totalmessage ?? this.totalmessage,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      dayDiamondUsersRank: dayDiamondUsersRank ?? this.dayDiamondUsersRank,
      dayDiamondState: dayDiamondState ?? this.dayDiamondState,
      dayDiamondError: dayDiamondError ?? this.dayDiamondError,
      weekDiamondUsersRank: weekDiamondUsersRank ?? this.weekDiamondUsersRank,
      weekDiamondState: weekDiamondState ?? this.weekDiamondState,
      weekDiamondError: weekDiamondError ?? this.weekDiamondError,
      monthDiamondUsersRank:
          monthDiamondUsersRank ?? this.monthDiamondUsersRank,
      monthDiamondState: monthDiamondState ?? this.monthDiamondState,
      monthDiamondError: monthDiamondError ?? this.monthDiamondError,
      dayCoinUsersRank: dayCoinUsersRank ?? this.dayCoinUsersRank,
      dayCoinState: dayCoinState ?? this.dayCoinState,
      dayCoinError: dayCoinError ?? this.dayCoinError,
      weekCoinUsersRank: weekCoinUsersRank ?? this.weekCoinUsersRank,
      weekCoinState: weekCoinState ?? this.weekCoinState,
      weekCoinError: weekCoinError ?? this.weekCoinError,
      monthCoinUsersRank: monthCoinUsersRank ?? this.monthCoinUsersRank,
      monthCoinState: monthCoinState ?? this.monthCoinState,
      monthCoinError: monthCoinError ?? this.monthCoinError,
      colorBackground: colorBackground ?? this.colorBackground,
    );
  }

  @override
  List<Object?> get props => [
        todayUserTopModel,
        totalUserTopModel,
        todayState,
        totalState,
        todaymessage,
        totalmessage,
        dayDiamondUsersRank,
        dayDiamondState,
        dayDiamondError,
        weekDiamondUsersRank,
        weekDiamondState,
        weekDiamondError,
        monthDiamondUsersRank,
        monthDiamondState,
        monthDiamondError,
        dayCoinUsersRank,
        dayCoinState,
        dayCoinError,
        weekCoinUsersRank,
        weekCoinState,
        weekCoinError,
        monthCoinUsersRank,
        monthCoinState,
        monthCoinError,
        backgroundImage,
        colorBackground,
      ];
}
