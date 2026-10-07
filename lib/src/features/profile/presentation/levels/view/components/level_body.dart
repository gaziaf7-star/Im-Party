part of '../level_page.dart';

class LevelBody extends StatelessWidget {
  const LevelBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SenderLevel(),
          const ReciverLevel(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  StringManager.userLevelText.tr(),
                  style: context.bodyMedium.w400.size(13),
                ),
                TextWidget(
                  StringManager.anchorLevelText.tr(),
                  style:context.bodyMedium.w400.size(13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
