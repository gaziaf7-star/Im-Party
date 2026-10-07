part of 'package:general/src/features/setting/presentation/settings_screen.dart';

class MainCard extends StatelessWidget {
  final String mainTitle;
  final List<String> titles;
  final List<String> images;
  final List<void Function()?> onTaps;

  const MainCard({
    super.key,
    required this.titles,
    required this.mainTitle,
    required this.images,
    required this.onTaps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          mainTitle,
          style: context.bodyMedium.w700.colorExt( ColorManager.secondaryText),
        ),

      ],
    );
  }
}
