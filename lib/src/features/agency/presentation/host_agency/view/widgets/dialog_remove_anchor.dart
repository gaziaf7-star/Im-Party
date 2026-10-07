part of'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';
class DialogRemoveAnchor extends StatelessWidget {
  const DialogRemoveAnchor({
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
      height: ScreenUtil().screenHeight * 0.3,
      width: ScreenUtil().screenWidth * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: context.paddingAll(10.0),
            child: TextWidget(
              content,
              //maxLines: 3,
              style: context.bodyMedium.size(20).colorExt(ColorManager.grey2).w600,

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
