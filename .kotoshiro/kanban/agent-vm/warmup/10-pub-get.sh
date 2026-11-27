#!/usr/bin/env bash
# Pin layer: fetch form_app packages into PUB_CACHE so sessions start offline-ready.
set -euo pipefail
cd "${AGENT_VM_REPO_ROOT}/form_app"
flutter pub get
echo "form_app packages cached"
