import '../../../../../../core/index.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});
  static ValueNotifier<bool> isChecked = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamedRoute(Routes.privacy);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWidget(
            StringManager.haveRead.tr(),
            style: context.bodyMedium
                .size(12)
                .colorExt(ColorManager.textPrimary)
                .copyWith(decorationColor: ColorManager.primary),
          ),
          TextWidget(
            StringManager.termsAndCondition.tr(),
            style: context.bodyMedium
                .size(12)
                .colorExt(ColorManager.textPrimary)
                .copyWith(decorationColor: ColorManager.primary),
          ),
        ],
      ),
    );
  }
}
