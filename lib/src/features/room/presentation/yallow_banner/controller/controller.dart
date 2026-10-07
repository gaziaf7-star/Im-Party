import 'dart:async';
import 'dart:collection';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/home/domain/entities/room_entity.dart';
import 'package:general/src/features/profile/data/profile_remotely_data_source/profile_remotely_data_source.dart';

class YallowBannerController {
  // ====== Singleton Pattern ======
  YallowBannerController._internal();
  static final YallowBannerController _instance =
      YallowBannerController._internal();
  factory YallowBannerController() => _instance;

  // ====== Variables ======
  UserModel? senderData;
  RoomEntity? roomData;
  int senderId = -1;
  String message = '';
  ValueNotifier<bool> isShowYallowBanner = ValueNotifier<bool>(false);
  ValueNotifier<bool> isYallowBannerEnabled = ValueNotifier<bool>(false);

  final Queue<_BannerData> _bannerQueue = Queue<_BannerData>();
  bool _isShowing = false;
  Timer? _autoCloseTimer;

  // ====== Public Methods ======
  Future<void> showYallowBannerAnimation({
    required int senderId,
    required String message,
    required RoomEntity? room,
  }) async {
    _bannerQueue.add(
      _BannerData(
        senderId: senderId,
        message: message,
        room: room,
      ),
    );

    if (_isShowing) {
      _forceCloseCurrent();
    } else {
      _showNextBanner();
    }
  }

  void closeBanner() {
    _autoCloseTimer?.cancel();
    isShowYallowBanner.value = false;
    _isShowing = false;

    if (_bannerQueue.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), _showNextBanner);
    }
  }

  // ====== Private Methods ======
  void _forceCloseCurrent() {
    _autoCloseTimer?.cancel();
    isShowYallowBanner.value = false;
    _isShowing = false;

    _showNextBanner();
  }

  void _showNextBanner() async {
    if (_bannerQueue.isEmpty) {
      _isShowing = false;
      return;
    }

    _isShowing = true;
    final data = _bannerQueue.removeFirst();

    // A failed sender lookup must never drop the banner (or leave _isShowing
    // stuck true, which would block every later banner) — fall back to the
    // payload's sender id and show anyway.
    try {
      final response =
          await ProfileRemotelyDataSource(dioFactory: di()).getUserData(
        params: GetUserDataParameter(
          userId: data.senderId.toString(),
        ),
      );
      senderData = response.data;
    } catch (_) {
      senderData = UserModel(id: data.senderId);
    }
    roomData = data.room;
    message = data.message;
    senderId = data.senderId;

    isShowYallowBanner.value = true;

    final duration = _bannerQueue.isEmpty
        ? const Duration(minutes: 5)
        : const Duration(seconds: 5);

    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(duration, () {
      closeBanner();
    });
  }
}

class _BannerData {
  final int senderId;
  final String message;
  final RoomEntity? room;

  _BannerData({required this.senderId, required this.message, this.room});
}
