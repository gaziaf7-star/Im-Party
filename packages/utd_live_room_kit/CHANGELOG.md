# Changelog

## 1.6.2

Fix — the local user's OWN tile did not repaint on a mid-session cosmetic change.

- `LocalParticipant.setAttributes` (livekit_client) only sends the change to the
  SFU and awaits an ack; it does **not** update `localParticipant.attributes`,
  and the server does not necessarily echo a participant update back to the
  sender. So after `updateSelfAttributes`, `live_stage`'s `_avatarOf`/`_nameOf`
  re-read the still-stale local attribute map and the user's own tile kept the
  old avatar/name until they rejoined.
- New `UTDSeatController.applyLocalCosmeticOverride(attrs)`, called from
  `updateSelfAttributes`, records the freshly published values in
  `localCosmeticOverrides` and re-emits `seats` so the stage rebuilds. The stage
  helpers now overlay these overrides for the local identity, so the local tile
  repaints immediately. Cleared on dispose.

## 1.6.1

Live cosmetics update — additive and backward compatible.

- New `UTDRoomController.updateSelfAttributes(Map<String, String>)` re-publishes
  the local participant's cosmetic attributes (avatar, name, …) after join.
  LiveKit fans the change to everyone in the room and to late joiners, so a user
  who changes their photo mid-session updates on their host/guest tile — for
  themselves and others — without leaving and re-entering.
- `UTDLiveStage` now resolves the tile avatar and name from the live participant
  attributes first, falling back to the `_seats` snapshot. The snapshot is built
  at the last seat mutation and would otherwise render a mid-session change
  stale.

## 1.6.0

- **Developer-controlled video publish quality.** New `UTDVideoQuality` enum
  (`low` 360p / `sd` 540p / `hd` 720p / `fullHd` 1080p) exposed as
  `UTDLiveRoomConfig.videoQuality` and `UTDRoomController.setVideoQuality`
  (call before `connect`). The tier drives BOTH the camera capture resolution
  and the publish encoding (`defaultVideoPublishOptions.videoEncoding` +
  simulcast layers) for every local camera path: host self-preview → Go Live,
  guest go-live, `setCameraEnabled`, and reconnect re-publish. Default is
  **HD (720p)** — unchanged capture behavior, but the publish bitrate is now
  pinned to the tier (~1.7 Mbps for HD) instead of LiveKit's derived default.

## 1.5.1

- Distinguish a not-activated service from a ban on the token endpoint. A non-ban `403`
  (e.g. `Type 'live_stream' is not enabled for this project`) now throws the new
  `UTDServiceNotAvailableException` instead of `UTDBannedException`.
