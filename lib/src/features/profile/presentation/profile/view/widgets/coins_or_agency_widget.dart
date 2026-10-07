part of 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

class CoinsOrAgency extends StatelessWidget {
  final String image;
  final String title;
  final String lastImage;
  final double sizeImage;
  final double sizeLastImage;
  final BoxFit? boxFit;
  final String num;
  final List<Color> colors;
  final bool gold;
  final VoidCallback? onTap;

  const CoinsOrAgency({
    super.key,
    required this.image,
    required this.title,
    required this.lastImage,
    required this.sizeImage,
    required this.sizeLastImage,
    this.boxFit,
    required this.num,
    required this.colors,
    required this.gold,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 5.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(colors: colors),
          ),
          child: Row(
            children: [
              Image.asset(
                image,
                scale: sizeImage,
                fit: boxFit,
              ),
            10.wBox,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    num,
                    style: context.bodyMedium.size(13).colorExt( ColorManager.textPrimary),
                  ),
                  TextWidget(
                    title,
                    style:  context.bodyMedium.size(13).colorExt(gold ? ColorManager.primary : ColorManager.textPrimary),
                  ),
                ],
              ),
              const Spacer(),
              Image.asset(
                lastImage,
                scale: sizeLastImage,
                fit: boxFit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage of the CustomButton Widget
// CustomButton(
//   image: 'path/to/image.png',
//   title: 'Title',
//   lastImage: 'path/to/lastImage.png',
//   sizeImage: 1.0,
//   sizeLastImage: 1.0,
//   num: '1',
//   colors: [Colors.blue, Colors.green],
//   gold: true,
//   onTap: () {
//     // Handle tap
//   },
// );
