import 'dart:async';
import 'dart:developer';
import 'package:general/src/features/room/presentation/lucky_box/widgets/error_luck_widget.dart';
import 'package:general/src/features/room/room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/index.dart';
import 'widgets/sucess_luck_widget.dart';

class LuckyBoxData extends Equatable {
  final String boxId;
  final String uId;
  final String ownerImage;
  final String coins;
  final String ownerName;
  final String ownerBoxId;
  final TypeLuckyBox typeLuckyBox;
  final String endTime;
  final int usersNumber;

  const LuckyBoxData({
    required this.boxId,
    required this.uId,
    required this.ownerImage,
    required this.coins,
    required this.ownerName,
    required this.ownerBoxId,
    required this.typeLuckyBox,
    required this.endTime,
    required this.usersNumber,
  });

  @override
  List<Object?> get props => [boxId];
}

class LuckyBoxVariables {
  static bool? isRemove;
  static String typeBox = "luckyBox";
  static String bannerSuperBoxKey = 'bannerSuperBox';
  static ValueNotifier<int> notifierLuckyBox = ValueNotifier<int>(0);
  static ValueNotifier<int> notifierTypeBox = ValueNotifier<int>(0);
  static ValueNotifier<int> notifierCoins = ValueNotifier<int>(0);
  static ValueNotifier<int> notifierQuantity = ValueNotifier<int>(0);
  static StreamController<List<LuckyBoxData>> luckyBoxAddController =
      StreamController.broadcast();
  static StreamController<List<LuckyBoxData>> luckyBoxRemoveController =
      StreamController.broadcast();
  static ValueNotifier<bool> showBannerLuckyBox = ValueNotifier<bool>(false);

  /// Closes and reinitialises the broadcast StreamControllers and clears all
  /// transient banner/box state. Call on every room exit.
  static void reset() {
    luckyBoxAddController.close();
    luckyBoxRemoveController.close();
    luckyBoxAddController = StreamController.broadcast();
    luckyBoxRemoveController = StreamController.broadcast();
    bannerQueue.clear();
    activeBanners.clear();
    bannerIndexMap.clear();
    showBannerLuckyBox.value = false;
    notifierLuckyBox.value = 0;
    notifierTypeBox.value = 0;
    notifierCoins.value = 0;
    notifierQuantity.value = 0;
    activeBannersNotifier.value = 0;
    (luckyBoxMap['luckyBoxes'] as List<LuckyBoxData>).clear();
  }
  static final List<Map<String, dynamic>> bannerQueue = [];
  static final List<Map<String, dynamic>> activeBanners = [];
  static ValueNotifier<int> activeBannersNotifier = ValueNotifier<int>(0);
  static final Map<String, int> bannerIndexMap = {};

  static final Map<String, dynamic> luckyBoxMap = {
    "luckyBoxes": <LuckyBoxData>[],
    "coins": "",
    "quantity": "",
    "currentBox": 1,
  };

  static final Map<String, dynamic> bannerLuckyBoxModel = {
    "room": {},
    "ownerRoomId": '',
    "coins": '',
    "ownerBoxName": '',
    "ownerBoxImage": '',
    "ownerBoxUId": '',
    "ownerBoxSL": 0,
    "ownerBoxRL": 0,
    "ownerBoxAL": 0,
  };
}

void pickFromLuckyBox(Map<String, dynamic> result, BuildContext context) async {
  final Map<String, dynamic> message = result['messageContent'];
  final List<dynamic> winners = message['winners'];

  // Check if the current user is among the winners
  final winnerEntry = winners.firstWhere(
    (w) => w['user_id'].toString() == MyDataModel.getInstance().id.toString(),
    orElse: () => null,
  );

  if (winnerEntry != null) {
    RoomData.instance.chatController?.sendMessage(
      StringManager.winInLuckyBoxMessageKey,
      userData: {
        "coins": winnerEntry['coins'].toString(),
        "img": MyDataModel.getInstance().profile?.image ?? "",
        "bu": MyDataModel.getInstance().bubble ?? "",
        "buId": MyDataModel.getInstance().bubbleId.toString(),
        "sL": MyDataModel.getInstance().level?.senderImage ?? "",
        "rL": MyDataModel.getInstance().level?.receiverImage ?? "",
        "v": MyDataModel.getInstance().vip1?.img1 ?? "",
        "c": MyDataModel.getInstance().vip1?.colorName ?? "",
        'type': 'games',
      },
    );
    // User is a winner, show success dialog with coins
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorManager.transparent,
          contentPadding: EdgeInsets.zero,
          content: SuccessLuckWidget(
            coins: winnerEntry['coins'].toString(),
            ownerName: message['ownerName'].toString(),
            ownerImage: message['ownerImage'].toString(),
          ),
        );
      },
    );
  } else {
    final prefs = await SharedPreferences.getInstance();
    final hasPicked = prefs.getBool('picked_${message["boxUId"]}') ?? false;

    if (hasPicked) {
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: ColorManager.transparent,
            contentPadding: EdgeInsets.zero,
            content: ErrorLuckWidget(
              isNotLucky: false,
              ownerName: message['ownerName'].toString(),
              ownerImage: message['ownerImage'].toString(),
            ),
          );
        },
      );
    }
  }
}

