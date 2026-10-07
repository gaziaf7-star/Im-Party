part of 'get_family_ranking_bloc.dart';


abstract class GetFamilyRankingEvent extends Equatable{
  const GetFamilyRankingEvent();

  @override
  List<Object?> get props => [];

}

class GetDailyFamilyRankingEvent extends GetFamilyRankingEvent{
  final  bool isFirstLoading ;
  const GetDailyFamilyRankingEvent({this.isFirstLoading = true});
}
class GetWeeklyFamilyRankingEvent extends GetFamilyRankingEvent{
 final  bool isFirstLoading ;
  const GetWeeklyFamilyRankingEvent({this.isFirstLoading = true});
}
class GetMonthlyFamilyRankingEvent extends GetFamilyRankingEvent{
  final  bool isFirstLoading ;
  const GetMonthlyFamilyRankingEvent({this.isFirstLoading = true});
}
class TopUsersViewEvent extends GetFamilyRankingEvent{
  final  int tabBarIndex ;
  const TopUsersViewEvent({this.tabBarIndex = 0});
}
