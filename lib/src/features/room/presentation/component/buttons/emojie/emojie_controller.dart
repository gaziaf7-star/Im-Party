import 'package:general/src/core/index.dart';

class EmojieController {
  static const String showEmojie = "showEmojie";
  static ValueNotifier<Map<String, EmojieData>> emojies = ValueNotifier({});
  static ValueNotifier<int> updateEmojie = ValueNotifier(0);

  static void reset() {
    emojies.value = {};
    updateEmojie.value = 0;
  }

  Future<void> showingEmojie({
    required String userId,
    required EmojieData emojieData,
    required int timeEmojie,
  }) async {
    // Was a hardcoded 1500ms regardless of the emoji's own configured
    // length (t_length, in seconds -- `timeEmojie`/`emojieData.length` were
    // received but never used) -- on a real network fetch, the SVGA's own
    // load+decode time (CacheSvgaWidget._loadSvga is async) ate into that
    // fixed window before playback even started, so a 1-second animation
    // was only actually ON SCREEN for whatever was left of the 1500ms,
    // reading as "cut in half". Basing the window on the real configured
    // length plus a generous load buffer fixes that regardless of network
    // speed.
    final displayDuration = Duration(
      milliseconds: (timeEmojie > 0 ? timeEmojie * 1000 : 1500) + 800,
    );
    if (EmojieController.emojies.value[userId] != null) {
      Future.delayed(displayDuration, () {
        EmojieController.emojies.value.remove(userId);
        EmojieController.emojies.value.putIfAbsent(userId, () => emojieData);
        EmojieController.updateEmojie.value =
            DateTime.now().millisecondsSinceEpoch.toInt() +
                (MyDataModel.getInstance().id ?? -1);

        Future.delayed(displayDuration, () {
          EmojieController.emojies.value.remove(userId);
          EmojieController.updateEmojie.value =
              DateTime.now().millisecondsSinceEpoch.toInt() +
                  (MyDataModel.getInstance().id ?? -1);
        });
      });
    } else {
      EmojieController.emojies.value.remove(userId);
      EmojieController.emojies.value.putIfAbsent(userId, () => emojieData);
      EmojieController.updateEmojie.value =
          DateTime.now().millisecondsSinceEpoch.toInt() +
              (MyDataModel.getInstance().id ?? -1);

      Future.delayed(displayDuration, () {
        EmojieController.emojies.value.remove(userId);
        EmojieController.updateEmojie.value =
            DateTime.now().millisecondsSinceEpoch.toInt() +
                (MyDataModel.getInstance().id ?? -1);
      });
    }
  }
}

class EmojieData {
  final String emojie;
  final int emojieId;
  final int length;
  final String type;

  const EmojieData( {
    required this.emojie,
    required this.emojieId,
    required this.length,
    required this.type,
  });
}
