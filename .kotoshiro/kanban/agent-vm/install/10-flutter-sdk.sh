#!/usr/bin/env bash
# Flutter SDK 3.50.1 (the version in cardbot scripts/infra-aws2/flutter-samples/flutter-sdk.lock).
set -euo pipefail
version=3.50.1
revision=ae9b586f34a8443573f82ef57c3bf914a908cbf7
url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${version}-stable.tar.xz"
sha256=4ad17fc8462fbcef2ba19ff4a78c0a16b7147fde1add8578e267ea62cdb92678
dest="${AGENT_VM_TOOLCHAIN_PREFIX}/flutter"

if [[ ! -x "${dest}/bin/flutter" || "$(cat "${dest}/version" 2>/dev/null)" != "${version}" ]]; then
    work="$(mktemp -d)"
    trap 'rm -rf "${work}"' EXIT
    curl -fsSL --retry 3 -o "${work}/flutter.tar.xz" "${url}"
    echo "${sha256}  ${work}/flutter.tar.xz" | sha256sum -c -
    rm -rf "${dest}"
    mkdir -p "$(dirname "${dest}")"
    tar -xJf "${work}/flutter.tar.xz" -C "$(dirname "${dest}")"
fi
# Flutter is a git checkout; root runs it here and the agent user later.
git config --system --add safe.directory "${dest}"
[[ "$(git -C "${dest}" rev-parse HEAD)" == "${revision}" ]] || { echo "unexpected Flutter revision" >&2; exit 1; }
export PATH="${dest}/bin:${PATH}"
flutter config --no-analytics >/dev/null
flutter precache --android
chown -R "${AGENT_VM_AGENT_USER}:" "${dest}"
flutter --version
