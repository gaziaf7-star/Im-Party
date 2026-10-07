import 'package:general/src/core/utils/country_codes.dart';
import 'package:general/src/features/auth/auth.dart';

/// Builds the Explore/Trend country-filter list from the bundled
/// `country_codes.dart` asset instead of the (empty) backend
/// `/countries/categories` + `/countries/category/{id}` endpoints.
///
/// Each [CountryEntity] carries:
///  - `id`   : a deterministic int derived from the ISO2 code so the selection
///             contract (int countryId) is preserved end-to-end.
///  - `name` / `nameEn`: the asset country name (English is the only name the
///             offline asset ships).
///  - `iso`  : the ISO2 code, used to render an offline emoji flag.
///  - `phoneCode`: the e164 dial code.
class LocalCountries {
  LocalCountries._();

  static List<CountryEntity>? _cache;

  static List<CountryEntity> get all => _cache ??= _build();

  static List<CountryEntity> _build() {
    final list = countryCodes
        .where((e) => (e['iso2_cc'] as String?)?.isNotEmpty ?? false)
        .map((e) {
          final iso = (e['iso2_cc'] as String).toUpperCase();
          final name = (e['name'] as String?) ?? iso;
          return CountryEntity(
            id: _isoToId(iso),
            name: name,
            nameEn: name,
            iso: iso,
            phoneCode: (e['e164_cc'] as String?) ?? '',
            photo: '',
            supporters: const [],
          );
        })
        .toList();
    list.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    return list;
  }

  /// Stable numeric id from the two ISO2 letters (A=1..Z=26): l1*100 + l2.
  /// Deterministic and collision-free for distinct ISO2 codes.
  static int _isoToId(String iso) {
    final a = iso.codeUnitAt(0) - 64;
    final b = iso.codeUnitAt(1) - 64;
    return a * 100 + b;
  }

  /// ISO2 -> regional-indicator emoji flag (offline, no bundled images).
  static String flagEmoji(String? iso) {
    if (iso == null || iso.length != 2) return '';
    final upper = iso.toUpperCase();
    const base = 0x1F1E6; // regional indicator 'A'
    final first = base + (upper.codeUnitAt(0) - 65);
    final second = base + (upper.codeUnitAt(1) - 65);
    return String.fromCharCode(first) + String.fromCharCode(second);
  }
}
