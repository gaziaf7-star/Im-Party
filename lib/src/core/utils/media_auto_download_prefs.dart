import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:general/src/core/utils/cache/hive_manager.dart';
import 'package:general/src/core/utils/cache/keys_manager.dart';

/// When [shouldAutoDownload] should fire — independent of who calls it. The
/// chat media widgets consult this before kicking off an image/video fetch so
/// the owner's WhatsApp-style preference is honored everywhere consistently.
enum MediaNetworkPolicy { always, wifiOnly, mobileOnly }

/// Persistent preferences for auto-download of chat media. Backs the
/// [MediaSettingsScreen] UI and is read by every media-loading widget before
/// triggering a network fetch.
///
/// Defaults: auto-download ON, network policy = ALWAYS (matches today's
/// behavior, so existing users notice nothing until they flip the switch).
class MediaAutoDownloadPrefs {
  MediaAutoDownloadPrefs._();

  static const String _kAuto = 'media_auto_download_enabled';
  static const String _kPolicy = 'media_auto_download_policy';

  static bool isAutoDownloadEnabled() {
    return HiveManager()
            .getData<bool>(KeysManager.USER_BOX, _kAuto) ??
        true;
  }

  static Future<void> setAutoDownloadEnabled(bool value) {
    return HiveManager().saveData(KeysManager.USER_BOX, _kAuto, value);
  }

  static MediaNetworkPolicy networkPolicy() {
    final raw =
        HiveManager().getData<String>(KeysManager.USER_BOX, _kPolicy) ?? 'always';
    switch (raw) {
      case 'wifi':
        return MediaNetworkPolicy.wifiOnly;
      case 'mobile':
        return MediaNetworkPolicy.mobileOnly;
      default:
        return MediaNetworkPolicy.always;
    }
  }

  static Future<void> setNetworkPolicy(MediaNetworkPolicy policy) {
    final raw = switch (policy) {
      MediaNetworkPolicy.wifiOnly => 'wifi',
      MediaNetworkPolicy.mobileOnly => 'mobile',
      MediaNetworkPolicy.always => 'always',
    };
    return HiveManager().saveData(KeysManager.USER_BOX, _kPolicy, raw);
  }

  /// Single decision point all media widgets call before fetching: should we
  /// fire a network download right now given the user's prefs + the live
  /// connectivity state?
  static Future<bool> shouldAutoDownload() async {
    if (!isAutoDownloadEnabled()) return false;
    final policy = networkPolicy();
    if (policy == MediaNetworkPolicy.always) return true;

    // Match the current connectivity against the user's policy. Multiple
    // results (e.g. wifi + vpn) are common — wifi presence is enough.
    final results = await Connectivity().checkConnectivity();
    final onWifi = results.contains(ConnectivityResult.wifi);
    final onMobile = results.contains(ConnectivityResult.mobile);
    if (policy == MediaNetworkPolicy.wifiOnly) return onWifi;
    if (policy == MediaNetworkPolicy.mobileOnly) return onMobile;
    return true;
  }
}
