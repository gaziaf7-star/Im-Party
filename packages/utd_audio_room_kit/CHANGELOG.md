# Changelog

## 1.10.3

Fix — the local user's OWN seat did not repaint on a mid-session cosmetic change.

- `LocalParticipant.setAttributes` (livekit_client) only sends the change to the
  SFU and awaits an ack; it does **not** update `localParticipant.attributes`,
  and the server does not necessarily echo a participant update back to the
  sender. So after `updateSelfAttributes`, `_withLiveAttributes` re-read the
  still-stale local attribute map and the user's own seat kept the old
  avatar/frame until they rejoined (a rejoin reads the fresh backend `_seats`).
- New `UTDSeatController.applyLocalCosmeticOverride(identity, attrs)`, called from
  `updateSelfAttributes`, records the freshly published values in a
  `_localCosmeticOverrides` map and repaints the local seat immediately. The map
  is overlaid on the local participant in `_liveParticipantInfo`, so a subsequent
  `_seats` reapply cannot revert the seat to the stale published values. The
  eventual RTC echo (if any) is then a no-op. Cleared on dispose.

## 1.10.2

Live cosmetics update — additive and backward compatible.

### Mid-session avatar / frame changes

- New `UTDRoomController.updateSelfAttributes(Map<String, String>)` re-publishes
  the local participant's cosmetic attributes (avatar, frame, frame geometry,
  color name) after join. LiveKit fans the change to everyone in the room and to
  late joiners, so a user who changes their photo or equips a new frame updates
  on their seat — for themselves and others — without leaving and re-entering.
- `_withLiveAttributes` now treats **cosmetic keys as live-authoritative**: a
  non-empty live value wins over the (possibly stale) `_seats` snapshot, instead
  of only filling blanks. Non-cosmetic keys keep the previous backend-wins /
  fill-blanks-only behavior. Cosmetics are never server-moderated (the backend
  only reads them), so preferring the occupant's own latest published value is
  correct.
- The cosmetic key set is **not hardcoded** — it is derived at runtime from the
  exact keys the app publishes as the local participant's attributes (the
  `userInRoomAttributes` map at connect, plus every `updateSelfAttributes`
  delta), via the new `UTDSeatController.registerCosmeticKeys`. The app publishes
  only cosmetics as participant attributes, so the set can never drift from the
  app's own cosmetic definition, and new cosmetic keys need no kit change. Until
  the app registers any keys, the merge falls back to blank-fill-only (the
  original behavior).

## 1.10.1

Bugfix.

### Speaking ring

- `UTDSpeakingRing` no longer shrinks the avatar while the occupant is speaking.
  The pulsing ring previously insetting the child by its animating border width,
  so the seat image visibly shrank and pulsed smaller on every open mic. The ring
  now paints just OUTSIDE the avatar (`BorderSide.strokeAlignOutside`) and the
  avatar keeps a constant size. The default `UTDSeatWidget` occupied-seat `Stack`
  is now `Clip.none` so the outward ring/glow isn't clipped.

## 1.10.0

Dev-tunable seat sizing, snappier minimized overlays, and a polished pre-connect
state. All additive and backward compatible — apps that pass nothing are unaffected.

### Seat layout

- New `UTDSeatLayout` (`avatarRatio`, `rowPadding`, `rowSpacing`, `seatScale`), passed
  via `UTDAudioRoomConfig.seatLayout`. The mounted room publishes it to a shared source
  so every seat-size consumer (grid, skeleton, `computeSeatSize` call sites, and the
  app-side metrics) reads the same values and can't drift. Defaults reproduce the
  original look; the 52–120px safety clamp still applies as a hard rail.

### Minimized overlay & PiP

- Speaking state is now event-driven off `activeSpeakers` instead of a 1s polling
  `Timer` — the ring reacts instantly and nothing ticks while the room is silent.
- Wave animations run only while someone is speaking, so a silent minimized session
  holds zero per-frame animation work.
