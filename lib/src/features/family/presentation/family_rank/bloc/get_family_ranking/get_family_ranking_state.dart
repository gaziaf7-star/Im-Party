part of 'get_family_ranking_bloc.dart';

class GetFamilyRankingState extends Equatable {
  final RequestState dailyRequestState;
  final String dailyErrorMessage;
  final List<FamilyRankModel>? dailyTopFamilies;
  final List<FamilyRankModel>? dailyOtherFamilies;

  final RequestState weeklyRequestState;
  final String weeklyErrorMessage;
  final List<FamilyRankModel>? weeklyTopFamilies;
  final List<FamilyRankModel>? weeklyOtherFamilies;

  final RequestState monthlyRequestState;
  final String monthlyErrorMessage;
  final List<FamilyRankModel>? monthlyTopFamilies;
  final List<FamilyRankModel>? monthlyOtherFamilies;

  final int tabBarIndex;

  const GetFamilyRankingState({
    this.dailyRequestState = RequestState.idle,
    this.dailyErrorMessage = '',
    this.dailyTopFamilies,
    this.dailyOtherFamilies,
    this.weeklyRequestState = RequestState.idle,
    this.weeklyErrorMessage = '',
    this.weeklyTopFamilies,
    this.weeklyOtherFamilies,
    this.monthlyRequestState = RequestState.idle,
    this.monthlyErrorMessage = '',
    this.monthlyTopFamilies,
    this.monthlyOtherFamilies,
    this.tabBarIndex = 0,
  });

  GetFamilyRankingState copyWith({
    RequestState? dailyRequestState,
    String? dailyErrorMessage,
    List<FamilyRankModel>? dailyTopFamilies,
    List<FamilyRankModel>? dailyOtherFamilies,
    RequestState? weeklyRequestState,
    String? weeklyErrorMessage,
    List<FamilyRankModel>? weeklyTopFamilies,
    List<FamilyRankModel>? weeklyOtherFamilies,
    RequestState? monthlyRequestState,
    String? monthlyErrorMessage,
    List<FamilyRankModel>? monthlyTopFamilies,
    List<FamilyRankModel>? monthlyOtherFamilies,
    int? tabBarIndex,
  }) {
    return GetFamilyRankingState(
      dailyRequestState: dailyRequestState ?? this.dailyRequestState,
      dailyErrorMessage: dailyErrorMessage ?? this.dailyErrorMessage,
      dailyTopFamilies: dailyTopFamilies ?? this.dailyTopFamilies,
      dailyOtherFamilies: dailyOtherFamilies ?? this.dailyOtherFamilies,
      weeklyRequestState: weeklyRequestState ?? this.weeklyRequestState,
      weeklyErrorMessage: weeklyErrorMessage ?? this.weeklyErrorMessage,
      weeklyTopFamilies: weeklyTopFamilies ?? this.weeklyTopFamilies,
      weeklyOtherFamilies: weeklyOtherFamilies ?? this.weeklyOtherFamilies,
      monthlyRequestState: monthlyRequestState ?? this.monthlyRequestState,
      monthlyErrorMessage: monthlyErrorMessage ?? this.monthlyErrorMessage,
      monthlyTopFamilies: monthlyTopFamilies ?? this.monthlyTopFamilies,
      monthlyOtherFamilies: monthlyOtherFamilies ?? this.monthlyOtherFamilies,
      tabBarIndex: tabBarIndex ?? this.tabBarIndex,
    );
  }

  @override
  List<Object?> get props => [
        dailyRequestState,
        dailyErrorMessage,
        dailyTopFamilies,
        dailyOtherFamilies,
        weeklyRequestState,
        weeklyErrorMessage,
        weeklyTopFamilies,
        weeklyOtherFamilies,
        monthlyRequestState,
        monthlyErrorMessage,
        monthlyTopFamilies,
        monthlyOtherFamilies,
        tabBarIndex,
      ];
}
