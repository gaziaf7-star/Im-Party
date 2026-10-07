part of '../family_rank_page.dart';

class _ViewBody extends StatelessWidget {
  final List<FamilyRankEntity>? otherFamilyRankList;
  final RankingType rankingType;

  const _ViewBody({
    this.otherFamilyRankList = const [],
    required this.rankingType,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicatorWidget(
      onRefresh: () async {
        rankingType == RankingType.daily
            ? di<GetFamilyRankingBloc>()
                .add(const GetDailyFamilyRankingEvent(isFirstLoading: false))
            : rankingType == RankingType.weekly
                ? di<GetFamilyRankingBloc>().add(
                    const GetWeeklyFamilyRankingEvent(isFirstLoading: false))
                : di<GetFamilyRankingBloc>().add(
                    const GetMonthlyFamilyRankingEvent(isFirstLoading: false));
      },
      child:
      Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: TopThreeFamiliesBody(
                  families: List.of(otherFamilyRankList?.take(3) ?? []),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.paddingOnly(top: 10),
                  child: RankContainerWidgetFamily(
                    familiesRank: List.of(otherFamilyRankList?.skip(3) ?? []),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
