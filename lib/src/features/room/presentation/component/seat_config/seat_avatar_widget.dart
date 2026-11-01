import 'dart:async';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:shimmer/shimmer.dart';
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/cache/cache_alpha_widget.dart';
import 'package:general/src/core/widgets/cache/cache_vap_widget.dart';
import 'package:general/src/core/widgets/cache/cache_video_widget.dart';
import 'package:general/src/features/room/presentation/component/seat_config/charisma_badge_widget.dart';
import 'package:general/src/features/room/presentation/component/seat_config/seat_metrics.dart';
import 'package:general/src/features/room/presentation/component/seat_config/seat_mute_badge.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/room_controls/room_controls.dart';

class SeatAvatarWidget extends StatelessWidget {
  final String userId;
  final Map<String, String> attributes;

  /// The FULL seat slot size, in device-real px, supplied by the audio-room kit
  /// — the same value the empty/locked builders receive. The avatar diameter and
  /// every sub-element are derived from it via [SeatMetrics], so the occupied,
  /// empty and locked seats share one size source and stay identical in every
  /// mode and on every device.
  final double size;

  const SeatAvatarWidget({
    super.key,
    required this.userId,
    this.attributes = const {},
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final int id = int.tryParse(userId) ?? 0;

    // Register the actual rendered AUDIO-seat context for lucky-gift fly
    // targeting. This replaces the old per-user GlobalKey and therefore stays
    // safe even if the room kit briefly renders the same user twice during a
    // seat/overlay transition.
    if (di<RoomStateManager>().isInAudioRoom && userId.isNotEmpty) {
      RoomScreenState.registerSeatAvatarContext(userId, context);
    }

    // All data comes from backend metadata (attributes) — no local cache.
    final String resolvedImage = attributes['avatar'] ?? "";
    final String? frame = attributes['fr'];
    final String? frameType = attributes['frt'];
    final String displayName = attributes['name'] ?? "";
    final String colorName = attributes['cn'] ?? '';
    final String soundWaveSvga = attributes['sw'] ?? '';

    final m = SeatMetrics.forSeat(size);
    final double avatarSize = m.avatar;

    // Build avatar image widget using the kit-provided size.
    // The initials circle is ALWAYS rendered as the base layer, with the photo
    // painted over it once loaded. An occupied seat whose occupant arrived with
    // empty metadata (reconnect race) or whose avatar URL hangs used to render
    // nothing at all — an invisible seat.
    final Widget avatarImage = Stack(
      alignment: Alignment.center,
      children: [
        // While the occupant's metadata hasn't arrived yet (empty name), a
        // circular shimmer reads as "loading" instead of InitialsAvatar's
        // '?' placeholder, on request.
        // Also shimmer while the photo itself is still loading, so a slow
        // profile image never flashes a grey/initials placeholder first.
        displayName.isEmpty || resolvedImage.isNotEmpty
            ? _SeatAvatarShimmer(size: avatarSize)
            : InitialsAvatar(name: displayName, size: avatarSize),
        if (resolvedImage.isNotEmpty)
          ImageViewWidget(
            url: resolvedImage,
            boxFit: BoxFit.cover,
            width: avatarSize,
            height: avatarSize,
            shape: BoxShape.circle,
            // Transparent while loading so the initials base shows through
            // instead of an invisible/shimmer slot on the dark room background.
            isStopLoadingAndError: false,
            // Avatar context: a failing URL falls back to initials, not the logo.
            displayName: displayName,
          ),
      ],
    );

    // Mirrors EmptySeat/LockedSeatWidget's own wrapper exactly: a
    // Flexible+AspectRatio+avatar-sized box anchored to the BOTTOM of the
    // slot, with a caption line below it. Previously this widget was a
    // bare Stack centered in whatever slot the kit handed it -- when that
    // slot was taller than the avatar circle alone (room left for the
    // caption), centering put the avatar visibly lower than where the
    // empty/locked circle sits (which is bottom-anchored, not centered).
    // The name now sits in that same footer spot the seat NUMBER uses on
    // an empty/locked seat, instead of overlaid on the avatar photo.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // ================== Sound Wave ==================
                  // Painted FIRST (bottom-most) so it sits BEHIND the actual
                  // profile photo -- the wave is a big halo (avatar * 4.5),
                  // and only its ring shows around the photo; the middle
                  // portion that would otherwise overlap the face is covered
                  // by the avatar image drawn right after it. The Frame
                  // (also drawn after, per its own overlap-the-edge design --
                  // see SeatMetrics.frame) only covers the innermost slice of
                  // the wave's radius (frame box is 1.35x avatar vs the
                  // wave's 4.5x), so most of the ring still reads on top of
                  // it.
                  if (soundWaveSvga.isNotEmpty)
                    _SoundWaveOverlay(
                      userId: userId,
                      avatarSize: avatarSize,
                      soundWaveSvga: soundWaveSvga,
                    ),

                  // ================== Avatar Image with Glow ==================
                  Center(
                    child: _SpeakingGlow(
                      userId: userId,
                      hasSoundWave: soundWaveSvga.isNotEmpty,
                      child: avatarImage,
                    ),
                  ),

                  // ================== Frame ==================
                  // The Stack hands its children at most the avatar's size, which
                  // capped the frame to the photo diameter. OverflowBox lets the
                  // frame take its real size, centred on the photo.
                  if (frame != null && frame != "")
                    OverflowBox(
                      minWidth: 0,
                      minHeight: 0,
                      maxWidth: m.frame,
                      maxHeight: m.frame,
                      child: _buildFrameWidget(
                        frame: frame,
                        frameType: frameType,
                        id: id,
                        width: m.frame,
                        height: m.frame,
                      ),
                    ),

                  // ================== Mic State (below avatar, right side) ==================
                  if (userId.isNotEmpty)
                    _MicState(imageSize: avatarSize, userId: userId),

                  // ================== Emoji Overlay ==================
                  _EmojiOverlay(userId: userId, imageSize: avatarSize),
                ],
              ),
            ),
          ),
        ),

        // Breathing room between the photo (and its frame) and the name.
        SizedBox(height: m.avatar * 0.07),

        // ================== Name (same spot the seat number sits) ==================
        // The admin/owner badge used to sit stamped on top of the profile
        // photo (top-left corner). Moved on request to a small icon right
        // before the name instead, so the photo itself stays uncovered.
        if (displayName.isNotEmpty)
          SizedBox(
            width: m.nameMaxWidth,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (userId.isNotEmpty)
                  _InlineAdminBadge(userId: userId, avatarSize: avatarSize),
                Flexible(
                  child: GradientName(
                    child: TextScroll(
                      displayName,
                      velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
                      pauseBetween: const Duration(milliseconds: 1000),
                      textAlign: TextAlign.center,
                      style: context.bodyMedium
                          .copyWith(fontSize: m.nameFont)
                          .w600
                          .colorExt(
                            colorName.isNotEmpty
                                ? Color(
                                  int.parse(colorName.replaceAll('#', '0xff')),
                                )
                                : ColorManager.white,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Charisma value (heart + number) under the name, while charisma is
        // on -- moved off the photo, as in im_Chat.
        CharismaValueLine(
          userId: userId,
          fontSize: m.charismaFont,
          iconSize: m.charismaIcon,
        ),
      ],
    );
  }

  Widget _buildFrameWidget({
    required String frame,
    required String? frameType,
    required int id,
    required double width,
    required double height,
  }) {
    // The backend's frame_type is not reliable: it can say "png" for a
    // ".svga" file (seen live: frame=files/svga_ypPGL0.svga, frame_type=png).
    // Rendering that through ImageViewWidget fails and draws nothing, so the
    // frame flashed for a moment and then vanished from the seat. Trust the
    // file extension first.
    final path = frame.toLowerCase().split('?').first;
    if (path.endsWith('.svga') || path.endsWith('.zz')) {
      frameType = 'svga';
    }
    if (frameType == "svga") {
      return CacheSvgaWidget(
        key: ValueKey("frame_$id"),
        url: frame,
        width: width,
        height: height,
        boxFit: BoxFit.fill,
      );
    } else if (frameType == "alpha") {
      return CacheAlphaWidget(
        url: frame,
        width: width,
        height: height,
        isLoop: true,
      );
    } else {
      return IgnorePointer(
        child: ImageViewWidget(
          key: ValueKey("frame_$id"),
          url: frame,
          isFromRoom: true,
          // A frame that is still loading (or failed) must draw nothing --
          // never the grey person placeholder square.
          isGift: true,
          width: width,
          height: height,

          // Only the USER PHOTO is circular.
          // The profile-frame asset must keep its original transparent
          // shape (square/ornamental/custom), so never clip it to a circle.
          shape: BoxShape.rectangle,
          boxFit: BoxFit.contain,
        ),
      );
    }
  }
}

// ================== Loading Shimmer ==================
// Circular shimmer shown in place of InitialsAvatar's '?' placeholder while
// a seat's occupant metadata (name/avatar) hasn't arrived yet. Tinted with
// the app's own home-background gradient colors, lightened via alpha, per
// request.
class _SeatAvatarShimmer extends StatelessWidget {
  final double size;
  const _SeatAvatarShimmer({required this.size});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFFDA3E8).withValues(alpha: 0.25),
      highlightColor: const Color(0xFFB9F6FB).withValues(alpha: 0.6),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ================== Speaking Glow ==================
// Plain default green pulse. Suppressed (returns [child] untouched) whenever
// the occupant has an equipped Sound Wave SVGA -- that premium effect is
// rendered separately by [_SoundWaveOverlay], as the outermost layer of the
// whole seat Stack (see SeatAvatarWidget.build), not nested here.
class _SpeakingGlow extends StatelessWidget {
  final String userId;
  final Widget child;
  final bool hasSoundWave;

  const _SpeakingGlow({
    required this.userId,
    required this.child,
    this.hasSoundWave = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = RoomData.instance.utdController;
    if (controller == null || userId.isEmpty || hasSoundWave) {
      return child;
    }

    return ValueListenableBuilder<Set<String>>(
      valueListenable: controller.activeSpeakers,
      builder: (context, speakers, _) {
        final isMuted = controller.mutedParticipants.value.contains(userId);
        final isSpeaking = speakers.contains(userId) && !isMuted;
        return AvatarGlow(
          animate: isSpeaking,
          glowColor: Colors.greenAccent,
          glowRadiusFactor: 0.3,
          duration: const Duration(milliseconds: 1000),
          child: child,
        );
      },
    );
  }
}

// ================== Sound Wave Overlay ==================
// The premium SVIP "Sound Wave" SVGA. Deliberately a SEPARATE, independent
// child of the seat's outer Stack (added AFTER the Frame -- see
// SeatAvatarWidget.build) rather than nested inside the avatar/frame layer.
// The Frame is painted on top of the avatar on purpose so its ring can
// overlap the photo edge (SeatMetrics.frame), which meant an earlier version
// that nested the wave under the avatar got it painted OVER by the Frame too
// -- hiding most of it, with only the ripple's edge flashing in and out from
// behind the Frame as its shape animated, which read as the wave "cutting".
// Rendering it after (on top of) the Frame instead fixes that.
class _SoundWaveOverlay extends StatefulWidget {
  final String userId;
  final double avatarSize;
  final String soundWaveSvga;

  const _SoundWaveOverlay({
    required this.userId,
    required this.avatarSize,
    required this.soundWaveSvga,
  });

  @override
  State<_SoundWaveOverlay> createState() => _SoundWaveOverlayState();
}

class _SoundWaveOverlayState extends State<_SoundWaveOverlay> {
  /// Whether the wave SVGA is currently mounted. Only flips true→false after
  /// [_hideGrace] of continuous silence (see [_onSpeakersChanged]) -- never
  /// directly off the raw activeSpeakers signal.
  bool _showWave = false;

  /// Bumped every time the wave (re)starts, so its `ValueKey` changes and
  /// `CacheSvgaWidget` mounts a fresh instance that plays from frame 0.
  int _playToken = 0;

  Timer? _hideTimer;

  /// VAD marks someone as "not speaking" for brief gaps between words/
  /// syllables even in continuous speech -- confirmed by the raw
  /// activeSpeakers signal flickering on/off many times within one
  /// utterance. Reacting to every flicker (hide+restart) never let the SVGA
  /// finish a play-through, which read as the wave "cutting" mid-animation.
  /// Waiting this long past the last "not speaking" tick before actually
  /// hiding treats those gaps as still-speaking, so the wave keeps playing
  /// continuously through a whole sentence and only replays from the start
  /// once the person has genuinely gone quiet.
  static const _hideGrace = Duration(milliseconds: 900);

  bool get _isSpeaking {
    final controller = RoomData.instance.utdController;
    if (controller == null || widget.userId.isEmpty) return false;
    final isMuted = controller.mutedParticipants.value.contains(widget.userId);
    return controller.activeSpeakers.value.contains(widget.userId) && !isMuted;
  }

  @override
  void initState() {
    super.initState();
    RoomData.instance.utdController?.activeSpeakers.addListener(
      _onSpeakersChanged,
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    RoomData.instance.utdController?.activeSpeakers.removeListener(
      _onSpeakersChanged,
    );
    super.dispose();
  }

  void _onSpeakersChanged() {
    if (_isSpeaking) {
      _hideTimer?.cancel();
      _hideTimer = null;
      if (!_showWave) {
        setState(() {
          _showWave = true;
          _playToken++;
        });
      }
    } else if (_showWave && _hideTimer == null) {
      _hideTimer = Timer(_hideGrace, () {
        _hideTimer = null;
        if (mounted) setState(() => _showWave = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showWave) return const SizedBox.shrink();

    // The source SVGA's own canvas has a lot of transparent margin around
    // the actual ring graphic (confirmed from a live screenshot: even at
    // avatarSize * 2.6 with BoxFit.contain, the visible ring stayed a thin
    // outline hugging the avatar edge -- BoxFit.contain scales the WHOLE
    // canvas, margin included, so the margin was eating most of the box).
    // BoxFit.cover instead zooms/crops into the canvas so the ring itself
    // fills the box, and a much bigger box makes that filled ring read as a
    // large, obvious wave instead of a thin border.
    final double waveSize = widget.avatarSize * 1.65;
    return IgnorePointer(
      // The parent Stack is sized to avatarSize x avatarSize, and Stack's
      // default StackFit.loose caps every non-positioned child's layout
      // constraints at the STACK'S OWN size -- so a bigger declared
      // width/height was silently clamped straight back down to avatarSize
      // during layout, no matter how large `waveSize` was set.
      // `clipBehavior: Clip.none` on that Stack only stops the overflow from
      // being CLIPPED at paint time; it does nothing about this layout
      // clamp, which happens earlier. OverflowBox is what actually lets this
      // child claim a size bigger than what its parent offers.
      child: Center(
        child: OverflowBox(
          maxWidth: waveSize,
          maxHeight: waveSize,
          child: SizedBox(
            width: waveSize,
            height: waveSize,
            child: CacheSvgaWidget(
              key: ValueKey('wave_${widget.userId}_$_playToken'),
              url: widget.soundWaveSvga,
              width: waveSize,
              height: waveSize,
              boxFit: BoxFit.cover,
              pauseWhenHidden: true,
            ),
          ),
        ),
      ),
    );
  }
}

// ================== Mic STATE ==================
class _MicState extends StatelessWidget {
  final double imageSize;
  final String userId;

  const _MicState({required this.imageSize, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = RoomData.instance.utdController;
    if (controller == null) return const SizedBox();

    // Mic actually off, or All Mute blocks this user. The owner/admins (and
    // users allowed to speak) are exempt from All Mute, so their badge just
    // follows their real mic — it clears as soon as they unmute.
    return ValueListenableBuilder<RoomControlsState>(
      valueListenable: RoomControls.instance.state,
      builder:
          (context, s, __) => ValueListenableBuilder<Set<String>>(
            valueListenable: controller.mutedParticipants,
            builder: (context, muted, _) {
              final isMuted =
                  muted.contains(userId) ||
                  !RoomControls.instance.canSpeak(userId);
              if (!isMuted) return const SizedBox();
              return SeatMuteIcon(avatarSize: imageSize);
            },
          ),
    );
  }
}

// ================== Emoji Overlay ==================
class _EmojiOverlay extends StatelessWidget {
  final String userId;
  final double imageSize;

  const _EmojiOverlay({required this.userId, required this.imageSize});

  @override
  Widget build(BuildContext context) {
    // A bit bigger than the plain avatarSize again, on request -- the real
    // bug behind the animation looking "cut" was the fixed-duration timer
    // in EmojieController racing the SVGA's network load time, not the box
    // size (see emojie_controller.dart). BoxFit.contain stays so nothing
    // gets stretched/cropped at this size either.
    final double emojiSize = imageSize * 1.0;
    return Center(
      child: OverflowBox(
        maxWidth: emojiSize,
        maxHeight: emojiSize,
        child: SizedBox(
          width: emojiSize,
          height: emojiSize,
          child: ValueListenableBuilder<int>(
            valueListenable: EmojieController.updateEmojie,
            builder: (context, _, __) {
              final emoji = EmojieController.emojies.value[userId]?.emojie;
              final type = EmojieController.emojies.value[userId]?.type;
              if (emoji == null) return const SizedBox();

              return type == "svga"
                  ? CacheSvgaWidget(
                    url: emoji,
                    height: emojiSize,
                    width: emojiSize,
                    boxFit: BoxFit.contain,
                  )
                  : type == "vap"
                  ? CachedVapWidget(
                    url: emoji,
                    height: emojiSize,
                    width: emojiSize,
                  )
                  : type == "alpha"
                  ? CacheAlphaWidget(
                    url: emoji,
                    height: emojiSize,
                    width: emojiSize,
                  )
                  : type == "mp4"
                  ? CacheVideoWidget(
                    videoUrl: emoji,
                    height: emojiSize,
                    width: emojiSize,
                  )
                  : emoji.toLowerCase().endsWith('.gif')
                  ? _AnimatedGifEmoji(url: emoji, size: emojiSize)
                  : ImageViewWidget(
                    isFromRoom: true,
                    url: emoji,
                    height: emojiSize,
                    width: emojiSize,
                    radius: 50,
                    boxFit: BoxFit.contain,
                  );
            },
          ),
        ),
      ),
    );
  }
}

/// ImageViewWidget renders via a [DecorationImage] wrapped in [ResizeImage],
/// which only ever paints a single frame here -- that's why a .gif emoji sent
/// to the seat showed as a static picture instead of playing, unlike the
/// SVGA/vap/alpha/mp4 emoji types above. [Image.file]/[Image.network] drive
/// their own multi-frame ticker and animate GIFs correctly, so this bypasses
/// ImageViewWidget just for that extension while still reusing the shared
/// disk cache for consistency with the rest of the app.
class _AnimatedGifEmoji extends StatefulWidget {
  final String url;
  final double size;

  const _AnimatedGifEmoji({required this.url, required this.size});

  @override
  State<_AnimatedGifEmoji> createState() => _AnimatedGifEmojiState();
}

class _AnimatedGifEmojiState extends State<_AnimatedGifEmoji> {
  final _assetCacheManager = AssetCacheManager();
  File? _file;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AnimatedGifEmoji oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _file = null;
      _load();
    }
  }

  Future<void> _load() async {
    final file = await _assetCacheManager.getCachedAsset(widget.url);
    if (!mounted) return;
    setState(() => _file = file);
  }

  @override
  Widget build(BuildContext context) {
    if (_file != null) {
      return Image.file(
        _file!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      );
    }
    return Image.network(
      EndPoints.getImage(widget.url),
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const SizedBox(),
    );
  }
}

/// Marks a seat whose occupant runs the room: the host, or one of its admins.
///
/// Reads the same [AdminRoomBloc] list the Admin List screen shows, so a
/// promote or demote made there is reflected on the seat without a second
/// source of truth. The room owner is included even though the backend does not
/// list them as an admin — from a member's point of view the owner is the most
/// senior moderator in the room, and leaving them unmarked reads as an
/// inconsistency rather than a distinction.
///
/// Previously stamped on the profile photo itself via [Positioned] (which
/// only works as a direct child of a [Stack]). Moved on request to a small
/// icon sitting right before the occupant's name instead, so it renders as
/// a plain sized [Image] that fits inline in the name's [Row] and no longer
/// covers any part of the photo.
class _InlineAdminBadge extends StatelessWidget {
  final String userId;
  final double avatarSize;

  const _InlineAdminBadge({required this.userId, required this.avatarSize});

  @override
  Widget build(BuildContext context) {
    final ownerId = RoomData.instance.room.ownerId?.toString();

    return BlocBuilder<AdminRoomBloc, AdminRoomStates>(
      bloc: di<AdminRoomBloc>(),
      buildWhen: (p, c) => p.admins != c.admins,
      builder: (context, state) {
        final isOwner = ownerId != null && ownerId == userId;
        final isAdmin = state.admins.any((a) => a.id.toString() == userId);
        if (!isOwner && !isAdmin) return const SizedBox.shrink();

        // Owner and admin are different jobs and now read as different people:
        // the host is the red figure, an admin the blue one. Previously both
        // carried the same badge, so a member could not tell who actually owned
        // the room.
        final asset =
            isOwner ? AssetsManager.hostBadge : AssetsManager.adminBadge;
        final badgeSize = avatarSize * 0.22;

        return Padding(
          padding: EdgeInsets.only(right: avatarSize * 0.05),
          child: Image.asset(
            asset,
            width: badgeSize,
            height: badgeSize,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
