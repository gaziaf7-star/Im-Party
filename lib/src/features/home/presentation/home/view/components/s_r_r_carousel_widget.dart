import 'package:carousel_slider/carousel_slider.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_top_ranking_manager/fetch_top_ranking_bloc.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/rank_widget.dart';

class SRRCarouselWidget extends StatefulWidget {
  const SRRCarouselWidget({super.key});

  @override
  State<SRRCarouselWidget> createState() => _SRRCarouselWidgetState();
}

class _SRRCarouselWidgetState extends State<SRRCarouselWidget> {
  // Cache carousel options - these don't change
  static final _carouselOptions = CarouselOptions(
    initialPage: 0,
    reverse: false,
    autoPlay: true,
    aspectRatio: 5,
    viewportFraction: 0.53,
    enlargeFactor: 0.2,
    enableInfiniteScroll: true,
    height: 100.h,
    autoPlayInterval: const Duration(seconds: 5),
    autoPlayAnimationDuration: const Duration(milliseconds: 600),
    autoPlayCurve: Curves.easeInOutCubic,
    enlargeCenterPage: true,
  );

  // Cache translated strings
  late final String _charmStarTitle;
  late final String _wealthStarTitle;
  late final String _roomStarTitle;
  late final String _gameStarTitle;

  @override
  void initState() {
    super.initState();
    _charmStarTitle = StringManager.charmStar.tr();
    _wealthStarTitle = StringManager.wealthStar.tr();
    _roomStarTitle = StringManager.roomStar.tr();
    _gameStarTitle = StringManager.gameStar.tr();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchTopUserImageBloc, FetchTopRankingState>(
      bloc: di<FetchTopUserImageBloc>(),
      buildWhen: (previous, current) =>
          previous.requestState != current.requestState ||
          previous.rankingEntity != current.rankingEntity,
      builder: (context, state) {
        if (state.requestState.isLoading) {
          return const LoadingWidget();
        }

        final ranking = state.rankingEntity;
        // Cache the topGamers image list to avoid repeated mapping
        final topGamerImages =
            ranking?.topGamers.map((e) => e.image).toList() ?? const [];

        return CarouselSlider(
          items: [
            RankSliderWidget(
              viewIndex: 2,
              data: ranking?.receiver ?? const [],
              background: AssetsManager.backgroundRankHomeCharm,
              color: ColorManager.receiverColors,
              title: _charmStarTitle,
            ),
            RankSliderWidget(
              viewIndex: 1,
              data: ranking?.sender ?? const [],
              background: AssetsManager.backgroundRankHomeWealth,
              color: ColorManager.senderColors,
              title: _wealthStarTitle,
            ),
            RankSliderWidget(
              viewIndex: 0,
              data: ranking?.room ?? const [],
              background: AssetsManager.backgroundRankHomeRoom,
              color: ColorManager.roomColors,
              title: _roomStarTitle,
            ),
            RankSliderWidget(
              viewIndex: 3,
              data: topGamerImages,
              background: AssetsManager.backgroundRankHomeGame,
              color: ColorManager.roomColors,
              title: _gameStarTitle,
            ),
          ],
          options: _carouselOptions,
        );
      },
    );
  }
}
