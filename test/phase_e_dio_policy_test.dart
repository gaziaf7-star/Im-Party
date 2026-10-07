// Pure-Dart unit tests for the Phase E dio retry-safety + cache opt-in logic
// (Jo Live, package `general`).
//
// The real decision predicates live inside DioFactory and its interceptors
// (lib/src/core/network/dio_factory.dart) and BaseRoomRemoteDataSource
// (lib/src/features/room/data/data_source/base_room_remote_data_source.dart).
// None of them are directly callable in a pure-Dart test: they are private
// statics, are wired into DioCacheInterceptor / RetryInterceptor, and pull in
// heavy plugin imports (firebase, platform_device_id, ...).
//
// So — exactly like test/crash_fix_helpers_test.dart — we REPLICATE each PURE
// decision predicate here, byte-for-byte with the source, and lock its
// behaviour with tests. If the production logic drifts, these replicas must be
// updated in lockstep — which is the point: the tests document and pin the
// exact Phase E rules.
//
// Isolation-safe: no device / plugin / network / Dio instances are touched.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// (A) Retry method-guard.
// Replica of DioFactory._idempotentMethods + the guard in _retryEvaluator
// (dio_factory.dart lines 31, 37-40): retries are restricted to idempotent
// reads so a lost write response is never re-sent (no double gift-send /
// double coin charge). This is the financial-safety guard.
// ---------------------------------------------------------------------------
const Set<String> idempotentMethods = {'GET', 'HEAD', 'OPTIONS'};

bool isRetryableMethod(String method) =>
    idempotentMethods.contains(method.toUpperCase());

// ---------------------------------------------------------------------------
// (B) Cache opt-in gate.
// Replica of the gate in DioFactory._handleRequest (dio_factory.dart line 388):
// a per-request CacheOptions is attached ONLY for GET requests that explicitly
// carry a cacheDuration. Everything else falls to the global noCache default.
// ---------------------------------------------------------------------------
bool shouldCache(String method, Duration? cacheDuration) =>
    method.toUpperCase() == 'GET' && cacheDuration != null;

// ---------------------------------------------------------------------------
// (C) Gift cache gating.
// Replica of fetchGifts (base_room_remote_data_source.dart line 246): only the
// static gift catalog (positive category type) is cached for 30m; the per-user
// bag/backpack types (-1 and 11) have MUTABLE quantity and must never be cached
// (null cacheDuration -> global noCache default).
// ---------------------------------------------------------------------------
Duration? giftCacheDuration(int type) =>
    (type > 0 && type != 11) ? const Duration(minutes: 30) : null;

// ---------------------------------------------------------------------------
// (D) forceRefresh policy mapping.
// Replica of the CachePolicy selection in _handleRequest (dio_factory.dart
// lines 391-393): forceRefresh bypasses any cached value and refreshes the
// entry; otherwise the response is force-cached.
// ---------------------------------------------------------------------------
String pick(bool forceRefresh) =>
    forceRefresh ? 'refreshForceCache' : 'forceCache';

