
import 'package:general/src/core/index.dart';

class SuccessTransferScreen extends StatelessWidget {
  final SuccessTransferScreenParam param;

  const SuccessTransferScreen({super.key, required this.param});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget(
        title: StringManager.balanceTransfer.tr(),
      ),
      body: Padding(
        padding: context.paddingSymmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              200.hBox,
              Image.asset(AssetsManager.success, scale: 3),
              Padding(
                padding: context.paddingAll(10),
                child: TextWidget(
                  StringManager.transferSuccess.tr(),
                  style: context.bodyMedium.size(18).w600
                ),
              ),
              TextWidget(
                StringManager.transferSuccessHint.tr(),
                textAlign: TextAlign.center,
                style: context.bodyMedium.size(13).colorExt(ColorManager.secondaryText),
              ),
              Padding(
                padding: context.paddingSymmetric(vertical: 20),
                child: Container(
                    color: Colors.grey,
                    height: 1,
                    width: ScreenUtil().screenWidth),
              ),
              Padding(
                padding: context.paddingAll(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      StringManager.transferAmount.tr(),
                      style: context.bodyMedium.colorExt(ColorManager.secondaryText),
                    ),
                    param.isCoins
                        ? Row(
                            children: [
                              Image.asset(
                                AssetsManager.mallCoin,
                                scale: 4,
                              ),
                              3.wBox,
                              TextWidget(
                                param.value,
                              )
                            ],
                          )
                        : TextWidget(
                            '\$ ${param.value}',
                          )
                  ],
                ),
              ),
              30.hBox,
              MainButton(
                width: 200.w,
                height: 45.h,
                onTap: () => Navigator.pop(context),
                title: StringManager.done.tr(),
                buttonColor: ColorManager.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
