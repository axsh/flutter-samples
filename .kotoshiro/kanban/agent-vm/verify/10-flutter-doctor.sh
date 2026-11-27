#!/usr/bin/env bash
# Runs as the agent user with runtime.env and runtime.path_prepend applied.
set -euo pipefail
flutter --version | grep -q 'Flutter 3.50.1'
adb version >/dev/null
test -x "${ANDROID_HOME}/emulator/emulator"
test -f /var/lib/cardbot/avd/cardbot.avd/config.ini
flutter doctor -v || true
echo "flutter toolchain ok"
