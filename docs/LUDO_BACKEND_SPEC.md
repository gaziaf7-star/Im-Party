# Ludo (In-Room Game) — Backend Specification

Audience: backend developer. Client: Miva Flutter app (audio room). Realtime: existing room channel (Centrifugo / RoomDataTrait::pushRoomData) and LiveKit for audio only.

Goal: a user in an audio room creates a Ludo game, everybody in the room is notified, users join by paying a virtual-coin entry fee, the game is played in real time, everyone in the room can watch, and at the end the winner is paid and everybody sees the result.

> Compliance: coins are **in-app virtual coins**. The UI states the game is not to be used for monetary transactions. Do not connect Ludo coins to withdrawals/cash-out unless legal has approved.

---

## 1. Rules recap (so server logic matches the client)

- Seats/colours: `green` (host, always seated), `yellow`, `blue`, `red`. Turn order: green → yellow → blue → red (skip empty / finished).
- `mode`: `duo` (1 vs 1: green + blue) or `multi` (2–4 players).
- `rule`: `classic` (first to bring **4** tokens home wins) or `simple` (first to bring **2** tokens home wins).
- `magic`: `true` = a capture or a token reaching home gives a bonus roll; `false` = only a roll of 6 gives a bonus roll.
- Each player has 4 tokens, `relative_step`: `-1` base, `0..50` shared track, `51..56` home stretch, `56` finished.
- Roll 6 to leave base. Roll 6 = bonus roll. Three 6s in a row = turn forfeited. A token cannot overshoot step 56. Landing on an opponent on a non-safe track square sends it to base. Safe squares + home stretch cannot be captured.
- **Magic squares** (only when `magic = true`): fixed items on the shared track (indexes into `LudoPath.track`, never on start/safe squares). A token that finishes its move on one triggers it (after capture resolution; effects do not chain):
  - `dice` (10, 23, 36): bonus roll.
  - `rocket` (3, 29, 42): token jumps +3 steps (stops at step 50 max), then captures are re-checked.
  - `battery` (6, 32): token jumps +2 steps, then captures are re-checked.
  - `ice` (19, 45): the next player's next turn is skipped (ice skip is consumed once).
  - `crown` (16, 49): visual/sound only (reserved for future rewards).
  If Phase 2 (server-authoritative moves) is built, the server must implement these exactly; see `game/ludo_magic.dart` and `ludo_movement_engine.dart`.
- Reference implementation of the rules: `lib/src/features/ludo/game/ludo_movement_engine.dart`, `game_state.dart`, `models/ludo_path.dart` (track, safe cells, start indexes). Port these exactly for server-side validation.

## 2. Game lifecycle (state machine)

```
lobby ──start──► playing ──winner──► finished
  │                 │
  └─cancel/expire──►cancelled ◄──all-but-one left / host abort
```

| Status | Meaning |
|---|---|
| `lobby` | Created, players joining, fees held. |
| `playing` | Started, turns running. |
| `finished` | Winner decided, prizes paid. Terminal. |
| `cancelled` | Aborted, all fees refunded. Terminal. |

One active game (`lobby` or `playing`) per room at a time.

## 3. Database

**ludo_games**
`id, room_id, host_user_id, mode, rule, magic(bool), entry_fee(int), status, current_color, last_dice(nullable), consecutive_sixes, turn_deadline_at, token_state(json), started_at, finished_at, winner_user_id(nullable), prize_pool, commission, version(int, increments every state change), created_at`

**ludo_players**
`id, game_id, user_id, color, fee_paid, status(joined|left|forfeited|winner|loser), rank(nullable), prize(int default 0), joined_at`
Unique: `(game_id, user_id)`, `(game_id, color)`.

**ludo_moves** (audit log)
`id, game_id, seq, user_id, color, type(roll|move|auto_roll|auto_move|pass), dice, token_slot, from_step, to_step, captured(json), created_at`

**ludo_transactions** (or reuse the wallet ledger with `type`)
`id, game_id, user_id, kind(fee|refund|prize|commission), amount, balance_after, idempotency_key(unique), created_at`

`token_state` example:
`{"green":[-1,-1,-1,-1],"blue":[0,12,-1,-1]}`

## 4. REST API

Auth: normal user token. All responses: `{ "status": true, "data": {...} }` or `{ "status": false, "code": "ERROR_CODE", "message": "..." }`. Every state-changing endpoint is wrapped in a DB transaction with a row lock on the game and must be **idempotent** (accept header `Idempotency-Key`, or return the existing result if the user already did the same action).

