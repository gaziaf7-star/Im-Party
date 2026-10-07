import 'package:carousel_slider/carousel_slider.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/games/domain/entities/user_profile_entity.dart';

class MeetUserImagesCarousel extends StatefulWidget {
  final UserProfileEntity data;

  const MeetUserImagesCarousel({required this.data, super.key});

  @override
  State<MeetUserImagesCarousel> createState() => _MeetUserImagesCarousel();
}

class _MeetUserImagesCarousel extends State<MeetUserImagesCarousel> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return widget.data.multiImages != null &&
            widget.data.multiImages!.isNotEmpty
        ? Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider(
                items: List.generate(
                  widget.data.multiImages?.length ?? 0,
                  (index) => ImageViewWidget(
                    url: widget.data.image ?? '',
                    boxFit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                options: CarouselOptions(
                  initialPage: 0,
                  height: double.infinity,
                  aspectRatio: 16 / 9,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayCurve: Curves.easeInOut,
                  enableInfiniteScroll: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                    // di<GetCarouselBloc>()
                    //     .add(ChangeCarsouleIndex(index: index));
                  },
                ),
              ),
              Positioned(
                top: 0,
                child: Padding(
                  padding: context.paddingSymmetric(vertical: 8, horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        widget.data.multiImages!.asMap().entries.map((entry) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6.0,
                        width: ScreenUtil().screenWidth /
                                widget.data.multiImages!.length +
                            1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: _currentIndex == entry.key
                              ? ColorManager.white
                              : ColorManager.white.withValues(alpha: (0.5)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              /* Positioned(
                top: 0,
                child: Padding(
                  padding: context.paddingSymmetric(vertical: 8),
                  child: Container(
                    width: ScreenUtil().screenWidth * 0.8,
                    height: 6.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: (ScreenUtil().screenWidth *
                                  0.8 *
                                  (_currentIndex + 1)) /3
                              ,
                          height: 6.0,
                          decoration: BoxDecoration(
                            color: ColorManager.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),*/
            ],
          )
        : ImageViewWidget(
            url: widget.data.image ?? '',
            boxFit: BoxFit.cover,
          );
  }
}
