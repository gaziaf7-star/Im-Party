import 'dart:convert';

import 'package:general/src/core/utils/cache/hive_manager.dart';
import 'package:general/src/core/utils/cache/keys_manager.dart';
import 'package:general/src/features/chats/data/contact_discovery_service.dart';

/// Hive-backed cache for the device contacts discovery flow.
///
/// **Why:** owners can have 2000+ device contacts. Re-running the full
/// "read address book + POST /contacts/match (chunked) + parse" sweep every
/// time the picker opens is the difference between a 5-second loading screen
/// and instantaneous WhatsApp-style results.
///
/// **Strategy (mirrors WhatsApp):**
///   - First open ever: no cache → run the full discovery, save the result
///     along with a timestamp.
///   - Subsequent opens: emit the cached result *immediately* (no loading
///     spinner), then — if the cache is older than [_freshness] — refresh
///     silently in the background and emit the updated result when ready.
///   - Pull-to-refresh: always forces a fresh discovery, regardless of age.
///
/// The cache only holds what the screen needs: the registered list (matched
/// app users with name/avatar) and the unregistered list (name/phone for
/// the invite tiles). No raw address book is persisted.
class ContactsCache {
  ContactsCache(this._discovery);

  final ContactDiscoveryService _discovery;

  /// 12 hours — long enough that an active user effectively never waits, short
  /// enough that newly-joined friends surface within a day.
  static const Duration _freshness = Duration(hours: 12);

  static const String _kCache = 'contacts_discovery_cache_v1';
  static const String _kTime = 'contacts_discovery_cache_ts_v1';

  ContactDiscoveryResult? readCached() {
    final raw = HiveManager().getData<String>(KeysManager.USER_BOX, _kCache);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      final registered = (json['registered'] as List? ?? [])
          .map((e) => DiscoveredContact(
                userId: e['userId'] as int,
                name: e['name'] as String,
                avatar: e['avatar'] as String,
              ))
          .toList();
      final unregistered = (json['unregistered'] as List? ?? [])
          .map((e) => UnregisteredContact(
                name: e['name'] as String,
                phone: e['phone'] as String,
              ))
          .toList();
      return ContactDiscoveryResult(
        registered: registered,
        unregistered: unregistered,
      );
    } catch (_) {
      // Corrupt cache: drop it silently and force a fresh discovery.
      return null;
    }
  }

  bool isStale() {
    final ts = HiveManager().getData<int>(KeysManager.USER_BOX, _kTime);
    if (ts == null) return true;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    return age > _freshness.inMilliseconds;
  }

  Future<ContactDiscoveryResult> refresh() async {
    final result = await _discovery.discover();
    await _save(result);
    return result;
  }

  Future<void> _save(ContactDiscoveryResult result) async {
    final json = jsonEncode({
      'registered': result.registered
          .map((c) => {
                'userId': c.userId,
                'name': c.name,
                'avatar': c.avatar,
              })
          .toList(),
      'unregistered': result.unregistered
          .map((c) => {'name': c.name, 'phone': c.phone})
          .toList(),
    });
    await HiveManager().saveData(KeysManager.USER_BOX, _kCache, json);
    await HiveManager().saveData(
      KeysManager.USER_BOX,
      _kTime,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
