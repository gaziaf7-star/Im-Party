import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:general/src/core/constants/end_points.dart';
import 'package:general/src/core/network/dio_factory.dart';

/// A device contact that is also a registered app user (WhatsApp-style discovery).
/// [name] prefers the name the user saved locally for this contact, falling back
/// to the user's app display name.
class DiscoveredContact {
  const DiscoveredContact({
    required this.userId,
    required this.name,
    required this.avatar,
  });

  final int userId;
  final String name;
  final String avatar;
}

/// A device contact that is NOT on the app yet, surfaced so the user can invite
/// them. [name] is the locally saved contact name; [phone] is kept only so the
/// share sheet can pre-address the invite where the channel supports it.
class UnregisteredContact {
  const UnregisteredContact({required this.name, required this.phone});

  final String name;
  final String phone;
}

/// Outcome of a single address-book sweep: contacts already on the app, and the
/// rest (invitable). Both lists keep only the locally saved name on the client;
/// the server only ever receives phone numbers it already holds for its users.
class ContactDiscoveryResult {
  const ContactDiscoveryResult({
    required this.registered,
    required this.unregistered,
  });

  final List<DiscoveredContact> registered;
  final List<UnregisteredContact> unregistered;

  bool get isEmpty => registered.isEmpty && unregistered.isEmpty;
}

/// Thrown when the user denies the contacts permission so the UI can show the
/// "grant permission" affordance instead of a generic error.
class ContactsPermissionDenied implements Exception {}

/// Reads the device address book, uploads the phone numbers to the match endpoint
/// and splits them into registered users and invitable (unregistered) contacts.
class ContactDiscoveryService {
  ContactDiscoveryService(this._dio);

  final DioFactory _dio;

  Future<ContactDiscoveryResult> discover() async {
    final granted = await FlutterContacts.requestPermission(readonly: true);
    if (!granted) throw ContactsPermissionDenied();

    final contacts = await FlutterContacts.getContacts(withProperties: true);

    // Map the last-10-digits key -> the locally saved contact name and a
    // representative phone number, and collect the raw numbers to send (the
    // server normalizes the same way).
    final nameByKey = <String, String>{};
    final phoneByKey = <String, String>{};
    final phones = <String>[];
    for (final c in contacts) {
      for (final phone in c.phones) {
        final digits = phone.number.replaceAll(RegExp(r'\D'), '');
        if (digits.length < 7) continue;
        final key =
            digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
        // First-wins: keep the name from whichever contact the address book
        // lists first for a given last-10-digit key (#92).
        nameByKey.putIfAbsent(key, () => c.displayName);
        phoneByKey.putIfAbsent(key, () => phone.number);
        phones.add(phone.number);
      }
    }
    if (phones.isEmpty) {
      return const ContactDiscoveryResult(registered: [], unregistered: []);
    }

    // The backend caps `phones` at 2000 per request (Common::upload validation).
    // Address books regularly cross that — chunk locally and merge the matches
    // so users with large contact lists don't get a flat 500.
    const int batchSize = 1500;
    final matchList = <Map>[];
    for (var i = 0; i < phones.length; i += batchSize) {
      final end = (i + batchSize < phones.length) ? i + batchSize : phones.length;
      final batch = phones.sublist(i, end);
      final response =
          await _dio.post(EndPoints.contactsMatch, data: {'phones': batch});
      final body = response.data;
      final list = (body is Map ? body['data'] : body);
      if (list is List) {
        for (final e in list) {
          if (e is Map) matchList.add(e);
        }
      }
    }

    final registered = <DiscoveredContact>[];
    final seenUsers = <int>{};
    final matchedKeys = <String>{};
    for (final e in matchList) {
      final key = e['phone_key']?.toString() ?? '';
      if (key.isNotEmpty) matchedKeys.add(key);
      final userId = int.tryParse('${e['id']}') ?? 0;
      if (userId <= 0 || !seenUsers.add(userId)) continue;
      registered.add(DiscoveredContact(
        userId: userId,
        name: nameByKey[key] ?? (e['name']?.toString() ?? ''),
        avatar: e['avatar']?.toString() ?? '',
      ));
    }

    // Every address-book entry whose key did not match a user is invitable.
    final unregistered = <UnregisteredContact>[];
    for (final entry in nameByKey.entries) {
      if (matchedKeys.contains(entry.key)) continue;
      final name = entry.value.trim();
      if (name.isEmpty) continue;
      unregistered.add(
        UnregisteredContact(name: name, phone: phoneByKey[entry.key] ?? ''),
      );
    }
    unregistered.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return ContactDiscoveryResult(
      registered: registered,
      unregistered: unregistered,
    );
  }
}
