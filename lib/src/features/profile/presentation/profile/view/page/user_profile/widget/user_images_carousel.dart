import 'package:carousel_slider/carousel_slider.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/auth/auth.dart';

class UserImagesCarousel extends StatefulWidget {
  final UserEntity? userData;

  const UserImagesCarousel({this.userData, super.key});

  @override
  State<UserImagesCarousel> createState() => _UserImagesCarousel();
}

class _UserImagesCarousel extends State<UserImagesCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return widget.userData?.images != null &&
            widget.userData!.images!.isNotEmpty
        ? Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider(
                items: List.generate(
                  widget.userData!.images?.length ?? 0,
                  (index) => InkWell(
                    onTap: () {
                      bottomDailog(
                        context: context,
                        widget: Scaffold(
                          backgroundColor: ColorManager.black,
                          appBar: const AppBarWidget(
                            backgroundColor: Colors.black,
                            iconColor: Colors.white,
                            title: '',
                          ),
                          body: PageView.builder(
                            itemCount: widget.userData?.images?.length,
                            controller: PageController(initialPage: index),
                            /* onPageChanged: (index) {
                              setState(() {
                                currentPage = index;
                              });
                            },*/
                            itemBuilder: (context, index) {
                              return InteractiveViewer(
                                child: ImageViewWidget(
                                  url:
                                      widget.userData?.images![index].img ?? '',
                                  boxFit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: ImageViewWidget(
                      url: widget.userData!.images?[index].img ?? '',
                      boxFit: BoxFit.cover,
                      width: double.infinity,
                    ),
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
                  enableInfiniteScroll:
                      widget.userData!.images!.length <= 1 ? false : true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                    // di<GetCarouselBloc>()
                    //     .add(ChangeCarsouleIndex(index: index));
                  },
                ),
              ),
              Padding(
                padding: context.paddingSymmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      widget.userData!.images!.asMap().entries.map((entry) {
                    return Container(
                      width: 5.w,
                      height: 5.h,
                      margin: context.paddingSymmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        shape: BoxShape.rectangle,
                        color: _currentIndex == entry.key
                            ? ColorManager.white
                            : ColorManager.white.withValues(alpha: (0.5)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          )
        : Image.asset(
            AssetsManager.profileDefaultBG,
            fit: BoxFit.cover,
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
          );
  }
}

