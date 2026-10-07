# UTD Live Room Kit

A Flutter package for building **video live-room** experiences, powered by
[LiveKit](https://livekit.io/) and the UTD Stream Engine. It puts a host camera
on a full-bleed **stage** with up to **3 invited co-publisher tiles** —
give it the required data and you get a fully interactive live room with **no
extra UI code**.

The engine treats a live room as the `live_stream` product type: an **unbounded,
seatless stage**. There is no seat grid and no participant cap — anyone can
watch. The host invites co-publishers onto the stage (audio/video publish),
while the room **owner** promotes moderators. The kit only caps how many guest
*tiles* it draws ([`maxGuestTiles`](#config), default 3); the engine itself is
uncapped.

> **Roles are server-authoritative.** Only the verified room owner joins as the
> publishing `host`; **everyone else joins as `audience`** (watch + chat). The
> engine clamps any non-owner's claimed role to `audience` — a client cannot
> self-grant publish or moderation. Publishing and moderation are **decoupled**:
> being added to the stage grants publish only; being promoted to `admin` grants
> moderation only (admins are never on camera).

## Features

- **Drop-in live-room UI** — host camera + up to 3 co-publisher video tiles from
  required data alone.
- **Stage flow** — the host invites viewers onto the stage to co-publish;
  viewers raise-hand (`stage/request`) and the host adds them. No server-side
  queue — a request is a transient `_stage_request` notification to host/admins.
- **Owner-promoted moderators** — the owner promotes configured `adminIds` to
  `admin` (moderate-only, **not** on camera) via the engine role endpoint.
- **Host force-control** — host can mute/unmute or stop a co-publisher's
  camera/mic, and remove them from the stage.
- **Media controls** — microphone & camera with reactive state
  (Bluetooth-preferring audio routing).
- **Real-time chat** — data-channel messages with batching and dedup.
- **Reconnection** — tiered: light sync (<15s), full sync (<60s), default
  force-exit (>60s).
- **Minimize / PiP** — minimize to a floating overlay; optional Android OS
  Picture-in-Picture.
- **Video effects** — pairs with
  [`utd_video_effects_kit`](https://pub.dev/packages/utd_video_effects_kit) via
  `UTDLiveRoomConfig.buildVideoProcessor` (a LiveKit `TrackProcessor`) for live
  filters & beauty effects.

## Getting started

Add the dependency:

```yaml
dependencies:
  utd_live_room_kit: ^1.4.0
```

### Credentials — pass your `appKey` (no backend required)

> Ship `appId` + `appKey` (the project's **publishable app key**, from the UTD console). The kit
> mints tokens directly from the engine with `X-App-Key`; the engine signs the returned per-user
> `user_token` with the project `server_secret` **server-side**, so the secret never ships in the
> app. The kit uses that `user_token` as the `Authorization: Bearer` for all in-room calls. No
> token server to stand up. `appKey` can't sign tokens or call the S2S API and rotates on its own.

```dart
import 'package:utd_live_room_kit/utd_live_room_kit.dart';

UTDLiveRoom(
  appId: '<utd-app-id>',
  appKey: '<utd-app-key>', // publishable; the kit mints tokens itself, no backend needed
  userId: 'user123',
  userName: 'Jane',
  roomId: 'room456',
  roomOwnerId: 'owner789',
  // Identities the OWNER will promote to `admin` (moderators) once they join.
  // Optional. The engine clamps non-owners to `audience`, so these are only
  // honored because the owner promotes them server-side after join.
  adminIds: const {'mod1', 'mod2'},
  config: const UTDLiveRoomConfig(maxGuestTiles: 3),
);
```

> **The live room is `type: live_stream`.** The kit mints its token with
> `type: live_stream` and sends **no** seat parameters (`seat_count`,
> `seat_mode`, `host_seat` are ignored for a live stream — the room is uncapped).
> The project must have `live_stream` in its `enabled_types` in the UTD console,
> otherwise `POST /api/v1/token` returns `403 "Type 'live_stream' is not
> enabled for this project"`. The same `appId` / `appKey` works for every product type the project
> has enabled — the type is a per-request field, not a separate credential.

See the exported API in
[`lib/utd_live_room_kit.dart`](lib/utd_live_room_kit.dart) — `UTDLiveRoom`,
`UTDRoomController`, `UTDStageApi`, `UTDMediaController`, `UTDChatController`, and
the room/role/participant models.

## Stage & roles

A live room has four server-authoritative roles:

| Role | Publishes | Moderates | How you get it |
| --- | --- | --- | --- |
| `host` | ✅ | ✅ | The verified room owner (`userId == roomOwnerId`). Force-upgraded by the engine. |
| `guest` | ✅ | ❌ | Host/admin invites you onto the stage. |
| `admin` | ❌ | ✅ | The **owner** promotes you (moderate-only, never on camera). |
| `audience` | ❌ | ❌ | Default for everyone non-owner — watch + chat. |

**Going on stage (co-publish).** A viewer raises their hand
(`POST /api/v1/rooms/:name/stage/request`), which fires a transient
`_stage_request` data message to the host/admins (there is no persisted queue).
A host/admin then adds them (`.../stage/add` → role becomes `guest`, publish
granted). Removal (`.../stage/remove`) or self step-down (`.../stage/leave`)
sends them back to `audience`. The current publisher set is
`GET /api/v1/rooms/:name/stage` → `{ members: [{ identity, name, role }] }`, and
roster changes broadcast a `_stage_update` data message. These endpoints are
`live_stream`-only (a seated room returns `400`).

The kit surfaces the stage through `UTDRoomController` — `inviteToSpeak`,
`requestToSpeak`, `approveSpeakerRequest`, `rejectSpeakerRequest` — and the raw
endpoints via `controller.stageApi` ([`UTDStageApi`](lib/src/api/stage_api.dart)).

**Promoting a moderator.** Moderation uses the **owner-only** role endpoint
`PUT /api/v1/rooms/:name/participants/:identity/role` with `{ role: 'admin' }`.
The kit does this for you: pass [`adminIds`](#config) (or `adminIdsResolver` /
`adminIdsNow`), and the host client promotes those identities as they join via
`controller.changeRole`. In a stage room this grants moderation but **not**
publish, and the engine **refuses (`409`)** an attempt to add an `admin` to the
stage — the two capabilities stay disjoint.

> **`maxGuestTiles` is a UI-only cap.** It sizes the on-screen tile strip
> (host + N co-publishers); the engine stage itself is unbounded. There is **no
> seat grid** — the host video is the full-bleed background and co-publishers are
> floating tiles above it.

## Config

`UTDLiveRoomConfig` controls the live experience. Notable fields:

- `maxGuestTiles` (default `3`) — how many co-publisher tiles to draw (UI cap
  only; the engine is uncapped).
- `autoHostCamera` (default `false`) — publish on connect vs. self-preview →
  "Go Live".
- `showGoLiveButton` (default `true`) — render the built-in "Go Live" button
  during host preview, or let the app drive `UTDMediaController.goLive`.
- `frontCameraOnJoin` / `mirrorLocalVideo` / `hostFit` / `guestFit` — camera &
  video-fit options.
- `videoQuality` (default `UTDVideoQuality.hd`, 720p) — the video publish
  quality for the local camera (capture resolution + publish bitrate/framerate).
  Tiers: `low` (360p ~450 kbps), `sd` (540p ~800 kbps), `hd` (720p ~1.7 Mbps),
  `fullHd` (1080p ~3 Mbps). Applied at connect; also settable headlessly via
  `UTDRoomController.setVideoQuality` before `connect`.
- `buildVideoProcessor` — a LiveKit `TrackProcessor` factory for live filters &
  beauty effects (pairs with `utd_video_effects_kit`).
- Section/tile overrides — `headerWidget`, `messagesWidget`, `controlsBarWidget`,
  `hostTileBuilder`, `guestTileBuilder`, `guestTileFooterBuilder`, `onStageTap`.

## Requirements

- A LiveKit server + UTD Stream Engine token endpoint, with `live_stream` in the
  project's `enabled_types`.
- Camera & microphone runtime permissions (handled via `permission_handler`).
