#!/usr/bin/env bash
# Per-client white-label registry (APP repo).
#
# Single source of truth for each client's branch name + the LINE-LEVEL native
# identity that merge-from-master.sh re-applies after every merge from master.
# Whole-file identity (Firebase config, icons, splash, brand art) is handled by
# .gitattributes (merge=ours) and is intentionally NOT listed here.
#
# To onboard a new client: add one entry to each array below with the same key.
#
# Per-client identity that also lives line-level in shared files but is NOT yet
# automated (currently correct-by-history for jo; MUST be set when onboarding a
# new client, and the master should be neutralised so it stops leaking):
#   - Android deep-link host   AndroidManifest.xml  android:host="..."
#   - iOS Google OAuth scheme  ios/Runner/Info.plist  reversed client id
# Track these per client and extend the re-apply step when a second client needs
# a different value.

MASTER_BRANCH="meow-live"

# `eco_local` is the same app as `eco` â€” same package, same branch, same label â€”
# pointed at the development backend running in WSL instead of the remote box.
# It exists as its own client so the local host never leaks into a release build:
# release-app.sh reads API_BASE_URL from this registry, so the only way to ship
# the LAN address would be to ask for it by name.
declare -A CLIENT_APP_BRANCH=(
  [meow]="meow-live"
  [eco]="eco-live"
  [imparty]="imparty"
  [eco_local]="eco-live"
)
declare -A CLIENT_APPLICATION_ID=(
  [meow]="com.jo.chat.app"
  [eco]="com.ecoapps.live"
  [imparty]="com.imparty.live"
  [eco_local]="com.ecoapps.live"
)
declare -A CLIENT_ANDROID_LABEL=(
  [meow]="Meow Live"
  [eco]="Eco Live"
  [imparty]="IM PARTY"
  [eco_local]="Eco Live"
)
declare -A CLIENT_IOS_NAME=(
  [meow]="Meow Live"
  [eco]="Eco Live"
  [eco_local]="Eco Live"
)

# BUILD-TIME dart-defines per client. The master code keeps these EMPTY by
# default (no client host hardcoded â€” white-label). Each client's build MUST
# inject its own bootstrap endpoints, or the app ships with an empty backend URL
# and is dead on launch. release-app.sh passes these automatically.
#   API_BASE_URL    : the client's backend host (bootstrap, before the panel)
#   STORAGE_URL     : the client's object-storage base
#   CENTRIFUGO_WSS  : the client's realtime websocket
# The user-facing brand woven into copy ("About <brand>", "Become a <brand>
# VIP"). Kept OUT of CLIENT_DART_DEFINES because every consumer expands that
# string unquoted, so a value containing a space would be split into two
# arguments and lose half the name. Build scripts pass this one through an
# array instead â€” see ops/ao1_build_release.sh.
declare -A CLIENT_BRAND_NAME=(
  [imparty]="IM PARTY"
)

declare -A CLIENT_DART_DEFINES=(
  # eco runs on its own box: 98.142.250.240, reached through sslip.io because no
  # domain of ours points there. Laravel + MariaDB + Redis + Centrifugo, behind
  # nginx with a real Let's Encrypt certificate.
  #
  # STORAGE_URL ends in a slash on purpose -- EndPoints.storageURL is concatenated
  # straight onto a filename. CENTRIFUGO_WSS is only the fallback; the server's
  # own `centrifugo_ws` setting wins when the panel sets one.
  [eco]="--dart-define=API_BASE_URL=https://98-142-250-240.sslip.io --dart-define=STORAGE_URL=https://98-142-250-240.sslip.io/storage/ --dart-define=CENTRIFUGO_WSS=wss://98-142-250-240.sslip.io/connection/websocket"
  [miva]="--dart-define=API_BASE_URL=https://api.miva.live --dart-define=STORAGE_URL=https://cdn.miva.live/storage/ --dart-define=CENTRIFUGO_WSS=wss://ws.miva.live/connection/websocket"

  # Development: the Laravel/MariaDB/Redis/Centrifugo stack running in WSL,
  # reached over the LAN at the Windows host's address. Plain http/ws â€” there is
  # no certificate for a private IP â€” which only works because the manifest
  # already sets android:usesCleartextTraffic="true".
  #
  # Requires ops/lan_open_8080.ps1 to have been run: Windows forwards
  # 0.0.0.0:8080 into the WSL VM and allows it through the firewall. Re-run it
  # after a WSL restart, because the VM's IP changes.
  [eco_local]="--dart-define=API_BASE_URL=http://192.168.1.113:8080 --dart-define=STORAGE_URL=http://192.168.1.113:8080/storage/ --dart-define=CENTRIFUGO_WSS=ws://192.168.1.113:8080/connection/websocket"

  # Development over USB. Use this one when the LAN route does not work.
  #
  # `eco_local` above is correct in principle and does not currently work: the
  # phone pings the PC fine, Windows' own requests reach nginx (they appear as
  # 172.18.224.1), the firewall rule is enabled on a Private profile and the
  # portproxy is bound to both 0.0.0.0 and the LAN address â€” yet connections
  # arriving from the LAN are reset before nginx ever logs them.
  #
  # This entry sidesteps it. `adb reverse tcp:8080 tcp:8080` tunnels the phone's
  # own localhost:8080 to the PC's localhost:8080 over the USB cable, which then
  # goes through the same portproxy into WSL. No firewall, no router, no WiFi.
  # Run tools/../../ops/adb_reverse.sh (or the adb command directly) after every
  # replug â€” the mapping does not survive a disconnect.
  [eco_usb]="--dart-define=API_BASE_URL=http://127.0.0.1:8080 --dart-define=STORAGE_URL=http://127.0.0.1:8080/storage/ --dart-define=CENTRIFUGO_WSS=ws://127.0.0.1:8080/connection/websocket"
)

