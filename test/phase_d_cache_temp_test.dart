// Pure-Dart unit tests for the Phase D streaming-cache fix (Jo Live, package `general`).
//
// The fix lives identically in five cache managers:
//   lib/src/core/cache/{svga,image,svg,vap,video}_cache_manager.dart
// and rests on two PURE rules that are not directly callable from a pure-Dart
// test because they sit behind file I/O + a private static counter (`_tmpSeq`):
//
//   (A) unique-temp generator (svga_cache_manager.dart:100-101):
//         '${file.path}.${DateTime.now().microsecondsSinceEpoch}_${_tmpSeq++}.tmp'
//       — a per-download temp, co-located with the final file, made collision-proof
//         by the monotonic `_tmpSeq` even when two downloads of the same url start
//         within the same microsecond.
//
//   (B) sweep predicate (svga_cache_manager.dart:134,137):
//         entity.path.endsWith('.tmp') && now.difference(stat.modified) > _tmpMaxAge
//       with _tmpMaxAge = Duration(minutes: 5)  (svga_cache_manager.dart:16)
//       — note the STRICT '>' : age == 5 minutes is NOT swept.
//
// Following the convention in test/crash_fix_helpers_test.dart, we replicate each
// PURE rule here byte-for-byte with the source and lock its behaviour. No real
// file I/O, no plugins, no device — fully isolation-safe. If the production logic
// drifts, these replicas must be updated in lockstep; that is the point.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// (A) Replica of the unique-temp generator.
// Source: '${file.path}.${DateTime.now().microsecondsSinceEpoch}_${_tmpSeq++}.tmp'
// `micros` stands in for DateTime.now().microsecondsSinceEpoch and `seq` for
// the post-increment value of the static `_tmpSeq`.
// ---------------------------------------------------------------------------
String makeTemp(String finalPath, int micros, int seq) =>
    '$finalPath.${micros}_$seq.tmp';

// ---------------------------------------------------------------------------
// (B) Replica of the sweep predicate.
// Source: entity.path.endsWith('.tmp') && now.difference(stat.modified) > _tmpMaxAge
// with _tmpMaxAge = 5 minutes. STRICT greater-than.
// ---------------------------------------------------------------------------
const int kTmpMaxAgeMinutes = 5;

bool shouldDelete(String name, num ageMinutes) =>
    name.endsWith('.tmp') && ageMinutes > kTmpMaxAgeMinutes;

void main() {
  group('(A) unique-temp generator — collision-proof, .tmp, co-located', () {
    const finalPath = '/cache/store/gifts/animation.svga';
    const micros = 1717200000000000; // a single fixed simulated microsecond

    test('many calls in the SAME microsecond, incrementing seq -> ALL distinct',
        () {
      // Reproduces the worst case the fix targets: two (or N) concurrent
      // downloads of the same url starting within the same microsecond. The
      // monotonic seq must make every temp name unique.
      const count = 1000;
      final names = <String>{};
      for (var seq = 0; seq < count; seq++) {
        names.add(makeTemp(finalPath, micros, seq));
      }
      expect(names.length, count,
          reason: 'no two temp names may collide for the same micros');
    });

    test('two same-micros downloads of the same url never share a temp', () {
      // seq is the only differentiator within one microsecond.
      final a = makeTemp(finalPath, micros, 0);
      final b = makeTemp(finalPath, micros, 1);
      expect(a, isNot(equals(b)));
    });

    test('every generated temp ends with .tmp', () {
      for (var seq = 0; seq < 50; seq++) {
        expect(makeTemp(finalPath, micros, seq).endsWith('.tmp'), isTrue);
      }
    });

    test('temp is co-located with the final file (same directory prefix)', () {
      final temp = makeTemp(finalPath, micros, 7);
      // The temp must begin with the full final path, guaranteeing it sits in
      // the SAME directory so the rename stays intra-filesystem/atomic.
      expect(temp.startsWith('$finalPath.'), isTrue);
      const dir = '/cache/store/gifts';
      expect(temp.startsWith('$dir/'), isTrue);
      expect(temp.substring(0, temp.lastIndexOf('/')), dir);
    });

    test('exact format matches the source: "\$finalPath.\${micros}_\$seq.tmp"',
        () {
      expect(makeTemp(finalPath, micros, 42),
          '$finalPath.${micros}_42.tmp');
    });

    test('distinct across different micros too (timestamp varies, seq varies)',
        () {
      final names = <String>{};
      var seq = 0;
      for (var m = micros; m < micros + 100; m++) {
        names.add(makeTemp(finalPath, m, seq++));
      }
      expect(names.length, 100);
    });
  });

  group('(B) sweep predicate — endsWith(.tmp) && age > 5min (strict)', () {
    test('.tmp older than 5 minutes -> deleted (true)', () {
      expect(shouldDelete('animation.svga.123_0.tmp', 6), isTrue);
      expect(shouldDelete('animation.svga.123_0.tmp', 30), isTrue);
      expect(shouldDelete('animation.svga.123_0.tmp', 5.0001), isTrue);
    });

    test('.tmp younger than 5 minutes -> kept (false)', () {
      expect(shouldDelete('animation.svga.123_0.tmp', 0), isFalse);
      expect(shouldDelete('animation.svga.123_0.tmp', 1), isFalse);
      expect(shouldDelete('animation.svga.123_0.tmp', 4.9999), isFalse);
    });

    test('boundary: exactly 5 minutes -> kept (strict >, not >=)', () {
      expect(shouldDelete('animation.svga.123_0.tmp', 5), isFalse);
      expect(shouldDelete('animation.svga.123_0.tmp', 5.0), isFalse);
    });

    test('final asset (.svga) is never swept, regardless of age', () {
      expect(shouldDelete('animation.svga', 9999), isFalse);
    });

    test('final asset (.mp4) is never swept, regardless of age', () {
      expect(shouldDelete('clip.mp4', 0), isFalse);
      expect(shouldDelete('clip.mp4', 60), isFalse);
    });

    test('other final extensions (.png/.svg/.webp/.gif) never swept', () {
      for (final name in const [
        'pic.png',
        'icon.svg',
        'sticker.webp',
        'frame.gif',
      ]) {
        expect(shouldDelete(name, 100), isFalse, reason: '$name must survive');
      }
    });

    test('a name merely CONTAINING .tmp but not ending with it -> kept', () {
      // Guards against accidental endsWith->contains drift.
      expect(shouldDelete('animation.tmp.svga', 9999), isFalse);
      expect(shouldDelete('a.tmp.backup', 9999), isFalse);
    });

    test('extension match is case-sensitive (endsWith) -> .TMP not swept', () {
      expect(shouldDelete('animation.TMP', 9999), isFalse);
    });
  });
}
