#!/usr/bin/env bash
# Re-apply a client's white-label BRAND identity (logo, launcher icon, splash
# background color) from tools/brand/<client>/ and regenerate the native splash
# (Android + iOS) and launcher icons from it.
#
#   tools/apply-identity.sh <client>
#
# WHY THIS EXISTS (do not remove):
#   .gitattributes merge=ours only protects a file when BOTH sides changed it
#   (a real conflict). When the master (Meow) changes a shared brand asset that
#   the client never re-touched — assets/images/logo.png, the generated splash,
#   the launcher icon, the splash color in pubspec — git applies the master's
#   version CLEANLY (no conflict, no merge driver) and the MASTER (Meow) identity
#   leaks into the client app. This actually shipped (jo splash + tiko icon/splash
#   showed the Meow logo). This script makes per-client identity BULLETPROOF by
#   re-deriving every brand asset from a per-client source that the master does
#   not have (tools/brand/<client>/), so merge mechanics can never leak again.
#   merge-from-master.sh runs this after every merge; onboarding runs it once.
#
# Per-client brand source (commit these on the client branch only):
#   tools/brand/<client>/logo.png        -> assets/images/logo.png  (splash + in-app logo)
#   tools/brand/<client>/icon.png        -> assets/images/app_icon.png (launcher icon source, 1024x1024)
#   tools/brand/<client>/splash-color    -> optional hex (e.g. #FEC901) for the splash background
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

CLIENT="${1:?usage: tools/apply-identity.sh <client>}"
BRAND="tools/brand/$CLIENT"
if [ ! -d "$BRAND" ]; then
  echo ">> apply-identity: no $BRAND — skipping (create it with the client's logo.png/icon.png)"
  exit 0
fi

did=0
if [ -f "$BRAND/logo.png" ]; then cp "$BRAND/logo.png" assets/images/img_2.png;     echo ">> applied $CLIENT logo -> assets/images/img_2.png"; did=1; fi
if [ -f "$BRAND/icon.png" ]; then cp "$BRAND/icon.png" assets/images/app_icon.png;  echo ">> applied $CLIENT icon -> assets/images/app_icon.png"; did=1; fi

# Optional per-client splash background color (hex in tools/brand/<client>/splash-color).
if [ -f "$BRAND/splash-color" ]; then
  COLOR="$(tr -d ' \r\n' < "$BRAND/splash-color")"
  sed -i -E "/^flutter_native_splash:/,/^[^[:space:]#]/ s/(color(_dark)?:[[:space:]]*)\"#?[0-9A-Fa-f]{3,8}\"/\1\"${COLOR}\"/" pubspec.yaml
  echo ">> applied $CLIENT splash color -> ${COLOR}"
fi

[ "$did" -eq 1 ] || { echo ">> apply-identity: nothing to apply for $CLIENT"; exit 0; }

flutter pub get >/dev/null 2>&1 || true
if grep -q "^flutter_native_splash:" pubspec.yaml; then
  dart run flutter_native_splash:create >/dev/null 2>&1 \
    && echo ">> regenerated native splash (Android + iOS)" \
    || echo "!! native splash regen FAILED — run manually: dart run flutter_native_splash:create"
fi
if [ -f "$BRAND/icon.png" ] && grep -q "^flutter_launcher_icons:" pubspec.yaml; then
  dart run flutter_launcher_icons >/dev/null 2>&1 \
    && echo ">> regenerated launcher icons (Android + iOS)" \
    || echo "!! launcher icon regen FAILED — run manually: dart run flutter_launcher_icons"
fi
echo ">> apply-identity: done for $CLIENT"
