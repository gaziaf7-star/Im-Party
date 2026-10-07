# Carrom (Carom) in the audio room — backend spec

The Flutter client is finished (`lib/src/features/carom/`). It works exactly like the
Ludo mode: a "Carrom" tile in **More options** opens a create sheet, the room's mic-seat
grid is replaced by a lobby / board, everyone else gets an Accept / Reject invite,
non-players watch live, the winner overlay shows the prize, coins move through the wallet.

Everything below is what the **backend** must build. The wire format deliberately
mirrors `LUDO_BACKEND_SPEC.md` / `LUDO_EVENTS_FOR_BACKEND.md` (same envelope, same
`version` rule, same error shape) so the same helpers can be reused.

---------------------------------------------------------------------------------------

## 0. Architecture in one paragraph

Carrom is a **physics** game (sliding discs, collisions, pockets). The backend owns
**everything that has money or fairness in it** — seats, entry fees, whose turn it is,
turn timer, scoring, queen / foul rules, winner, prize, wallet. It does **not** have to
simulate the physics:

1. The active player aims and **shoots** → client calls `POST /shot` (striker position,
   angle, power). Server validates the turn and broadcasts a `shot` event.
2. **Every** client (shooter and spectators) plays that same shot locally so the board
   animates live for the whole room.
3. When the pieces stop, the **shooter's** client reports the final board with
   `POST /shot/result`. The server applies the rules to that board, updates scores /
   queen / turn, stores the new piece positions and broadcasts `shot_result`. The
   clients snap to the positions in that event, so small floating-point differences
   between phones never matter.

Because the shooter reports the final positions, the server must **sanity-check** them
(section 7). A full server-side port of the physics can be added later without changing
the API.

---------------------------------------------------------------------------------------

## 1. Realtime envelope (same as Ludo)

Publish every event to the **room channel** with the existing room-frame helper
(the one behind `pushRoomData`). Do not create a new channel.

```json
{
  "Action": "carom",
  "MessageContent": {
    "message": "carom_event",
    "type": "shot_result",
    "game_id": 7,
    "version": 12,
    "...": "event specific fields"
  }
}
```

* `MessageContent.message` MUST be exactly `"carom_event"`.
* Every event except `wallet_updated` and `aim` carries `game_id` and an integer
  `version` that increases by **exactly 1** per state change of that game
  (create = 1, join = 2, ...). The client applies events strictly in version order and
  re-fetches `GET /carom/games/active?room_id=` when it sees a gap.
* Send to **everyone in the room including the sender** (the client de-duplicates).
* Publish **after** the DB transaction commits.
* `wallet_updated` goes only to the affected user. `aim` is not versioned (see 4.2).

---------------------------------------------------------------------------------------

## 2. Board facts the backend needs

Coordinates are the client's board units: a square **740 × 740**, origin top-left,
x → right, y → down. Pocket centres: (50,50) (690,50) (50,690) (690,690).
Playing field is 34 … 706 on both axes. Coin radius **15.5**, striker radius **20.5**.

### 2.1 Seats

| seat | duo (1v1) | doubles (2v2) | colour | team |
|---|---|---|---|---|
| `player1` | South (bottom) | South | white | A |
| `player2` | North (top) | West (left) | black | B |
| `player3` | – | North (top) | white | A |
| `player4` | – | East (right) | black | B |

* Seats are given in **join order**: host = `player1`, next = `player2`, then
  `player3`, `player4`.
* Turn order: duo `player1 → player2 → player1…`; doubles clockwise
  `player1 → player2 → player3 → player4 → player1…`.
* Striker baseline per seat (the striker must sit on this line when shot):
  `player1` y = 635, `player2` (duo) y = 105, `player3` y = 105 — x between **145 and 595**;
  `player2` (doubles) x = 105, `player4` x = 635 — y between **145 and 595**.

### 2.2 Coins (ids are fixed, the client builds the opening layout itself)

