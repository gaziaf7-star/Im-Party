# White-label merge tooling

`meow-live` is the **master**. Every client app (jo, lumio, kitty, …) is a
branch that receives code/feature changes from the master via merge, while
keeping its own brand identity.

## Merge master → client(s)

```bash
tools/merge-from-master.sh jo                # merge, verify locally, no push
tools/merge-from-master.sh jo lumio --push   # merge into several + push
```

## What stays the client's, automatically

| Identity | How it is kept | Where |
| --- | --- | --- |
| Firebase config | `merge=ours` | `google-services.json`, `GoogleService-Info.plist`, `firebase.json` |
| App / launcher icon, splash | `merge=ours` | `android/.../mipmap*`, `drawable*`, `ios/.../Assets.xcassets` |
| In-app brand art (logo, ui icons) | `merge=ours` | `assets/**` images |
| applicationId, app label, iOS name | re-applied from registry | `tools/clients.sh` |

New asset files added on the master still flow to clients (a new feature's icon
is delivered); only files that exist on **both** sides keep the client's version.

## Onboarding a new client

1. Add a row for the client to each array in `tools/clients.sh`.
2. Ensure the client branch already carries its own Firebase config, icons,
   splash and brand assets (these are never taken from the master).
3. Run `tools/merge-from-master.sh <client>`.

> Per-clone requirement (the script sets it for you):
> `git config merge.ours.driver true`

## Backend

The backend (`Eagle` repo) carries **no** per-client identity in code — Firebase,
storage, payment and brand all come from each client's admin panel + DB. Its
`tools/merge-from-master.sh` is therefore a plain code merge with no re-apply.
