part of 'package:general/src/features/profile/presentation/levels/view/level_page.dart';

class LevelItem extends StatelessWidget {
  final String iconText;
  final String imagePath;

  const LevelItem({super.key, required this.iconText, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(
              imagePath,
            width: 100.w,
          ),
          TextWidget(iconText,style: context.bodySmall.colorExt(ColorManager.textPrimary))
          
        ],
      ),
    );
  }
}
