import 'package:flutter/widgets.dart';
import 'package:livekit_client/livekit_client.dart'
    show VideoViewFit, TrackProcessor, VideoProcessorOptions;

import '../theme/utd_room_strings.dart';
import '../theme/utd_room_theme.dart';
import 'video_quality.dart';

/// Configuration for [UTDLiveRoom].
///
/// A live room is a video room: the host's camera fills the screen (the host
/// video IS the background — there is no separate background layer or seat
/// Guests a SOLO broadcast still accepts, shown as a floating rail over the
/// host's camera rather than in a grid cell.
///
/// Shared so the host app sizes its seat list the same way the kit does —
/// they disagreed before, and a solo live ended up with a single host seat
/// and no slot any guest could be approved into.
const int kUTDSoloRailGuests = 8;

/// How many solo-rail tiles are DRAWN at once.
///
/// The stage itself accepts [kUTDSoloRailGuests]; this is only what fits on
/// screen beside the host's camera before the column starts colliding with
/// the chat.
const int kUTDSoloRailVisible = 3;

/// grid), and up to [maxGuestTiles] invited guests appear as floating video
/// tiles on top.
class UTDLiveRoomConfig {
  // --- Shared room behaviour ---
  final bool showControlsBar;
  final bool enableMinimize;
  final bool useSpeakerWhenJoining;

  /// When false, the kit does NOT render its built-in centered "Go Live"
  /// button during the host self-preview — the app renders its own composer
  /// (title/cover/start) and triggers [UTDMediaController.goLive] itself.
  final bool showGoLiveButton;

  // --- Live (video) behaviour ---

  /// When true, the host publishes the camera immediately on connect instead of
  /// going through the self-preview → "Go Live" step. Default false (preview),
  /// per the locked product decision (self-preview → Go Live).
  final bool autoHostCamera;

  /// When true (default), the local camera starts on the front camera.
  final bool frontCameraOnJoin;

  /// When true (default), the LOCAL camera tile is mirrored (front-camera selfie
  /// view). Remote tiles are never force-mirrored.
  final bool mirrorLocalVideo;

  /// Video publish quality for the LOCAL camera (capture resolution + publish
  /// bitrate/framerate). Applies to the host self-preview → Go Live path and
  /// to guests going live. Default [UTDVideoQuality.hd] (720p). Applied at
  /// connect — changing it on an already-open room has no effect.
  final UTDVideoQuality videoQuality;

  /// Max simultaneous guest tiles (host excluded). The engine enforces the same
  /// cap server-side — this is the client gate.
  ///
  /// 0 means SOLO: no seat grid. It does NOT mean "no guests" — a solo
  /// broadcast still accepts up to [soloRailGuests], drawn as floating tiles
  /// over the host's full-screen camera. Treating 0 as "nobody may join" is
  /// what made the join button on a plain live do nothing.
  final int maxGuestTiles;

  /// Guests a SOLO broadcast shows in the floating rail. Matches the engine's
  /// `StageService::SOLO_RAIL_GUESTS`.
  final int soloRailGuests;

  /// How the host's full-bleed video is fitted. Default [VideoViewFit.cover].
  final VideoViewFit hostFit;

  /// How each floating guest tile's video is fitted. Default [VideoViewFit.cover].
  final VideoViewFit guestFit;

  /// Seat index that maps to the host tile (full-bleed). Always 0 for live.
  final int hostSeatIndex;

  // --- Theming ---
  final UTDRoomTheme theme;

  /// Strings for the built-in default UI. `null` => [UTDRoomStrings.en].
  final UTDRoomStrings? strings;

  // --- Section overrides (null = built-in default) ---
  final Widget? headerWidget;
  final Widget? messagesWidget;
  final Widget? controlsBarWidget;
  final Widget? foregroundWidget;

  // --- Tile builders (null = built-in default) ---
  /// Replaces the full-bleed host tile.
  final Widget Function(BuildContext context)? hostTileBuilder;

  /// Replaces a floating guest tile (by seat index 1..maxGuestTiles).
  final Widget Function(BuildContext context, int seatIndex)? guestTileBuilder;

  /// Optional overlay rendered at the BOTTOM of each guest tile (over the
  /// video) — the app uses it for the guest's name + per-stage gift counter.
  /// Receives the guest's identity (user id).
  final Widget Function(BuildContext context, String identity)?
      guestTileFooterBuilder;

  /// Fired when the user taps the empty stage area (the full-bleed host
  /// video, outside any button/tile). The app uses it for TikTok-style
  /// tap-hearts. Buttons/chat/tiles keep winning their own taps — this only
  /// receives taps that reach the stage layer underneath the chrome.
  final void Function()? onStageTap;

  /// User attributes shared with other participants.
  final Map<String, String> userInRoomAttributes;

  // --- Video effects (beauty / filters) ---

  /// Builds a fresh LiveKit video-effects processor for each local camera
  /// capture. `null` (default) = no effects, fully backward compatible.
  ///
  /// This is a FACTORY (not a shared instance) because LiveKit *destroys* the
  /// processor on every `restartTrack` (camera flip / reconnect), so each
  /// capture needs its own instance. The kit attaches the result to the host
  /// self-preview ([UTDMediaController.startPreview]) and to the SDK's default
  /// camera options (reconnect / autoHostCamera / guest go-live).
  ///
  /// Typed against livekit_client so the kit needs no dependency on an effects
  /// package. The kit passes the trusted, server-signed `entitled` flag (decoded
  /// from the join token's `videoEffects` claim) into the factory; forward it to
  /// the processor so effects run only when the customer has activated + paid:
  /// ```dart
  /// UTDLiveRoomConfig(
  ///   buildVideoProcessor: (entitled) =>
  ///       VideoEffectsProcessor.create(entitled: entitled),
  /// )
  /// ```
  final TrackProcessor<VideoProcessorOptions> Function(bool entitled)?
      buildVideoProcessor;

  const UTDLiveRoomConfig({
    this.showControlsBar = true,
    this.enableMinimize = true,
    this.useSpeakerWhenJoining = true,
    this.showGoLiveButton = true,
    this.autoHostCamera = false,
    this.frontCameraOnJoin = true,
    this.mirrorLocalVideo = true,
    this.videoQuality = UTDVideoQuality.hd,
    this.maxGuestTiles = 3,
    this.soloRailGuests = kUTDSoloRailGuests,
    this.hostFit = VideoViewFit.cover,
    this.guestFit = VideoViewFit.cover,
    this.hostSeatIndex = 0,
    this.theme = const UTDRoomTheme(),
    this.strings,
    this.headerWidget,
    this.messagesWidget,
    this.controlsBarWidget,
    this.foregroundWidget,
    this.hostTileBuilder,
    this.guestTileBuilder,
    this.guestTileFooterBuilder,
    this.onStageTap,
    this.userInRoomAttributes = const {},
    this.buildVideoProcessor,
  });

  /// Resolves the effective strings — the supplied [strings] or English defaults.
  UTDRoomStrings resolveStrings() => strings ?? UTDRoomStrings.en();
}
