part of '../family_rank_page.dart';

class _FamilyRankTabBarView extends StatefulWidget {
  final RequestState requestState;
  final List<FamilyRankEntity>? otherFamilyRankList;
  // final List<FamilyRankEntity>? topThreeFamilyRankList;
  final RankingType rankingType;
  const _FamilyRankTabBarView({
    required this.otherFamilyRankList,
    // required this.topThreeFamilyRankList,
    required this.requestState,
    required this.rankingType,
  });

  @override
  State<_FamilyRankTabBarView> createState() => _FamilyRankTabBarViewState();
}

class _FamilyRankTabBarViewState extends State<_FamilyRankTabBarView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HandlingDataWidget(
        reqState: widget.requestState,
        title: titleError(widget.rankingType),
        subTitle: StringManager.pleaseRefresh.tr(),
        titleStyle: context.bodyLarge.w600.colorExt(ColorManager.textPrimary),
        onTap: () {
          widget.rankingType == RankingType.daily
              ? di<GetFamilyRankingBloc>()
                  .add(const GetDailyFamilyRankingEvent(isFirstLoading: false))
              : widget.rankingType == RankingType.weekly
                  ? di<GetFamilyRankingBloc>().add(
                      const GetWeeklyFamilyRankingEvent(isFirstLoading: false))
                  : di<GetFamilyRankingBloc>().add(
                      const GetMonthlyFamilyRankingEvent(
                          isFirstLoading: false));
        },
        child: _ViewBody(
          otherFamilyRankList: widget.otherFamilyRankList,
          rankingType: widget.rankingType,
        ));
  }

  String titleError(RankingType type) {
    return widget.rankingType == RankingType.daily
        ? StringManager.noFamiliesToday.tr()
        : widget.rankingType == RankingType.weekly
            ? StringManager.noFamiliesWeekly.tr()
            : StringManager.noFamiliesMonthly.tr();
  }
}
