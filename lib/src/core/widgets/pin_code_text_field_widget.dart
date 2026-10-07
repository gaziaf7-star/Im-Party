import 'package:general/src/core/index.dart';
import 'package:pinput/pinput.dart';

class PinCodeTextFieldWidget extends StatelessWidget {
  const PinCodeTextFieldWidget({super.key, required this.onChanged});
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    // Default pin theme for inactive or unfilled fields
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle:
          context.bodyMedium.size(20).bold.colorExt(ColorManager.textPrimary),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorManager.textPrimary
                .withValues(alpha: 0.30), // Default color for the line
            width: 2.0,
          ),
        ),
        color: ColorManager.transparent, // Background color behind the line
      ),
    );

    // Pin theme for the focused field
    final focusedPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ColorManager.textPrimary,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorManager.primary,
            width: 2.0,
          ),
        ),
        color: ColorManager.transparent,
      ),
    );

    // Pin theme for the filled field
    final filledPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ColorManager.textPrimary,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorManager.primary, // Color when filled
            width: 2.0,
          ),
        ),
        color: ColorManager.transparent, // Background color behind the line
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: 6,
        onChanged: onChanged,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: filledPinTheme,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "This field is required";
          }
          return null;
        },
      ),
    );
  }
}
