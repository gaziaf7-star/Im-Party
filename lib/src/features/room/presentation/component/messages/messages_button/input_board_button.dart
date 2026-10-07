import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/messages/messages_button/input_board.dart';

/// @nodoc
class AudioRoomInRoomMessageInputBoardButton extends StatefulWidget {
  final bool rootNavigator;
  final Function(int)? onSheetPopUp;
  final Function(int)? onSheetPop;

  const AudioRoomInRoomMessageInputBoardButton({
    super.key,
    this.rootNavigator = false,
    this.onSheetPopUp,
    this.onSheetPop,
  });

  @override
  State<AudioRoomInRoomMessageInputBoardButton> createState() =>
      _AudioRoomInRoomMessageInputBoardButtonState();
}

/// @nodoc
class _AudioRoomInRoomMessageInputBoardButtonState
    extends State<AudioRoomInRoomMessageInputBoardButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final key = DateTime.now().millisecondsSinceEpoch;
        widget.onSheetPopUp?.call(key);

        Navigator.of(
          context,
          rootNavigator: widget.rootNavigator,
        )
            .push(
          AudioRoomInRoomMessageInputBoard(
            rootNavigator: widget.rootNavigator,
          ),
        )
            .then((value) {
          widget.onSheetPop?.call(key);
        });
      },
      child: ConstantsManager.isTheme1
          ? Image.asset(
        AssetsManager.chatIcon,
        width: 36.w,
        height: 36.h,
        fit: BoxFit.cover,
      )
          : Container(
        padding: context.paddingOnly(start: 5),
        decoration: BoxDecoration(
          // "Say hi" pill background changed from light-white to
          // light-black, to match the rest of the bottom bar.
          color: ColorManager.black.withValues(alpha: 0.2),
          borderRadius: 20.radius,
        ),
        width: ScreenUtil().screenWidth * 0.3,
        height: 30,
        child: Row(
          children: [
            15.wBox,
            TextWidget(
              StringManager.sendMessage.tr(),
              style: context.bodySmall.colorExt(ColorManager.white),
            ),
          ],
        ),
      ),
    );
  }
}