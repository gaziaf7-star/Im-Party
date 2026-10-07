import 'package:general/src/core/index.dart';

class ForceUpdateDialog extends StatelessWidget {
  final String description;
  final bool isOptionalUpdate;
  final VoidCallback onConfirm;

  const ForceUpdateDialog({
    super.key,
    this.description = StringManager.updatDesc,
    required this.isOptionalUpdate,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final bool isForce = !isOptionalUpdate;

    final String innerTitle = isForce
        ? StringManager.updateForcedTitle.tr()
        : StringManager.updateOptionalTitle.tr();

    final String innerSubtitle = isForce
        ? StringManager.updateForcedSubtitle.tr()
        : StringManager.updateOptionalSubtitle.tr();
    if (isForce == true) ConstantsManager.isOptionalUpdate = false;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360.w,
          // Taller to fit the illustration without squeezing the texts.
          height: 480.h,
          decoration: BoxDecoration(
            color: ColorManager.backgroundDarkLight,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Container(
                width: double.infinity,
                padding: context.paddingSymmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  color: ColorManager.primary,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: context.paddingAll(8),
                      decoration: BoxDecoration(
                        color: ColorManager.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.info_outline,
                          size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextWidget(
                        isForce
                            ? StringManager.updateRequired.tr()
                            : StringManager.updatAvailable.tr(),
                        style:  TextStyle(
                          color: ColorManager.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isForce)
                      GestureDetector(
                        onTap: () {
                          ConstantsManager.isOptionalUpdate = true;
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: context.paddingAll(10),
                          child: const Icon(Icons.close,
                              size: 20, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),

              12.hBox,

              // ================= ILLUSTRATION =================
              // Update illustration (gift box bursting + rocket — owner
              // approved 2026-06-11). White background blends with the card.
              Center(
                child: Image.asset(
                  AssetsManager.updateIllustration,
                  height: 130.h,
                  fit: BoxFit.contain,
                ),
              ),

              8.hBox,

              // ================= INNER TITLE =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextWidget(
                  innerTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),

              5.hBox,

              // ================= SUBTITLE =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextWidget(
                  innerSubtitle,
                  style: TextStyle(
                      color: ColorManager.textPrimary.withValues(alpha: 0.6), fontSize: 14),
                ),
              ),

              20.hBox,

              // ================= DESCRIPTION =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextWidget(
                  description,
                  style: TextStyle(
                    color: ColorManager.secondaryText,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),

              const Spacer(),

              // ================= BUTTON =================
              Padding(
                padding: context.paddingSymmetric(horizontal: 20),
                child: ButtonWidget(
                  onPressed: () {
                    ConstantsManager.isOptionalUpdate = true;

                    onConfirm.call();
                  },
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsManager.downloadIcon,
                        height: 30,
                        width: 25,
                        color: ColorManager.buttonTextColor,
                      ),
                      8.wBox,
                       TextWidget(
                        StringManager.updateNow.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: ColorManager.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              5.hBox,

              Padding(
                padding:
                    context.paddingOnly(bottom: 18, top: 4, start: 20, end: 20),
                child: Center(
                  child: ButtonWidget(
                    onPressed: isForce
                        ? () {}
                        : () {
                            ConstantsManager.isOptionalUpdate = true;
                            Navigator.pop(context);
                          },
                    title: TextWidget(
                      isForce
                          ? StringManager.mustUpdateMessage.tr()
                          : StringManager.maybeLater.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isForce ? ColorManager.secondaryText : ColorManager.textPrimary,
                        fontWeight:
                            isForce ? FontWeight.normal : FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: isForce
                        ? ColorManager.transparent
                        : ColorManager.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
