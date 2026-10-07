part of 'package:general/src/features/profile/presentation/levels/view/level_page.dart';

class LevelListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final String imagePath;

  const LevelListTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextWidget(
        title,
        style: context.bodyLarge.size(14).w600.colorExt(ColorManager.textPrimary),
      ),
      subtitle: TextWidget(
        subTitle,
        style: context.bodyMedium.size(12).colorExt(ColorManager.greyTextColor),
      ),
      leading: Image.asset(
        imagePath,
        width: 40.w,
      ),
    );
  }
}
