import 'package:general/src/core/index.dart';

class GameRoomCardItem extends StatelessWidget {
  const GameRoomCardItem({super.key, required this.title, required this.img});

  final String img;
  final String title;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ClipRRect(
            borderRadius: 10.radius,
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  ImageViewWidget(
                    url: img,
                    height: 100.h,
                    boxFit: BoxFit.fill,
                    width: 100.w,
                    radius: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: (0.6)),
                          spreadRadius: 7,
                          blurRadius: 8,
                          offset: const Offset(0, 15),
                        ),
                      ],
                      borderRadius: 3.radius,
                    ),
                    height: 87.0.h,
                    width: 87.0.w,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 7.5.w,
            right: 7.5.w,
            child: SizedBox(
              height: 100.h,
              // width: 75.w,
              child: Column(
                children: [
                  ImageViewWidget(
                    url: img,
                    height: 60.h,
                    width: 60.w,
                    radius: 10,
                    border: Border.all(
                      width: 2,
                      color: ColorManager.white.withValues(
                        alpha: (0.4),
                      ),
                    ),
                  ),
                  10.hBox,
                  TextWidget(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodySmall.w600
                        .colorExt(ColorManager.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, 0);
    path.quadraticBezierTo(size.width - 10, 0, 0, size.height / 3);
    path.quadraticBezierTo(
      20,
      size.height / 3,
      0,
      size.height / 3,
    );
    path.lineTo(0, size.height / 3);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
