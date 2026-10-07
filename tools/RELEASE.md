# Release runbook — master → client (no more mess)

`meow-live` is the **master**. We fix/build on it, then ship to each client.
Identity is preserved on every merge by THREE layers:
1. **Firebase config** — `.gitattributes` merge=ours keeps the client's version.
2. **applicationId / label / iOS name** — re-applied from `tools/clients.sh`.
3. **Brand assets (logo / launcher icon / splash + color)** — re-derived from
   `tools/brand/<client>/` by `tools/apply-identity.sh`.

> ⚠️ merge=ours is NOT enough on its own: it only kicks in on a *conflicting*
> change. When master changes a shared brand asset the client didn't also touch
> (e.g. `assets/images/logo (2).png`, the generated splash, the launcher icon), git
> applies master's version CLEANLY and the **Meow** identity leaks into the
> client. This shipped once (jo splash + tiko icon/splash showed the Meow logo).
> `apply-identity.sh` re-derives every brand asset from a per-client source the
> master doesn't have, so it can never leak again. `merge-from-master.sh` runs it
> automatically after each merge.

## Branch map (the source of truth)

| Client | App branch | Backend branch | Android package | Build dir |
| --- | --- | --- | --- | --- |
| **meow** (master) | `meow-live` | `meow-live` | `com.jo.chat.app` | — |
| **jo** | `jo_release` | `jo` | `com.jo.live.app` | `../../jo-live` |
| lumio | _add_ | `lumio` | _add_ | _add_ |
| kitty | _add_ | `kitty-voice` | _add_ | _add_ |

> Stale, do not use: `jo_live_v2`, `jo_merge` (old `com.jo.chat.app` era).

## Release a client — e.g. `jo`

### 1. Backend (push triggers the client's deploy pipeline)
```bash
cd MeowLive_new/backend
git fetch origin meow-live && git checkout meow-live && git pull
tools/merge-from-master.sh jo --push
```

### 2. App (build a signed AAB + upload)
```bash
cd jo-live                       # the client's app build checkout (jo_release)
git fetch origin
tools/merge-from-master.sh jo     # merge master fixes; jo identity kept automatically
 bump versionCode# bump versionCode + build the signed AAB
# -> upload the printed AAB to Play Console (com.jo.live.app) -> Production
```

That's it. `merge-from-master.sh` keeps jo's Firebase/icons/splash/brand
(merge=ours) and re-applies applicationId/label/iOS-name; `release-app.sh <client>`
bumps the version and produces the signed bundle.

## Several clients at once
```bash
# backend
tools/merge-from-master.sh jo lumio kitty --push
# app: one build dir per client (each on its own branch), run release-app.sh in each
```

## Onboarding a new client (one-time)
1. Add the client to the **Branch map** above + to `tools/clients.sh`
   (app: branch + applicationId + label + iOS name) and to
   `backend/tools/merge-from-master.sh` (`CLIENT_BACKEND_BRANCH`).
2. On the new client branch, commit its own identity: `google-services.json`,
   `GoogleService-Info.plist`, `applicationId`, label, iOS display name,
   `android/key.properties` + keystore, `android/fastlane/{Appfile,Fastfile}`
   package_name + Play service-account json, AndroidManifest deep-link host.
3. Commit the client's **brand source** under `tools/brand/<client>/`:
   - `logo.png`  — splash + in-app brand logo (square, ~1024).
   - `icon.png`  — launcher icon source (1024×1024, no transparency).
   - `splash-color` — optional, hex of the splash background (e.g. `#FEC901`).
   Then run `tools/apply-identity.sh <client>` once to generate the splash +
   launcher icons from them, and commit the result. (Every later merge re-runs
   this automatically, so the identity is locked in.)
4. Future releases = merge + build; identity is re-applied automatically.

### One-button onboarding (the goal)
Drop the three brand files into `tools/brand/<client>/`, add the client row to
`tools/clients.sh`, drop in `google-services.json`/keystore, then:
`tools/apply-identity.sh <client> && tools/release-app.sh <client>`.

## Notes / landmines fixed
- jo identity is **committed** on `jo_release` (was uncommitted mods in `jo-live`).
- jo `android/fastlane` package_name must be `com.jo.live.app` (old config said
  `com.jo.chat.app`). The Play **service-account json** must belong to the
  account that owns `com.jo.live.app` (the new account), not the old one.
- Keystore (`android/key.jks`) is gitignored and stays per-client on the machine.
