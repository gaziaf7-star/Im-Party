# Carrom – Backend Note #2 (from 2-phone test logs, game 15, room 326)

Stack: PHP/Laravel + Centrifugo. Client is patched (aim throttled, 1 request in flight). The lag now comes from the server side below.

## 1. `POST /carom/games/{id}/aim` is far too slow and too chatty (HIGH)
One game, one phone: ~35 aim requests, each **1.0 – 2.9 s** (fast phone 1032–1807 ms, second phone 1210–2871 ms).
Aim is a high-frequency, throw-away signal (slider position / angle / power while the shooter drags). It must NOT go through the normal REST + DB path.

Do one of these (best first):
1. **Client publishes directly to Centrifugo** channel `carom:{game_id}` (publish permission only for the current shooter, via a subscription/connection token claim). No Laravel hit at all. Tell us the namespace/channel and we switch the client in minutes.
2. If it must stay REST: make `/aim` a "fire and forget" endpoint – validate shooter (Redis), `publish` to Centrifugo, return `204` immediately. No DB write, no logging, no user-profile loading. Target < 30 ms.
3. Rate-limit per game (max 5/s) and drop silently; never return an error to the client.

Event to the room: `{Action:"carom", MessageContent:{message:"carom_event", type:"aim", game_id, user_id, slider_x, aiming, angle, power}}` – unversioned, not stored.

## 2. Shot / shot_result latency (HIGH)
| Request | Time |
|---|---|
| POST /shot | 1335 ms, 1643 ms, 2639 ms |
| POST /shot/result | 1215 ms, 1351 ms, 2042 ms |
Target < 150 ms server time each.
- Publish the `shot` / `shot_result` event to Centrifugo FIRST, persist/log/stats after the response (queue).
- Game state in Redis, one row lock only around the state change.
- Small payloads: don't attach full user profiles to events/responses (`user_id,name,avatar` is enough).
- Octane (Swoole/RoadRunner) or at least opcache + `config:cache` + `route:cache`.
Please log `request_time_ms` server-side for `/shot`, `/shot/result`, `/aim` so we can see DB vs publish vs serialization.

## 3. Every event arrives twice
`shot v11`, `shot_result v12`, … each appear twice on each phone (Centrifugo + LiveKit data). Client de-duplicates by `version`, but please publish via ONE channel only (Centrifugo). It halves traffic and CPU on the phones (part of the heat/lag after a game).

## 4. Turn timeout
`turn_timeout v10` is correct. Keep timeout auto-play for disconnected/backgrounded players so the game never waits.

## 5. Keep as is
- Versions are consecutive (no gaps) – good.
- Envelope `{Action:"carom", MessageContent:{message:"carom_event", type, game_id, version, ...}}`.

## Test checklist
1. 1 full turn on 2 phones: `/aim` p95 < 30 ms (or no REST aim calls at all), `/shot` and `/shot/result` p95 < 150 ms.
2. Each event delivered once per phone.
3. Phone stays cool after leaving the room (client side already stops engine/audio on exit).
