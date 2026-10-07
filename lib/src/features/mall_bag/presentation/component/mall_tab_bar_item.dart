part of '../mall/view/mall_page.dart';


class MallBagTabBarItem extends StatelessWidget {
  final bool isSelected;
  final String title;
  //final String image;


  const MallBagTabBarItem({
    super.key,
    required this.isSelected,
    required this.title,
    //required this.image,

  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: FittedBox(
            child: TextWidget(
              title,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: isSelected ? 16.sp : 16.sp,
                color: isSelected
                    ? ColorManager.primary
                    : ColorManager.greyTextColor,
                fontWeight:
                isSelected ? FontWeight.w500 : FontWeight.w500,
              ),
            ),
          ),
        ),
        5.hBox,
      ],
    );
  }
}
