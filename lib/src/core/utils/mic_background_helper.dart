import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// Manages microphone background behavior preferences.
class MicBackgroundHelper {
  MicBackgroundHelper._();

  /// Whether the user chose to mute mic when app goes to background.
  /// Defaults to true.
  static bool get shouldMuteMicInBackground {
    return HiveManager().getData<bool>(
          KeysManager.USER_BOX,
          KeysManager.MUTE_MIC_IN_BACKGROUND_KEY,
          defaultValue: true,
        ) ??
        true;
  }

  /// Saves the mic-mute-in-background preference.
  static Future<void> setMuteMicInBackground(bool value) async {
    await HiveManager().saveData(
      KeysManager.USER_BOX,
      KeysManager.MUTE_MIC_IN_BACKGROUND_KEY,
      value,
    );
  }

  /// Whether the background dialog has already been shown.
  static bool get hasShownBackgroundDialog {
    return HiveManager().getData<bool>(
          KeysManager.USER_BOX,
          KeysManager.MIC_BACKGROUND_DIALOG_SHOWN_KEY,
          defaultValue: false,
        ) ??
        false;
  }

  /// Marks the background dialog as shown.
  static Future<void> markDialogAsShown() async {
    await HiveManager().saveData(
      KeysManager.USER_BOX,
      KeysManager.MIC_BACKGROUND_DIALOG_SHOWN_KEY,
      true,
    );
  }

  /// Shows the mic background preference dialog if it hasn't been shown before.
  static Future<void> showMicBackgroundDialogIfNeeded(
      BuildContext context) async {
    if (hasShownBackgroundDialog) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AnimatedDialog(
          title: StringManager.micBackgroundDialogTitle.tr(),
          conText: StringManager.yes.tr(),
          cancelText: StringManager.no.tr(),
          isHideConfirm: false,
          isUpdateDialog: true,
          onTapCancel: () async {
            await setMuteMicInBackground(false);
            await markDialogAsShown();
            Navigator.of(context).pop();
          },
          onTap: () async {
            await setMuteMicInBackground(true);
            await markDialogAsShown();
            Navigator.of(context).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              15.hBox,
              Text(
                StringManager.micBackgroundDialogQuestion.tr(),
                style: context.bodyMedium.w500.colorExt(ColorManager.textPrimary),
                textAlign: TextAlign.center,
              ),
              15.hBox,
              Container(
                padding: context.paddingAll(12),
                decoration: BoxDecoration(
                  color: ColorManager.grey.withValues(alpha: 0.1),
                  borderRadius: 8.radius,
                ),
                child: Text(
                  StringManager.micBackgroundDialogExplanation.tr(),
                  style: context.bodySmall.w400
                      .colorExt(ColorManager.black.withValues(alpha: 0.4)),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Mutes the microphone when entering PiP/background mode
  /// if the user preference is set.
  static void handleEnterBackground() {
    final controller = RoomData.instance.utdController;
    if (controller == null) return;

    final isMicOn = controller.mediaController.isMicEnabled.value;
    if (!isMicOn) return;

    if (shouldMuteMicInBackground) {
      controller.mediaController.setMicrophoneEnabled(false);
    }
  }

  /// Restores the microphone when returning from PiP/background mode
  /// if the user preference allows it.
  static void handleReturnFromBackground() {
    final controller = RoomData.instance.utdController;
    if (controller == null) return;

    if (!shouldMuteMicInBackground) {
      controller.mediaController.setMicrophoneEnabled(true);
    }
  }
}
