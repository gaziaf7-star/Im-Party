import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/buttons/basic_tool/chat_button.dart';
import 'package:general/src/features/room/presentation/component/buttons/games_quick_button.dart';
import 'package:general/src/features/room/presentation/component/buttons/pk_button.dart';
import 'package:general/src/features/room/presentation/component/messages/messages_button/input_board_button.dart';
import 'package:general/src/features/room/room.dart';

class ButtomBarWidget extends StatelessWidget {
  const ButtomBarWidget({super.key});

  // Cached getters to avoid repeated calls
  MyDataModel get _myData => MyDataModel.getInstance();
  EnterRoomModel get _room => RoomData.instance.room;
  bool get _isOwner => _myData.id == _room.ownerId;

  bool get _isOnSeat =>
      RoomData.instance.utdController?.seatController
          .isUserOnSeat(_myData.id.toString()) ??
          false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SeatState>>(
      valueListenable:
      RoomData.instance.utdController?.seatController.seats ??
          ValueNotifier([]),
      builder: (context, _, __) {
        return Padding(
          // 10px gap from the screen's left/right edges on request -- the
          // row itself uses spaceBetween below, so without this the
          // left/right clusters sat flush against the very edges.
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            // spaceBetween (was spaceAround) so the right-side cluster --
            // Gift + More option -- sits flush against the row's right edge
            // instead of stopping short of it, per request ("more option
            // exactly on the right side").
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ConstantsManager.isTheme1
                ? _buildNewThemeButtons()
                : _buildDefaultThemeButtons(),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // New Theme Layout
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _buildNewThemeButtons() {
    return [
      Row(
        children: [
          const AudioRoomInRoomMessageInputBoardButton(),
          10.wBox,
          const SpeakerButton(),
          if (_isOnSeat) ...[10.wBox, const MicrophoneButton()],
        ],
      ),
      _giftButton,
      Row(
        children: [
          const ChatButton(),
          if (_isOwner) ...[10.wBox, const PkButton()],
          10.wBox,
          if (ConstantsManager.isVariantBuildA || ConstantsManager.isTheme2) ...[
            const EmoijeButton(),
            10.wBox
          ],
          // One-tap games launcher for EVERYONE in all modes.
          if (!ConstantsManager.isVariantBuildA) ...[
            const GamesQuickButton(),
            10.wBox,
          ],
          _basicToolButton(isOnMic: true),
        ],
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Default Theme Layout
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _buildDefaultThemeButtons() {
    final isOnMic = _isOwner || _isOnSeat;
    // Reorganized on request into two clusters:
    //  - left: Say hi, then Chat (Mail), then (when on mic) Emoji, then the
    //    Mic/"Mute" toggle -- Chat sits immediately left of Emoji.
    //  - right: Gift, then More option, flush against the row's right edge.
    // The one-tap games launcher used to sit here too -- dropped, since
    // it's redundant with the More-option sheet's own "Tricks in room"/
    // "Room Game" sections.
    return [
      Row(
        children: [
          const AudioRoomInRoomMessageInputBoardButton(),
          10.wBox,
          const ChatButton(),
          if (isOnMic) ...[
            10.wBox,
            const EmoijeButton(),
            10.wBox,
            const MicrophoneButton(),
          ],
        ],
      ),
      Row(
        children: [
          _giftButton,
          10.wBox,
          _basicToolButton(isOnMic: isOnMic),
        ],
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared Widgets
  // ─────────────────────────────────────────────────────────────────────────

  Widget _basicToolButton({required bool isOnMic}) => BasicToolButton(
    myDataModel: _myData,
    roomId: _room.id.toString(),
    ownerId: _room.ownerId.toString(),
    isOnMic: isOnMic,
    roomData: _room,
  );

  Widget get _giftButton => GiftButton(
    users: RoomService.instance.getAllUsers(),
    roomData: _room,
    myDataModel: _myData,
  );
}