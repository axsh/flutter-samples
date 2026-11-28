#!/usr/bin/env bash
# Emulator, system image and AVD through the Kanban platform helper (spec 068 R6).
# API 35 matches the system image the legacy Android Agent AMI used.
set -euo pipefail
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
"${AGENT_VM_HELPERS}/android-emulator-install" --api 35 --image google_apis --avd cardbot \
    --sdk "${AGENT_VM_TOOLCHAIN_PREFIX}/android-sdk"
