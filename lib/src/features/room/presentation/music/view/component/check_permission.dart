part of 'music_list.dart';

class _CheckPermission extends StatelessWidget {
  const _CheckPermission({required this.onPressed});
final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        elevation: 5,
        borderRadius: 10.radius,
        child: BlurryContainer(
          blur: 3,
          width: ScreenUtil().screenWidth / 1.0,
          height: 150.h,
          borderRadius: 10.radius,
          color: ColorManager.grey.withValues(alpha: (0.9 )),
          padding: context.paddingAll(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextWidget(StringManager.youHaveNoAccess.tr()),
              10.hBox,
              ElevatedButton(
                onPressed: onPressed,
                child: Text(StringManager.allow.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}