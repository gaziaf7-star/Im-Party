import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/services/auth_service.dart';
import 'package:general/src/core/realtime/in_app_chat_notifier.dart';
import 'package:general/src/core/services/firebase_config_store.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:path_provider/path_provider.dart';

// FCM HYBRID — background isolate. This runs in a SEPARATE isolate spawned by
// the OS for data messages while the app is backgrounded/terminated; it has no
// access to the main isolate's runtime (panel-driven) Firebase config or DI.
//
// It PREFERS the runtime (panel-driven) identity: it reads the PERSISTED config
// the main isolate already saved (SharedPreferences/JSON file — both are
// readable cross-isolate) WITHOUT any network call (the OS background budget is
// tiny), and initializes Firebase with those explicit [FirebaseOptions]. When
// nothing is persisted yet (e.g. the very first cold push right after install,
// before the main isolate has ever fetched the config) it falls back to
// Firebase.initializeApp() WITHOUT options, so the NATIVE google-services.json /
// GoogleService-Info.plist guarantees FCM still works. The native files are the
// floor; the persisted runtime config is the preferred ceiling.
@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage remoteMessage) async {
  if (Firebase.apps.isNotEmpty) return;
  try {
    final FirebaseOptions? options =
        await FirebaseConfigStore.instance.loadPersistedOnly();
    if (options != null) {
      await Firebase.initializeApp(options: options);
      return;
    }
  } catch (_) {
    // Fall through to the native default below.
  }
  await Firebase.initializeApp();
}

/// Outcome of the launch-push readiness gate (see
/// [NotificationService.dispatchReadiness]).
enum DispatchReadiness { dispatch, retry, drop }

class NotificationService {
  NotificationService._internal();

  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() => _notificationService;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  /// SINGLE source for the notification channel identity. White-label: the
  /// user-visible name is the runtime app display name (native app label /
  /// APP_BRAND_NAME), never a hardcoded client brand; falls back to a neutral
  /// 'Notifications'. The channel id is a stable neutral constant (changing it
  /// would orphan the OS-registered channel).
  static const String _channelId = 'default_high_importance';
  static String get _channelName {
    final name = ConstantsManager.appDisplayName.trim();
    return name.isNotEmpty ? name : 'Notifications';
  }

  static String get _channelDescription =>
      'Used for important notifications.';

