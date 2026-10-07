import 'package:general/src/core/index.dart';

class DatePickerWidget extends StatelessWidget {
  const DatePickerWidget({
    super.key,
    required this.onDateTimeChanged,
    this.dateTime,
    required this.controller,
    this.title,
    this.textColor,
    this.accentColor,
  });

  final TextEditingController controller;
  final String? title;
  final DateTime? dateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  /// Opt-in override for the displayed date's text colour (was always the
  /// panel-driven [ColorManager.textPrimary], which can resolve too light to
  /// read on a caller that force-locks its own background, e.g. the
  /// registration/add-information page). Null keeps every existing caller's
  /// current look.
  final Color? textColor;

  /// Opt-in override for the focused-border/icon accent colour (was a plain
  /// hardcoded green, mismatched against a caller with its own brand
  /// gradient, e.g. the pink/purple accent every other field on the
  /// registration page uses). Null keeps every existing caller's current
  /// green.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return TextInputWidget(
       controller.text==""? StringManager.birthday.tr():controller.text,
      label: TextWidget(
        StringManager.birthday.tr(),
        style: context.bodyLarge.colorExt(
          textColor ?? ColorManager.secondaryText,
        ),
      ),
      controller: controller,
      title: title,
      textColor: textColor ?? ColorManager.textPrimary,
      textStyle: context.bodyMedium.colorExt(textColor ?? ColorManager.secondaryText),
      hintStyle: context.bodyMedium.colorExt(textColor ?? ColorManager.secondaryText),
      suffixColor: accentColor ?? ColorManager.primary,
      prefixColor: accentColor ?? ColorManager.primary,
      readOnly: true,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.45)),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: accentColor ?? Colors.green),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      onTap: () {

        Methods.showCupertinoDatePicker(
          context: context,
          initialDateTime: dateTime ?? DateTime.now(),
          onDateTimeChanged: onDateTimeChanged,
          // Same overrides as the field itself (was always the sheet's own
          // panel-driven textPrimary/primary, independent of textColor
          // above — a caller could fix the field's text and still get an
          // unreadable picker sheet).
          titleColor: textColor,
          pickerTextColor: textColor,
          buttonTextColor: textColor,
        );
      },

      validator: (value) {
        if (value == null || value.isEmpty) {
          return StringManager.requiredField.tr();
        }
        return null;
      },
    );
  }
}
