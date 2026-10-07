import 'package:general/src/core/constants/end_points.dart';

/// Runtime realtime-transport config, populated from the server's
/// `/config/settings` response (`use_realtime_banners` + `centrifugo_ws`).
///
/// Centrifugo is the SOLE chat transport (legacy realtime has been fully removed from the
/// client), so the chat socket + drift/offline path are always on. Only the
/// outside-room banner transport remains independently server-gated.
class RealtimeConfig {
  /// Whether this client should receive the OUTSIDE-room banners/counters
  /// (gift/lucky-box/super-boom/close-zego + unread + game-status) via Centrifugo.
  /// Set from the server's `use_realtime_banners` on each settings fetch. Gated
  /// independently so the banner routing can be toggled/rolled back from the
  /// admin without an app rebuild. Rides the always-open chat socket.
  static bool useRealtimeBanners = false;

  /// WebSocket endpoint for the centrifuge-dart client — set from admin panel via /config/settings.
  static String wsUrl = '';

  /// UTD Stream room credentials, server-overridable from the admin panel
  /// (set from `/config/settings` on each fetch). Null/empty means the server
  /// block hasn't arrived yet — the room widgets fall back to
  /// [defaultUtdStreamAppId] / [defaultUtdStreamAppSecret] so an empty/late
  /// config can NEVER blank the credentials and break room entry (the bug that
  /// broke release 1.0.21).
  static String? utdStreamAppId;
  static String? utdStreamAppKey;

  /// Host serving the room engine — `POST /api/v1/token` and every in-room
  /// seat / speaker / ban / role call.
  ///
  /// Empty means "use the kit's built-in default", which is the vendor's hosted
  /// service. Set it (admin panel → `/config/settings` → `rtc_engine_url`) to
  /// point the app at a self-hosted engine instead. Server-driven on purpose:
  /// moving between the vendor and our own engine must not need a rebuild.
  static String rtcEngineUrl = '';

  /// UTD Stream credentials come ONLY from the backend (admin panel -> DB ->
  /// `/config/settings` -> applyFromSettings). NO credential is hardcoded in the
  /// source — a clone never ships another app's app_id/secret. The build-time
  /// dart-define is an optional TEST-build injection (e.g. Meow Live) for the
  /// pre-settings window; its default is EMPTY, so without DB/define the app has
  /// no credentials and will not connect to a room until the admin sets them.
  ///   flutter build ... \
  ///     --dart-define=UTD_STREAM_APP_ID=<test-app-id> \
  ///     --dart-define=UTD_STREAM_APP_SECRET=<test-app-secret>
  static const String defaultUtdStreamAppId =
      String.fromEnvironment('UTD_STREAM_APP_ID', defaultValue: '');
  static const String defaultUtdStreamAppKey = String.fromEnvironment(
    'UTD_STREAM_APP_KEY',
    defaultValue:
        String.fromEnvironment('UTD_STREAM_APP_SECRET', defaultValue: ''),
  );

  /// Support WhatsApp contact (full international number / wa.me target), set from
  /// the server's `support_whatsapp` on each settings fetch. Empty until the
  /// admin sets it — the UI HIDES the contact button when empty rather than show
  /// a foreign number. No client number is ever hardcoded.
  static String supportWhatsapp = '';

  /// In-app About Us content (bilingual), set from the server's `about_us_ar` /
  /// `about_us_en` on each settings fetch. Empty until the admin fills it from
  /// the panel — the About Us screen renders nothing/brand-neutral rather than a
  /// hardcoded client name. No client/brand text is ever shipped in the source.
  static String aboutUsAr = '';
  static String aboutUsEn = '';

  /// In-app Privacy Policy content (bilingual), set from the server's
  /// `privacy_policy_ar` / `privacy_policy_en` on each settings fetch. This is
  /// the SINGLE source the Privacy screen reads — admin-managed from the panel.
  static String privacyPolicyAr = '';
  static String privacyPolicyEn = '';

  /// Apply the realtime block from the `/config/settings` response.
  static void applyFromSettings(Map<String, dynamic> json) {
    useRealtimeBanners = json['use_realtime_banners'] == true;
    final ws = json['centrifugo_ws'];
    if (ws is String && ws.isNotEmpty) {
      wsUrl = ws;
    }
    final appId = json['utd_stream_app_id'];
    if (appId is String && appId.isNotEmpty) {
      utdStreamAppId = appId;
    }
    final appKey = json['utd_stream_app_key'] ?? json['utd_stream_app_secret'];
    if (appKey is String && appKey.isNotEmpty) {
      utdStreamAppKey = appKey;
    }
    final engineUrl = json['rtc_engine_url'];
    if (engineUrl is String && engineUrl.isNotEmpty) {
      rtcEngineUrl = engineUrl;
    }
    // Per-app object-storage base + privacy-policy override (white-label, set
    // from the admin panel). Empty values are ignored by the EndPoints setters
    // so a late/blank config can never wipe the bootstrap values.
    final storageUrl = json['storage_url'];
    if (storageUrl is String) {
      EndPoints.setStorageBaseUrl(storageUrl);
    }
    final privacyUrl = json['privacy_policy_url'];
    if (privacyUrl is String) {
      EndPoints.setPrivacyPolicyUrl(privacyUrl);
    }
    final supportWa = json['support_whatsapp'];
    if (supportWa is String && supportWa.isNotEmpty) {
      supportWhatsapp = supportWa;
    }
    // In-app About Us + Privacy content (bilingual). Empty values are ignored so
    // a late/blank config never wipes already-applied content; the screens read
    // these admin-managed values directly with no hardcoded brand text.
    final aboutAr = json['about_us_ar'];
    if (aboutAr is String && aboutAr.isNotEmpty) {
      aboutUsAr = aboutAr;
    }
    final aboutEn = json['about_us_en'];
    if (aboutEn is String && aboutEn.isNotEmpty) {
      aboutUsEn = aboutEn;
    }
    final privacyAr = json['privacy_policy_ar'];
    if (privacyAr is String && privacyAr.isNotEmpty) {
      privacyPolicyAr = privacyAr;
    }
    final privacyEn = json['privacy_policy_en'];
    if (privacyEn is String && privacyEn.isNotEmpty) {
      privacyPolicyEn = privacyEn;
    }
  }
}

/// LIVE accessor for the outside-room banner/counter transport switch. Reads the
/// runtime value so flipping the server flag re-routes banners with no rebuild.
bool get kUseRealtimeBanners => RealtimeConfig.useRealtimeBanners;
