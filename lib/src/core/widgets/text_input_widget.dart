import 'package:general/src/core/index.dart';

class TextInputWidget extends StatelessWidget {
  const TextInputWidget(
    this.hintText, {
    super.key,
    this.controller,
    this.title,
    this.keyboardType = TextInputType.text,
    this.hintStyle,
    this.isPassword = false,
    this.onChanged,
    this.focusNode,
    this.border,
    this.validator,
    this.textStyle,
    this.prefixIcon,
    this.prefixColor,
    this.suffixIcon,
    this.onPressed,
    this.initialValue,
    this.suffixColor,
    this.fillColor,
    this.textInputAction,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.contentPadding,
    this.colorFilter,
    this.maxLength,
    this.showMaxLength,
    this.hintTextDirection,
    this.textSize,
    this.cursorColor,
    this.textColor,
    this.isTappedOutside = true,
    this.minLines,
    this.onSubmitted,
    this.label,
    this.suffixIconConstraints,
    this.onEditingComplete,
    this.inputFormatters,
    this.autofocus,
  });

  final TextEditingController? controller;
  final TextDirection? hintTextDirection;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final String? hintText;
  final String? title;
  final Color? prefixColor;
  final Color? fillColor;
  final FocusNode? focusNode;
  final bool isPassword;
  final bool? autofocus;
  final dynamic prefixIcon;
  final dynamic suffixIcon;
  final Color? suffixColor;
  final VoidCallback? onPressed;
  final Function(String?)? onChanged;
  final void Function()? onEditingComplete;
  final String? Function(String?)? validator;
  final String? initialValue;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? minLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final EdgeInsetsGeometry? contentPadding;
  final ColorFilter? colorFilter;
  final Color? cursorColor;
  final Color? textColor;
  final int? maxLength;
  final bool? showMaxLength;
  final double? textSize;
  final bool isTappedOutside;
  final void Function(String)? onSubmitted;
  final dynamic label;
  final BoxConstraints? suffixIconConstraints;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onEditingComplete: onEditingComplete,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTapOutside: isTappedOutside == true
          ? (_) {
              FocusScope.of(context).unfocus();
            }
          : null,
      autofocus: autofocus ?? false,
      initialValue: initialValue,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: isPassword,
      onChanged: onChanged,
      validator: validator,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: minLines ?? 1,
      textInputAction: textInputAction,
      cursorColor: cursorColor ?? ColorManager.textPrimary,
      buildCounter: (
        BuildContext context, {
        required int currentLength,
        required bool isFocused,
        required int? maxLength,
      }) {
        return showMaxLength == null
            ? null
            : Text(
                '$currentLength/$maxLength',
                style: context.bodyMedium.w500.colorExt(
                    ColorManager.appBarTitlegrey.withValues(alpha: 0.85)),
              );
      },
      maxLength: maxLength,
      style: context.bodyMedium
          .copyWith(
              color: textColor ?? ColorManager.textPrimary,
              fontWeight: FontWeight.w500)
          .size(textSize ?? 14),
      onFieldSubmitted: onSubmitted,
      textDirection: hintTextDirection,
      decoration: InputDecoration(
        label: label,
        hintTextDirection: hintTextDirection,
        contentPadding: contentPadding ??
            context.paddingSymmetric(horizontal: 20, vertical: 5),
        hintText: tr(hintText ?? ""),
        hintStyle: hintStyle ??
            context.bodyLarge.colorExt(
              ColorManager.secondaryText,
            ),
        counterStyle: context.bodyMedium.colorExt(ColorManager.appBarTitlegrey),
        filled: true,
        fillColor: fillColor ?? ColorManager.transparent,
        prefixIcon: (prefixIcon != null)
            ? (prefixIcon is IconData)
                ? Icon(
                    prefixIcon,
                    size: 10.h,
                    color: prefixColor ?? ColorManager.iconColor,
                  )
                : (prefixIcon is String)
                    ? ImageWidget(
                        boxFit: BoxFit.contain,
                        image: prefixIcon,
                        color: prefixColor ?? ColorManager.iconColor,
                        height: 1.h,
                        width: 1.w,
                      )
                    : prefixIcon
            : null,
        suffixIconConstraints: suffixIconConstraints,
        suffixIcon: (suffixIcon != null)
            ? IconButton(
                onPressed: onPressed,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(),
                icon: (suffixIcon is IconData)
                    ? Icon(
                        suffixIcon,
                        size: 20.h,
                        color: suffixColor ?? ColorManager.iconColor,
                      )
                    : (suffixIcon is String)
                        ? ImageWidget(
                            image: suffixIcon,
                            height: 20.h,
                            width: 20.w,
                          )
                        : suffixIcon,
              )
            : null,
        border: border,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
      ),
      readOnly: readOnly,
      onTap: onTap,
    );
  }
}
