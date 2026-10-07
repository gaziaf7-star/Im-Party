import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/pk/pk_functions.dart';
import 'package:general/src/features/room/presentation/component/pk/pk_widget.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_bloc.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_events.dart';
import 'package:general/src/features/room/presentation/room_ticker.dart';

class CounterPkTimeWidget extends StatelessWidget {
  const CounterPkTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final seconds =
        PkController.timeSecondPK.toString().padLeft(2, '0');
    return Text(
      "${PkController.timeMinutePK} : $seconds",
      style: context.bodyMedium.size(15).w300.colorExt(
            ColorManager.whiteColor,
          ),
    );
  }
}

class SetTimerPK {
  // Not final: closed and reinitialised in dispose() so the DI singleton
  // survives multiple PK sessions without leaking stream listeners.
  StreamController<TimeData> streamController =
      StreamController<TimeData>.broadcast();

  StreamSubscription<int>? _tickerSubscription;

  Stream<TimeData> get stream => streamController.stream;

  void start(BuildContext context, String ownerId, String roomId) {
    // Cancel any previous subscription before starting a fresh countdown so a
    // re-started PK never runs two tickers in parallel (double-decrement).
    RoomTicker.instance.unsubscribe(_tickerSubscription);
    _tickerSubscription = RoomTicker.instance.subscribe((_) {
      _updateSeconds(context, ownerId, roomId);
    });
  }

  /// Stop ticking without tearing down the broadcast stream, so the PK widget's
  /// StreamBuilder stays subscribed and can show the final frozen time.
  void stop() {
    RoomTicker.instance.unsubscribe(_tickerSubscription);
    _tickerSubscription = null;
  }

  void dispose() {
    RoomTicker.instance.unsubscribe(_tickerSubscription);
    _tickerSubscription = null;
    streamController.close();
    streamController = StreamController<TimeData>.broadcast();
  }

  void _updateSeconds(BuildContext context, String ownerId, String roomId) {
    if (PkController.timeMinutePK < 1 && PkController.timeSecondPK < 1) {
      // Time is up. Stop ticking on every client (keeps the stream alive so the
      // widget can render the frozen 0:0), and let the owner ask the server to
      // close/score the PK. The owner's StartPK was applied locally (LiveKit
      // does not echo our own data messages back), so the owner reaches 0 too.
      stop();
      if (MyDataModel.getInstance().id.toString() == ownerId) {
        di<PKBloc>().add(ClosePKEvent(roomId: roomId, pkId: PKWidget.pkId));
      }
    } else if (PkController.timeSecondPK < 1) {
      PkController.timeSecondPK = 59;
      PkController.timeMinutePK--;
      di<TimeData>().setMinute = PkController.timeMinutePK;
      di<TimeData>().setSecond = PkController.timeSecondPK;
      streamController.sink.add(di<TimeData>());
    } else {
      PkController.timeSecondPK--;
      di<TimeData>().setSecond = PkController.timeSecondPK;
      streamController.sink.add(di<TimeData>());
    }
  }
}

class TimeData {
  int minute;
  int second;

  TimeData({this.minute = 0, this.second = 0});

  int get getMinute => minute;

  set setMinute(int minute) => this.minute = minute;

  int get getSecond => second;

  set setSecond(int second) => this.second = second;
}
