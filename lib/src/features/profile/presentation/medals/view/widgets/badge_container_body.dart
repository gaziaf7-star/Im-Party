part of '../medals_page.dart';

class _BadgeContainerBody extends StatelessWidget {
  const _BadgeContainerBody(
      {this.badgeImages = const [], this.badgeIds = const []});
  final List<String> badgeImages;
  final List<String> badgeIds;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: ScreenUtil().screenWidth * 0.6,
      height: ScreenUtil().screenWidth * 0.2,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   gradient:
      //       const LinearGradient(colors: ColorManager.containerMedalsGradient),
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          3,
          (index) {
            return ContainerItemPicked(
              onTap: () {
                // bottomDialog(
                //   context: context,
                //   widget: bottomDialogPick(
                //     pickedAchievements: badgeIds,
                //     /* isPicked: true, */
                //   ),
                // );
              },
              isImage: badgeImages.length > index ? true : false,
              imageUrl: badgeImages.length > index ? badgeImages[index] : null,
            );
          },
        ),
      ),
    );
  }
}
