import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/update_dialog.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';

/// One update prompt shared by both intro variants and logged-in layouts.
class AppUpdatePrompt {
  AppUpdatePrompt._();

  static bool _isOpen = false;

  static void showIfNeeded(BuildContext context, ConfigAppState state) {
    if (_isOpen || !context.mounted) return;
    if (!(state.requestState.isLoaded || state.requestState.isEmpty)) return;
    final config = state.config;
    if (config?.isLastVersion != false) return;

    final storeLink = (config?.appURL ?? ConstantsManager.appURL).trim();
    final uri = Uri.tryParse(storeLink);
    if (uri == null ||
        !(uri.scheme == 'https' || uri.scheme == 'http') ||
        uri.host.isEmpty) {
      return; // Never display a broken Update button.
    }

    final forced = config?.isForce == true;
    _isOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: !forced,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => PopScope(
        canPop: !forced,
        child: ForceUpdateDialog(
          description: StringManager.updatDesc.tr(),
          isOptionalUpdate: !forced,
          onConfirm: () => Methods.openUrl(storeLink),
        ),
      ),
    ).whenComplete(() => _isOpen = false);
  }
}