### 4.1 Create
`POST /api/ludo/games`
```json
{ "room_id": 123, "mode": "multi", "rule": "classic", "magic": true, "entry_fee": 100 }
```
Checks: user is in the room, no active game in that room, `entry_fee` within allowed list/range (config, may be `0` = free), balance ≥ fee.
Actions: create game (`lobby`), seat host as `green`, deduct host fee (kind `fee`), push `ludo_created`.
Response: `{ "game": <Game> }` (see 4.9).
Errors: `ROOM_HAS_ACTIVE_GAME`, `INSUFFICIENT_BALANCE`, `INVALID_FEE`, `NOT_IN_ROOM`.

### 4.2 Join
`POST /api/ludo/games/{id}/join`
Checks: status `lobby`, free seat exists, user not already seated, balance ≥ fee, user in the same room.
Seat assignment: `duo` → `blue`; `multi` → first free of `yellow, blue, red`.
Actions: deduct fee, insert player, push `ludo_player_joined`.
Errors: `GAME_STARTED`, `GAME_FULL`, `ALREADY_JOINED`, `INSUFFICIENT_BALANCE`.

### 4.3 Leave
`POST /api/ludo/games/{id}/leave`
- `lobby`: refund fee, remove player, push `ludo_player_left`. If the host leaves → cancel game (4.5).
- `playing`: mark `forfeited`, **no refund**, remove from turn order, push `ludo_player_left`. If one player remains → finish with that player as winner (4.7).

### 4.4 Start (host only)
`POST /api/ludo/games/{id}/start`
Checks: caller is host, status `lobby`, ≥ 2 players.
Actions: status `playing`, `current_color = green`, init `token_state`, set `turn_deadline_at = now + 20s`, push `ludo_started`.

### 4.5 Cancel (host only, lobby only)
`POST /api/ludo/games/{id}/cancel`
Refund every fee, status `cancelled`, push `ludo_cancelled` (reason `host_cancelled`).

### 4.6 Roll and move (server-authoritative — recommended)
`POST /api/ludo/games/{id}/roll`
Checks: status `playing`, caller owns `current_color`, no pending token choice.
Server generates dice with a CSPRNG (never trust the client value). Applies rules: 3 sixes → forfeit turn; no movable token → pass (or bonus roll on 6 when nothing can move). Pushes `ludo_rolled` and, if the turn changes, `ludo_turn`.

`POST /api/ludo/games/{id}/move`
```json
{ "token_slot": 2 }
```
Checks: status `playing`, caller owns `current_color`, a dice value is pending, token can legally move that dice. Server moves the token, resolves capture, home, win, bonus roll, next turn. Pushes `ludo_moved`.

If exactly one token can move after a roll, the server may auto-move it and send both events (client currently auto-moves in that case, so either is fine as long as the event order is `rolled` → `moved`).

Errors: `NOT_YOUR_TURN`, `INVALID_MOVE`, `GAME_NOT_PLAYING`, `STALE_VERSION`.

> **Phase 1 fallback (if server-side rules are not ready):** the client keeps sending roll/move over LiveKit exactly as it does today; the server only needs 4.1–4.5 and 4.7 (below). This is cheatable, so use only for early testing.

### 4.7 Finish
Normally **internal** (triggered by the server when the win condition is met, or when one player is left). Only if Phase 1 fallback is used, expose:
`POST /api/ludo/games/{id}/finish` `{ "winner_user_id": 5 }` — accept only from the host or require ≥2 matching reports from seated players; reject otherwise.

On finish: `pool = entry_fee × players`, `commission = pool × commission_rate` (config), `prize = pool − commission`. Credit the winner (kind `prize`), record commission, set ranks, status `finished`, push `ludo_finished` and `wallet_updated` to each affected user.

### 4.8 Snapshot (late joiners / spectators)
`GET /api/ludo/games/active?room_id=123` → `{ "game": <Game> | null }`
Called when a user enters the room, and by the client as a fallback to re-sync. Includes full `token_state`, `current_color`, `last_dice`, `version`.

`GET /api/ludo/games/{id}` → same shape.

### 4.9 Game object
```json
{
  "id": 77,
  "room_id": 123,
  "status": "playing",
  "mode": "multi",
  "rule": "classic",
  "magic": true,
  "entry_fee": 100,
  "prize_pool": 400,
  "host_user_id": 5,
  "current_color": "yellow",
  "last_dice": 4,
  "turn_deadline_at": "2026-10-05T12:00:20Z",
  "version": 42,
  "players": [
    { "user_id": 5, "color": "green", "name": "Alamin", "avatar": "https://...", "status": "joined", "rank": null }
  ],
  "tokens": { "green": [-1,-1,-1,-1], "yellow": [0,12,-1,-1] },
  "winner_user_id": null
}
```

