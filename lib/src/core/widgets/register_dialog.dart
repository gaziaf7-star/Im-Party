import 'package:general/src/core/index.dart';

class RegisterAnimatedDialog extends StatefulWidget {

  final String countryName;
  final String countryCode;
  final TextEditingController phoneNumber;

  const RegisterAnimatedDialog({
    super.key,
    required this.countryName,
    required this.countryCode,
    required this.phoneNumber,
  });


  @override
  RegisterAnimatedDialogState createState() => RegisterAnimatedDialogState();
}

class RegisterAnimatedDialogState extends State<RegisterAnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: ColorManager.scaffoldBg,
          insetPadding: EdgeInsets.symmetric(horizontal: 60.w),
          shape: RoundedRectangleBorder(borderRadius: 15.radius),
          elevation: 0.0,
          child: Container(
            decoration: BoxDecoration(
              color: ColorManager.surfaceCardColor,
              borderRadius: 20.radius,
            ),
            child: Padding(
              padding: context.paddingAll(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImageWidget(
                      height: 100.h,
                      width: 100.w,
                      image: AssetsManager.mobileValidate),
                  10.hBox,
                  TextWidget(
                    StringManager.notRegisteredYet.tr(),
                    textAlign: TextAlign.center,
                    style: context.bodyMedium.w500.size(16).colorExt(
                      ColorManager.textPrimary,
                    ),
                  ),
                  20.hBox,

                  ButtonWidget(
                    title: StringManager.registerNow.tr(),
                    height: 45.h,
                    fontSize: 14.sp,
                    width: 150.w,
                    titleColor: ColorManager.buttonTextColor,
                    radius: 20,
                    fontWeight: FontWeight.w400,
                    backgroundColor: ColorManager.primary,
                    onPressed: () {
                      context.pushNamedRoute(Routes.register,arguments: {
                      "countryName": widget.countryName,
                      "countryCode": widget.countryCode,
                      "poneNumber": widget.phoneNumber,
                    },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
