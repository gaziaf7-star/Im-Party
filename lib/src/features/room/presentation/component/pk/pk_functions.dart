import 'package:general/src/core/index.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/features/room/presentation/component/pk/counter_time_pk_widget.dart';
import 'package:general/src/features/room/presentation/component/pk/pk_widget.dart';
import 'package:general/src/features/room/presentation/manager/room_mode/room_mode_cubit.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:general/src/features/room/presentation/room_screen.dart';
import 'package:flutter_svga/flutter_svga.dart';

class PkController {
  static const String showPk = "showPK";
  static const String hidePk = "hidePK";
  static const String startPk = "startPK";
  static const String updatePk = "updatePk";
  static const String closePk = "closePk";
  static int timeSecondPK = 0;
  static int scoreTeam1 = 0;
  static int scoreTeam2 = 0;
  static double precantgeTeam1 = 0.5;
  static double precantgeTeam2 = 0.5;
  static double scoreBlue = 0.5;
  static double scoreRed = 0.5;
  static int timeMinutePK = 0;
  static SVGAAnimationController? animationControllerRedTeam;
  static SVGAAnimationController? animationControllerBlueTeam;

  /// PK runs in the default 9-seat mode (id "3"): one host seat on top, then two
  /// rows of four — rows = [ [0], [1,2,3,4], [5,6,7,8] ]. Team membership is
  /// decided by the seat's PHYSICAL position within its 4-wide row, split down
  /// the middle: the two left seats are the LEFT/RED team (team1), the two right
  /// seats are the RIGHT/BLUE team (team2). Only the single host seat (0) is
  /// NEUTRAL; every other seat belongs to a team.
  ///
  /// This yields RED = {1,2,5,6}, BLUE = {3,4,7,8}, neutral = {0}.
  ///
  /// Returns -1 = neutral (host), 0 = team1 (left/red), 1 = team2 (right/blue).
  static int teamForSeat(int seatIndex) {
    if (seatIndex <= 0) return -1; // host (single top seat) is neutral
    final pos = (seatIndex - 1) % 4; // 0,1 = left half; 2,3 = right half
    return pos < 2 ? 0 : 1; // left -> team1 (red), right -> team2 (blue)
  }

  /// True only for seats that belong to the left/red team (team1).
  static bool isTeam1Seat(int seatIndex) => teamForSeat(seatIndex) == 0;

  /// True only for seats that belong to the right/blue team (team2).
  static bool isTeam2Seat(int seatIndex) => teamForSeat(seatIndex) == 1;

  static ValueNotifier<bool> isPK = ValueNotifier<bool>(false);
  static ValueNotifier<bool> showPK = ValueNotifier<bool>(false);
  static ValueNotifier<int> updatePKNotifier = ValueNotifier<int>(0);
}

void activePK() {
  PkController.isPK.value
      ? PkController.isPK.value = false
      : PkController.isPK.value = true;
}

void showPK(TickerProvider ticker) {
  PkController.animationControllerRedTeam?.dispose();
  PkController.animationControllerBlueTeam?.dispose();
  PkController.animationControllerRedTeam = SVGAAnimationController(
    vsync: ticker,
  );
  PkController.animationControllerBlueTeam = SVGAAnimationController(
    vsync: ticker,
  );
  PkController.showPK.value = true;
  PkController.isPK.value = true;
  di<RoomOverlayCubit>().setShowPk(true);
}

void startPK(
  Map<String, dynamic> result,
  String ownerId,
  String roomId,
  BuildContext context,
) {
  startPKLocal(
    int.parse(result[messageContent]["PkTime"].toString()),
    ownerId,
    roomId,
    context,
  );
}

/// Starts a PK countdown locally from a chosen [minutes] duration.
///
/// LiveKit never echoes a participant's own data messages, so the host that
/// presses "start" never receives the broadcast `startPK` message — its timer
/// must be started locally from the picker. Remote participants reach the same
/// code via the RTM [startPK] handler. Both paths converge here so the
/// countdown ticks identically on every client.
void startPKLocal(
  int minutes,
  String ownerId,
  String roomId,
  BuildContext context,
) {
  PkController.timeMinutePK = minutes;
  PkController.timeSecondPK = 0;
  PkController.scoreTeam2 = 0;
  PkController.precantgeTeam1 = 0.5;
  PkController.precantgeTeam2 = 0.5;
  PKWidget.isStartPK.value = true;
  PkController.showPK.value = true;
  PkController.isPK.value = true;
  di<RoomOverlayCubit>().setShowPk(true);
  PkController.scoreTeam1 = 0;
  PkController.updatePKNotifier.value = PkController.updatePKNotifier.value + 1;

  di<SetTimerPK>().start(context, ownerId, roomId);
}

void hidePK() {
  PkController.showPK.value = false;
  di<RoomOverlayCubit>().setShowPk(false);
  restorePKData();
  PkController.isPK.value = false;
  PKWidget.isStartPK.value = false;
  PkController.timeSecondPK = 0;
  di<SetTimerPK>().stop();
  PkController.animationControllerBlueTeam?.dispose();
  PkController.animationControllerRedTeam?.dispose();
  PkController.animationControllerBlueTeam = null;
  PkController.animationControllerRedTeam = null;
}

