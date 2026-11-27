#!/usr/bin/env bash
# Validate form_app/android Gradle config (spec 001). Optional flutter build apk.
set -euo pipefail

REPO_ROOT=""
REQUIRE_FLUTTER=0
while (($#)); do
  case "$1" in
    --repo-root) REPO_ROOT="$2"; shift 2 ;;
    --require-flutter) REQUIRE_FLUTTER=1; shift ;;
    --help|-h)
      echo "Usage: check_form_app_android.sh [--repo-root DIR] [--require-flutter]"
      exit 0
      ;;
    *) echo "error: unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "${REPO_ROOT}" ]]; then
  REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
fi
[[ -n "${REPO_ROOT}" && -d "${REPO_ROOT}" ]] || {
  echo "error: --repo-root is required (or run inside a git repo)" >&2
  exit 2
}
REPO_ROOT="$(cd "${REPO_ROOT}" && pwd)"

if [[ "${FORM_APP_ANDROID_REQUIRE_FLUTTER:-0}" == "1" ]]; then
  REQUIRE_FLUTTER=1
fi

PYTHON_BIN="$(command -v python3 || command -v python || true)"
[[ -n "${PYTHON_BIN}" ]] || {
  echo "form_app_android_check_failed rule=python file=scripts/process/lib/form_app_android_check.py detail=python3-not-found"
  exit 1
}

# Prefer repo-relative path for Windows Python.
CHECK_PY="scripts/process/lib/form_app_android_check.py"
if [[ ! -f "${REPO_ROOT}/${CHECK_PY}" ]]; then
  echo "form_app_android_check_failed rule=python file=${CHECK_PY} detail=missing"
  exit 1
fi

(
  cd "${REPO_ROOT}"
  "${PYTHON_BIN}" "${CHECK_PY}" --repo-root "${REPO_ROOT}"
)

if command -v flutter >/dev/null 2>&1; then
  echo "form_app_android_check_step rule=flutter-build"
  (
    cd "${REPO_ROOT}/form_app"
    flutter pub get
    flutter build apk --debug
  )
  echo "form_app_android_check_ok rule=flutter-build"
else
  if [[ "${REQUIRE_FLUTTER}" -eq 1 ]]; then
    echo "form_app_android_check_failed rule=flutter-build file=form_app detail=flutter-not-on-PATH"
    exit 1
  fi
  echo "form_app_android_check_skipped rule=flutter-build detail=flutter-not-on-PATH"
fi