- Overlay bubble snaps to the nearest edge on release (with flick support), clamps
  clear of system chrome so it can't tuck behind the notch/home indicator, lifts on
  grab, and adds haptic feedback on drag/restore/close/mic actions.

### Connecting state

- The static pre-connect placeholder is now a gently breathing skeleton driven by a
  single shared `AnimationController`, wrapped in a `RepaintBoundary`, torn down the
  instant the real room paints, and honoring reduce-motion.

## 1.9.0

Room renders at **token receipt** — occupied seats with names and avatars appear roughly
one token round trip after the tap, instead of waiting for the full RTC connection
(WSS + ICE/DTLS). On a prefetched token the room is effectively instant.

### Rendering

- The room body (seats, chat, controls) now paints as soon as the token response arrives
  (`_tokenReady`). The grey skeleton only gates the ban check (token POST 403), not the
  entire RTC establishment. A connect failure drops back to the skeleton/error view.
- Seats are seeded pre-connect via `UTDRoomController.primeSeats`: newer engines embed a
  `seats` snapshot in the token response (zero extra round trips); against older engines
  the kit fires `GET /seats` in parallel with the RTC dial.
- Seat mutations (take/move) are gated on connection state so a tap during the pre-connect
  window cannot create ghost occupants.

### Avatars

- `UTDDefaultAvatar` now uses `cached_network_image` (disk cache) — avatars download once
  per install, not once per session. Keyed by occupant so a seat that changes hands shows
  the new person's initials, not the old photo.
- `MediaQuery.devicePixelRatioOf` replaces the full `MediaQuery.of` to avoid rebuilding
  every avatar on each keyboard-inset animation frame.

### Seat updates

- Seat mutation responses from newer engines carry the synced seat `state` inline; the kit
  applies it immediately (`applyMutationResponse`, generation- and room-guarded) so the
  actor sees changes without waiting for the `_seat_update` broadcast round trip.
- Blank occupant name/avatar self-heals from the occupant's live RTC participant attributes
  (`_withLiveAttributes` + a `participantAttributesChanged` repair listener). The per-key
  merge never un-fills existing attributes.
- The preservation guard treats an all-empty-string attribute map (server enrichment
  failure) as effectively empty, so it no longer blocks the live-attribute fill.

### Host join

- `audioSetup()` (mic capture, Bluetooth routing, setAttributes) now runs unawaited for
  **all** joins, including hosts with `turnOnMicrophoneWhenJoining`. The ordering is
  internal to the closure; the mic permission dialog now appears over the rendered room
  instead of behind a skeleton. The `_opEpoch`/`cancelPendingPublish` machinery handles
  a `leave()` during setup.
- Same-instance reconnect (`connect()` re-dial) now drains pending mic publishes before
  disconnecting, closing the `addTransceiver` track-is-null window.
- Device-info collection is bounded at 150 ms; a timeout sends nulls (the engine treats
  all device fields as optional). `deviceId` stays fully awaited (single-session enforcement).

### Reliability

- Inter-attempt teardown in the retry loop is bounded at 2 s (was unbounded — the SDK's
  disconnect can block ~10 s per attempt on a half-dead link).
- `connectTimeout` raised 15 s → 25 s (deadlock backstop aligned with the SDK's 3 × 7 s
  internal phase budget). The reconnection handler's force-exit is suspended during a
  kit-driven connect so it cannot fire mid-retry.

### Jank cluster

- Payload `debugPrint`s (data messages, seat metadata) gated to `kDebugMode`.
- The seat grid binds `participantRolesNotifier` (cached, updated on participant/role
  changes) instead of the `participantRoles` getter that jsonDecodes every participant's
  metadata on every rebuild.
- `MediaQuery.sizeOf` / `devicePixelRatioOf` replace `MediaQuery.of` in the seat grid,
  skeleton, seat widget, and avatar — eliminates full-subtree rebuilds on keyboard frames.
