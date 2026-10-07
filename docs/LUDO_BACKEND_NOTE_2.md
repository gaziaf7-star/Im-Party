# Ludo – Backend Note #2 (after retest, games 32 & 33)

## Already fixed by backend (thanks) – verified in logs
- Versions are consecutive (no gaps), no more `GET /active` after every roll.
- `last_dice` is `null` after a turn change, `dice_pending` field exists.
- Magic items work (rocket +3, dice, crown…), `magic_item` is sent.

## 1. LATENCY – the one thing left (HIGH, this is the "lag")
Measured on real phones (Bangladesh, mobile data):

| Request | Time |
|---|---|
| POST /roll | 1644 ms, 1679 ms, 1736 ms, **2294 ms** |
| POST /move | **1251 ms** |
| GET /active | 725–1492 ms |

Target: roll/move < 150 ms server time (network adds ~100 ms).
Do, in this order:
1. **Publish to Centrifugo first, write DB after.** Load state from Redis, compute the move, `publish` the event, return the HTTP response, then persist/log/stats in a queued job.
2. Row lock only around the state change (not around profile loading, wallet, logs).
3. Don't build full user profiles (covers, country, birthday…) on every roll/move response. Send `user_id,color,name,avatar` only. Response size is ~4 KB, should be < 1 KB.
4. Octane (Swoole/RoadRunner) or at least opcache + `config:cache` + `route:cache`; no per-request heavy middleware on `/ludo/*`.
5. Keep game state in Redis; `/active` reads Redis, never rebuilds from many DB queries.
Please log `request_time_ms` server side for roll/move so we can see where the time goes (DB vs publish vs serialization).

## 2. Send the rocket/magic path in the `moved` event (MEDIUM)
Today `moved` has `from_step`, `to_step` (final, e.g. 0 -> 6) and `magic_item: "rocket"`.
The client needs the step where the dice ended, so every phone can show: walk to the rocket square, pause, jump.
Please add to `moved` (and to the roll/move REST response when `auto_moved`):
```
"landed_step": 3,        // from_step + dice, before the item effect
"to_step": 6,            // final step after the effect
"magic_item": "rocket",
"dice": 3
```
Same for `battery` (+2). For `dice` item: keep `extra_turn: true`. `crown`/`ice`: tell us the effect fields you want to show.

## 3. Event delivery
- Each event still arrives twice (Centrifugo + LiveKit data). Fine, client de-duplicates by version, but if you can publish through ONE channel only it halves traffic and CPU on the phones.
- Keep order guarantee: `rolled` -> `moved` -> `turn` strictly in that version order (it is right now).

## 4. Turn timeout
In game 33 two `turn` events came 20 s and 60 s apart with no player action (v41, v42): make sure a timeout of a disconnected/backgrounded player auto-plays (roll + auto-move) and does not leave the game waiting for 60 s.

## Test checklist
1. 20 rolls on 2 phones: `request_time_ms` p95 < 150 ms for roll/move.
2. Rocket landing: `moved` contains `landed_step` and `to_step`.
3. Backgrounded phone: game continues by auto-play within the 7 s timeout.
