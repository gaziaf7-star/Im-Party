# Publishing `utd_live_room_kit` to pub.dev

Releases are **tag-driven** (pub.dev refuses branch-triggered publishes). The
tag is created automatically when you bump the version on `main`, and a GitHub
Action then publishes to pub.dev over OIDC (no long-lived secrets).

Workflows: [.github/workflows/release-on-main.yml](.github/workflows/release-on-main.yml)
and [.github/workflows/publish.yml](.github/workflows/publish.yml).

## One-time setup (a pub.dev uploader must do this)

pub.dev cannot automate the *first* publish or its own config, so do these once:

1. **First publish (manual).** From this directory, signed in to pub.dev:
   ```sh
   flutter pub publish
   ```
   This claims the name `utd_live_room_kit` and publishes the current version.

2. **Enable automated publishing** at
   <https://pub.dev/packages/utd_live_room_kit/admin> → *Automated publishing* →
   **Enable publishing from GitHub Actions**:
   - Repository: `Company-utd-projects/live_room_kit`
   - Tag pattern: `v{{version}}`

3. **Add the release token** (needed for "push to main → publish"): create a PAT
   (classic `repo` scope, or fine-grained on this repo with *Contents: Read/Write*)
   and save it as repo secret **`RELEASE_TOKEN`**
   (Settings → Secrets and variables → Actions → New repository secret).
   Required because a tag pushed by the default `GITHUB_TOKEN` will not trigger
   the publish workflow.

## Day-to-day releasing

1. Bump `version:` in `pubspec.yaml` and add a `CHANGELOG.md` entry.
2. Commit and push to `main`.
3. `release-on-main.yml` pushes tag `vX.Y.Z`; `publish.yml` publishes it.

pub.dev rejects duplicate versions, so nothing publishes unless the version changed.

**Manual alternative:** `git tag v1.2.3 && git push origin v1.2.3`

**Without `RELEASE_TOKEN`:** the tag is still created on a version bump, but you
must run the publish job manually — Actions → *Publish to pub.dev* → Run workflow → ref `vX.Y.Z`.
