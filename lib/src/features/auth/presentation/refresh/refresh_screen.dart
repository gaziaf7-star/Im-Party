import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';

class RefreshScreen extends StatelessWidget {
  const RefreshScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundImgWidget(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: ColorManager.redAccount,
              size: 100.h,
            ),
            20.hBox,
            TextWidget(
              StringManager.someThingWentWrong,
              style: context.bodyLarge.w600,
            ),
            TextWidget(
              StringManager.appUnderDevelopment,
              style: context.bodyLarge.colorExt(ColorManager.grayMain).w400,
            ),
            30.hBox,
            ButtonWidget(
              padding: context.paddingSymmetric(horizontal: 30),
              backgroundColor: ColorManager.transparent,
              borderColor: ColorManager.redAccount,
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.splash,
                  (route) => false,
                );
              },
              titleColor: ColorManager.redAccount,
              title: StringManager.refresh.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
