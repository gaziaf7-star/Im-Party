import '../../../../../../core/index.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
    Navigator.pushNamed(context, Routes.searchScreen);
        //Navigator.pushNamed(context, Routes.reelsScreen);
  // Navigator.pushNamed(context, Routes.fileUploaderTest);
      },
      child: SizedBox(
        width: ScreenUtil().screenWidth * 0.807,
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                width: ScreenUtil().screenWidth * 0.8,
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: (0.1 )),
                  border: Border.all(color: ColorManager.primary, width: 1),
                  borderRadius: 20.radius,
                ),
                child: Padding(
                  padding: context.paddingSymmetric(
                    vertical: 6,
                    horizontal: 30,
                  ),
                  child: Text(
                    StringManager.pleaseEnterUserID.tr(),
                    style: context.bodyMedium.colorExt(ColorManager.primary),
                  ),
                ),
              ),
            ),
            Image.asset(
              AssetsManager.searchIcon,
              height: 24.h,
              width: 24.w,
              color:ColorManager.primary,
            ),
          ],
        ),
      ),
    );
  }
}