`id 1` = queen (centre 370,370). `id 2…7` = inner ring, `id 8…19` = outer ring.
White = 9 coins, black = 9 coins, queen = 1. The striker (id 999) is never stored.
**Opening layout:** when `pieces` is missing/empty in a snapshot the client uses the
standard layout, so the backend does NOT need to generate positions at game start.
After the first `shot_result` the backend stores the reported positions and always
sends the full `pieces` list.

A piece object everywhere:

```json
{ "id": 5, "type": "white", "x": 412.37, "y": 288.9, "pocketed": false }
```
`type` ∈ `white | black | queen`.

---------------------------------------------------------------------------------------

## 3. REST endpoints

Base: `/api/carom`. Same auth, same envelope as Ludo:
success `{ "status": true, "data": { ... } }`, error `{ "status": false, "code": "...", "message": "..." }`.
Every endpoint that changes a game returns `data.game` (the full snapshot, section 5).

| Method | Path | Body | Notes |
|---|---|---|---|
| GET | `/config` | – | `{ config: { allowed_fees:[0,100,500,1000,5000,10000,50000], commission_rate:0.05, turn_timeout_seconds:20, lobby_timeout_seconds:180, aim_sync:true } }` |
| POST | `/games` | `room_id`, `mode` (`duo`\|`doubles`), `entry_fee` | creator becomes host + `player1`, fee charged. User must be in the room. One live game per room. |
| POST | `/games/{id}/join` | – | takes next free seat, charges fee |
| POST | `/games/{id}/leave` | – | lobby → refund + free seat; playing → forfeit (section 8) |
| POST | `/games/{id}/start` | – | host only; needs 2 players (duo) / 4 players (doubles) |
| POST | `/games/{id}/cancel` | – | host only, lobby only, refunds everyone |
| POST | `/games/{id}/shot` | `shot_id`, `striker_x`, `striker_y`, `angle`, `power` | active seat only |
| POST | `/games/{id}/shot/result` | `shot_id`, `striker_pocketed`, `pieces[]` | shooter only |
| POST | `/games/{id}/aim` | `slider`, `aiming`, `angle`, `power` | fire-and-forget live aim |
| GET | `/games/active?room_id=` | – | `{ game: {...} }` or `{ game: null }` |

### 3.1 `POST /shot`

* `shot_id` must be `game.shot_seq + 1` (idempotent: the same id again returns the
  current snapshot without a second event).
* Validate: game `playing`, caller is the `current_seat`, no shot already in flight,
  `0.10 ≤ power ≤ 1.0`, `striker_x/striker_y` on the seat's baseline within its slider
  range (section 2.1, allow ±1 unit), `angle` finite.
* Effects: `shot_seq = shot_id`, mark "shot in flight", **extend the deadline** to
  `now + 25 s` (settle window, see section 6), `version++`, publish `shot`.

### 3.2 `POST /shot/result`

Body:
```json
{
  "shot_id": 12,
  "striker_pocketed": false,
  "pieces": [ { "id":1,"type":"queen","x":370,"y":370,"pocketed":false }, ... 19 items ... ]
}
```
* Only the seat that fired `shot_id`, only once, only while that shot is in flight.
* Validate the board (section 7), then run the rules (section 6) → new scores, queen
  state, next seat, optional game over. `version++`, publish `shot_result`
  (+ `finished` as a separate event when the game ends).

### 3.3 `POST /aim`

Body `{ "slider": 312.5, "aiming": true, "angle": -1.57, "power": 0.42 }`.
Only the current seat may send it; otherwise answer `200` and ignore. Rate-limit to
~10/s per game. Relay as an `aim` event (4.2). Do not store anything.
`config.aim_sync=false` tells the client not to send these at all (use it if you move
aim to a LiveKit data channel later).

---------------------------------------------------------------------------------------

## 4. Events

### 4.1 Versioned events

