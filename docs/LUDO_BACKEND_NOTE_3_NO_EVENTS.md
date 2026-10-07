# Ludo / Carrom – realtime events are NOT arriving now (Backend Note #3)

## Symptom (latest test, game 34, room 326)
- `POST /api/ludo/games` -> 201, game 34 created (1.9 s).
- But the phone receives **no `ludo_event`** frames at all (no `created`, no `player_joined`, nothing after the 141-byte frame).
  Before, every event arrived in the room data channel within ~10 ms of the REST call.

## Why we think it happened
In Note #1/#2 we asked to publish each event through ONE channel only (events were arriving twice).
How the app receives game events today:
- The app gets `ludo_event` / `carom_event` ONLY from the **room's LiveKit data channel** (log line `UTDRoomManager Data received`, JSON `{"Action":"ludo","MessageContent":{"message":"ludo_event",...}}`).
- The app does **NOT** subscribe to any Centrifugo channel for games. Its Centrifugo connection only has the `banner:*` channels, the user's DM channel and group-chat channels.
So if the backend now publishes game events only to Centrifugo (or stopped LiveKit `sendData`), the app sees nothing.

## What to do (pick ONE)
**Option A (fastest, no app release):** publish Ludo/Carrom events to the room again via LiveKit data (`RoomService.SendData`, room = the live room, reliable, to all participants) – exactly the payload used before. You may keep Centrifugo as a second publish; the app de-duplicates by `version`.

**Option B (cleaner, needs a small app change on our side):** keep Centrifugo only. Then give us:
1. channel name, e.g. `game:room:{room_id}` (or `ludo:{game_id}` / `carom:{game_id}`),
2. subscription token endpoint (or `channels` claim in `/api/centrifugo/token`) allowing every user in that room to subscribe,
3. history/recovery enabled (`history_size`, `history_ttl`, `force_recovery`) so a reconnect gets missed events.
We will then subscribe in the app when a room is joined.

## Check on your side right now
1. In Laravel/Centrifugo logs: is the `created` event for game 34 published? To which channel?
2. Is LiveKit `sendData` still called for `ludo_event` / `carom_event`? (it was working before the "one channel" change)
3. Test with 2 phones: after `POST /games` the host must receive `type:"created"`, after `/join` both must receive `player_joined`.

## Still open (unchanged)
- `POST /roll`, `/move`, `/games` take 1.2–2.3 s -> target < 150 ms.
- Keep versions consecutive, `last_dice=null` after turn change, `landed_step` in `moved` for rocket.
