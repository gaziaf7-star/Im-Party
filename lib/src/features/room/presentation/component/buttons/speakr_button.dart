import 'package:general/src/features/room/presentation/room_controller.dart';
import '../../../../../core/index.dart';

class SpeakerButton extends StatelessWidget {
  const SpeakerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RoomData.instance.utdController;
    if (controller == null) return const SizedBox();

    return ValueListenableBuilder<bool>(
      valueListenable: controller.mediaController.isAllRemoteAudioMuted,
      builder: (context, isMuted, _) {
        return GestureDetector(
          onTap: () {
            controller.mediaController.muteAllRemoteAudio(!isMuted);
          },
          child: ConstantsManager.isTheme1
              ? Image.asset(
            isMuted
                ? AssetsManager.soundOffIcon
                : AssetsManager.soundOnIcon,
            width: 36.w,
            height: 36.h,
            fit: BoxFit.cover,
          )
              : Container(
            padding: context.paddingAll(5),
            margin: context.paddingOnly(top: 5),
            width: 90.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: context.paddingAll(9),
                  // Same brand-gradient badge + icon as the rest of the
                  // "More" tools sheet, on request.
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: ColorManager.brandGradientColors
                            .map((c) => c.withValues(alpha: 0.1))
                            .toList(),
                      ),
                      borderRadius: 30.radius),
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) =>
                        ColorManager.brandGradient.createShader(bounds),
                    child: Image.asset(
                      isMuted
                          ? AssetsManager.volumeOff
                          : AssetsManager.volume,
                      width: 30.w,
                      height: 30.h,
                      color: ColorManager.white,
                    ),
                  ),
                ),
                5.hBox,
                Text(
                  isMuted
                      ? StringManager.turnOnSound.tr()
                      : StringManager.turnOffSound.tr(),
                  style: context.bodySmall
                      .colorExt(ColorManager.black)
                      .copyWith(fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}