### 4.10 Extras
- `GET /api/ludo/leaderboard?period=daily|weekly|all` → top players (wins, total prize). Used by the trophy badge.
- `GET /api/ludo/history` → user's past games.
- `GET /api/ludo/config` → allowed fees, commission rate (display only), turn timeout, min/max players.

## 5. Realtime events

Send on the **room channel** so every user in the room (players and spectators) receives them. Use the existing frame format the app already parses (`RoomDataTrait::pushRoomData`):

```json
{ "Action": "...", "MessageContent": { "message": "ludo_event", "type": "<event type>", "game_id": 77, "version": 42, "...": "..." } }
```

Every event carries `game_id` and monotonically increasing `version`. The client ignores events with a lower `version` than it already holds and calls the snapshot API if it detects a gap.

| `type` | Sent when | Extra fields |
|---|---|---|
| `created` | Game created | `game` (full object), `host {id,name,avatar}`, `entry_fee`. **The client shows the "Ludo started — Join?" invitation to everyone in the room from this.** |
| `player_joined` | Someone joined | `player`, `players_count` |
| `player_left` | Left / forfeited | `user_id`, `color`, `reason` (`left`/`forfeit`/`disconnect`) |
| `started` | Host started | `game` (full object) |
| `rolled` | Dice rolled | `color`, `user_id`, `dice`, `auto`(bool) |
| `moved` | Token moved | `color`, `token_slot`, `from_step`, `to_step`, `captured:[{color,slot}]`, `reached_home`(bool) |
| `turn` | Turn changes | `current_color`, `turn_deadline_at` |
| `finished` | Game over | `winner {user_id,color,name,avatar}`, `prize`, `ranking:[{user_id,color,rank,prize}]`. **All room users see the winner / losers from this.** |
| `cancelled` | Aborted | `reason` (`host_cancelled`, `lobby_expired`, `host_left`, `server_error`) |

User-specific (private channel / targeted push):
- `wallet_updated` → `{ "balance": 1234, "delta": -100, "reason": "ludo_fee" }` so the coin balance in the UI refreshes immediately.

Also write a system chat line in the room for `created` and `finished` (optional, nice for people who are not looking at the board).

## 6. Server jobs / timers

1. **Turn timer (every second or scheduled per turn):** if `turn_deadline_at` passes (default 20 s) → perform an automatic action for that player: auto-roll, then auto-move the most advanced movable token (or pass). Mark event `auto: true`. After 3 consecutive auto turns, treat as `forfeited`.
2. **Lobby expiry:** `lobby` older than 3 minutes (config) → cancel + refund everyone, push `cancelled` (`lobby_expired`).
3. **Stale game cleanup:** `playing` with no activity for 10 minutes → cancel + refund (or finish by highest progress; pick one and document it).
4. **Host/room departure:** if the host leaves the room during `lobby` → cancel + refund. If a player leaves the **room** during `playing` → treat as forfeit after 30 s grace (they may reconnect).
5. **Reconnect:** a player re-entering the room within the game can call `GET /ludo/games/active` and continue; seat is kept while status is `joined`.

## 7. Wallet rules (important)

- All coin movements happen inside the same DB transaction as the game change, with a lock on the user's wallet row.
- Every movement has a unique `idempotency_key` (`ludo:{game_id}:{user_id}:{kind}`) so a retry or double tap can never double-charge or double-pay.
- Fee is taken at create/join, refunded on lobby leave/cancel/expiry, never refunded after `started`.
- Payout only once, only in `finish`. A finished/cancelled game rejects every mutating call.
- Keep a ledger row for every change (fee, refund, prize, commission) for auditing.

## 8. Security and anti-cheat

- The client is **never** the source of truth for dice, turn order, captures, or winners.
- Validate turn ownership (`current_color` ↔ user) on every roll/move.
- Rate limit roll/move/join (e.g. 5 req/s per user).
- Reject actions from users who are not in the game's room.
- Do not expose other players' wallet balances. Do not put secrets in events.
- Log everything in `ludo_moves` so a disputed game can be replayed.

## 9. Error codes

`NOT_IN_ROOM, ROOM_HAS_ACTIVE_GAME, INVALID_FEE, INSUFFICIENT_BALANCE, GAME_NOT_FOUND, GAME_STARTED, GAME_FULL, ALREADY_JOINED, NOT_HOST, NEED_MORE_PLAYERS, GAME_NOT_PLAYING, NOT_YOUR_TURN, INVALID_MOVE, STALE_VERSION, GAME_ENDED`

## 10. Delivery phases

**Phase 1 — playable with coins (do first):** tables, create / join / leave / start / cancel, wallet fee + refund + prize, `created / player_joined / player_left / started / finished / cancelled / wallet_updated` events, snapshot API, lobby expiry. (Roll/move stay on the current LiveKit sync.)