| `type` | When | Required fields |
|---|---|---|
| `created` | game created | `game` (snapshot), `host {id,name,avatar}`, `entry_fee` |
| `player_joined` | someone joined | `player {user_id,seat,name,avatar}`, `players_count` |
| `player_left` | left / forfeit | `user_id`, `seat`, `reason` (`left`\|`forfeit`\|`disconnect`) |
| `started` | host started | `game` (snapshot with `current_seat`, `turn_deadline_at`) |
| `shot` | a shot was fired | `shot_id`, `seat`, `user_id`, `striker_x`, `striker_y`, `angle`, `power` |
| `shot_result` | board settled & rules applied | see below |
| `turn_timeout` | a turn expired | same fields as `shot_result` (`foul:"timeout"`) |
| `finished` | game over | `winners [{user_id,seat,name,avatar}]`, `prize` (per winner), `scores {seat:int}` |
| `cancelled` | cancelled | `reason` (`host_cancelled`\|`lobby_expired`\|`host_left`\|`server_error`) |
| `wallet_updated` | only to the affected user | `balance`, `delta`, `reason` (`fee`\|`prize`\|`refund`) |

`shot_result` / `turn_timeout` fields (all required):

```json
{
  "type": "shot_result", "game_id": 7, "version": 12, "shot_id": 12,
  "seat": "player1",
  "pocketed": [3, 9],
  "foul": "none",                       // none | striker_pocket | timeout
  "notice": "+10 PTS! Player 1 continues",
  "notice_color": 4283215102,           // ARGB int, optional (default light blue)
  "scores": { "player1": 20, "player2": 5 },   // doubles: both partners carry the team score
  "queen_status": "waitingForCover",    // unpocketed | waitingForCover | covered
  "next_seat": "player1",               // may equal seat (bonus turn)
  "game_over": false,
  "turn_deadline_at": "2026-10-06T10:00:20Z",
  "pieces": [ ...all 19 pieces, after penalty / queen returns... ]
}
```
`pieces` must already contain returned coins (queen back to centre, penalty coin back
to centre — algorithm in 6.4), so the clients just snap to it.

When the game ends send `shot_result` with `game_over:true` (no `next_seat` needed)
and then `finished` as the next version.

### 4.2 `aim` (not versioned)

```json
{ "type":"aim", "game_id":7, "seat":"player1", "slider":312.5, "aiming":true, "angle":-1.57, "power":0.42 }
```
`slider` is the striker coordinate along the baseline (x for South/North, y for
West/East). Pure relay; clients ignore it when it is not the active seat.

---------------------------------------------------------------------------------------

## 5. Game snapshot (`data.game`, `created.game`, `started.game`)

```json
{
  "id": 7, "room_id": 123, "host_user_id": "55",
  "mode": "duo",                     // duo | doubles
  "entry_fee": 500, "prize_pool": 950, "commission": 50,
  "status": "playing",               // lobby | playing | finished | cancelled
  "current_seat": "player1",
  "turn_deadline_at": "2026-10-06T10:00:20Z",
  "version": 12, "shot_seq": 12,
  "queen_status": "unpocketed", "queen_seat": null,
  "scores": { "player1": 0, "player2": 0 },
  "pieces": [],                      // [] = standard opening layout
  "players": [
    { "user_id":"55", "seat":"player1", "name":"Ali", "avatar":"profile/a.jpg",
      "is_host":true, "status":"joined" }   // joined | winner | loser | forfeited
  ],
  "winner_user_id": null
}
```
(`prize_pool = entry_fee × players`, `commission = round(prize_pool × commission_rate)`.)

---------------------------------------------------------------------------------------

## 6. Rules the server must apply on `shot/result`

Let *A* = the seat that shot, *O* = the opposing side (duo: the other player; doubles:
the other team). A's colour = white for `player1/3`, black for `player2/4`.
Compute `pocketed_now` = pieces that were un-pocketed before this shot and are
`pocketed:true` in the report. Points: **white coin 10, black coin 5, queen 25 (only when
covered)**. Scores are clamped to 0…999.

