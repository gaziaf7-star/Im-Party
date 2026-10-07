// Pure-Dart unit tests for today's crash-fix helpers (Jo Live, package `general`).
//
// The three helpers shipped today are not directly callable in a pure-Dart test:
//   * _isPackageError              -> private, lives in lib/main.dart (heavy plugin imports)
//   * buildNumber/version guard    -> wraps PackageInfo.fromPlatform() (method channel)
//   * identifyUserForCrashlytics() -> wraps MyDataModel singleton + FirebaseCrashlytics
//
// So we replicate each helper's PURE predicate here, byte-for-byte with the source,
// and lock its behaviour with tests. If the production logic drifts, these
// replicas must be updated in lockstep — which is the point: the tests document
// and pin the exact crash-fix rules.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Replica of lib/main.dart _noisyPackageSignatures + _isPackageError (lines 217-230)
// ---------------------------------------------------------------------------
const List<String> noisyPackageSignatures = <String>[
  'package:flutter_vap2/',
  'Reply already submitted',
  'DartMessenger',
];

bool isPackageError(StackTrace? stack) {
  if (stack == null) return false;
  final frames = stack.toString();
  for (final signature in noisyPackageSignatures) {
    if (frames.contains(signature)) return true;
  }
  return false;
}

// A StackTrace whose toString() is fully controllable, so we can assert the
// allowlist matching against the same surface (stack.toString()) the source uses.
class _FakeStackTrace implements StackTrace {
  _FakeStackTrace(this._text);
  final String _text;
  @override
  String toString() => _text;
}

// ---------------------------------------------------------------------------
// Replica of lib/main.dart version/buildNumber guard (lines 54-58)
// Returns the value appVersionCode WOULD be set to, or null when the guard
// rejects the input (so it must be left unchanged).
// ---------------------------------------------------------------------------
int? guardedVersionCode(String buildNumber) {
  final code = int.tryParse(buildNumber);
  if (code != null && code > 0) return code;
  return null;
}

bool shouldUpdateVersionName(String version) => version.isNotEmpty;

// ---------------------------------------------------------------------------
// Replica of Methods.identifyUserForCrashlytics guard conditions
// (lib/src/core/utils/methods.dart lines 1769, 1772)
// ---------------------------------------------------------------------------
bool shouldIdentifyUser(int? id) => !(id == null || id == 0);
bool shouldSetSpecialId(int? special) => special != null && special != 0;

void main() {
  group('_isPackageError allowlist (main.dart crash-noise filter)', () {
    test('null stack -> false (real crash, must be reported)', () {
      expect(isPackageError(null), isFalse);
    });

    test('empty stack -> false', () {
      expect(isPackageError(_FakeStackTrace('')), isFalse);
    });

    test('matches flutter_vap2 bounce signature', () {
      expect(
        isPackageError(_FakeStackTrace(
            '#0 _someFrame (package:flutter_vap2/src/vap.dart:42:5)')),
        isTrue,
      );
    });

    test('matches "Reply already submitted" signature', () {
      expect(
        isPackageError(
            _FakeStackTrace('PlatformException: Reply already submitted')),
        isTrue,
      );
    });

    test('matches DartMessenger signature', () {
      expect(
        isPackageError(_FakeStackTrace(
            '#3 DartMessenger.handlePlatformMessage (DartMessenger.java:1)')),
        isTrue,
      );
    });

    test('real zego/dio/hive crash -> false (must NOT be swallowed)', () {
      expect(
        isPackageError(_FakeStackTrace(
            '#0 ZegoExpressEngine.startPublishing (package:zego_express_engine/zego.dart:10:3)\n'
            '#1 DioMixin.fetch (package:dio/src/dio_mixin.dart:200:7)')),
        isFalse,
      );
    });

    test('matching is case-sensitive (contains), e.g. lowercase variant -> false', () {
      // The source uses String.contains with the exact-cased signatures.
      expect(
        isPackageError(_FakeStackTrace('reply already submitted')),
        isFalse,
      );
    });

    test('allowlist is exactly the three known noisy signatures', () {
      expect(noisyPackageSignatures, <String>[
        'package:flutter_vap2/',
        'Reply already submitted',
        'DartMessenger',
      ]);
    });
  });

  group('buildNumber/version guard (main.dart appVersion sync)', () {
    test('valid positive numeric buildNumber -> parsed int', () {
      expect(guardedVersionCode('19'), 19);
    });

    test('large valid buildNumber parses', () {
      expect(guardedVersionCode('12345'), 12345);
    });

    test('non-numeric buildNumber -> null (leave appVersionCode unchanged)', () {
      expect(guardedVersionCode('abc'), isNull);
    });

    test('empty buildNumber -> null', () {
      expect(guardedVersionCode(''), isNull);
    });

    test('zero buildNumber rejected (> 0 guard) -> null', () {
      expect(guardedVersionCode('0'), isNull);
    });

    test('negative buildNumber rejected (> 0 guard) -> null', () {
      expect(guardedVersionCode('-5'), isNull);
    });

    test('decimal buildNumber not an int -> null', () {
      expect(guardedVersionCode('1.5'), isNull);
    });

    test('non-empty version is applied', () {
      expect(shouldUpdateVersionName('1.0.17'), isTrue);
    });

    test('empty version is skipped (guard)', () {
      expect(shouldUpdateVersionName(''), isFalse);
    });
  });

  group('identifyUserForCrashlytics guard conditions', () {
    test('null id -> skip identification', () {
      expect(shouldIdentifyUser(null), isFalse);
    });

    test('id == 0 -> skip identification', () {
      expect(shouldIdentifyUser(0), isFalse);
    });

    test('valid positive id -> identify', () {
      expect(shouldIdentifyUser(42), isTrue);
    });

    test('negative id is still a non-null non-zero id -> identify', () {
      // Source guard only rejects null and 0; any other value identifies.
      expect(shouldIdentifyUser(-1), isTrue);
    });

    test('null specialId -> do not set custom key', () {
      expect(shouldSetSpecialId(null), isFalse);
    });

    test('specialId == 0 -> do not set custom key', () {
      expect(shouldSetSpecialId(0), isFalse);
    });

    test('valid specialId -> set custom key', () {
      expect(shouldSetSpecialId(7777), isTrue);
    });
  });
}