**Phase 2 — secure gameplay:** server-side roll / move / turn timer / auto-play, `rolled / moved / turn` events, forfeits, disconnect handling.

**Phase 3 — polish:** leaderboard, history, config endpoint, system chat lines, admin reports (games per day, commission, refunds).

## 11. Acceptance checklist

- [ ] Creating a game deducts the host fee and every user in the room receives `created`.
- [ ] Joining deducts the fee; balance below fee returns `INSUFFICIENT_BALANCE` and does not change anything.
- [ ] Double-tapping Join never charges twice.
- [ ] Leaving in lobby refunds; host leaving cancels and refunds everyone.
- [ ] A spectator who enters the room mid-game gets the current board from `/ludo/games/active`.
- [ ] Spectators receive every `rolled / moved / turn` event in order.
- [ ] Winner receives `pool − commission` exactly once; all room users receive `finished` with winner and ranking.
- [ ] Idle player is auto-played after the timeout; repeated idling forfeits.
- [ ] Expired lobby is cancelled and refunded automatically.
- [ ] A finished or cancelled game rejects further actions.

## 12. Turn timer change requested by product

- `GET /api/ludo/config` → `turn_timeout_seconds` must be **7**. The app reads this value and draws a shrinking ring around the active player's avatar for exactly that long.
- When the 7 seconds run out and the player has **not rolled**, the server must **pass the turn to the next player** (send `turn` with the next `current_color` and a fresh `turn_deadline_at`). It must NOT auto-roll for the idle player. (If the player already rolled and has movable tokens but did not choose one within the time, the server may auto-move or pass; document the choice.)
- `turn_deadline_at` must be sent on every `turn` event and in every game snapshot.

---------------------------------------------------------------------------------------

## Speed & smoothness checklist (PHP/Laravel + Centrifugo)

The Ludo client already animates the dice and tokens the moment a player taps, and
reconciles with the server answer. What players still feel is the latency of
`/roll` and `/move` and the delay of the pushed events. Please do the following.

1. **Hot path = Redis, not MySQL.** Keep the live game (`board`, `current_color`,
   `last_dice`, `deadline`, `version`) in Redis. `/roll` and `/move` read/modify/write
   Redis under a short per-game lock (`Cache::lock("ludo:{id}", 2)`), `INCR` the
   version, **publish to Centrifugo, return the response, and only then** write to MySQL
   (`dispatch(...)->afterResponse()` or a queued job). Target: request received →
   Centrifugo publish returned **< 50 ms**, p95 < 80 ms.
2. **Publish before any slow work.** Wallet / prize / history writes must never sit in
   front of the `rolled`, `moved`, `turn` events.
3. **One response must be enough to animate.** `/roll` should return in the snapshot:
   `last_dice`, `movable_slots` (token slots that may move), and if there is exactly one
   legal move (or none) the server's automatic result (`moved`/`turn` info) — the client
   then does not wait for a second round trip. `/move` returns the final board,
   `captured`, `reached_home`, `extra_turn` and the next `current_color`.
4. **Send `server_time_ms` (unix ms)** in every event and snapshot, and keep
   `turn_deadline_at` accurate. The client uses it to correct clock drift on the turn ring.
5. **Events stay small.** `rolled`/`moved`/`turn` carry only the delta (no full `board`
   in each). The full snapshot is sent only in `created`/`started` and `GET /games/active`.
   Enable gzip/HTTP2 on the API.
6. **Centrifugo recovery** (this is the biggest cause of "the board got stuck" /
   "jumped"): enable history + recovery on the room namespace —
   `history_size: 100`, `history_ttl: "300s"`, `force_recovery: true` — so a phone with
   a short network drop receives the events it missed instead of falling out of sync.
   Keep `version` strictly +1 per change, assigned **inside the lock**.
7. **Turn timeouts server-side.** A delayed job (or Redis ZSET worker polled every
   second) fires at `turn_deadline_at`: re-check version/deadline, then auto-roll /
   auto-move or pass the turn (`turn_timeout_seconds` = 7–10 s suggested), publish
   `turn`. A stale job must do nothing.
8. **Idempotent actions.** Double taps / retries of `/roll` or `/move` for the same
   turn must return the current snapshot, not an error or a second event.
9. **Infra:** API + Centrifugo + Redis in the same region/datacenter, keep-alive on the
   Centrifugo HTTP API client, PHP-FPM workers warmed (or Laravel Octane) for
   `/roll` & `/move`, no heavy middleware/logging on these routes.
10. **Measure** and send us numbers: `request received → publish returned` for
    `/roll` and `/move`, and Centrifugo publish→delivery latency. If p95 is above
    ~100 ms the game will feel laggy.