/// Adds the value of a gift to the correct PK team bar in real time.
///
/// The server is not relied on to echo an `updatePk` for every gift (and
/// LiveKit never echoes the sender's own message at all), so each client scores
/// the gift locally from the `showGifts` payload. [receiverIds] are the user
/// ids that received the gift and [giftValue] is the value credited to each of
/// them (price × quantity). A receiver's team is resolved from its current
/// seat's physical column: left columns are team1 (red), right columns are
/// team2 (blue). Neutral seats (the host and the center column) do not score.
void addGiftToPK(List<String> receiverIds, int giftValue) {
  if (!PkController.isPK.value || giftValue <= 0 || receiverIds.isEmpty) return;

  var changed = false;
  for (final receiverId in receiverIds) {
    if (receiverId.isEmpty) continue;
    final entry =
        RoomScreenState.seatAvatarIds.entries
            .where((e) => e.value == receiverId)
            .firstOrNull;
    if (entry == null) continue;

    final team = PkController.teamForSeat(entry.key);
    if (team == 0) {
      PkController.scoreTeam1 += giftValue;
    } else if (team == 1) {
      PkController.scoreTeam2 += giftValue;
    } else {
      continue; // neutral seat (host/center) — does not score
    }
    changed = true;
  }
  if (!changed) return;

  final total = PkController.scoreTeam1 + PkController.scoreTeam2;
  if (total > 0) {
    PkController.precantgeTeam1 = PkController.scoreTeam1 / total;
    PkController.precantgeTeam2 = PkController.scoreTeam2 / total;
  }
  PkController.updatePKNotifier.value = PkController.updatePKNotifier.value + 1;
}

void updatePK(Map<String, dynamic> result) {
  PkController.scoreTeam2 = result[messageContent]['scoreTeam2'];
  PkController.precantgeTeam1 = double.parse(
    result[messageContent]['percentagepk_team1'],
  );
  PkController.precantgeTeam2 = double.parse(
    result[messageContent]['percentagepk_team2'],
  );
  PkController.scoreTeam1 = result[messageContent]['scoreTeam1'];
  PkController.updatePKNotifier.value = PkController.updatePKNotifier.value + 1;
}

void closePKKey(Map<String, dynamic> result) {
  PkController.scoreTeam2 = result[messageContent]['scoreTeam2'];
  PkController.precantgeTeam1 = double.parse(
    result[messageContent]['percentagepk_team1'],
  );
  PkController.precantgeTeam2 = double.parse(
    result[messageContent]['percentagepk_team2'],
  );
  PKWidget.isStartPK.value = false;
  PkController.scoreTeam1 = result[messageContent]['scoreTeam1'];
  PkController.updatePKNotifier.value = PkController.updatePKNotifier.value + 1;
  if (result[messageContent]['winner_Team'] == 2) {
    loadAnimationBlueTeam("images/WIN.svga");
    loadAnimationRedTeam("images/LOSE.svga");
  } else if (result[messageContent]['winner_Team'] == 1) {
    loadAnimationBlueTeam("images/LOSE.svga");
    loadAnimationRedTeam("images/WIN.svga");
  } else {
    loadAnimationBlueTeam("files/ce611dcb83b465805d552565d0705be4.svga");
    loadAnimationRedTeam("files/091e42c561800ca052493228e2165d70.svga");
  }
  PkController.timeSecondPK = 0;
  di<SetTimerPK>().stop();
}

Future<void> loadAnimationRedTeam(String img) async {
  final controller = PkController.animationControllerRedTeam;
  if (controller == null) {
    return;
  }
  final videoItem = await SvgaMovieCache.instance.loadFromUrl(
    EndPoints.getImage(img),
  );
  if (PkController.animationControllerRedTeam != controller ||
      videoItem == null) {
    return;
  }
  controller.videoItem = videoItem;
  controller.forward().whenComplete(() {
    if (PkController.animationControllerRedTeam == controller) {
      controller.videoItem = null;
    }
  });
}

Future<void> loadAnimationBlueTeam(String img) async {
  final controller = PkController.animationControllerBlueTeam;
  if (controller == null) {
    return;
  }
  final videoItem = await SvgaMovieCache.instance.loadFromUrl(
    EndPoints.getImage(img),
  );
  if (PkController.animationControllerBlueTeam != controller ||
      videoItem == null) {
    return;
  }
  controller.videoItem = videoItem;
  controller.forward().whenComplete(() {
    if (PkController.animationControllerBlueTeam == controller) {
      controller.videoItem = null;
    }
  });
}

void restorePKData() {
  PkController.scoreTeam2 = 0;
  PkController.precantgeTeam1 = 0.5;
  PkController.precantgeTeam2 = 0.5;
  PkController.scoreTeam1 = 0;
}