  AndroidNotificationChannel get _androidChannel => AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
      );

  String? _lastNotificationHash;

  String _generateHash({
    required String? title,
    required String? body,
    required Map<String, dynamic> data,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(title?.trim().toLowerCase() ?? '');
    buffer.writeln(body?.trim().toLowerCase() ?? '');

    const importantKeys = ['type', 'id', 'timestamp', 'message_id'];

    for (final key in importantKeys) {
      final value = data[key];
      if (value != null) {
        buffer.writeln('$key:${value.toString().trim().toLowerCase()}');
      }
    }

    final input = buffer.toString();
    return _hash(input);
  }

  String _hash(String input) {
    int hash = 17;
    for (int i = 0; i < input.length; i++) {
      hash = 37 * hash + input.codeUnitAt(i);
    }
    return hash.toRadixString(16);
  }

  @pragma('vm:entry-point')
  Future<void> openMessageHandler(RemoteNotificationModel message) async {
    String? type = message.type;

    if (type == null) {
      if (message.channelId != null &&
          message.userName != null &&
          message.toUserId != null) {
        type = notificationKeySystemMsg;
      }
    }

    Methods.printLog(
        "📩 Push Notification Received ${message.toJson()} with type: $type");

    // Capture the navigator once and bail if it is not mounted yet (terminated
    // cold-start can deliver a tap before the root navigator exists). This
    // replaces every force-unwrapped navKey.currentState!/currentContext! below
    // with a null-safe call so a push tap can never crash on launch.
    final nav = navKey.currentState;
    if (nav == null) return;

    switch (type) {
      case notificationKeyVisitProfile:
        nav.pushNamed(Routes.friendFollowing, arguments: 3);
        break;

      case notificationKeyFollow:
        nav.pushNamed(Routes.friendFollowing, arguments: 1);
        break;

      case notificationKeyFamily:
        nav.pushNamed(Routes.familyScreen, arguments: message.familyId);
        break;
      case notificationKeySystemMsg:
        nav.pushNamed(Routes.systemMessageScreen);
        break;

      case notificationKeyRequestJoinFamily:
        nav.pushNamed(Routes.familyRequests, arguments: message.familyId);
        break;

      case acceptJoinToFamily:
        nav.pushNamed(Routes.familyScreen, arguments: message.familyId);
        break;
      case notificationKeyVips:
        // di<VipCenterBloc>().add(const GetVipCenterEvent());
        nav.pushNamed(Routes.vipPage);
        break;
      case notificationKeyFamilyLevelUpgrade:
        nav.pushNamed(Routes.familyScreen, arguments: message.familyId);
        break;
      case "ban-user":
        debugPrint(
          '[LOGIN_REDIRECT] source=NotificationService status=ban-user '
          'reason=backend_ban_notification',
        );
        nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
        break;

      // ── Chat (group) ── tapping a 'new group message' push deep-links into
      // the group conversation; falls back to the chat list when the room id is
      // missing so the user never lands on nothing.
      case notificationKeygroupChat:
        final gid = int.tryParse(message.chatRoomId ?? '');
        if (gid != null && gid > 0) {
          nav.pushNamed(
            Routes.groupChatDetailScreen,
            arguments: GroupEntity(id: gid, chatRoomId: gid),
          );
        } else {
          nav.pushNamed(Routes.chatsPage);
        }
        break;

      // ── Chat (DM) ── tapping a 'new message' push opens the 1:1 conversation
      // with the sender; falls back to the chat list when no peer is resolvable.
      case notificationChatPayload:
        final peerId = (message.userId != null && message.userId!.isNotEmpty)
            ? message.userId
            : message.toUserId;
        if (peerId != null && peerId.isNotEmpty) {
          nav.pushNamed(
            Routes.messages,
            arguments: MessagesParameter(
              userId: peerId,
              name: message.userName ?? message.name ?? '',
              image: message.image ?? message.imageUrl ?? '',
              hasColorName: message.hasColorName ?? false,
              chatId: int.tryParse(message.chatRoomId ?? ''),
            ),
          );
        } else {
          nav.pushNamed(Routes.chatsPage);
        }
        break;

      default:
        // Unknown / empty type (incl. plain chat pushes whose message-type we
        // don't route): never dead-end the user — do nothing rather than crash.
        break;
    }
  }

  /// Maximum readiness-gate attempts before giving up on a launch push.
  /// 40 attempts × 250ms ≈ 10s — generous enough for the slowest cold boot,
  /// bounded so a never-mounting navigator can't loop forever.
  static const int _dispatchMaxAttempts = 40;
  static const Duration _dispatchRetryDelay = Duration(milliseconds: 250);

  /// Whether a launch push should be dispatched now (navigator mounted),
  /// retried (still booting, attempts left), or dropped (cap reached). Pure so
  /// the gating decision is unit-testable without a real navigator.
  @visibleForTesting
  static DispatchReadiness dispatchReadiness({
    required bool navigatorReady,
    required int attempts,
    int maxAttempts = _dispatchMaxAttempts,
  }) {
    if (navigatorReady) return DispatchReadiness.dispatch;
    if (attempts >= maxAttempts) return DispatchReadiness.drop;
    return DispatchReadiness.retry;
  }

  /// Dispatch a pending launch [message] as soon as the root navigator is
  /// mounted, retrying on a fixed cadence and bailing after the cap so a slow
  /// boot never loses the deep-link nor a stuck boot spins forever.
  void _dispatchWhenReady(RemoteNotificationModel message, {int attempts = 0}) {
    switch (dispatchReadiness(
      navigatorReady: navKey.currentState != null,
      attempts: attempts,
    )) {
      case DispatchReadiness.dispatch:
        openMessageHandler(message);
        break;
      case DispatchReadiness.drop:
        Methods.printLog(
            "⛔ Dropping launch push: navigator not ready after cap");
        break;
      case DispatchReadiness.retry:
        Future.delayed(
          _dispatchRetryDelay,
          () => _dispatchWhenReady(message, attempts: attempts + 1),
        );
        break;
    }
  }

  Future<void> initLocalNotification() async {
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    Methods.printLog("🔧 Initializing local notifications...");

    await localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        Methods.printLog(
            "📨 Local notification tapped. Payload: ${response.payload}");
        try {
          final data = jsonDecode(response.payload!);
          if (data is Map<String, dynamic> &&
              data['message-type'] == 'reel-ready') {
            navKey.currentState?.pushNamed(
              Routes.reelsScreen,
              arguments: data['reel_id'],
            );
            return;
          }
          final message = RemoteNotificationModel.fromJson(
              data as Map<String, dynamic>);
          openMessageHandler(message);
        } catch (e) {
          Methods.printLog("❌ Failed to parse local notification payload: $e");
        }
      },
    );

    await localNotification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    Methods.printLog(
        "✅ Local notification channel '${_androidChannel.id}' created.");
  }

  Future<void> initPushNotification() async {
    Methods.printLog("🔧 Initializing push notifications...");

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        Methods.printLog("📩 App opened from terminated state via push.");
        Methods.printLog("📦 Initial message data: ${message.data}");

        // Dispatch as soon as the navigator is mounted instead of guessing with
        // a fixed 4s delay (too short on slow cold boot — message lost; too long
        // on fast boot — laggy). Readiness-gated retry handles both.
        _dispatchWhenReady(RemoteNotificationModel.fromJson(message.data));

        final notifTitle = message.notification?.title?.trim();
        final dataTitle = message.data['title']?.toString().trim();
        final title = notifTitle?.isNotEmpty == true ? notifTitle : dataTitle;

        Methods.printLog("📌 Initial notification title: $title");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Methods.printLog("🟡 App opened from background via push.");
      Methods.printLog("📦 onMessageOpenedApp data: ${message.data}");

      openMessageHandler(RemoteNotificationModel.fromJson(message.data));
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Methods.printLog(
          "📥 Foreground push received. Raw data: ${message.data}");

/*
  final notificationTitle = message.notification?.title?.trim();
  final dataTitle = message.data['title']?.toString().trim();
  final title = notificationTitle?.isNotEmpty == true ? notificationTitle : dataTitle;
*/
      Methods.printLog("🔔 Push title: ${message.notification}");

      _showLocalNotification(message, message.data);
    });

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    Methods.printLog("✅ Background message handler registered.");
  }

  Future<void> _showLocalNotification(
    RemoteMessage message,
    Map<String, dynamic> data,
  ) async {
    try {
      final notifTitle = message.notification?.title?.trim();
      final dataTitle = message.data['title']?.toString().trim();
      final title = (notifTitle != null && notifTitle.isNotEmpty)
          ? notifTitle
          : dataTitle;

      final notifBody = message.notification?.body?.trim();
      final dataBody = message.data['body']?.toString().trim();
      final body =
          (notifBody != null && notifBody.isNotEmpty) ? notifBody : dataBody;

      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        Methods.printLog("⛔ Skipping notification: no title or body found");
        return;
      }

      // Suppress 'enter-room' notifications when user is already in/entering a room
      final notificationType = message.data['message-type']?.toString() ?? '';
      if (notificationType == notificationKeyEnterRoom &&
          di<RoomStateManager>().isInRoom) {
        Methods.printLog(
            "⛔ Skipping enter-room notification: user already in room");
        return;
      }

      // Suppress chat system notifications for the conversation already on
      // screen — mirrors the in-app banner suppression in
      // InAppChatNotifier.notifyIncoming so the FCM path is consistent.
      if (notificationType == notificationChatPayload) {
        final userMap = message.data['user'];
        final senderId = int.tryParse((userMap is Map
                    ? userMap['user_id']
                    : (message.data['user_id'] ?? message.data['toUserId']))
                ?.toString() ??
            '');
        if (senderId != null &&
            InAppChatNotifier.instance.activePeerUserId == senderId) {
          Methods.printLog('⛔ Skipping chat push: DM already on screen');
          return;
        }
      } else if (notificationType == notificationKeygroupChat) {
        final roomId = int.tryParse(
            (message.data['chat_room_id'] ?? message.data['room_id'])
                    ?.toString() ??
                '');
        if (roomId != null &&
            InAppChatNotifier.instance.activeGroupRoomId == roomId) {
          Methods.printLog('⛔ Skipping group push: group already on screen');
          return;
        }
      }

      final currentHash = _generateHash(title: title, body: body, data: data);
      if (_lastNotificationHash == currentHash) {
        Methods.printLog("⛔ Duplicate notification skipped");
        return;
      }

      _lastNotificationHash = currentHash;

      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      Methods.printLog(
          "✅ Showing notification: ID=$notificationId, Title=$title, Body=$body, data=$data");

      await localNotification.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(data),
      );
      // NOTE: do NOT navigate here. A foreground arrival must only surface the
      // (suppressible) banner — navigation happens exclusively on a user TAP
      // (onDidReceiveNotificationResponse / onMessageOpenedApp / launch). The
      // old unconditional openMessageHandler() yanked the user off-screen on
      // every foreground push (and, with the new chat cases, would re-push the
      // conversation on top of itself on each incoming message).
    } catch (error) {
      if (kDebugMode) {
        Methods.printLog('❌ Error showing notification: $error');
      }
    }
  }

  Future<void> initialize() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Methods.printLog('✅ User granted notification permission');
    } else {
      Methods.printLog('❌ User declined or has not accepted permission');
    }

    unawaited(NotificationService.getToken());

    await initLocalNotification();
    await initPushNotification();
  }

  /// Fetches the current FCM token and registers it on the backend so pushes
  /// can be targeted to this device. The token is also sent at auth time
  /// (`notification_id`), but it can rotate mid-session — this keeps the backend
  /// in sync without requiring a re-login.
  ///
  /// FCM HYBRID: getting the token uses the NATIVE Firebase Messaging config
  /// (google-services.json / GoogleService-Info.plist), which is independent of
  /// the runtime/panel-driven Dart config. The POST below carries it into our
  /// backend. No-op for unauthenticated sessions (the endpoint is user-scoped)
  /// and best-effort — never throws into the caller.
  static Future<void> getToken() async {
    try {
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      Methods.printLog("🔑 FCM Token: $fcmToken");
      if (fcmToken == null || fcmToken.isEmpty) return;
      if (!AuthService().isAuthenticated) return;
      if (!di.isRegistered<DioFactory>()) return;

      final String deviceId = await di<DioFactory>().ensureDeviceId();
      await di<DioFactory>().post(
        EndPoints.updateNotificationId,
        data: {
          'notification_id': fcmToken,
          'device_token': deviceId,
        },
      );
      Methods.printLog("✅ FCM token registered on backend");
    } catch (e) {
      Methods.printLog("❌ Error registering FCM token: $e");
    }
  }

  Future<void> showProgressNotification(int progress) async {
    await NotificationService().flutterLocalNotificationsPlugin.show(
          122,
          'Uploading Reel',
          'Uploading: $progress%',
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: 'Shows upload progress',
              importance: Importance.high,
              priority: Priority.high,
              onlyAlertOnce: true,
              showProgress: true,
              maxProgress: 100,
              progress: progress,
              ongoing: true,
            ),
          ),
        );
  }

  Future<void> cancelProgressNotification() async {
    await NotificationService().flutterLocalNotificationsPlugin.cancel(122);
  }

  Future<void> showReelReadyNotification(String reelId) async {
    await flutterLocalNotificationsPlugin.show(
      123,
      'Reels ready',
      'Your reel has been uploaded successfully. Tap to view.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Reel upload complete',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode({
        'message-type': 'reel-ready',
        'reel_id': reelId,
      }),
    );
  }

  Future<String> downloadAndSaveImage(String imageUrlmain) async {
    bool isFullUrl =
        imageUrlmain.contains('http') || imageUrlmain.contains('https');
    String imageUrl =
        isFullUrl ? imageUrlmain : EndPoints.getImage(imageUrlmain);
    //HttpClient httpClient = HttpClient();
    Uri uri = Uri.parse(imageUrl);
    //HttpClientRequest request = await httpClient.getUrl(uri);
    //HttpClientResponse response = await request.close();
    // List<int> bytes = await consolidateHttpClientResponseBytes(response);

    String tempDir = (await getTemporaryDirectory()).path;
    String filePath = '$tempDir/${uri.pathSegments.last}';

    // File file = File(filePath);

    return filePath;
  }
}

