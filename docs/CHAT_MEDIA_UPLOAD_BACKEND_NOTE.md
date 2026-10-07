# Chat (inbox) image / video send fails – Backend Note

## What the app log shows
When a user sends a photo/video in the inbox, the app first asks the server for an upload link:

```
POST https://iamparty.linlive.fr/api/chatVideo
Authorization: Bearer <token>
Body: { "name": "1000049836.jpg", "type": "image/jpeg", "size": 1094238 }

-> 500 Internal Server Error  (4.7 s)
{ "success": false, "message": "Ops, something went wrong, please try again later", "data": null, "paginates": null }
```

The request is valid (name, mime type, size are all present). The failure is on the server, so the message stays in the chat as "Resend Message" and the file is never uploaded.

## What the app expects from `POST /api/chatVideo`
Status 200 with JSON:
```
{ "upload_url": "<pre-signed PUT url>", "name": "<stored object name, e.g. chat/xyz.jpg>" }
```
Then the app does `PUT <upload_url>` with the raw bytes (header `Content-Type` = the same mime type) and treats any 2xx as success. The public URL shown in the chat is built from `name` (same helper as profile images), so `name` must be the object path under the public storage root.

## Please check (most likely causes of the 500)
1. Laravel log (`storage/logs/laravel.log`) at the time of the request – the real exception is there.
2. Storage driver credentials (S3 / MinIO / R2 / DO Spaces): key, secret, bucket, region, endpoint, `use_path_style_endpoint`. A wrong/expired key or missing bucket gives exactly this 500.
3. The pre-signed URL creation (`temporaryUploadUrl` / `createPresignedRequest`): content type and size must be allowed; expiry >= 10 minutes (video uploads are slow).
4. Bucket CORS / policy allows `PUT` from the app and the object ACL/public-read so `EndPoints.getImage(name)` can display it.
5. Max size limits (nginx `client_max_body_size`, PHP `upload_max_filesize`) do not apply to the PUT itself, but make sure the endpoint doesn't reject `size` ~1 MB – 100 MB.
6. Return proper errors: 422 with a clear message for bad input, never a generic 500.

## Speed
Other chat calls in the same log are slow too: `/api/centrifugo/token` 1.6 s, `/api/v1/sync/rooms` 3.3 s, `/api/user-status/{id}` 1.3–1.9 s, `/api/role-requests` 1.1–1.9 s. Target < 300 ms (cache the sync/rooms list, Redis for user-status).

## Test checklist
1. `POST /api/chatVideo` with the body above returns 200 + `upload_url` + `name` in < 500 ms.
2. `PUT upload_url` with the image bytes returns 200.
3. `GET <public base>/<name>` shows the image.
4. Same for a ~20 MB mp4 (`video/mp4`).