- `UTDSpeakingRing` keeps a structure-stable widget tree (AnimatedBuilder → SizedBox →
  DecoratedBox → Padding → child always), so the avatar subtree is never torn down and
  re-inflated on speaking transitions.

### README

- New "Fast first join" section documenting `warmUp()` and the tap-time token prefetch
  pattern for apps that want the first entrance to be as fast as every later one.

## 1.8.0

Faster room entry — every serial cost on the join path was removed, overlapped, or cached:

- HTTP transport is now process-shared and survives room exit → re-entry, so rejoins reuse the
  warm TLS connection to the engine instead of paying a fresh DNS+TCP+TLS handshake per join
  (~60–200ms on mobile). `UTDApiClient.dispose()` no longer closes the shared transport.
- The token host's TLS connection and the device-id/device-info caches are warmed
  fire-and-forget at `initApi()` time, off the join's critical path.
- New `UTDRoomController.warmUp()` (static): apps can call it when a room entry becomes likely
  (e.g. the lobby screen opens) to pre-open the token-host connection, heat the device caches,
  and pre-warm DNS/TLS to the RTC edge — making the subsequent join near-handshake-free.
- The RTC edge URL from each successful join is remembered (memory + SharedPreferences) and the
  next join pre-warms DNS/TLS to it in parallel with its token request, so the WSS dial resumes
  a TLS session instead of running a cold handshake (~30–150ms).
- Device-id and device-info lookups now run concurrently (and package/device platform channels
  inside the collector too), with in-flight memoization — a cold first join pays one platform
  hop instead of three.
- On a room switch, the previous room's teardown starts as soon as the new join begins and
  overlaps the token round trip instead of serializing ahead of the RTC dial (~50–300ms on
  switches). Note: the old room now starts closing even if the new join later fails.
- Flaky-network joins fail over faster: the SDK's signal phases are bounded at 7s (was 10s
  default, racing the kit's own 15s outer timeout), and the retry delay dropped 500ms → 200ms.

## 1.7.0

- Internalized the real-time transport layer so it is no longer part of the public API. The
  low-level engine handle (`UTDRoomManager`) is no longer exported, and `UTDRoomController.roomManager`
  is now private. Consumers use the neutral surface — `UTDAudioRoom`, `UTDRoomController`, and the
  seat/media/chat controllers — none of which expose transport-specific types. `UTDConnectionState`
  moved to its own file but is still exported unchanged.
- **Breaking (advanced API only):** code that reached `controller.roomManager` or the raw engine
  handle must migrate to the controller's public getters (e.g. `localIdentity`, `connectionState`,
  `isConnected`). The standard widget/controller usage is unaffected.

## 1.6.1

- Distinguish a not-activated service from a ban on the token endpoint. A non-ban `403`
  (e.g. `Type 'audio_room' is not enabled for this project`) now throws the new
  `UTDServiceNotAvailableException` instead of `UTDBannedException`.
