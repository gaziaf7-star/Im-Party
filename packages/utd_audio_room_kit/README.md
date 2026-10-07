# UTD Audio Room Kit

A Flutter package for building live audio-room experiences, powered by a real-time audio engine and the UTD Stream Engine. It is a drop-in prebuilt live-audio-room solution: give it the required data and you get a fully interactive room — seats, chat, mic/speaker controls, seat actions, member list, speak requests, and moderation — with **no extra UI code**.

## Features

- **Drop-in room UI** — a complete, interactive room from required data alone.
- **Seat management** — take, leave, switch, lock, unlock, kick, mute, swap.
- **Built-in seat actions** — tap a seat to take/leave it; host/admin get a moderation sheet (mute, kick, lock, invite).
- **Speak requests** — audience apply-to-speak; host approve/reject queue with a live badge.
- **Member list** — participants with host actions (mute, kick, invite, ban, promote/demote).
- **Media controls** — microphone & speaker with reactive state (Bluetooth-preferring routing).
- **Real-time chat** — data-channel messages with batching and dedup.
- **Reconnection** — tiered: light sync (<15s), full sync (<60s), default force-exit (>60s).
- **Minimize / PiP** — minimize to a floating overlay; optional Android OS Picture-in-Picture.
- **Theming & i18n** — `UTDRoomTheme` (colors) + `UTDRoomStrings` (EN/AR built in) without replacing widgets.
- **Full customization** — replace any section (header, messages, controls, background, seats) with your own widgets.

## Installation

```yaml
dependencies:
  utd_audio_room_kit:
    path: packages/utd_audio_room_kit
```

### Platform setup

**iOS** — add to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Required for audio room participation</string>
```

For background audio + PiP, enable **Background Modes → Audio, AirPlay, and Picture in Picture** in Xcode.

**Android** — add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

Set `minSdkVersion` to at least **21** (31+ for OS PiP).

## Credentials — pass your `appKey` (no backend required)

> Ship `appId` + `appKey` (the project's **publishable app key**, from the UTD console). The kit
> mints tokens directly from the engine with `X-App-Key`; the engine signs the returned per-user
> `user_token` with the project `server_secret` **server-side**, so the secret never ships in the
> app. The kit then uses that `user_token` as the `Authorization: Bearer` for all in-room calls.
> No token server to stand up.

`appKey` is **not** the `server_secret`: it can't sign tokens or call the server-to-server API, and
it can be rotated on its own from the console. Treat a leak as a project-scoped incident (rotate +
ship a new build).

> **Type-first engine.** The engine groups products by a per-request `type`, not by credential —
> one `appId`/`appKey` works for every type enabled on the project. This kit always mints
> `type: 'audio_room'` on `POST /api/v1/token`; the project just needs **`audio_room`** in its
> enabled types (set per project in the UTD console). The seat model below is the `audio_room`
> model — unchanged. (Live video broadcasts are a separate `live_stream` type served by the
> standalone live kit; this package does not use it.)

## Quick start (drop-in, no backend)

```dart
import 'package:utd_audio_room_kit/utd_audio_room_kit.dart';

UTDAudioRoom(
  appId: '<utd-app-id>',
  appKey: '<utd-app-key>', // publishable; the kit mints tokens itself, no backend needed
  userId: 'user123',
  userName: 'John Doe',
  roomId: 'room456',
  roomOwnerId: 'owner789', // userId == roomOwnerId ⇒ this user is the host
);
```

With only this, the package renders: a dark background, the seat grid (avatars + names),
a header (minimize + exit), the chat list, and a role-aware controls bar. Tapping a seat
takes/leaves it; audience can apply to speak; host/admin get member-list, the speak-request
queue, and per-seat moderation. A connect failure shows an error + retry instead of an
endless spinner.

> The host is detected as `userId == roomOwnerId`; identities in `adminIds` are treated as
> admins. By default a host/admin joins mic-on (`autoHostMic`) and is auto-seated on
> `hostSeatIndex` if the backend didn't seat them (`autoSeatHost`).

## Fast first join (recommended)

The room body and seats render as soon as the **token** arrives — the RTC connection
finishes in the background. That makes the token round trip the only thing standing
between the tap and a populated room, so two one-time integrations make the FIRST
entrance of a session as fast as every later one:

**1. Warm up when a join becomes likely** (e.g. the rooms lobby opens). The very first
request of a process otherwise pays DNS + TLS to the token host inline (~100–300 ms on
mobile networks), plus cold device caches:

```dart
// Fire-and-forget; safe to call repeatedly (everything is cached).
UTDRoomController.warmUp();
```

**2. Prefetch the token at tap time**, so the round trip overlaps the route navigation
instead of starting after the room screen mounts:

```dart
final controller = UTDRoomController()
  ..initApi(appId: appId, appKey: appKey)
  ..registerModes(myModes);
final isHost = userId == roomOwnerId;
final seatParams = UTDAudioRoom.resolveTokenSeatParams(
    layoutMode: layoutMode, isHost: isHost, modes: myModes);
