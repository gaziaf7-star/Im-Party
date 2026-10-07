# Ludo – Backend Fix Note (from 2-phone test logs, game 24, room 326)

Stack: PHP/Laravel + Centrifugo. Client is already patched; these are the server-side problems the logs prove.

## 1. Version numbers must never skip (HIGH)
Every state change = exactly one `version` + one event, strictly +1.

Observed on every roll:
- start v3 -> client next sees `rolled v5` (v4 missing)
- `turn v6` -> next `rolled v8` (v7 missing) -> `turn v9` -> `rolled v11` ...
- roll responses: `version 6 -> 9 -> 15 -> 20 -> 26 -> 29`

Each skipped number makes the client think it missed an event, so it calls
`GET /ludo/games/active` on every roll (extra 0.8–1.5 s + stale data, see #2).
Likely cause: version incremented twice per action (e.g. once on roll, once inside the
"pass/turn" step, or a retry/idempotent path bumping it). Increment once per published event.

## 2. Snapshot must not carry a stale `last_dice` (HIGH)
`GET /games/active` and roll/move responses return `last_dice` from the PREVIOUS player after a pass/turn change.

Example: green rolled 5 (v28) -> `turn blue` (v29) -> snapshot says
`current_color: blue, last_dice: 5`. Blue never rolled 5.
Blue then POSTed `/move` and got `idempotent: true` (nothing happened).

Fix: set `last_dice = null` whenever the turn changes (pass, timeout, after move without bonus).
Optionally add `dice_pending: true|false` (true only when current player has rolled and still must choose a token).

## 3. Roll response consistency
When `passed: true` (no movable token) the response `game.current_color` is already the next player and `version` already includes the `turn` event – good, but keep the `rolled` and `turn` events in the same
consecutive versions (see #1).
`POST /move` called when no dice is pending should return a clear error (422 `no_dice_pending`), not `200 idempotent`, so the client can resync.

## 4. Latency (HIGH – this is the "lag")
Measured: roll 784–1472 ms, join 833–1643 ms, start 1451 ms, create 1352 ms, `active` 725–1492 ms.
Target: < 100 ms for roll/move/active.
- Lock game row, update, `publish to Centrifugo FIRST`, then do DB writes/logs/stats/notifications after response (queue).
- Don't load full player profiles (covers, country…) for every event/response; send `user_id,color,name,avatar` only.
- Cache game state in Redis; use it for `/active`.
- Run Laravel with Octane (Swoole/RoadRunner) or at least opcache + `route:cache`/`config:cache`.
- Make sure only ONE of Centrifugo / LiveKit data channel publishes the event (client currently receives each event twice).

## 5. Keep as is
- 7 s turn timeout with server auto-move/auto-pass works (`turn_deadline_at`).
- Event envelope `{Action:"ludo", MessageContent:{message:"ludo_event", type, game_id, version, ...}}`.

## Quick test checklist
1. Play 20 rolls with 2 phones: versions in events must be consecutive (no gaps), client log must show NO `GET /active` during normal play.
2. After a pass/turn change, `GET /active` returns `last_dice: null`.
3. Roll p95 < 100 ms in server logs.