- The built-in connect-error view shows a distinct "not available" message and hides Retry
  for that refusal (retrying can't help). Adds `UTDRoomStrings.serviceNotAvailable` (EN + AR).

## 1.5.0

- **Video Effects entitlement (trusted, token-signed).** The kit now decodes a
  server-signed `videoEffects` entitlement from the join token (the engine
  resolves it per-platform against the requesting client's `os` at mint and
  stamps a boolean into the token's `metadata` claim) and threads it into the
  video-processor factory. Effects therefore run only when the customer has
  activated + paid for the current platform; unentitled sessions get a
  passthrough processor. The signature is read client-side WITHOUT verifying it
  (the SFU verifies the token on join); the processor is the authoritative gate.
  - **Breaking:** the processor factory now receives the entitlement —
    `UTDLiveRoomConfig.buildVideoProcessor` and
    `UTDRoomController.setVideoProcessorFactory` changed from
    `TrackProcessor Function()?` to `TrackProcessor Function(bool entitled)?`.
    Forward the flag to your processor, e.g.
    `(entitled) => VideoEffectsProcessor.create(entitled: entitled)`.
  - **New** `UTDRoomController.videoEffectsEntitled` getter (valid after
    `connect`) so UI can surface an "activate to unlock" hint.
  - **Backward-compatible / fail-open:** a token with no `videoEffects` claim
    (older engine) keeps effects working; only an explicit `false` disables them.

## 1.4.0

- **Seat grid → unbounded stage.** A live room is no longer a fixed 4-tile seat
  grid (host on seat 0 + up to 3 guest tiles). `live_stream` is now ALWAYS the
  engine's **unbounded seatless stage**: the LiveKit room is uncapped
  (`maxParticipants: 0`) so viewers are unlimited, and this package decides how
  many co-host tiles to surface (still 4 by default — the cap is now purely a UI
  choice, not an engine limit). Every non-owner joins as `audience`; the host
  promotes co-publishers post-join.
- **Type-first token.** `generateToken` now sends `type: 'live_stream'` to
  `POST /api/v1/token` and **no longer sends `service`/`kind` or
  `seat_count`/`seat_mode`/`host_seat`** — those are ignored for `live_stream`.
  The engine still accepts the legacy `service`(`rooms`)+`kind`(`live`) fields,
  so an un-migrated app keeps working; this version opts into the canonical type.
  The same `app_id`/`app_key` works for every product type the project has
  enabled — `type` is a per-request field, not a credential. A request for a type
  the project hasn't enabled returns
  `403 "Type 'live_stream' is not enabled for this project"`.
- **Publishing decoupled from moderation.** Roles are server-authoritative and
  the engine clamps a non-owner's claimed role to `audience` (a client can no
  longer self-grant publish by claiming `role: 'host'`):
  - `host` — the verified room owner (publishes **and** moderates).
  - `guest` — a host-invited co-publisher (publishes only).
  - `admin` — an owner-promoted **moderator** that moderates only and is **never
    on camera** (decoupled — promoting to admin no longer grants a tile).
  - `audience` — default (neither).
- **New `stage_api`** (`UTDStageApi`, exported via `stage_api.dart`) for the
  `live_stream` stage endpoints (all `live_stream`-only; the engine returns `400`
  on a seated/non-`live_stream` room and `403` if `live_stream` isn't enabled):
  - `getStage` → `GET /api/v1/rooms/:name/stage` → `{ members: [{ identity, name, role }] }`
    (publishers = host + guests).
  - `addToStage` → `POST /api/v1/rooms/:name/stage/add` `{ target_identity }`
    (host/admin → grants publish, sets role `guest`).
  - `removeFromStage` → `POST /api/v1/rooms/:name/stage/remove` `{ target_identity }`
    (host/admin → back to `audience`).
  - `leaveStage` → `POST /api/v1/rooms/:name/stage/leave` (self step-down).
  - `requestStage` → `POST /api/v1/rooms/:name/stage/request` (viewer raise-hand;
    the engine notifies host/admins via a `_stage_request` data message — no
    server-side queue).

  The actor is resolved server-side from the per-user bearer; `identity` rides
  the body as a dual-mode fallback. Stage state arrives over the data channel as
  `_stage_update` (roster) and via the `_stage` room-metadata key for late
  joiners; `_stage_request` is the raise-hand ping.
- **Moderator promotion** reuses the existing role endpoint —
  `PUT /api/v1/rooms/:name/participants/:identity/role` `{ role: 'admin' }`,
  **owner-only**. On a stage room this grants moderation but **not** publish; the
  engine refuses (`409`) to add an `admin` to the stage to keep the two
  capabilities disjoint (demote first).
- **Removed `seat_api` and `speaker_api`** along with the invite/request-to-go-
  live **invitation handshake** (`/seats/*`, `/speakers/*` including
  `speakers/invite` + `invitations/:id/accept|decline`). The live room is the
  stage now; seats/speakers remain in `utd_audio_room_kit` (and on the engine for
  `audio_room` + the legacy live kit) but are gone from this package.
  **Breaking** for integrators driving seats/speakers directly: switch to
  `UTDStageApi`.
- **Minimum engine version:** requires an engine build with the type-first token
  path and the `live_stream` stage endpoints (`enabled_types` + `/stage/*`).
  Older engines that only understand `service`/`kind` will reject the `type`
  field — stay on `1.3.0` against those until the engine is upgraded.

## 1.3.0

- No-backend credentials (recommended): pass `UTDLiveRoom(appKey: ...)` /
  `UTDRoomController.initApi(appKey: ...)` — the project's publishable **app key**. The kit
  mints tokens directly from the engine (`X-App-Key` on `POST /api/v1/token`), and the engine
  signs the returned per-user `user_token` with the project `server_secret` **server-side**, so
  the secret never ships in the app and no integrator backend is required. The kit applies that
  `user_token` as the `Authorization: Bearer` for all in-room/moderation calls (persisted across
  `initApi` re-inits, so it survives restore-from-minimize).
- **Removed `tokenProvider`** and its `UTDTokenRequest` / `UTDTokenBundle` / `UTDTokenProvider`
  types (added in 1.2.0). The no-backend `appKey` flow above replaces it. **Breaking** for
  integrators who adopted `tokenProvider`: migrate to `appKey`.
- **Removed `serverSecret`** from `UTDLiveRoom` and `UTDRoomController.initApi` (deprecated in
  1.2.0). Shipping the project secret in an app let anyone extract it and mint tokens for any
  identity/room. **Breaking**: `appKey` is now the only credential and is required on `UTDLiveRoom`.
  The legacy `X-App-Secret` header path is gone (`UTDApiClient` no longer takes `appSecret`).
- A leaked `app_key` cannot forge bearers offline or call the server-to-server API, and rotates
  independently via the engine `regenerate-credentials` admin endpoint.

## 1.2.0

- Secure credential mode: new `tokenProvider` callback mints tokens via the
  integrator's own backend (which holds the project secret and authenticates the
  real user) instead of embedding `serverSecret` in the app. The kit never sees
  the secret; the returned per-user `user_token` becomes the `Authorization:
  Bearer` for all in-room/moderation REST calls.
- Deprecate `serverSecret` on `UTDLiveRoom` and `UTDRoomController.initApi`
  (now optional). Shipping it in an app lets anyone extract it and mint tokens
  for any identity/room. Existing callers keep working in legacy/dual mode.
- Add the `UTDTokenRequest`, `UTDTokenBundle`, and `UTDTokenProvider` types
  (exported via `token_provider.dart`); `UTDTokenResponse` gains `userToken`.
- The secure-mode per-user bearer is persisted on the controller and re-applied
  whenever the API clients are rebuilt (e.g. restore-from-minimize re-inits
  without re-minting a token), so in-room/moderation calls stay authenticated.
- `generateToken` validates the `tokenProvider` bundle and throws
  `UTDTokenException` on an empty token/url instead of failing later in connect.

## 1.1.0

- Single-active-session enforcement: send a stable per-install `device_id`
  (persisted via `shared_preferences`, auto-resolved in `generateToken`) and
  handle the `_kicked` (`signed_in_elsewhere`) data event through the existing
  exit funnel with a distinct "signed in on another device" notice and dialog.
- Add `UTDRateLimitedException` for `429` responses from the token endpoint.
- Split the API into separate token (`udt-stream.com`) and engine
  (`engine.udt-stream.com`, grey-cloud) clients; configure via the new
  `engineBaseUrl` parameter on `initApi`.
- Security: stop mirroring user attributes into participant metadata
  (server-owned, spoofing vector); chat text/sender name are treated as
  untrusted and rendered plain-text only.

## 1.0.0

- Initial standalone release. Extracted from the Tempo-Live monorepo into its
  own package repository.
- LiveKit-based video live room (host camera + up to 3 guest video tiles) built
  on the same seat state machine as `utd_audio_room_kit`.
- Camera tiles, invite / request-to-go-live, host force-control of guest media,
  real-time chat over the data channel, tiered reconnection, and
  minimize / Android OS Picture-in-Picture.
- Pairs with `utd_video_effects_kit` via
  `UTDLiveRoomConfig.buildVideoProcessor` (a LiveKit `TrackProcessor`) for
  real-time filters / beauty effects.
