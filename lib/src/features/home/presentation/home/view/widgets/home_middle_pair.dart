import 'package:carousel_slider/carousel_slider.dart';
import 'package:general/src/features/home/domain/entities/carousel_entity.dart';
import '../../../../../../core/index.dart';
import '../../bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'carousel_cta.dart';
import 'home_banner_metrics.dart';

/// The two fixed cards that sit directly under the home banner.
///
/// The slots themselves never move — the pair is a layout, not a carousel.
/// Whatever the panel puts in the `home_middle` slot is dealt alternately into
/// the left and right card, and each card slides through its own share on its
/// own timer. Add a third item in the panel and it starts rotating inside the
/// left card; add a fourth and the right card rotates too.
///
/// Both cards are exactly [HomeBannerMetrics.cardWidth] wide and share the
/// banner's side inset, so the block above and this row line up on both edges.
///
/// Replaces the single full-width `home_middle` carousel, which showed one
/// image at a time and left the row half empty.
class HomeMiddlePair extends StatelessWidget {
  const HomeMiddlePair({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetCarouselBloc, GetCarouselState>(
      bloc: di<GetCarouselBloc>(),
      buildWhen: (previous, current) =>
          previous.homeMiddleCarousels != current.homeMiddleCarousels ||
          previous.reqStateHomeMiddle != current.reqStateHomeMiddle,
      builder: (context, state) {
        final items = state.homeMiddleCarousels;
        if (items.isEmpty) return const SizedBox.shrink();

        // Alternate rather than split down the middle so a single extra item
        // lands in the emptier card instead of all of them piling into one.
        final left = <CarouselEntity>[];
        final right = <CarouselEntity>[];
        for (var i = 0; i < items.length; i++) {
          (i.isEven ? left : right).add(items[i]);
        }

        final height = HomeBannerMetrics.cardHeight();

        return SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(child: _MiniSlider(items: left, height: height)),
              // One card only: let it span the row rather than leaving a hole
              // where the second would be.
              if (right.isNotEmpty) ...[
                SizedBox(width: HomeBannerMetrics.gapCardsW),
                Expanded(child: _MiniSlider(items: right, height: height)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MiniSlider extends StatelessWidget {
  const _MiniSlider({required this.items, required this.height});

  final List<CarouselEntity> items;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(HomeBannerMetrics.radius),
      child: items.length == 1
          ? _Card(item: items.first, height: height)
          : CarouselSlider(
              items: [
                for (final item in items) _Card(item: item, height: height),
              ],
              options: CarouselOptions(
                height: height,
                viewportFraction: 1,
                autoPlay: true,
                enableInfiniteScroll: true,
                enlargeCenterPage: false,
                // Offset from the banner's own timer so the two do not flip in
                // lockstep.
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 600),
                autoPlayCurve: Curves.easeInOutCubic,
              ),
            ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.item, required this.height});

  final CarouselEntity item;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handleCarouselTap(context, item),
      // A card that fails to load once must not stay blank: the default here is
      // to swallow the error and draw nothing, which is why one of the two cards
      // intermittently came up empty even though the file served fine. Retrying
      // and showing progress makes a slow fetch look slow instead of broken.
      child: ImageViewWidget(
        url: item.img,
        boxFit: BoxFit.cover,
        height: height,
        width: double.infinity,
        isStopLoadingAndError: false,
        showLoadingIndicator: true,
        canRetry: true,
      ),
    );
  }
}
