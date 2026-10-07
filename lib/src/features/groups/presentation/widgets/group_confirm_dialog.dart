import 'package:general/src/core/index.dart';

/// Reusable yes/no confirmation used by destructive group actions
/// (leave / delete / kick / transfer). Returns true when confirmed.
Future<bool> showGroupConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmText,
  bool isDestructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ColorManager.scaffoldBg,
      shape: RoundedRectangleBorder(borderRadius: 16.radius),
      title: TextWidget(
        title,
        style: ctx.bodyLarge.w600.colorExt(ColorManager.textPrimary),
      ),
      content: TextWidget(
        message,
        style: ctx.bodyMedium.colorExt(ColorManager.greyTextColor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: TextWidget(
            StringManager.cancel.tr(),
            style: ctx.bodyMedium.w600.colorExt(ColorManager.greyTextColor),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: TextWidget(
            confirmText ?? StringManager.confirm.tr(),
            style: ctx.bodyMedium.w600.colorExt(
              isDestructive ? ColorManager.red : ColorManager.primary,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
