#!/usr/bin/env bash
# Bump the version and build a signed Play appbundle for a client checkout.
# Run inside the client's build checkout AFTER tools/merge-from-master.sh has
# brought in the latest fixes. Requires android/key.properties + its keystore.
#
#   tools/release-app.sh <client>            # auto-bump build number, build AAB
#   tools/release-app.sh <client> --no-bump  # rebuild current version
#
# The client's BUILD-TIME dart-defines (API_BASE_URL / STORAGE_URL /
# CENTRIFUGO_WSS) are injected from tools/clients.sh. The master code defaults
# these to EMPTY (no client host hardcoded), so a build WITHOUT them ships a dead
# app (empty backend URL). This script REFUSES to build if they are missing.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

CLIENT=""
BUMP=1
for a in "$@"; do
  case "$a" in
    --no-bump) BUMP=0 ;;
    *) CLIENT="$a" ;;
  esac
done
[ -n "$CLIENT" ] || { echo "usage: $0 <client> [--no-bump]"; exit 1; }

# Resolve dart-defines from the registry (search up to the master app repo).
DEFINES=""
for reg in tools/clients.sh ../MeowLive_new/app/tools/clients.sh "../../MeowLive_new/app/tools/clients.sh"; do
  [ -f "$reg" ] && { source "$reg"; break; }
done
DEFINES="${CLIENT_DART_DEFINES[$CLIENT]:-}"

# SAFETY: never ship an app with an empty backend URL.
if [ -z "$DEFINES" ] || ! echo "$DEFINES" | grep -q "API_BASE_URL=https\?://."; then
  echo "!! REFUSING to build '$CLIENT': no API_BASE_URL dart-define in clients.sh."
  echo "   A build without it ships a dead app (empty backend URL). Add"
  echo "   CLIENT_DART_DEFINES[$CLIENT] to tools/clients.sh first."
  exit 1
fi

ver=$(grep -E '^version:' pubspec.yaml | head -1 | sed -E 's/^version:[[:space:]]*//')
name="${ver%%+*}"; code="${ver##*+}"

if [ "$BUMP" -eq 1 ]; then
  newcode=$((code + 1))
  base="${name%.*}"; last="${name##*.}"
  newname="${base}.$((last + 1))"
  echo ">> version $name+$code  ->  $newname+$newcode"
  sed -i -E "s|^version: .*|version: ${newname}+${newcode}|" pubspec.yaml
  if [ -f android/local.properties ]; then
    grep -q '^flutter.versionCode=' android/local.properties \
      && sed -i -E "s|^flutter.versionCode=.*|flutter.versionCode=${newcode}|" android/local.properties \
      || echo "flutter.versionCode=${newcode}" >> android/local.properties
    grep -q '^flutter.versionName=' android/local.properties \
      && sed -i -E "s|^flutter.versionName=.*|flutter.versionName=${newname}|" android/local.properties \
      || echo "flutter.versionName=${newname}" >> android/local.properties
  fi
else
  newname="$name"; newcode="$code"
  echo ">> rebuilding $name+$code (no bump)"
fi

appid=$(grep -oE 'applicationId "[^"]*"' android/app/build.gradle | sed -E 's/applicationId "([^"]*)"/\1/')
echo ">> client=$CLIENT  applicationId=$appid  version=$newname+$newcode"
echo ">> dart-defines: $DEFINES"

flutter pub get >/dev/null
# shellcheck disable=SC2086
flutter build appbundle --release --build-name="$newname" --build-number="$newcode" $DEFINES

AAB="build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "=================================================================="
echo " SIGNED AAB READY  ($CLIENT)"
echo "   package : $appid"
echo "   version : $newname (code $newcode)"
echo "   file    : $(git rev-parse --show-toplevel)/$AAB"
echo "=================================================================="
