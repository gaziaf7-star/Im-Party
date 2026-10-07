import '../../../../../../core/index.dart';

class RoomProfileButtonWidget extends StatelessWidget {
  final String image;
  final String title;
  final double size;
  const RoomProfileButtonWidget({super.key, required this.image, required this.title, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingAll(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorManager.grey.withAlpha(70),
      ),
      child: Image.asset(
        image,
        width: size,
        height: size,
        color: ColorManager.white,
      ),
    );
  }
}
