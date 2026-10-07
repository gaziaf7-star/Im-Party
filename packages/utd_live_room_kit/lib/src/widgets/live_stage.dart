import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../controller/utd_room_controller.dart';
import '../models/room_config.dart';
import '../models/seat_model.dart';
import 'live_tile_widget.dart';
import 'multi_guest_seat_layout.dart';

/// The live video stage.
///
/// The host's camera fills the whole screen (the host video IS the background —
/// there is no seat grid and no separate background layer). Invited guests
/// appear as a vertical strip of floating video tiles on top.
///
/// Tracks are resolved at build time (never stored): the local participant's
/// camera comes from its own publication (or the unpublished preview track
/// before "Go Live"); remote cameras come from
/// [UTDRoomManager.getRemoteVideoTrack]. Each tile is keyed by occupant identity
/// so its renderer is reused across rebuilds.
class UTDLiveStage extends StatelessWidget {
  final UTDRoomController controller;
  final UTDLiveRoomConfig config;

  /// The room owner — always the full-bleed host tile, seated or not.
  final String roomOwnerId;

  /// Per-guest-tile tap (opens the tile action sheet). The [BuildContext] is
  /// under the [UTDRoomScope] so the sheet can read theme/strings.
  final void Function(BuildContext context, SeatState seat)? onGuestTileTap;

  /// Tap on an EMPTY guest slot. The host is offered the invite list; anyone
  /// else asks to join. Null makes empty slots inert but still visible — the
  /// slots are what tell a viewer the broadcast has room.
  final void Function(BuildContext context, SeatState seat)? onEmptySlotTap;

  /// When false, the stage renders the HOST layer only and the guest tile
  /// strip is rendered by the parent as a separate layer (the live room puts
  /// it ABOVE the swipe-to-clear chrome PageView, which is hit-test opaque
  /// and would otherwise swallow tile taps).
  final bool showGuestTiles;

  /// When false, the full-bleed host layer is skipped — used by the parent to
  /// render a guest-tiles-only overlay above the chrome.
  final bool showHost;

  const UTDLiveStage({
    super.key,
    required this.controller,
    required this.config,
    required this.roomOwnerId,
    this.onGuestTileTap,
    this.onEmptySlotTap,
    this.showGuestTiles = true,
    this.showHost = true,
  });

  // Floating guest tile dimensions (portrait, ~9:16).
  static const double _guestTileWidth = 104;
  static const double _guestTileHeight = 150;

