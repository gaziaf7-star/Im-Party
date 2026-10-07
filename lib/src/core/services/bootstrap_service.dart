import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/data/model/setting_model.dart';
import 'package:general/src/features/auth/data/model/my_store_model.dart';

/// Parsed payload of the single `/bootstrap` cold-start aggregate.
///
/// Mirrors the three models the legacy startup populated via three separate
/// calls (`/my-data`, `/my-store`, `/user-app-setting`), so a caller can adopt
/// these into the SAME blocs/state with no model changes.
class BootstrapResult {
  const BootstrapResult({
    required this.myData,
    required this.myStore,
    required this.appSetting,
  });

  final MyDataModel? myData;
  final MyStoreModel? myStore;
  final SettingModel? appSetting;
}

/// Fetches `/bootstrap` once on app start and parses it into the existing
/// [MyDataModel] / [MyStoreModel] / [SettingModel].
///
/// This replaces three cold-start round-trips with one. It is ADDITIVE: parsing
/// [BootstrapResult.myData] through [MyDataModel.fromJson] reuses that factory's
/// existing side-effect of setting the [MyDataModel] singleton, so any code
/// reading `MyDataModel.getInstance()` is populated for free. Distributing
/// my_store / app_setting into their blocs is left to the caller (see the wiring
/// note in the task report) so the existing bloc state flow is not disturbed.
///
/// Backend contract (GET /bootstrap → one apiResponse):
/// ```
/// data: {
///   my_data:     <same shape as /my-data 'data'>,
///   my_store:    <same shape as /my-store 'data'>,   // may nest { my_store: {...} }
///   app_setting: <same shape as /user-app-setting 'data'>,
/// }
/// ```
class BootstrapService {
  BootstrapService(this._dioFactory);

  final DioFactory _dioFactory;

  /// Network-first fetch of the aggregate.
  ///
  /// `forceRefresh: true` maps (in [DioFactory._handleRequest]) to
  /// [CachePolicy.refreshForceCache]: the request ALWAYS hits the network and
  /// stores the fresh response unconditionally. The persistent HTTP cache
  /// ([FileCacheStore]) is therefore consulted ONLY as a last-resort offline
  /// fallback — `hitCacheOnNetworkFailure: true` serves the last stored
  /// bootstrap snapshot exclusively when the network actually fails. This is
  /// critical: `/bootstrap` carries financial state (wallet / coins / diamonds
  /// via my_store), which must be fresh whenever the device is online; a stale
  /// cached balance is never served while connectivity is available.
  ///
  /// When online: fresh from network (and the cache is refreshed).
  /// When offline: the last successful bootstrap snapshot, bounded to 12h by
  /// maxStale, instead of an empty screen.
  ///
  /// Returns null on a hard failure (no network AND no cached entry); callers
  /// should then fall back to the legacy per-feature fetches. Never throws.
  Future<BootstrapResult?> fetch() async {
    try {
      final response = await _dioFactory.get(
        EndPoints.bootstrap,
        // Always go to the network (refreshForceCache); store the response so a
        // later OFFLINE cold start can still serve it. maxStale bounds that
        // offline fallback's lifetime to 12h.
        forceRefresh: true,
        cacheDuration: const Duration(hours: 12),
        // Financial safety (FIX B): /bootstrap carries the wallet/coins/diamonds
        // balance. A server 5xx must NOT be papered over with a stale cached
        // balance; only a genuine offline failure (hitCacheOnNetworkFailure)
        // may serve the last snapshot. So opt OUT of hit-cache-on-5xx here.
        serveCacheOn5xx: false,
      );

      final body = response.data;
      if (body is! Map) return null;
      final data = body['data'];
      if (data is! Map) return null;

      return BootstrapResult(
        myData: _parseMyData(data['my_data']),
        myStore: _parseMyStore(data['my_store']),
        appSetting: _parseAppSetting(data['app_setting']),
      );
    } catch (e) {
      Methods.printLog('[BootstrapService] fetch failed: $e');
      return null;
    }
  }

  MyDataModel? _parseMyData(dynamic raw) {
    if (raw is! Map) return null;
    // MyDataModel.fromJson sets the singleton as a side-effect (same behaviour
    // the /my-data path relied on), so the global instance is populated here.
    return MyDataModel.fromJson(Map<String, dynamic>.from(raw));
  }

  MyStoreModel? _parseMyStore(dynamic raw) {
    if (raw is! Map) return null;
    // /my-store returns its store under a nested `my_store` key
    // (ProfileRemotelyDataSource.myStore parses data['my_store']); accept both
    // the nested shape and a flat store object for forward-compatibility.
    final inner = raw['my_store'];
    final storeMap = inner is Map ? inner : raw;
    return MyStoreModel.fromJson(Map<String, dynamic>.from(storeMap));
  }

  SettingModel? _parseAppSetting(dynamic raw) {
    if (raw is! Map) return null;
    return SettingModel.fromJson(Map<String, dynamic>.from(raw));
  }
}