// Top-level shims kept for existing call sites; delegate to the single
// channel-aware implementation on NotificationService (no duplicated channel id).
Future<void> showProgressNotification(int progress) =>
    NotificationService().showProgressNotification(progress);

Future<void> cancelProgressNotification() =>
    NotificationService().cancelProgressNotification();

class RemoteNotificationModel {
  final String? type;
  final String? title;
  final String? body;
  final String? channelId;
  final String? userName;
  final String? toUserId;
  final String? bookingId;
  final String? giftId;
  final String? imageUrl;
  final String? messageId;
  final String? timestamp;
  final String? familyId;
  final String? name;
  final String? image;
  final String? userId;
  final bool? hasColorName;

  /// Server chat room id (chat_room_id) for a chat push, so a notification tap
  /// can deep-link straight into the conversation. Null when absent.
  final String? chatRoomId;

  RemoteNotificationModel({
    this.type,
    this.title,
    this.body,
    this.channelId,
    this.userName,
    this.toUserId,
    this.bookingId,
    this.giftId,
    this.imageUrl,
    this.messageId,
    this.timestamp,
    this.familyId,
    this.name,
    this.image,
    this.userId,
    this.hasColorName,
    this.chatRoomId,
  });

  factory RemoteNotificationModel.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : {
            'name': '',
            'image': '',
            'user_id': '',
            'has_color_name': false,
          };
    Methods.printLog('RemoteNotificationModel $json');
    return RemoteNotificationModel(
      // Control-flow fields keep their real absence (null) instead of being
      // coerced to '' — '' would defeat the null-type inference fallback in
      // openMessageHandler and parse to a bogus 0 id downstream.
      type: json['message-type']?.toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      channelId: (json['channelId'] ?? json['channel_id'])?.toString(),
      userName: (json['userName'] ?? json['user_name'])?.toString(),
      toUserId: (json['toUserId'] ?? json['to_user_id'])?.toString(),
      bookingId: json['bookingId'] ?? json['booking_id'] ?? '',
      giftId: json['giftId'] ?? json['gift_id'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      messageId: json['message_id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      familyId: json['family_id'] ?? '',
      name: userJson['name'] ?? '',
      image: userJson['image'] ?? '',
      userId: userJson['user_id']?.toString(),
      hasColorName: userJson['has_color_name'] ?? false,
      // Chat deep-link target — backend commonly sends one of these keys.
      chatRoomId:
          (json['chat_room_id'] ?? json['chatRoomId'] ?? json['room_id'])
              ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'channelId': channelId,
      'userName': userName,
      'toUserId': toUserId,
      'bookingId': bookingId,
      'giftId': giftId,
      'imageUrl': imageUrl,
      'message_id': messageId,
      'timestamp': timestamp,
      'chat_room_id': chatRoomId,
    };
  }
}

const String notificationChatPayload = 'chat-payload';
const String acceptJoinToFamily = 'accept-user-family';
const String notificationKeyBuyItemPayload = 'buyItem_payload';
const String notificationKeyChargeCoinPayload = 'chargeCoin-payload';
const String notificationKeyJoinFamily = 'joinFamily-payload';
const String notificationKeyLikeReel = 'like_reel';
const String notificationKeyEnterRoom = 'enter-room';
const String notificationKeyMallSend = 'mall-send';
const String notificationKeygroupChat = 'send-notifaction';
const String notificationKeyVisitProfile = 'visit-profile';
const String notificationKeyFollow = 'follow';
const String notificationKeyFollowBack = 'followBack';
const String notificationKeyFamily = 'family';
const String notificationKeySystemMsg = 'system-msg';
const String notificationKeyRequestJoinFamily = 'request-join-family';
const String notificationKeyVips = 'vips';
const String notificationKeyFamilyLevelUpgrade = 'family-level-upgrade';
const String notificationKeyWareVip = 'ware-vip';
const String notificationKeyAchieveTargetMonthly = 'achieve-target-monthly';
const String notificationKeyRealComment = 'real-comment';
const String notificationKeyAcceptAgencyApp = 'accept-agency-app';
const String notificationKeyAgencyJoinRequestApp = 'agency-join-request';
const String notificationKeyAgencyAddAdminApp = 'agency-add-admin';
const String notificationKeyAgencyRemoveAdminApp = 'agency-remove-admin';
const String notificationKeyChargeActionNotification =
    'charge-action-notifaction';
