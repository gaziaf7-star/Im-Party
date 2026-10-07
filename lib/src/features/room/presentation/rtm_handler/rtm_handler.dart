import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/rtm_handler/room_message_processor.dart';
import 'package:general/src/features/room/room.dart';

class RtmHandler {
  final GiftController giftController;
  final String roomId;
  final String userModelId;
  final bool isHost;
  final TickerProvider tickerProvider;

  /// Kept for backward compatibility but no longer used internally.
  /// Room mode changes are now emitted via [RoomOverlayCubit].
  final VoidCallback? onRoomModeChange;

  late final RoomMessageProcessor _processor;

  RtmHandler({
    required this.giftController,
    required this.roomId,
    required this.userModelId,
    required this.isHost,
    required this.tickerProvider,
    this.onRoomModeChange,
  }) {
    _processor = RoomMessageProcessor(
      giftController: giftController,
      roomId: roomId,
      userModelId: userModelId,
      isHost: isHost,
      tickerProvider: tickerProvider,
    );
  }

  /// Set the context supplier so handlers can show dialogs.
  set contextSupplier(BuildContext Function()? supplier) {
    _processor.contextSupplier = supplier;
  }

  /// Enqueue a command string for batched processing.
  void onInRoomCommandReceived(
    String command,
    BuildContext context,
  ) {
    _processor.contextSupplier ??= () => context;
    _processor.onMessage(command);
  }

  /// Enqueue a pre-parsed data channel message for batched processing.
  /// Used with LiveKit data channel (replaces Zego RTM).
  void onDataReceived(Map<String, dynamic> data, BuildContext context) {
    _processor.contextSupplier ??= () => context;
    _processor.onDataMessage(data);
  }

  void updateTickerProvider(TickerProvider tp) {
    _processor.updateTickerProvider(tp);
  }

  void dispose() {
    _processor.dispose();
  }
}
