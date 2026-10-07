import 'package:carousel_slider/carousel_slider.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_top_ranking_manager/fetch_top_ranking_bloc.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/cp_rank_discover_widget.dart';


class RankDiscoverWidget extends StatefulWidget {
  const RankDiscoverWidget({super.key});

  @override
  State<RankDiscoverWidget> createState() => _RankDiscoverWidgetState();
}

class _RankDiscoverWidgetState extends State<RankDiscoverWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchTopUserImageBloc, FetchTopRankingState>(
      bloc: di<FetchTopUserImageBloc>(),
      buildWhen: (prev, curr) =>
          prev.requestState != curr.requestState ||
          prev.rankingEntity != curr.rankingEntity,
      builder: (context, state) {
        if (state.requestState == RequestState.loading) {
          return const LoadingWidget();
        }
        if ((state.rankingEntity?.topCpEntity ?? []).isEmpty) {
          return SizedBox(
            height: 110.h,
            child: const EmptyStateWidget(),
          );
        }
        return CarouselSlider(
          items: [
            CpRankDiscoverWidget(
              viewIndex: 0,
              img1: (state.rankingEntity?.topCpEntity ?? []).isNotEmpty
                  ? state.rankingEntity?.topCpEntity[0].userOne?.image ?? ''
                  : '',
              img2: (state.rankingEntity?.topCpEntity ?? []).isNotEmpty
                  ? state.rankingEntity?.topCpEntity[0].userTwo?.image ?? ''
                  : '',
              icon: AssetsManager.frameTopOneCp,
              color: ColorManager.cpCouple,
              title: StringManager.couple.tr(),
            ),
            CpRankDiscoverWidget(
              viewIndex: 1,
              img1: (state.rankingEntity?.topCpEntity ?? []).length >= 2
                  ? state.rankingEntity?.topCpEntity[1].userOne?.image ?? ''
                  : '',
              img2: (state.rankingEntity?.topCpEntity ?? []).length >= 2
                  ? state.rankingEntity?.topCpEntity[1].userTwo?.image ?? ''
                  : '',
              icon: AssetsManager.frameTopTwoCp,
              color: ColorManager.cpCouple,
              title: StringManager.couple.tr(),
            ),
            CpRankDiscoverWidget(
              viewIndex: 2,
              img1: (state.rankingEntity?.topCpEntity ?? []).length >= 3
                  ? state.rankingEntity?.topCpEntity[2].userOne?.image ?? ''
                  : '',
              img2: (state.rankingEntity?.topCpEntity ?? []).length >= 3
                  ? state.rankingEntity?.topCpEntity[2].userTwo?.image ?? ''
                  : '',
              icon: AssetsManager.frameTopThreeCp,
              color: ColorManager.cpCouple,
              title: StringManager.couple.tr(),
            ),
          ],
          options: CarouselOptions(
            initialPage: 0,
            reverse: false,
            autoPlay: true,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            height: 110.h,
            scrollDirection: Axis.vertical,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
            //  di<GetCarouselBloc>().add(ChangeCarsouleIndex(index: index));
            },
          ),
        );
      },
    );
  }
}
