


import 'package:general/src/core/index.dart';

class ProfileCardBuilder extends StatelessWidget {
  const ProfileCardBuilder({
    super.key,
    required this.title,
    required this.onTap,
    required this.colors,
  });
  final String title;
  final void Function()? onTap;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50.h,
          padding: context.paddingSymmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: colors),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Center(
            child: TextWidget(
              title,
              overflow: TextOverflow.clip,
              style: context.bodyMedium.bold
                  .size(15)
                  .colorExt(
                    ColorManager.onDark,
                  )
                  .copyWith(fontFamily: StringManager.fontFamily),
            ),
          ),
        ),
      ),
    );
  }
}

Widget ordinaryGiftCard(
  String assetPath,
) {
  return Card(
    color: ColorManager.white.withValues(alpha: (0.1 )),
    elevation: 0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.r))),
    child: Container(
      height: 75,
      width: 65,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            width: 30,
            height: 30,
          ),
           Text(
            StringManager.gin.tr(),
            style:
             TextStyle(
              color: ColorManager.textPrimary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