- The built-in connect-error view shows a distinct "not available" message and hides Retry
  for that refusal (retrying can't help). When the host supplies no `onConnectError`,
  `UTDAudioRoom` now falls back to this error view instead of an endless connecting skeleton.
  Adds `UTDRoomStrings.serviceNotAvailable` (EN + AR).

## 1.6.0

- Auto-collect device facts for the dashboard's per-participant view. `UTDRoomController.generateToken`
  now populates `device_model` / `os` / `os_version` / `app_version` automatically (via
  `device_info_plus` + `package_info_plus`) when the host app doesn't pass them. Explicit arguments
  still win, collection is cached per process, and it never throws — on an unsupported platform or a
  plugin failure each field degrades to `null` rather than blocking token issuance. Values are capped
  to the engine's column limits (device_model 100, os 50, os_version/app_version 20).
- `UTDRoomController.generateToken` / `UTDTokenApi.generateToken`: add an optional `imageUrl`, sent as
  `image` on `POST /api/v1/token` and shown as the participant's profile image in the dashboard.
- New direct dependencies: `device_info_plus: ^12.0.0` and `package_info_plus: ^8.0.0` (the former was
  already in the tree transitively via the real-time engine).
- **Minimum SDK raised** to Dart `>=3.7.0` / Flutter `>=3.29.0`, required by `device_info_plus ^12.0.0`.
  Hosts on older toolchains should stay on `1.5.0`.

## 1.5.0

- Type-first token request: the kit now sends `type: 'audio_room'` on `POST /api/v1/token`
  instead of the legacy `service: 'rooms'`. The engine is type-first — one `appId`/`appKey`
  serves every product type enabled on the project, and the type is a per-request field, not a
  credential. The project must have **`audio_room`** in its enabled types. **Seat behavior is
  unchanged** — `audio_room` keeps the full seat model (take/leave/switch/lock/unlock/kick/mute/swap,
  apply-to-speak, seat grid); only the token field changed.
- `UTDRoomController.generateToken` / `UTDTokenApi.generateToken`: the required `service` parameter
  is **removed** and replaced by an optional `type` (default `'audio_room'`). Drop-in users of the
  `UTDAudioRoom` widget are unaffected — it no longer passes `service` internally. Direct callers of
  `generateToken` should drop `service: 'rooms'`; the default already targets `audio_room`.
- Non-breaking on the engine side: the deployed engine still accepts the legacy
  `service`+`kind` fields and derives the canonical type, so older builds of this kit keep working
  against the same engine while apps migrate to this version at their own pace.

## 1.4.0

- No-backend credentials (recommended): pass `UTDAudioRoom(appKey: ...)` /
  `UTDRoomController.initApi(appKey: ...)` — the project's publishable **app key**. The kit
  mints tokens directly from the engine (`X-App-Key` on `POST /api/v1/token`), and the engine
  signs the returned per-user `user_token` with the project `server_secret` **server-side**, so
  the secret never ships in the app and no integrator backend is required. The kit applies that
  `user_token` as the `Authorization: Bearer` for all in-room/moderation calls (persisted across
  `initApi` re-inits, so it survives restore-from-minimize).
- **Removed** `tokenProvider` and its `UTDTokenProvider` / `UTDTokenRequest` / `UTDTokenBundle`
  types plus the `UTDRoomController.usesTokenProvider` getter (added in 1.3.0). The no-backend
  `appKey` flow replaces it — there is no longer a built-in path for integrators who run their own
  token backend.
- **Removed** `serverSecret` entirely (deprecated in 1.3.0). `UTDAudioRoom.serverSecret`,
  `UTDRoomController.initApi(serverSecret:)` / its `serverSecret` getter, and the
  `UTDApiClient(appSecret:)` param / `X-App-Secret` header are all gone. `appKey` is now the
  sole, **required** credential. Migrate any `serverSecret:` callsites to `appKey:`.
- A leaked `app_key` cannot forge bearers offline or call the server-to-server API, and rotates
  independently via the engine `regenerate-credentials` admin endpoint.

## 1.3.0

- Secure credentials via `tokenProvider` (recommended): a new
  `UTDAudioRoom(tokenProvider: ...)` / `UTDRoomController.initApi(tokenProvider: ...)`
  callback lets the integrator mint tokens from **their own backend**, so the project
  `serverSecret` never ships in the app. The kit calls the provider with a
  `UTDTokenRequest` (identity, room, service, room owner, device id) and consumes the
  returned `UTDTokenBundle` (`UTDTokenBundle.fromEngineJson` parses the engine
  `POST /api/v1/token` response verbatim). The per-user `user_token` from the bundle is
  applied as the `Authorization: Bearer` for all in-room/moderation REST calls, so actions
  are authenticated as the server-verified user. New exported API:
  `UTDTokenProvider`, `UTDTokenRequest`, `UTDTokenBundle`, plus
  `UTDRoomController.usesTokenProvider`. The role is intentionally **not** sent from the
  client in this mode — the integrator backend is the authority on the user's role.
- `serverSecret` is now **deprecated** and optional. `UTDAudioRoom.serverSecret` /
  `initApi(serverSecret:)` still work in legacy/dual mode (the kit keeps sending
  `X-App-Secret`), but embedding the secret in a shipped app lets anyone extract it and mint
  tokens for any identity/room — migrate to `tokenProvider`. `UTDAudioRoom` now asserts that
  exactly one of `tokenProvider` (recommended) or `serverSecret` (legacy) is provided.
- `UTDTokenResponse` gains a `userToken` field (engine `user_token`; empty on legacy
  responses) so the per-user bearer is surfaced through the normal token flow as well.
- README rewritten around the secure `tokenProvider` flow, with a backend-proxy example and
  an explicit "do not ship the secret" warning; the params table marks `appId` as a safe
  public identifier and `serverSecret` as deprecated/legacy.

## 1.2.0

- Comment lock: host/admin can now lock room chat so only host/admin may post.
  New `UTDCommentApi` (exported) wrapping the engine endpoints
  `POST /api/v1/rooms/{room}/comments/{lock,unlock}`, plus
  `UTDRoomController.lockComments()` / `unlockComments()` / `setCommentsLocked()`,
  the `commentsLocked` notifier and the `canIComment` getter. The lock is driven
  by the server (the `_chat_lock` broadcast + the `chat_locked` room-metadata
  field), never set optimistically, so it stays consistent across devices and is
  restored for late joiners on reconnect. Enforcement lives in both the send
  path (a hidden composer can't be bypassed) and the receive path (chat from
  non-privileged senders is dropped while locked, as a backstop against a
  tampered client). The default controls bar gains a host/admin lock toggle and
  swaps the audience chat button for a lock indicator while locked.
- Admin role announcements: a centered, dimmed room-chat system line is posted
  when a user gains or loses the `admin` role ("<name> became an admin" /
  "<name> was removed from admins"), driven by the broadcast `_role_change` so
  every client renders it identically with no extra network message.
- `UTDRoomController.strings` lets the host app's localized `UTDRoomStrings`
  back controller-emitted system lines; wired automatically from
  `UTDAudioRoomConfig`. New strings (English + Arabic defaults) for the
  comment-lock UI and the admin/lock announcements; existing direct
  `UTDRoomStrings` callers are unaffected (the new fields default to English).

## 1.1.0

- Split the API base URL by operation: token generation now uses the edge host
  `https://udt-stream.com` while all in-room operations (seats, speakers, bans,
  roles) use the grey-cloud engine host `https://engine.udt-stream.com`.
  `UTDApiClient.defaultBaseUrl` is now the engine host; the new
  `UTDApiClient.defaultTokenBaseUrl` is the token host. `initApi` gained a
  `tokenBaseUrl` parameter (defaulted) — existing callers need no change.
- Security (M2): the client no longer self-writes cosmetic fields (avatar, frame,
  color name) into RTC participant **metadata**. Cosmetics are published only
  as participant **attributes**; the server remains the sole owner of metadata
  (`role`, `_device`, …). This removes a client-trust surface where a peer could
  spoof `role`/VIP in broadcast metadata. No public API change — cosmetics still
  flow through `userAttributes`/`setAttributes`. Part of a coordinated rollout:
  the backend may then gate `canUpdateOwnMetadata` to privileged roles only.

## 1.0.1

- Update the default API base URL to `https://api.udt-stream.com`.

## 1.0.0

- Initial standalone release. Extracted from the Tempo-Live monorepo into its
  own package repository.
- Real-time audio room: a drop-in prebuilt live-audio-room solution.
- Seat management (take, leave, switch, lock, unlock, kick, mute, swap), built-in
  seat actions and moderation sheet, apply-to-speak request queue, member list
  with host actions, mic/speaker controls (Bluetooth-preferring routing).
- Real-time chat over the data channel (batching + dedup), tiered reconnection,
  minimize / Android OS Picture-in-Picture, 8 layout modes.
