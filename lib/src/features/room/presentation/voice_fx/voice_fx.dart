import 'dart:async';
import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Room "Mixer": music effect, equalizer and voice changer applied to the
/// user's own mic on the device (Android, see VoiceFxProcessor.kt), so the
/// room hears the changed voice. Index 0 in every group is "off". The choice
/// is saved and re-applied whenever a room is joined.
class VoiceFx {
  VoiceFx._();

  static const MethodChannel _channel = MethodChannel('miva/voice_fx');
  static const _kMusic = 'voice_fx_music';
  static const _kEq = 'voice_fx_eq';
  static const _kVoice = 'voice_fx_voice';

  static final ValueNotifier<int> music = ValueNotifier<int>(0);
  static final ValueNotifier<int> eq = ValueNotifier<int>(0);
  static final ValueNotifier<int> voice = ValueNotifier<int>(0);

  static bool get isSupported => Platform.isAndroid;

  static Timer? _retry;

  /// Loads the saved choice and pushes it to the mic chain. The WebRTC
  /// engine only exists once a room is joined, so this keeps retrying for a
  /// little while until the processor is attached.
  static Future<void> applySaved() async {
    if (!isSupported) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      music.value = prefs.getInt(_kMusic) ?? 0;
      eq.value = prefs.getInt(_kEq) ?? 0;
      voice.value = prefs.getInt(_kVoice) ?? 0;
    } catch (_) {}
    _applyWithRetry();
  }

  static Future<void> select({int? musicIndex, int? eqIndex, int? voiceIndex}) async {
    if (musicIndex != null) music.value = musicIndex;
    if (eqIndex != null) eq.value = eqIndex;
    if (voiceIndex != null) voice.value = voiceIndex;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kMusic, music.value);
      await prefs.setInt(_kEq, eq.value);
      await prefs.setInt(_kVoice, voice.value);
    } catch (_) {}
    _applyWithRetry();
  }

  static void _applyWithRetry() {
    _retry?.cancel();
    var tries = 0;
    Future<void> attempt() async {
      final attached = await _push();
      tries++;
      if (!attached && tries < 15) {
        _retry = Timer(const Duration(seconds: 2), attempt);
      }
    }

    attempt();
  }

  static Future<bool> _push() async {
    if (!isSupported) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('set', {
        'music': music.value,
        'eq': eq.value,
        'voice': voice.value,
      });
      return ok ?? false;
    } catch (e) {
      debugPrint('[VoiceFx] set failed: $e');
      return false;
    }
  }
}

class _FxOption {
  const _FxOption(this.label, this.icon, this.colors);
  final String label;
  final IconData icon;
  final List<Color> colors;
}

/// The "Mixer" bottom sheet (reference design): three rows of round
/// options -- Music Effects, Equalizer, Voice changer -- the selected one
/// ringed in teal. Choices apply live to the user's mic.
class VoiceMixerSheet extends StatelessWidget {
  const VoiceMixerSheet({super.key});

  static const _off = [Color(0xFFF1F2F5), Color(0xFFE3E5EA)];

  static const List<_FxOption> _music = [
    _FxOption('Original', Icons.block_rounded, _off),
    _FxOption('Reverb', Icons.surround_sound_rounded,
        [Color(0xFF4FA3FF), Color(0xFF2F6BE8)]),
    _FxOption('Live Concert', Icons.stadium_rounded,
        [Color(0xFFFF7A45), Color(0xFFE8452F)]),
    _FxOption('KTV', Icons.mic_external_on_rounded,
        [Color(0xFF8E2C6B), Color(0xFF5B1748)]),
    _FxOption('Ethereal', Icons.auto_awesome_rounded,
        [Color(0xFFF6D3B5), Color(0xFFE9A97E)]),
    _FxOption('Concert Hall', Icons.piano_rounded,
        [Color(0xFF9C5A3A), Color(0xFF6B3A22)]),
  ];

  static const List<_FxOption> _eq = [
    _FxOption('None', Icons.block_rounded, _off),
    _FxOption('Custom', Icons.graphic_eq_rounded,
        [Color(0xFFB0457A), Color(0xFF7A2E8E)]),
    _FxOption('Electronic', Icons.bolt_rounded,
        [Color(0xFF7B3FF2), Color(0xFF4C1DB8)]),
    _FxOption('Rock', Icons.music_note_rounded,
        [Color(0xFFC86BFF), Color(0xFFE061C9)]),
    _FxOption('Bass', Icons.speaker_rounded,
        [Color(0xFFC0452F), Color(0xFF7A2418)]),
    _FxOption('Jazz', Icons.music_note_rounded,
        [Color(0xFFFF6B8B), Color(0xFFF0446E)]),
  ];

  static const List<_FxOption> _voice = [
    _FxOption('None', Icons.block_rounded, _off),
    _FxOption('Female Voice', Icons.face_3_rounded,
        [Color(0xFFF08AD8), Color(0xFFD45CC0)]),
    _FxOption('Male Voice', Icons.face_rounded,
        [Color(0xFF4F7BF0), Color(0xFF2B4FC8)]),
    _FxOption('Deep Male', Icons.record_voice_over_rounded,
        [Color(0xFF2B3E86), Color(0xFF16245C)]),
    _FxOption('Sweet Voice', Icons.favorite_rounded,
        [Color(0xFFE77AD8), Color(0xFFC94FCB)]),
    _FxOption('Child Voice', Icons.child_care_rounded,
        [Color(0xFFFFD84D), Color(0xFFF2B21B)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.hBox,
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDADCE2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 6.h),
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      'Mixer',
                      style: TextStyle(
                        color: const Color(0xFF1B1B1F),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF1F2F5),
                        ),
                        child: Icon(Icons.close_rounded,
                            color: const Color(0xFF1B1B1F), size: 22.sp),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0F1F4)),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                child: Text(
                  'Effects apply live to your mic -- everyone in the room hears them.',
                  style: TextStyle(
                    color: const Color(0xFF8E8F96),
                    fontSize: 12.sp,
                  ),
                ),
              ),
              _section('Music Effects', _music, VoiceFx.music,
                  (i) => VoiceFx.select(musicIndex: i)),
              _section('Equalizer', _eq, VoiceFx.eq,
                  (i) => VoiceFx.select(eqIndex: i)),
              _section('Voice changer', _voice, VoiceFx.voice,
                  (i) => VoiceFx.select(voiceIndex: i)),
              16.hBox,
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(
    String title,
    List<_FxOption> options,
    ValueNotifier<int> selected,
    void Function(int) onSelect,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFF1B1B1F),
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          12.hBox,
          SizedBox(
            height: 108.h,
            child: ValueListenableBuilder<int>(
              valueListenable: selected,
              builder: (context, value, _) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: options.length,
                separatorBuilder: (_, __) => 6.wBox,
                itemBuilder: (context, i) => _item(
                  options[i],
                  selected: value == i,
                  onTap: () => onSelect(i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(_FxOption o, {required bool selected, required VoidCallback onTap}) {
    final isOff = o.colors == _off;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 66.w,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xFF2CD3C5) : Colors.transparent,
                  width: 3,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2CD3C5).withValues(alpha: .35),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: o.colors,
                  ),
                ),
                child: Icon(
                  o.icon,
                  color: isOff ? const Color(0xFFB4B7BF) : Colors.white,
                  size: 26.sp,
                ),
              ),
            ),
            6.hBox,
            Text(
              o.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? const Color(0xFF1B1B1F) : const Color(0xFF8E8F96),
                fontSize: 11.5.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
