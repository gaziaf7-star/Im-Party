part of '../account_setting_page.dart';

class SecurityItem extends StatelessWidget {
  const SecurityItem({
    super.key,
    this.image,
    required this.title,
    required this.bind,
    required this.onTap,
  });

  final String? image;
  final String title;
  final String bind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onDoubleTap: () {},
      onTap: onTap,
      borderRadius: 12.radius,
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.white,
          border: Border(
            bottom: BorderSide(
              color: ColorManager.grey2.withValues(alpha: 0.25),
              width: 0.6,
            ),
          ),
        ),
        margin: context.paddingOnly(bottom: 0.5),
        padding: context.paddingSymmetric(horizontal: 14, vertical: 15),
        child: Row(
          children: [
            TextWidget(
              title,
              style: context.bodyMedium
                  .size(16)
                  .colorExt(ColorManager.black),
            ),
            const Spacer(),
            title == StringManager.changePassword.tr() ||
                title == StringManager.deleteAccount.tr() ||
                title == StringManager.changePhoneNumber.tr()
                ? Icon(
              Icons.arrow_forward_ios,
              color: ColorManager.black.withValues(alpha: 0.45),
              size: 17.r,
            )
                : bind.isEmpty
                ? 1.hBox
                : TextWidget(
                style: context.bodyMedium
                    .size(16)
                    .colorExt(bind == StringManager.bind.tr()
                    ? ColorManager.black.withValues(alpha: 0.5)
                    : ColorManager.primary)
                    .w600,
                bind),
          ],
        ),
      ),
    );
  }
}