1. **Striker foul** (`striker_pocketed == true`): turn ends (`next_seat` = next in order).
   If A has pocketed ≥1 of its own colour already → return one of them to the board
   (6.4) and A's score −10 (white) / −5 (black). If the queen was *waitingForCover* by
   A → queen returns to centre, status `unpocketed`. `foul:"striker_pocket"`.
   Other coins pocketed in the same shot stay pocketed and are not scored; only the
   penalty above applies.
2. Otherwise count `own` (A's colour) and `opp` (O's colour) coins in `pocketed_now`.
   Add `own×points` to A's score and `opp×points` to O's score.
3. **Queen**:
   * queen in `pocketed_now` and `own>0` → covered at once: `queen_status=covered`,
     A +25, A continues.
   * queen in `pocketed_now`, `own==0` → `waitingForCover`, `queen_seat=A`, A continues
     (one more shot to cover).
   * queen was `waitingForCover` by A and `own>0` → `covered`, A +25, A continues.
   * queen was `waitingForCover` by A and `own==0` → queen back to centre,
     `unpocketed`, turn passes.
4. Normal shot (no queen event): `own>0` → A continues; else turn passes
   (`opp>0` or a miss both end the turn).
5. **Win**: after the shot, if A's total pocketed coins of its colour is **9**:
   * queen `covered` → A (and partner in doubles) **win**, `game_over:true`.
   * queen not covered → the last coin goes back to the centre (6.4), A −10/−5,
     turn passes (ICF last-coin rule).
   Else if O's total pocketed is 9 and queen `covered` → O wins.
   Safety: if the queen is covered, nothing of the queen is on the board and one colour
   has no coins left on the board → that colour wins.
6. **Timeout** (`turn_timeout`): turn passes with `foul:"timeout"`; if the queen was
   waiting for cover by that seat it returns to the centre. No score change.
   Use the board as last stored (a timeout during a shot in flight uses the
   previously stored `pieces`).

`notice` is the text the clients show on the board ("FOUL! Striker Pocketed",
"QUEEN COVERED! +25 PTS", "Queen NOT covered! Returned to center",
"Turn passed to {name}", ...). Free text, ≤ 80 chars. `notice_color`: red `4293870703`
(foul), amber `4294226944` (queen), blue `4281518328` (normal).

### 6.4 Returning a coin to the centre

```
target = (370, 370); offset = 0
while any un-pocketed piece (other than itself) is within 31.0 of target:
    offset += 15; target = (370, 370 + offset)
set piece.x,y = target; piece.pocketed = false
```
For a "return one own coin" pick the highest `id` of that colour that is pocketed.

### 6.5 Timers

* `turn_timeout_seconds` (20) starts when a turn begins (`started`, every `shot_result`).
* While a shot is in flight the deadline is `shot time + 25 s` (settle window). If the
  shooter's result never arrives → treat as `turn_timeout` for that seat.
* Three consecutive timeouts by the same seat → that seat forfeits (suggested).
* `lobby_timeout_seconds` (180): unstarted lobby → `cancelled` / `lobby_expired`, refund.

---------------------------------------------------------------------------------------

## 7. Validation of the reported board (anti-cheat)

Reject with `INVALID_SHOT` (and keep the previous board) when any of these fails:

* exactly the 19 known ids, correct `type` per id, all numbers finite;
* a coin that was **pocketed before cannot be un-pocketed** (only the server returns
  coins, never the client);
* un-pocketed coins are inside the field (34…706) and not overlapping each other by more
  than ~2 units;
* number of newly pocketed coins ≤ 8 for one shot;
* result arrives from the shooter, for the in-flight `shot_id`, once.

Optional hardening (later): port `CaromPhysicsEngine` (`carom_physics.dart`) to PHP and
re-simulate from the `shot` data to compare; or accept the client result only when two
clients agree.

---------------------------------------------------------------------------------------

## 8. Wallet, forfeits, edge cases

