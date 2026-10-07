import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ Configure Firebase
    FirebaseApp.configure()

    // ✅ Notifications setup for iOS 10+
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    application.registerForRemoteNotifications()

    // ✅ Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // ✅ Setup Room Service Channel (for app-kill cleanup)
    setupRoomServiceChannel()

    // ⭐⭐⭐ IMPORTANT ⭐⭐⭐
    DispatchQueue.global(qos: .background).async {
        print("🔧 Background thread initialized for WebSocket services.")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ===============================
  // 🎧 Room Service Channel
  // ===============================
  private func setupRoomServiceChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let channel = FlutterMethodChannel(
      name: "room_service_channel",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "startRoomService":
        if let args = call.arguments as? [String: Any],
           let roomId = args["room_id"] as? String,
           let token = args["token"] as? String {
          let lang = args["language_code"] as? String ?? "en"
          let roomType = args["room_type"] as? String ?? "audio"
          let apiBaseUrl = args["api_base_url"] as? String ?? ""

          let defaults = UserDefaults.standard
          defaults.set(roomId, forKey: "room_id")
          defaults.set(token, forKey: "room_token")
          defaults.set(lang, forKey: "room_language_code")
          defaults.set(roomType, forKey: "room_type")
          defaults.set(apiBaseUrl, forKey: "api_base_url")

          print("🎧 [RoomService] Started for room=\(roomId), type=\(roomType)")
          result("Service Started")
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing args", details: nil))
        }

      case "stopRoomService":
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "room_id")
        defaults.removeObject(forKey: "room_token")
        defaults.removeObject(forKey: "room_language_code")
        defaults.removeObject(forKey: "room_type")
        defaults.removeObject(forKey: "api_base_url")
        print("🛑 [RoomService] Stopped")
        result("Stopped")

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // ===============================
  // 💀 App Termination Cleanup
  // ===============================
  override func applicationWillTerminate(_ application: UIApplication) {
    let defaults = UserDefaults.standard
    guard let roomId = defaults.string(forKey: "room_id"),
          let token = defaults.string(forKey: "room_token") else {
      return
    }
    let lang = defaults.string(forKey: "room_language_code") ?? "en"
    // No hardcoded host: the URL is built from the runtime base persisted by
    // Dart. Without it there is nothing to call (white-label).
    guard let apiBaseUrl = defaults.string(forKey: "api_base_url"),
          !apiBaseUrl.isEmpty else {
      return
    }

    print("🟥 [RoomService] App killed — executing cleanup for room=\(roomId)")

    // 🌐 Send quit_room API (synchronous, we have ~5s)
    sendExitRoomRequest(apiBaseUrl: apiBaseUrl, roomId: roomId, token: token, languageCode: lang)

    // 🧹 Clear stored data
    defaults.removeObject(forKey: "room_id")
    defaults.removeObject(forKey: "room_token")
    defaults.removeObject(forKey: "room_language_code")
    defaults.removeObject(forKey: "room_type")
    defaults.removeObject(forKey: "api_base_url")

    print("✅ [RoomService] Cleanup completed")
  }

  // ===============================
  // 🌐 API Cleanup
  // ===============================
  private func sendExitRoomRequest(apiBaseUrl: String, roomId: String, token: String, languageCode: String) {
    let base = apiBaseUrl.hasSuffix("/") ? String(apiBaseUrl.dropLast()) : apiBaseUrl
    guard let url = URL(string: "\(base)/rooms/quit_room") else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 5
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue(languageCode, forHTTPHeaderField: "X-localization")
    request.httpBody = "{\"room_id\":\"\(roomId)\"}".data(using: .utf8)

    let semaphore = DispatchSemaphore(value: 0)
    let task = URLSession.shared.dataTask(with: request) { _, response, error in
      if let httpResponse = response as? HTTPURLResponse {
        print("🌐 [RoomService] API response: \(httpResponse.statusCode)")
      }
      if let error = error {
        print("❌ [RoomService] API error: \(error.localizedDescription)")
      }
      semaphore.signal()
    }
    task.resume()
    _ = semaphore.wait(timeout: .now() + 4)
  }

  // ✅ Register FCM token with Firebase
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    print("📲 Device Token: \(deviceToken)")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

}
