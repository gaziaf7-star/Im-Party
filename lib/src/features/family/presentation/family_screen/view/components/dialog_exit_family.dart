part of '../family_screen.dart';

class DialogExitFamily extends StatelessWidget {
  const DialogExitFamily({
    super.key,
    required this.content,
    this.onTapCancel,
    this.onTapConfirm,
  });

  final void Function()? onTapCancel;
  final void Function()? onTapConfirm;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(vertical: 15),
      height: ScreenUtil().screenHeight * 0.2,
      width: ScreenUtil().screenWidth * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ColorManager.veryLightBlack,
      ),
      child: Column(
        children: [
          Padding(
            padding: context.paddingAll(10.0),
            child: TextWidget(
              content,
              //maxLines: 3,
              style: context.bodyMedium.size(20).w600.colorExt(ColorManager.grey2)
            ),
          ),
          10.hBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MainButton(
                onTap: onTapCancel ?? () => Navigator.pop(context),
                title: StringManager.cancel.tr(),
                width: 100.w,
                height: 45.h,
                buttonColor: ColorManager.transparent,
                titleColor: ColorManager.primary,
                border: Border.all(
                  color: ColorManager.primary,
                ),
              ),
              MainButton(
                onTap: onTapConfirm ?? () => Navigator.pop(context),
                title: StringManager.confirm.tr(),
                width: 100.w,
                height: 45.h,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showExitFamilyDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AnimatedDialog(
      title: StringManager.exitFamily.tr(),
      description: StringManager.areYouSureToLeaveTheFamily.tr(),
      onTap: () {
        di<ExitFamilyBloc>().add(const ExitFamilyEvent());
        Navigator.pop(context);
      },
    ),
  );

  // return showDialog(
  //   context: context,
  //   builder: (BuildContext context) {
  //     return AnimatedDialog(
  //       child: Container(
  //         width: MediaQuery.sizeOf(context).width,
  //         color: ColorManager.white,
  //         padding: context.paddingSymmetric(
  //           vertical: 20,
  //           horizontal:30,
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(
  //               Icons.login,
  //               color: Colors.red,
  //               size: 40.h,
  //             ),
  //             15.hBox,
  //             TextWidget(
  //               StringManager.exitFamily,
  //               style: context.bodyMedium.w600,
  //             ),
  //             2.hBox,
  //             TextWidget(
  //               StringManager.areYouSureToLeaveTheFamily,
  //               style: context.bodyMedium.w400,
  //             ),
  //             30.hBox,
  //             InkWell(
  //               onTap: () {
  //                 di<ExitFamilyBloc>().add(const ExitFamilyEvent());
  //                 Navigator.pop(context);
  //               },
  //               child: Container(
  //                 width: 10.w,
  //                 height: 50.h,
  //                 decoration:
  //                 BoxDecoration(color: Colors.red, borderRadius: 5.radius),
  //                 child: Center(
  //                   child: TextWidget(
  //                     StringManager.done,
  //                     style: context.bodyMedium.w600.colorExt(ColorManager.textPrimary),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //
  //     );
  //   },
  // );
}