* **Create / join:** charge `entry_fee` immediately (`INSUFFICIENT_BALANCE` if short),
  push `wallet_updated` (`reason:"fee"`).
* **Cancel / lobby leave / lobby expiry:** refund (`reason:"refund"`).
* **Finish:** winner pool = `prize_pool − commission`; one winner → everything,
  doubles → split equally between partners. Push `wallet_updated` (`reason:"prize"`)
  to the winners, publish `finished` with `prize` per winner.
* **Player leaves while playing:**
  * duo → the leaver forfeits, the other player wins immediately (`finished`).
  * doubles → publish `player_left` (`reason:"forfeit"`), the seat is skipped in the turn
    order; if both seats of a team are gone, the other team wins.
  * Do the same on LiveKit/room disconnect after a grace period (suggested 20 s).
* **Host leaves the lobby:** `cancelled` / `host_left` + refunds.
* **Spectators** receive every event and can call `GET /games/active` any time.
* **Late joiners / reconnects** use `GET /games/active?room_id=` — the snapshot must
  always contain the latest `pieces`, `scores`, `queen_status`, `current_seat`,
  `turn_deadline_at`, `shot_seq`, `version`.
* One live game per room; creating while another game (Ludo or Carrom) is live →
  `ROOM_HAS_ACTIVE_GAME`.

### Error codes the client already maps to friendly text

`NOT_IN_ROOM, ROOM_HAS_ACTIVE_GAME, INVALID_FEE, INSUFFICIENT_BALANCE, GAME_NOT_FOUND,
GAME_STARTED, GAME_FULL, ALREADY_JOINED, NOT_HOST, NEED_MORE_PLAYERS, NOT_YOUR_TURN,
INVALID_SHOT, STALE_VERSION, GAME_ENDED`.

---------------------------------------------------------------------------------------

## 9. Backend checklist

- [ ] Tables: `carom_games`, `carom_players` (seat, status, user), piece JSON column, `shot_seq`, `version`, `queen_status/seat`, `scores`.
- [ ] 9 REST endpoints above + config.
- [ ] Publish `carom_event` frames (envelope in section 1) after commit, version +1 each.
- [ ] Rules engine (section 6) — the only place scores / winner are decided.
- [ ] Board validation (section 7).
- [ ] Turn / settle / lobby timers (cron or delayed job) that publish `turn_timeout` / `cancelled`.
- [ ] Wallet charge / refund / prize + `wallet_updated`.
- [ ] Forfeit on leave / disconnect.

### Quick test script (two phones in one room)

1. Phone A: More options → Carrom → 1 vs 1 → Create. Phone B sees the invite → Accept.
2. A taps Start. Both see the board, A's avatar ring counts down.
3. A shoots. B must see the striker move **while A is aiming** (`aim`) and the same shot
   play out (`shot`). Within ~1 s after the coins stop both boards snap to `shot_result`.
4. Pocket a coin → score and "continues" notice; miss → turn goes to B.
5. B leaves mid-game → A gets `finished` with the prize and a wallet update.
6. A third phone joins late → sees the live board via `GET /games/active`.

---------------------------------------------------------------------------------------

## 10. Speed — what the backend must do so the game feels instant

Fast carrom games work because the phone simulates the physics itself and the network
only carries tiny messages (aim, shot). Our client already does that. What decides the
"feel" now is how quickly the backend relays those messages. Requirements:

1. **Relay first, save later.** For `/aim` and `/shot`: validate in memory, publish the
   event immediately, and write to the DB asynchronously (queue). Target: request in →
   event out in **< 50 ms**. Never run a DB transaction before publishing `aim`.
2. **Keep live game state in Redis** (current seat, shot_seq, deadline, pieces, scores).
   Use the DB only as a persisted copy and for wallet. `/aim` must not touch the DB at all.
