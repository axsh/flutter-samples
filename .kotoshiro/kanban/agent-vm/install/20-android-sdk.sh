#!/usr/bin/env bash
# Android SDK packages for building form_app (cardbot android-sdk.lock).
set -euo pipefail
tools_url=https://dl.google.com/android/repository/commandlinetools-linux-16111833_latest.zip
tools_sha1=e025545c62a8e64c7559119566a569fb1dec5f60
packages=(platform-tools "platforms;android-36" "build-tools;36.0.0" "ndk;28.2.13676358")
sdk="${AGENT_VM_TOOLCHAIN_PREFIX}/android-sdk"
sdkmanager="${sdk}/cmdline-tools/latest/bin/sdkmanager"

if [[ ! -x "${sdkmanager}" ]]; then
    work="$(mktemp -d)"
    trap 'rm -rf "${work}"' EXIT
    curl -fsSL --retry 3 -o "${work}/cmdline-tools.zip" "${tools_url}"
    echo "${tools_sha1}  ${work}/cmdline-tools.zip" | sha1sum -c -
    unzip -q "${work}/cmdline-tools.zip" -d "${work}/x"
    mkdir -p "${sdk}/cmdline-tools"
    rm -rf "${sdk}/cmdline-tools/latest"
    mv "${work}/x/cmdline-tools" "${sdk}/cmdline-tools/latest"
fi
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
# `yes` dies of SIGPIPE once sdkmanager stops reading, so judge the sdkmanager status only.
set +e +o pipefail
yes | "${sdkmanager}" --sdk_root="${sdk}" --licenses >/dev/null
status=("${PIPESTATUS[@]}")
set -e -o pipefail
[[ "${status[1]}" -eq 0 ]] || { echo "sdkmanager --licenses failed rc=${status[1]}" >&2; exit 1; }
"${sdkmanager}" --sdk_root="${sdk}" --install "${packages[@]}"
chown -R "${AGENT_VM_AGENT_USER}:" "${sdk}"
echo "android sdk packages installed: ${packages[*]}"