  @override
  Widget build(BuildContext context) {
    // Any of these changing affects what/where we render. They only notify on
    // real changes (the polls diff with setEquals), so this is not a per-tick
    // rebuild. VideoTrackRenderers are keyed by identity → no flicker.
    final listenable = Listenable.merge([
      controller.seatController.seats,
      controller.roomManager.videoTracksNotifier,
      controller.cameraOnParticipants,
      controller.activeSpeakers,
      controller.participantRolesNotifier,
      controller.mediaController.isCameraEnabled,
      controller.mediaController.isPreviewing,
    ]);

    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        // A multi-guest room is a GRID with the host as one cell. The floating
        // strip below is the SOLO shape — one or two viewers coming up over a
        // full-screen host — and using it for a 4- or 8-seat room is what made
        // "I chose 3 seats" look like a plain live.
        if (_isGrid) return _gridStage(context);

        // Solo rail: only OCCUPIED tiles, and capped by the solo allowance
        // rather than by maxGuestTiles — which is 0 here, and would otherwise
        // hide every guest who did come up.
        //
        // Three visible at a time. The engine lets more than three onto a solo
        // stage, but a taller column runs into the chat, so the rail shows the
        // first three and the rest are simply not drawn.
        final guestSeats = controller.seatController.seats.value
            .where((s) => s.isOccupied && s.index != config.hostSeatIndex)
            .take(config.soloRailGuests.clamp(0, kUTDSoloRailVisible))
            .toList();

        return Stack(
          children: [
            if (showHost)
              Positioned.fill(
                // Stage-level tap (tap-hearts): only taps that fall through
                // the chrome (buttons/chat/tiles win their own) land here.
                child: config.onStageTap == null
                    ? _hostTile(context)
                    : GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: config.onStageTap,
                        child: _hostTile(context),
                      ),
              ),
            if (showGuestTiles && guestSeats.isNotEmpty)
              Positioned(
                top: MediaQuery.of(context).padding.top + 118,
                // RIGHT side, stacked downwards. The chat column and the tab
                // strip both sit on the LEFT in this app's layout, so a rail on
                // the left landed on top of them.
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final seat in guestSeats)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: _guestTileWidth,
                          height: _guestTileHeight,
                          child: seat.isOccupied
                              ? _guestTile(context, seat)
                              : _emptySlot(context, seat),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Grid stage (multi-guest) ──

  /// Grid mode starts at four total seats (host + 3). Below that there is no
  /// grid worth drawing, and the solo shape is the right one.
  bool get _isGrid => config.maxGuestTiles >= 3;

  /// Total seats including the host, snapped to a shape the layout knows.
  int get _seatTotal =>
      UTDMultiGuestSeatLayout.normalise(config.maxGuestTiles + 1);

  /// The whole grid — host cell and guest cells together.
  ///
  /// Rendered in the GUEST pass, not the host pass, and deliberately so: the
  /// live room stacks a hit-test-opaque chrome PageView between the two, and
  /// empty cells have to be tappable. The host pass paints the backdrop the
  /// grid sits on.
  Widget _gridStage(BuildContext context) {
    if (showHost) {
      return SizedBox.expand(
        child: config.onStageTap == null
            ? _gridBackdrop()
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: config.onStageTap,
                child: _gridBackdrop(),
              ),
      );
    }

    if (!showGuestTiles) return const SizedBox.shrink();

    final seats = controller.seatController.seats.value;
    final media = MediaQuery.of(context);
    final width = UTDMultiGuestSeatLayout.widthForMaxHeight(
      _seatTotal,
      media.size.width - 16,
      media.size.height * gridMaxHeightFraction,
    );

    // Positioning belongs to the parent Stack in UTDLiveRoom. Returning a
    // Positioned here would put AnimatedBuilder between two competing
    // ParentDataWidgets (the crash reported by Flutter).
    return Padding(
      padding: EdgeInsets.only(top: media.padding.top + 96),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: width,
          child: UTDMultiGuestSeatLayout(
            seatCount: _seatTotal,
            hostBuilder: (ctx) => _hostCell(ctx),
            guestBuilder: (ctx, index) {
              // Positional, never compacted: cell `index` IS seat `index`. Matching
              // by position is what lets a viewer ask for one specific seat and land
              // in it.
              // No package:collection helper — the kit stays dependency-light, and
              // a missing seat is a real case (the list is sized at connect).
              SeatState? seat;
              for (final s in seats) {
                if (s.index == index) {
                  seat = s;
                  break;
                }
              }

              if (seat == null || !seat.isOccupied) {
                final target = seat;
                return UTDEmptySeatCell(
                  onTap: onEmptySlotTap == null || target == null
                      ? null
                      : () => onEmptySlotTap!(ctx, target),
                );
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _guestTile(ctx, seat),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Ceiling on how much of the screen the seat block may occupy.
  ///
  /// A 4-seat grid is naturally as tall as it is wide, which on a phone is
  /// close to half the screen and leaves the chat a sliver. Kept as a named
  /// constant because it is a product judgement, not a geometric one.
  static const double gridMaxHeightFraction = 0.36;

  Widget _gridBackdrop() => const ColoredBox(color: Color(0xFF14141A));

  /// The host inside a grid cell — tile-sized, unlike the full-bleed variant.
  Widget _hostCell(BuildContext context) {
    if (config.hostTileBuilder != null) return config.hostTileBuilder!(context);

    final isLocal = roomOwnerId == controller.localIdentity;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: UTDLiveTile(
        key: ValueKey('live-host-cell-$roomOwnerId'),
        displayName: _nameOf(roomOwnerId, null),
        avatarUrl: _avatarOf(roomOwnerId, null),
        track: controller.cameraTrackFor(roomOwnerId),
        isCameraOn: controller.cameraOnFor(roomOwnerId),
        isMicMuted: _micMuted(roomOwnerId),
        isSpeaking: controller.activeSpeakers.value.contains(roomOwnerId),
        fit: config.hostFit,
        mirrorMode: (isLocal && config.mirrorLocalVideo)
            ? VideoViewMirrorMode.auto
            : VideoViewMirrorMode.off,
        theme: config.theme,
        avatarRadius: 30,
        borderRadius: BorderRadius.circular(12),
        showRoleBadge: false,
        showSpeakingBorder: false,
      ),
    );
  }

  // ── Host (full-bleed) ──

  Widget _hostTile(BuildContext context) {
    if (config.hostTileBuilder != null) return config.hostTileBuilder!(context);

    final isLocal = roomOwnerId == controller.localIdentity;
    return UTDLiveTile(
      key: ValueKey('live-tile-$roomOwnerId'),
      displayName: _nameOf(roomOwnerId, null),
      avatarUrl: _avatarOf(roomOwnerId, null),
      track: controller.cameraTrackFor(roomOwnerId),
      isCameraOn: controller.cameraOnFor(roomOwnerId),
      isMicMuted: _micMuted(roomOwnerId),
      isSpeaking: controller.activeSpeakers.value.contains(roomOwnerId),
      // Camera-off: keep the host avatar in the upper third, clear of the chat.
      avatarAlignment: const Alignment(0, -0.45),
      fit: config.hostFit,
      mirrorMode: (isLocal && config.mirrorLocalVideo)
          ? VideoViewMirrorMode.auto
          : VideoViewMirrorMode.off,
      theme: config.theme,
      // Full-screen host: a larger camera-off avatar reads better than the
      // default tile-sized one.
      avatarRadius: 64,
      showRoleBadge: false,
      showSpeakingBorder: false,
    );
  }

  // ── Empty guest slot ──

  /// An unfilled guest slot: a dashed-looking outline with a plus, matching the
  /// occupied tiles' footprint exactly so the strip does not reflow when a
  /// guest joins or leaves.
  Widget _emptySlot(BuildContext context, SeatState seat) {
    final tap = onEmptySlotTap;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: tap == null ? null : () => tap(context, seat),
      child: Container(
        decoration: BoxDecoration(
          // Deliberately translucent rather than a solid panel: the host's
          // camera is the background and an opaque block would read as a dead
          // area of the screen.
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              // The slot number, so "3 Seats" is visibly three slots.
              '${seat.index}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                // Readable over any camera feed.
                shadows: const [Shadow(blurRadius: 3, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Guests (floating squares) ──

  Widget _guestTile(BuildContext context, SeatState seat) {
    if (config.guestTileBuilder != null) {
      return config.guestTileBuilder!(context, seat.index);
    }
    final id = seat.occupantUserId!;
    final isLocal = id == controller.localIdentity;
    final tile = UTDLiveTile(
      key: ValueKey('live-tile-$id'),
      displayName: _nameOf(id, seat),
      avatarUrl: _avatarOf(id, seat),
      track: controller.cameraTrackFor(id),
      isCameraOn: controller.cameraOnFor(id),
      isMicMuted: _micMuted(id),
      isSpeaking: controller.activeSpeakers.value.contains(id),
      role: controller.participantRolesNotifier.value[id],
      fit: config.guestFit,
      mirrorMode: (isLocal && config.mirrorLocalVideo)
          ? VideoViewMirrorMode.auto
          : VideoViewMirrorMode.off,
      theme: config.theme,
      avatarRadius: 28,
      borderRadius: BorderRadius.circular(12),
      onTap:
          onGuestTileTap == null ? null : () => onGuestTileTap!(context, seat),
    );
    final footer = config.guestTileFooterBuilder?.call(context, id);
    if (footer == null) return tile;
    return Stack(
      children: [
        Positioned.fill(child: tile),
        Positioned(left: 0, right: 0, bottom: 0, child: footer),
      ],
    );
  }

  // ── Resolution helpers ──

  bool _micMuted(String identity) =>
      controller.mutedParticipants.value.contains(identity);

  Participant? _participant(String identity) {
    final lp = controller.roomManager.localParticipant;
    if (lp?.identity == identity) return lp;
    return controller.roomManager.remoteParticipants
        .where((p) => p.identity == identity)
        .firstOrNull;
  }

  String _nameOf(String identity, SeatState? seat) {
    final p = _participant(identity);
    // Live participant attributes are authoritative for cosmetics (name): they
    // carry a mid-session change (Profile edit) that the `_seats` snapshot, built
    // at the last seat mutation, would otherwise render stale. Fall back to the
    // seat snapshot, then the participant name, then the identity.
    final name = (_liveAttr(identity, p, 'name')?.isNotEmpty == true
            ? _liveAttr(identity, p, 'name')
            : null) ??
        seat?.attributes['name'] ??
        seat?.attributes['cn'] ??
        (p?.name.isNotEmpty == true ? p!.name : null) ??
        identity;
    return name.isEmpty ? identity : name;
  }

  String? _avatarOf(String identity, SeatState? seat) {
    final p = _participant(identity);
    // Prefer the live participant attribute so a mid-session avatar change
    // repaints without a seat mutation; fall back to the seat snapshot.
    final live = _liveAttr(identity, p, 'avatar');
    final url =
        (live != null && live.isNotEmpty) ? live : seat?.attributes['avatar'];
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// Reads a live cosmetic attribute for [identity], overlaying the local user's
  /// mid-session overrides that have not yet echoed back into
  /// `localParticipant.attributes` (see
  /// [UTDSeatController.localCosmeticOverrides]). For remote participants this is
  /// just `p.attributes[key]`.
  String? _liveAttr(String identity, Participant? p, String key) {
    final localId = controller.roomManager.localParticipant?.identity;
    if (identity == localId) {
      final override = controller.seatController.localCosmeticOverrides[key];
      if (override != null && override.isNotEmpty) return override;
    }
    return p?.attributes[key];
  }
}
