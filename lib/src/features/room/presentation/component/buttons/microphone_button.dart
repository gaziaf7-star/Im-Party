import 'package:general/src/core/services/room_background_service.dart';
import 'package:general/src/features/room/presentation/room_controls/room_controls.dart';
import 'package:general/src/features/room/room.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/index.dart';

class MicrophoneButton extends StatelessWidget {
  const MicrophoneButton({super.key});

  @override
  Widget build(BuildContext context) {
    final media = RoomData.instance.utdController?.mediaController;
    // No controller yet (pre-connect / teardown): render a static muted icon
    // rather than subscribing to throwaway notifiers allocated per build.
    if (media == null) {
      return _icon(false);
    }

    // All Mute: while it holds for this user the mic stays off and a tap
    // only explains why.
    return ValueListenableBuilder<RoomControlsState>(
      valueListenable: RoomControls.instance.state,
      builder: (context, _, __) {
        if (!RoomControls.instance.canISpeak) {
          return InkWell(
            onTap: () => Methods.showToast(
              context,
              message: 'All Mute is on. The host has to allow you to speak.',
              isError: true,
            ),
            child: _icon(false),
          );
        }
        return _micButton(media);
      },
    );
  }

  Widget _micButton(UTDMediaController media) {
    // Gate the mic on the local publish permission. On a role demotion the
    // engine revokes publish and stops the track, so a tap-to-enable would
    // fail — disable the control and show it muted.
    return ValueListenableBuilder<bool>(
      valueListenable: media.canPublish,
      builder: (context, canPublish, __) {
        return ValueListenableBuilder<bool>(
          valueListenable: media.isMicEnabled,
          builder: (BuildContext context, bool micOn, Widget? child) {
            final isOn = canPublish && micOn;
            return InkWell(
              onTap: () async {
                if (!canPublish && !media.refreshCanPublish()) {
                  debugPrint('[MicrophoneButton] tapped — no publish permission');
                  Methods.showToast(
                    context,
                    message: 'Mic is not ready yet. Take a seat and try again.',
                    isError: true,
                  );
                  return;
                }
                debugPrint(
                    '[MicrophoneButton] tapped — current state: $isOn, target: ${!isOn}');
                final targetState = !isOn;
                if (targetState) {
                  final status =
                  await Methods.requestPermission(Permission.microphone);
                  debugPrint(
                      '[MicrophoneButton] microphone permission status: $status');
                  if (!status.isGranted) {
                    debugPrint(
                        '[MicrophoneButton] microphone permission NOT granted, aborting');
                    return;
                  }
                  // RECORD_AUDIO may have just been granted for the first time
                  // this session -- the background keep-alive service was
                  // started at room entry (before this permission existed) with
                  // the MICROPHONE foreground-service type omitted, so it never
                  // got background mic access. Re-running it now (idempotent)
                  // re-checks the permission and upgrades the running
                  // service's type, so backgrounding/minimizing after this
                  // point doesn't silently cut the outgoing mic.
                  RoomBackgroundService.start(
                    roomId: RoomData.instance.room.id?.toString() ?? '',
                    isLive: RoomData.instance.room.streamType == 'live',
                  );
                }
                // Toggling the mic publishes/unpublishes a track through the
                // realtime engine, which can throw (TrackPublishException /
                // NegotiationError / TimeoutException) when the media server is
                // unreachable or slow. These are server-side conditions, not app
                // bugs — catch them so a failed publish never crashes the room.
                try {
                  await media.setMicrophoneEnabled(targetState);
                  saveMicState(targetState);
                } catch (e, s) {
                  Methods.recordNonFatal(e, s,
                      reason: 'MicrophoneButton.setMicrophoneEnabled');
                  if (context.mounted) {
                    Methods.showToast(
                      context,
                      message: StringManager.someThingWentWrong.tr(),
                      isError: true,
                    );
                  }
                }
              },
              child: _icon(isOn),
            );
          },
        );
      },
    );
  }

  Widget _icon(bool isOn) {
    return ConstantsManager.isTheme1
        ? Image.asset(
      isOn ? AssetsManager.micOnIcon : AssetsManager.micOffIcon,
      width: 36.w,
      height: 36.h,
      fit: BoxFit.cover,
    )
        : CircleAvatar(
      radius: 19.5.r,
      // Bottom-bar icon buttons' tile background changed from a
      // light-white tint to a light-black tint on request.
      backgroundColor: Colors.black.withValues(alpha: 0.1),
      // Swapped the generic Material mic/mic_off glyphs for the
      // dedicated unmute/mute images on request. The two were showing
      // backwards (muting displayed the "unmute" art and vice versa)
      // -- flipped which asset maps to which state to match what the
      // button actually does.
      child: Image.asset(
        isOn
            ? AssetsManager.muteAudioIcon
            : AssetsManager.unmuteAudioIcon,
        width: 24.sp,
        height: 24.sp,
      ),
    );
  }
}