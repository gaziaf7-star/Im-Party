import 'package:general/src/core/index.dart';

import 'GradientLoader.dart';

void showCustomLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: ColorManager.transparent,
    builder: (_) => const Center(child: _LoadingDialog()),
  );
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return ConstantsManager.isTheme1
        ? const LoadingView()
        : Center(
      child: Container(
        width: 70.w,
        padding: context.paddingAll(17.5),
        decoration: BoxDecoration(
          color: ColorManager.black,
          borderRadius: 8.radius,
        ),
        // Just the spinner now — no caption, per the "only loading, no
        // text" redesign applied across every loading state in the app.
        child: const GradientLoader(size: 32),
      ),
    );
  }
}