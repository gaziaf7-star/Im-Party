part of 'package:general/src/features/setting/presentation/languages/view/language_screen.dart';

class LanguageScreenItem extends StatelessWidget {
  final String title;
  final bool currentValue;
  final void Function(bool) onChanged;

  const LanguageScreenItem({
    super.key,
    required this.title,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: 5.radius,
        onTap: () => onChanged(!currentValue), // Toggle the value on tap
        child: Padding(
          padding: context.paddingSymmetric(
              horizontal: 5,
              vertical: 5
          ),
          child: Row(
            children: [
              Container(
                margin: context.paddingAll(10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentValue? ColorManager.primary:ColorManager.transparent,
                    border: Border.all(
                        color:  currentValue
                            ? ColorManager.primary
                            : ColorManager.grayMouce4,
                        width: currentValue ? 1 : 0.5)),
                child: Icon(
                  Icons.check,

                  size: 13.r,
                  color: ColorManager.white,
                ),
              ),

              TextWidget(
                title,
                style: context.bodyMedium.w500.colorExt(ColorManager.black),
              ),
            ],
          ),
        ));
  }
}