3. **Aim must be low-latency.** REST per aim packet (~8/s) is the weakest part. Best
   option: let clients publish `aim` directly on the room channel (Centrifugo client
   publish to the room channel with a permission check on current seat) or via a LiveKit
   data channel (`unreliable`, topic `carom_aim`, JSON payload as in 4.2). If you
   do this, set `config.aim_sync` to the transport you chose and tell the app team;
   the client only needs a small change.
4. **`shot_result` must not wait on slow work.** Compute the rules in memory, publish
   `shot_result`, then persist and do wallet work (prize/`finished` can follow a few ms
   later as its own event).
5. **Add `server_time_ms` (unix ms)** to `shot`, `shot_result`, `turn_timeout` and the
   snapshot, so the client can correct clock drift for the turn ring and replay shots in sync.
6. **Region / hosting:** API and realtime server in the same region as most users;
   keep-alive + HTTP/2 or HTTP/3 enabled; no extra middleware (heavy logging, large
   resource transformers) on `/aim`, `/shot`, `/shot/result`.
7. **Payload size:** `pieces` only in `shot_result` and snapshots (not in `shot`/`aim`),
   round coordinates to 2 decimals, gzip enabled.
8. **Idempotent + ordered:** keep `version` increments atomic (Redis INCR) so two
   quick events (`shot` then `shot_result`) can never arrive out of order.

Measure: log `request_received → event_published` for aim/shot/result; p95 should stay
under 80 ms. Reply to the app team with the measured numbers and the transport chosen
for `aim`, and the client will switch to it.

---------------------------------------------------------------------------------------

## 11. Our stack: PHP (Laravel) + Centrifugo — concrete recommendations

PHP-FPM keeps no state between requests, so "in memory" in section 10 means **Redis**.

1. **State in Redis.** Key `carom:game:{id}` (hash/JSON: seat, shot_seq, deadline, pieces,
   scores, queen, status) and `carom:game:{id}:version` (use `INCR`, atomic). Wrap
   read-modify-write of one game in a short Redis lock (`SET NX PX 2000`, or
   `Cache::lock`) so two requests can never produce the same `version`.
2. **Publish through the Centrifugo HTTP API** (`/api/publish`, keep-alive connection,
   short timeout, same helper as the other room frames). Do it **before** the slow work:
   - `/shot`: validate against Redis → `INCR` version → publish `shot` → return the
     response → persist to MySQL after the response (`dispatch(...)->afterResponse()`
     or `fastcgi_finish_request()`).
   - `/shot/result`: validate → apply rules → update Redis → publish `shot_result`
     → return → then MySQL write, wallet, and, if the game ended, `finished`.
   Never put MySQL inside the path that precedes the publish. Wallet/prize work
   (MySQL transaction) is the only place a DB transaction is required.
3. **Aim over Centrifugo directly (no PHP).** Create a Centrifugo namespace `carom`
   with `allow_subscribe_for_client` + `allow_publish_for_subscriber` (or a publish
   proxy that checks "is this user the current seat" against Redis — preferred, cheap).
   Channel: `carom:room_{room_id}`. The shooter's phone publishes `aim` frames straight to that
   channel; other phones receive them with ~20–50 ms latency and PHP is not involved.
   Keep `shot`, `shot_result`, etc. on the normal room channel exactly as in sections 1/4.
   Set `history_size`/`history_ttl` to 0 for this namespace (aim is disposable).
   → Tell the app team the namespace/channel names once configured; the client will
   subscribe to it, publish `aim` frames there and stop calling `POST /aim`.
4. **Timers:** use Laravel scheduler/queue with delayed jobs (or a Redis sorted set
   polled every second by a worker) for `turn_timeout`, settle-window timeout and lobby
   expiry. On job run, re-check the Redis `deadline`/`shot_seq` so a stale job does nothing.
5. **Octane / Swoole (optional):** if the API is slow to boot per request, Laravel Octane
   removes the per-request bootstrap cost on these 3 hot endpoints.
6. **Measure** `request received → Centrifugo publish returned` for `/shot` and
   `/shot/result`; goal p95 < 80 ms. Send those numbers back.