final tokenFuture = controller.generateToken(
  identity: userId, roomName: roomId, roomOwnerId: roomOwnerId,
  role: isHost ? 'host' : 'audience', name: userName,
  seatCount: seatParams.seatCount, seatMode: seatParams.seatMode,
  hostSeat: seatParams.hostSeat, modeId: seatParams.modeId,
);
// ...navigate, then pass BOTH to the widget:
UTDAudioRoom(
  // ...,
  controller: controller,
  tokenProvider: () => tokenFuture,
);
```

Avatars are disk-cached after the first download, so only a fresh install pays for
them once. Serve resized CDN thumbnails (e.g. `?w=128`) in the avatar URLs — the kit
caps the *decode* size but cannot shrink the bytes on the wire.

## Constructor

| Param | Required | Description |
|---|---|---|
| `appId` | ✅ | UTD Stream Engine app id (public identifier, safe to ship) |
| `appKey` | ✅ | Publishable app key — the kit mints tokens directly from the engine (no backend). |
| `userId` | ✅ | Local user identity |
| `userName` | ✅ | Display name |
| `roomId` | ✅ | Room to join/create |
| `roomOwnerId` | ✅ | Owner identity (host detection + owner-only actions) |
| `adminIds` | – | Identities to request the `admin` role for |
| `layoutMode` | – | Mode id to use (default `'3'` = 9 seats); see **Layout modes** |
| `modes` | – | Custom `UTDRoomMode`s to register |
| `config` | – | `UTDAudioRoomConfig` (see below) |
| `controller` | – | Reuse an existing `UTDRoomController` (e.g. after minimize) |
| `onControllerReady` | – | Get the controller (wire `navigatorKey`, minimize, etc.) |
| `onConnectionChanged` | – | `(bool isConnected)` |
| `onSeatTap` | – | Override the built-in seat action sheet |
| `onSeatChanged` | – | `(List<SeatState> seats)` |
| `onConnectError` | – | Override the built-in connect-error view |

## Configuration (`UTDAudioRoomConfig`)

```dart
UTDAudioRoom(
  // …required data…
  config: UTDAudioRoomConfig(
    // behavior
    showControlsBar: true,
    showSeatNames: true,        // render occupant names under seats
    enableMinimize: true,
    turnOnMicrophoneWhenJoining: false,
    useSpeakerWhenJoining: true,
    hostSeatIndex: 0,
    autoHostMic: true,          // host/admin joins mic-on
    autoSeatHost: true,         // host auto-takes hostSeatIndex if empty
    useDefaultBackground: true, // paints theme.background when no backgroundWidget

    // theming & strings
    theme: UTDRoomTheme(),                 // or UTDRoomTheme().copyWith(primary: …)
    strings: UTDRoomStrings.ar(),          // null ⇒ English

    // user attributes shared with others (name/avatar are read on seats)
    userInRoomAttributes: {'avatar': 'https://…', 'name': 'John'},

    // section overrides (null ⇒ built-in default)
    headerWidget: null,
    messagesWidget: null,
    controlsBarWidget: null,
    backgroundWidget: null,
    foregroundWidget: null,
    pkWidget: null,

    // seat builders (null ⇒ built-in default avatar/name)
    seatBuilder: null,
    avatarBuilder: null,
    emptySeatBuilder: null,
    lockedSeatBuilder: null,
  ),
);
```

Every built-in default is **off when you override it** — supplying a `controlsBarWidget`,
`avatarBuilder`, `onSeatTap`, etc. fully replaces the corresponding default.

## Theming & localization

`UTDRoomTheme` is an all-defaulted color set (dark by default, so the white default content
is never invisible). `UTDRoomStrings.en()` / `.ar()` cover every default label; pass your own
`UTDRoomStrings(...)` to translate or relabel:

```dart
config: UTDAudioRoomConfig(
  theme: const UTDRoomTheme().copyWith(primary: Colors.teal, background: const Color(0xFF101010)),
  strings: UTDRoomStrings.ar(),
);
```

## Controller API

`onControllerReady` gives you a `UTDRoomController` for programmatic control:

```dart
final c = controller;

// Seats
await c.seatController.takeSeat(0, c.localIdentity!);
await c.seatController.leaveSeat(c.localIdentity!);
await c.seatController.lockSeat(2, identity: c.localIdentity!);

// Speak requests
await c.requestToSpeak();
await c.approveSpeakerRequest(requestId);
await c.inviteToSpeak(targetId, seatIndex: 3);

// Roles & bans (gated server-side)
await c.changeRole(targetIdentity: id, role: 'admin'); // OWNER-only (403 otherwise)
await c.banUser(id, reason: '…');                      // host/admin-gated

// Media
await c.mediaController.toggleMicrophone();

// Reactive state
c.seatController.seats;            // ValueNotifier<List<SeatState>>
c.seatController.pendingRequests;  // ValueNotifier<List<SpeakerRequest>>
c.activeSpeakers;                  // ValueNotifier<Set<String>>
c.participantsStream;             // Stream<List<UTDParticipant>>
```

## Minimize / PiP

Wrap your app with `UTDMiniPopScope` and mount `UTDMiniOverlayPage` at the root, then
configure minimize in `onControllerReady`:

```dart
onControllerReady: (controller) {
  controller.navigatorKey = navKey; // for default dialogs
  controller.minimize.configure(
    UTDMinimizeConfig(
      enableOSPip: true,
      onClose: () => myExitRoom(),
    ),
  );
},
```

## Layout modes

The package ships one default mode (`id: '3'`, 9 seats, 3×3). Register custom layouts via
`modes` and select with `layoutMode`:

```dart
UTDAudioRoom(
  layoutMode: 'party',
  modes: const [
    UTDRoomMode(id: 'party', seatCount: 8, rows: [[0,1,2,3],[4,5,6,7]]),
  ],
);
```

## Architecture

```
UTDRoomController
├── (real-time engine) — connection & lifecycle (internal)
├── UTDSeatController  — seat state (ValueNotifier) + speak requests
├── UTDMediaController — mic / speaker
├── UTDChatController  — data-channel chat
└── UTDMinimizeController / UTDPipController
```

All state is exposed via `ValueNotifier`/`Stream`, so it integrates with any state-management
approach. See the **Quick start** snippet above for a minimal drop-in app.