void enqueueLuckyBoxBanner(Map<String, dynamic> banner) {
  final banners = LuckyBoxVariables.activeBanners;

  final ownerBoxUId = '${banner['ownerBoxUId']}';

  final isDuplicate =
      banners.any((b) => '${b['ownerBoxUId']}' == ownerBoxUId) ||
          LuckyBoxVariables.bannerQueue
              .any((b) => '${b['ownerBoxUId']}' == ownerBoxUId);

  if (isDuplicate) return;

  if (banners.length < 3) {
    final usedIndexes = LuckyBoxVariables.bannerIndexMap.values.toSet();
    final availableIndexes =
        [0, 1, 2].where((i) => !usedIndexes.contains(i)).toList();

    if (availableIndexes.isNotEmpty) {
      final nextIndex = availableIndexes.first;
      LuckyBoxVariables.bannerIndexMap[ownerBoxUId] = nextIndex;
      banners.add(banner);
      LuckyBoxVariables.activeBannersNotifier.value++;
    }
  } else {
    LuckyBoxVariables.bannerQueue.add(banner);
  }
}

void removeLuckyBoxBanner(String ownerBoxUId) {
  final banners = LuckyBoxVariables.activeBanners;

  final removedIndex = LuckyBoxVariables.bannerIndexMap[ownerBoxUId];
  banners.removeWhere((b) => '${b['ownerBoxUId']}' == ownerBoxUId);
  LuckyBoxVariables.bannerIndexMap.remove(ownerBoxUId);

  if (removedIndex != null && LuckyBoxVariables.bannerQueue.isNotEmpty) {
    final nextBanner = LuckyBoxVariables.bannerQueue.removeAt(0);
    final nextOwnerId = '${nextBanner['ownerBoxUId']}';

    if (!banners.any((b) => '${b['ownerBoxUId']}' == nextOwnerId)) {
      LuckyBoxVariables.bannerIndexMap[nextOwnerId] = removedIndex;
      banners.add(nextBanner);
      LuckyBoxVariables.activeBannersNotifier.value++;
      log("➕ Added new banner at index $removedIndex: $nextOwnerId");
    }
  }
}

void bannerSuperBoxKey(
  Map<String, dynamic> result,
  Map<String, dynamic> bannerLuckyBoxModel,
) {
  bannerLuckyBoxModel['room'] = result["room"];
  bannerLuckyBoxModel['coins'] = result["coins"].toString();
  bannerLuckyBoxModel['ownerRoomId'] = result["ownerRoomId"].toString();
  bannerLuckyBoxModel['ownerBoxName'] = result["ownerBoxName"].toString();
  bannerLuckyBoxModel['ownerBoxImage'] = result["ownerBoxImage"].toString();
  bannerLuckyBoxModel['ownerBoxUId'] = result["ownerBoxUId"].toString();
  bannerLuckyBoxModel['ownerBoxSL'] = result["ownerBoxSL"] ?? 0;
  bannerLuckyBoxModel['ownerBoxRL'] = result["ownerBoxRL"] ?? 0;
  bannerLuckyBoxModel['ownerBoxAL'] = result["ownerBoxAL"] ?? 0;
  LuckyBoxVariables.showBannerLuckyBox.value = true;
}

void showLuckyBox(Map<String, dynamic> result) {
  final List<LuckyBoxData> boxes =
      (LuckyBoxVariables.luckyBoxMap['luckyBoxes'] as List<LuckyBoxData>?) ??
          [];
  if (kDebugMode) log("res -----> $boxes");

  if (boxes.any((box) => box.boxId == '${result[messageContent][boxIDKey]}')) {
    return;
  }
  final LuckyBoxData newLuckyBox = LuckyBoxData(
    boxId: result[messageContent][boxIDKey].toString(),
    coins: result[messageContent][boxCoinsKey].toString(),
    ownerBoxId: result[messageContent][ownerBoxIdKey].toString(),
    ownerName: result[messageContent][ownerBoxNameKey],
    typeLuckyBox: result[messageContent][boxTypeKey] == 'normal'
        ? TypeLuckyBox.normalBox
        : TypeLuckyBox.superBox,
    uId: result[messageContent]['ownerBoxUId'].toString(),
    ownerImage: result[messageContent]['ownerBoxImage'] ?? '',
    endTime: result[messageContent]['end_time'] ?? "",
    usersNumber: int.parse(result[messageContent]['numOfBoxes'].toString()),
  );
  boxes.add(newLuckyBox);
  LuckyBoxVariables.luckyBoxAddController.add(boxes);
  LuckyBoxVariables.notifierLuckyBox.notifyListeners();
}

void hideLuckyBox(Map<String, dynamic> result) {
  LuckyBoxVariables.luckyBoxMap['luckyBoxes'].removeWhere(
    (element) => element.boxId == result[messageContent][boxIDKey].toString(),
  );
  LuckyBoxVariables.luckyBoxAddController.add(
    LuckyBoxVariables.luckyBoxMap['luckyBoxes'],
  );
  LuckyBoxVariables.notifierLuckyBox.notifyListeners();
}

void hideLuckyBoxFromLocal(String boxId) {
  LuckyBoxVariables.luckyBoxMap['luckyBoxes'].removeWhere(
    (element) => element.boxId == boxId,
  );
  LuckyBoxVariables.luckyBoxAddController.add(
    LuckyBoxVariables.luckyBoxMap['luckyBoxes'],
  );
  LuckyBoxVariables.notifierLuckyBox.notifyListeners();
}
