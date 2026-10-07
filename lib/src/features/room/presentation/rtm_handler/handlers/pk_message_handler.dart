import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/charisma/bloc/charisma_bloc.dart';
import 'package:general/src/features/room/presentation/manager/room_mode/room_mode_cubit.dart';
import 'package:general/src/features/room/room.dart';

import '../room_message_processor.dart';

/// Handles PK (Player vs Player) and charisma RTM messages.
///
/// Charisma is SERVER-AUTHORITATIVE and render-only on the client: the backend
/// owns the per-room totals and ships them in the gift frame + enter-room
/// payload. This handler only reflects the start/close toggle cues and writes
/// the seat-state totals carried in an `updateCharisma` frame — no resync
/// request/response fan-out.
class PkMessageHandler {
  TickerProvider tickerProvider;

  PkMessageHandler({required this.tickerProvider});

  /// (G) The charisma bloc is `resetLazySingleton`'d around a room switch. Resolve
  /// it and skip the dispatch if it was torn down so a frame from the old room
  /// can't land on (or throw against) the freshly-rebuilt bloc.
  CharismaBloc? get _liveCharismaBloc {
    final bloc = di<CharismaBloc>();
    return bloc.isClosed ? null : bloc;
  }

  void handle(CategorizedMessage msg, BuildContext? context) {
    final result = msg.payload;

    switch (msg.messageType) {
      case PkController.showPk:
        showPK(tickerProvider);
        break;

      case PkController.startPk:
        if (context != null) {
          startPK(
            result,
            RoomData.instance.room.ownerId.toString(),
            RoomData.instance.room.id.toString(),
            context,
          );
        }
        break;

      case PkController.hidePk:
        hidePK();
        break;

      case PkController.updatePk:
        updatePK(result);
        break;

      case PkController.closePk:
        closePKKey(result);
        break;

      case startCharisma:
        // Charisma display turned on. Totals are server-authoritative and arrive
        // via gift frames / enter-room; the backend resets its per-room store on
        // the toggle, so start from a clean slate.
        _liveCharismaBloc?.add(const InitCharismaEvent());
        RoomData.instance.isCharismaVisible.value = true;
        di<RoomOverlayCubit>().setCharismaVisible(true);
        break;

      case closeCharisma:
        _liveCharismaBloc?.add(const InitCharismaEvent());
        RoomData.instance.isCharismaVisible.value = false;
        di<RoomOverlayCubit>().setCharismaVisible(false);
        break;

      case updateCharisma:
        // (G) Skip if the bloc was torn down around a room switch.
        final bloc = _liveCharismaBloc;
        if (bloc == null) break;
        bloc.add(
          UpdateCharismaEvent(
            data: List<CharismaModel>.from(
              (result[messageContent]['data'] as List)
                  .map((element) => CharismaModel.fromJson(element)),
            ),
          ),
        );
        break;
    }
  }
}