void main() {
  group('(A) retry method-guard (financial-safety: no double gift-send)', () {
    test('GET is retryable', () {
      expect(isRetryableMethod('GET'), isTrue);
    });

    test('HEAD is retryable', () {
      expect(isRetryableMethod('HEAD'), isTrue);
    });

    test('OPTIONS is retryable', () {
      expect(isRetryableMethod('OPTIONS'), isTrue);
    });

    test('lowercase get -> retryable (uppercased before lookup)', () {
      expect(isRetryableMethod('get'), isTrue);
    });

    test('lowercase head -> retryable', () {
      expect(isRetryableMethod('head'), isTrue);
    });

    test('lowercase options -> retryable', () {
      expect(isRetryableMethod('options'), isTrue);
    });

    test('mixed-case Get/Head/Options -> retryable', () {
      expect(isRetryableMethod('Get'), isTrue);
      expect(isRetryableMethod('Head'), isTrue);
      expect(isRetryableMethod('OpTiOnS'), isTrue);
    });

    test('POST is NEVER retried (write -> double-apply risk)', () {
      expect(isRetryableMethod('POST'), isFalse);
    });

    test('PUT is NEVER retried', () {
      expect(isRetryableMethod('PUT'), isFalse);
    });

    test('PATCH is NEVER retried', () {
      expect(isRetryableMethod('PATCH'), isFalse);
    });

    test('DELETE is NEVER retried', () {
      expect(isRetryableMethod('DELETE'), isFalse);
    });

    test('lowercase writes are NEVER retried (post/put/patch/delete)', () {
      expect(isRetryableMethod('post'), isFalse);
      expect(isRetryableMethod('put'), isFalse);
      expect(isRetryableMethod('patch'), isFalse);
      expect(isRetryableMethod('delete'), isFalse);
    });

    test('unknown / nonsense method -> not retryable', () {
      expect(isRetryableMethod('TRACE'), isFalse);
      expect(isRetryableMethod('CONNECT'), isFalse);
      expect(isRetryableMethod(''), isFalse);
    });

    test('idempotent set is exactly {GET, HEAD, OPTIONS}', () {
      expect(idempotentMethods, {'GET', 'HEAD', 'OPTIONS'});
    });

    test('every write verb is excluded from the idempotent set', () {
      for (final write in ['POST', 'PUT', 'PATCH', 'DELETE']) {
        expect(idempotentMethods.contains(write), isFalse,
            reason: '$write must not be idempotent/retryable');
      }
    });
  });

  group('(B) cache opt-in gate (GET + cacheDuration only)', () {
    test('GET + duration -> cache', () {
      expect(shouldCache('GET', const Duration(minutes: 30)), isTrue);
    });

    test('lowercase get + duration -> cache (uppercased before compare)', () {
      expect(shouldCache('get', const Duration(minutes: 30)), isTrue);
    });

    test('GET + null duration -> no cache (opt-in only)', () {
      expect(shouldCache('GET', null), isFalse);
    });

    test('POST + duration -> no cache (writes never cached)', () {
      expect(shouldCache('POST', const Duration(minutes: 30)), isFalse);
    });

    test('HEAD + duration -> no cache (only GET opts in)', () {
      expect(shouldCache('HEAD', const Duration(minutes: 30)), isFalse);
    });

    test('OPTIONS + duration -> no cache', () {
      expect(shouldCache('OPTIONS', const Duration(minutes: 30)), isFalse);
    });

    test('zero duration is still non-null -> cache (gate checks != null only)',
        () {
      expect(shouldCache('GET', Duration.zero), isTrue);
    });
  });

  group('(C) gift cache gating (catalog cached, bag uncached)', () {
    test('type 1 (catalog) -> 30m', () {
      expect(giftCacheDuration(1), const Duration(minutes: 30));
    });

    test('type 5 (catalog) -> 30m', () {
      expect(giftCacheDuration(5), const Duration(minutes: 30));
    });

    test('type 100 (catalog) -> 30m', () {
      expect(giftCacheDuration(100), const Duration(minutes: 30));
    });

    test('type -1 (bag, mutable) -> null (never cached)', () {
      expect(giftCacheDuration(-1), isNull);
    });

    // type 11 is the per-user backpack/bag (mutable quantity) — it must never be
    // cached. The predicate excludes it explicitly (type > 0 && type != 11).
    test('type 11 (bag, mutable) -> null (never cached)', () {
      expect(giftCacheDuration(11), isNull);
    });

    test('type 0 (not > 0) -> null', () {
      expect(giftCacheDuration(0), isNull);
    });

    test('catalog duration is exactly 30 minutes, not 29 or 31', () {
      final d = giftCacheDuration(2);
      expect(d, isNotNull);
      expect(d!.inMinutes, 30);
    });
  });

  group('(D) forceRefresh policy mapping', () {
    test('forceRefresh true -> refreshForceCache', () {
      expect(pick(true), 'refreshForceCache');
    });

    test('forceRefresh false -> forceCache', () {
      expect(pick(false), 'forceCache');
    });
  });
}
