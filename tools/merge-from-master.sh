#!/usr/bin/env bash
# Merge master (meow-live) code/features INTO one or more client app branches
# while preserving each client's white-label identity.
#
#   tools/merge-from-master.sh <client> [<client> ...] [--push]
#   tools/merge-from-master.sh jo                 # merge into jo, do NOT push
#   tools/merge-from-master.sh jo lumio --push    # merge into both and push
#
# Identity is preserved three ways:
#   1. Whole-file (Firebase config): kept as the client's version by
#      .gitattributes (merge=ours) + the driver set below.
#   2. Line-level (applicationId / android label / iOS display name): re-applied
#      from tools/clients.sh after the merge (idempotent).
#   3. Brand assets (logo / launcher icon / splash + its color): re-derived from
#      tools/brand/<client>/ by tools/apply-identity.sh after the merge. This is
#      MANDATORY — merge=ours only protects files on CONFLICTING changes, so a
#      clean master change to a shared brand asset would otherwise leak the
#      Meow identity into the client (this actually shipped before).
#
# The script stops on the first merge conflict so it can be resolved by hand;
# re-run it (or finish the merge manually) afterwards.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
# shellcheck source=tools/clients.sh
source tools/clients.sh

PUSH=0
CLIENTS=()
for a in "$@"; do
  if [ "$a" = "--push" ]; then PUSH=1; else CLIENTS+=("$a"); fi
done
[ ${#CLIENTS[@]} -gt 0 ] || { echo "usage: $0 <client> [client...] [--push]"; exit 1; }

# Required by .gitattributes merge=ours (per-clone config; not committable).
git config merge.ours.driver true

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "!! working tree not clean — commit/stash first"; exit 1
fi

for c in "${CLIENTS[@]}"; do
  br="${CLIENT_APP_BRANCH[$c]:-}"
  [ -n "$br" ] || { echo "!! unknown client '$c' (add it to tools/clients.sh)"; exit 1; }

  echo "==================== APP  $c  ($br) <- $MASTER_BRANCH ===================="
  git checkout "$br"
  git merge --no-edit "$MASTER_BRANCH" \
    || { echo "!! merge conflict on '$c' — resolve, commit, then re-run for the rest"; exit 1; }

  # Re-apply line-level native identity (no-op when already correct).
  appid="${CLIENT_APPLICATION_ID[$c]}"
  label="${CLIENT_ANDROID_LABEL[$c]}"
  iosname="${CLIENT_IOS_NAME[$c]}"
  sed -i -E "s|applicationId \"[^\"]*\"|applicationId \"${appid}\"|" \
    android/app/build.gradle
  sed -i -E "s|android:label=\"[^\"]*\"|android:label=\"${label}\"|" \
    android/app/src/main/AndroidManifest.xml
  awk -v n="$iosname" \
    'p ~ /CFBundle(DisplayName|Name)<\/key>/ { sub(/<string>[^<]*<\/string>/, "<string>" n "</string>") } { print; p=$0 }' \
    ios/Runner/Info.plist > ios/Runner/Info.plist.tmp && mv ios/Runner/Info.plist.tmp ios/Runner/Info.plist

  if ! git diff --quiet; then
    git commit -aqm "chore($c): re-apply white-label identity after merge from $MASTER_BRANCH"
    echo "-- re-applied line-level identity for $c"
  fi

  # 3) Brand assets (logo / launcher icon / splash) — bulletproof against
  #    clean-merge leaks of the master (Meow) identity. No-op if no brand dir.
  if [ -f tools/apply-identity.sh ]; then
    bash tools/apply-identity.sh "$c" || echo "!! apply-identity failed for $c (fix brand assets, re-run)"
    if ! git diff --quiet; then
      git commit -aqm "chore($c): re-apply brand identity (logo/icon/splash) after merge from $MASTER_BRANCH"
      echo "-- re-applied brand identity for $c"
    fi
  fi

  echo "-- flutter analyze --"
  flutter analyze --no-pub 2>&1 | tail -4 || true

  if [ "$PUSH" -eq 1 ]; then
    git push origin "$br:$br"
    echo "-- pushed $br"
  else
    echo "-- NOT pushed (re-run with --push when verified)"
  fi
  echo "==================== $c done ===================="
done
