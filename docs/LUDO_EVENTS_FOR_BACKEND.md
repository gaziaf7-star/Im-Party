# Ludo — realtime events: what the backend must send

The REST endpoints already work (config / create / cancel tested from the app).
What is NOT confirmed yet is that the **realtime events reach every client in the room**.
The app now logs every received frame as `[Ludo] event type=... game=... v=...`.
If that line never appears on a second phone, the event is not being published (or is published in the wrong shape).

## 1. How to publish (same way as the existing room frames)

Publish every Ludo event to the **room channel** using the same helper that already
sends other room frames (the one behind `RoomDataTrait::pushRoomData` — it is what
lucky-box / super-boom / room-support events use). Do NOT invent a new channel.

The client reads the frame as:

```json
{
  "Action": "ludo",
  "MessageContent": {
    "message": "ludo_event",
    "type": "created",
    "game_id": 1,
    "version": 1,
    "...": "event specific fields"
  }
}
```

Rules:
- `MessageContent.message` MUST be exactly `"ludo_event"` (the app drops frames whose
  `message` key is missing or unknown).
- `type` is inside `MessageContent` (not at the top level).
- `MessageContent` may be a JSON object or a JSON string — both are accepted.
- Every event except `wallet_updated` carries `game_id` and an integer `version` that
  increases by exactly 1 for every state change of that game (create = 1, join = 2 …).
  The app applies events strictly in version order; if it sees a gap it re-fetches
  `GET /api/ludo/games/active?room_id=…`.
- Send the event to **everyone in the room, including the user who caused it** (the app
  de-duplicates by `version`).
- Publish **after** the DB transaction has committed (otherwise a client that reacts
  to the event and calls the snapshot API can read stale data).

## 2. Events and required fields

| `type` | When | Required fields |
|---|---|---|
| `created` | game created | `game` (full snapshot), `host {id,name,avatar}`, `entry_fee` |
| `player_joined` | someone joined | `player {user_id,color,name,avatar}`, `players_count` |
| `player_left` | left / forfeit | `user_id`, `color`, `reason` (`left` \| `forfeit` \| `disconnect`) |
| `started` | host started | `game` (full snapshot) |
| `rolled` | dice rolled | `color`, `user_id`, `dice`, `auto` |
| `moved` | token moved | `color`, `token_slot`, `from_step`, `to_step`, `captured`, `reached_home` |
| `turn` | turn changes **and also when the same player gets a bonus roll** | `current_color`, `turn_deadline_at` |
| `finished` | game over | `winner {id,name,avatar,color}`, `prize`, `ranking [{rank,user_id,color,name}]` |
| `cancelled` | cancelled | `reason` (`host_cancelled` \| `lobby_expired` \| `host_left` \| `server_error`) |
| `wallet_updated` | **only to the affected user** | `balance`, `delta`, `reason` (`fee` \| `prize` \| `refund`) |

Details the app depends on:
- `avatar` may be a relative path (`profile/xxx.jpg`) — the app resolves it.
- `captured`: either `[{"color":"red","token_slot":2}]` (preferred) or `["red"]`.
- Step numbering: `-1` base, `0..50` shared track, `51..56` home lane, `57` home (finished).
- After a `moved` event the app assumes the same player may roll again until it receives
  `turn`. So **always send `turn` after `moved`** (with the same colour when the player
  earned a bonus roll, otherwise the next colour).
- `rolled` with no movable token: send `turn` right after it (the app waits for it).
- `created` must carry the full `game` object (same shape as the REST response).

## 3. Delivery checklist (please test each)

1. User A creates a game → user B (other phone, same room) receives `created`
   → B sees the Accept / Reject popup, console shows `[Ludo] event type=created`.
2. B accepts (POST join) → A and B receive `player_joined` (version 2).
3. A starts → both receive `started`; board appears.
4. A rolls → both receive `rolled`; A moves → both receive `moved` then `turn`.
5. A user who is only watching (never joined) also receives all of the above.
6. Cancel in lobby → everyone receives `cancelled`; refund → payers receive `wallet_updated`.
7. Finish → everyone receives `finished`, winner receives `wallet_updated` (`prize`).
8. Versions are consecutive 1,2,3… with no gaps and no duplicates.

## 4. Quick way to debug

Ask the tester to run the app and filter the console by `[Ludo] event`.
- Nothing printed on the 2nd phone → event not published to the room channel.
- `type=null` or `message` missing → wrong envelope (see section 1).
- `v=` jumps by more than 1 → version counter is not incremented per event.
