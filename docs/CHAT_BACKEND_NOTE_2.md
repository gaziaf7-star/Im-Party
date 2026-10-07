# Chat / Inbox – Backend Note #2 (after photo-send retest)

## Verified OK (thanks)
- `POST /api/chatVideo` returns `upload_url` + `name` (0.7–1.7 s).
- `PUT upload_url` stores the file; `https://iamparty.linlive.fr/storage/chat/<name>` returns `200 image/jpeg` with the exact byte size.
- `POST /api/Chat-Message` returns `type:"img"` and `albums:[{file,...}]`.
The app side is fixed for the formats below. Please keep them stable.

## Contract the app relies on (do not change without telling us)
- Photo message: `type: "img"` (gif: `"gif"`, voice: `"voice"`/`"audio"`, video: `"video"`).
- `albums` is an ARRAY; the app shows `albums[0].file` (absolute URL).
- Same shape in `/Chat-Message` response, `/v1/sync/rooms` -> `last_message`, realtime push and message history.

## 1. Latency – everything in chat is 0.7–3.5 s (HIGH)
Measured on a phone in Bangladesh:

| Endpoint | Times seen |
|---|---|
| POST /Chat-Message | 0.8 – 1.7 s |
| POST /Chat-room/{id}/read | 0.8 – **3.5 s** |
| GET /v1/sync/rooms | 0.7 – 2.1 s |
| GET /user-status/{id} | 0.7 – **6.5 s** |
| POST /centrifugo/token | 0.7 – 2.2 s |
| GET /role-requests?status=pending | 0.6 – 1.9 s |
| POST /chatVideo | 0.7 – 1.7 s |
Target: < 300 ms each (read/user-status/token < 100 ms).
- Redis cache for `user-status`, `centrifugo/token`, `role-requests`, first page of `sync/rooms`.
- `Chat-room/{id}/read`: just set `last_read_seq` (single UPDATE / Redis) and return; do counters/notifications in a queue.
- `Chat-Message`: publish to Centrifugo first, persist/notify after the response; don't load the full user/room each time.
- Octane (Swoole/RoadRunner) or at least opcache + `config:cache` + `route:cache`.

## 2. Too many repeated calls from the app side too (info)
On every chat open the app calls `user-status`, `role-requests`, `room-support`, `sync/rooms`, `centrifugo/token` again. We will reduce this in the app; please also add `Cache-Control: private, max-age=10` (or ETag/304) on `user-status`, `role-requests`, `sync/rooms`.

## 3. `user-status` data looks stale
`GET /user-status/18` keeps returning `online:0, last_seen_at: 2026-10-07T05:27:30` for hours while the other user is active. Please update `last_seen_at` on activity (socket connect/disconnect or any authenticated request) and keep it in Redis.

## 4. Old messages
Messages saved before today have `albums` fine on the server; only the app's local copy was wrong. Nothing to do on the server.

## Test checklist
1. Send photo -> `/chatVideo` < 300 ms, PUT 200, `/Chat-Message` < 300 ms.
2. Peer receives the photo via realtime with `albums[0].file`.
3. `/Chat-room/{id}/read` < 100 ms, `/user-status/{id}` < 100 ms and fresh.
