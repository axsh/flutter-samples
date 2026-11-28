#!/usr/bin/env bash
# Self-test for check_form_app_android.sh (spec 001 scenario 3).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROCESS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${PROCESS_DIR}/../.." && pwd)"
CHECK="${PROCESS_DIR}/check_form_app_android.sh"
PY="${PROCESS_DIR}/lib/form_app_android_check.py"
PYTHON_BIN="$(command -v python3 || command -v python)"

pass() { echo "PASS: $*"; }
fail() { echo "FAIL: $*" >&2; exit 1; }

echo "== form_app android check self-test =="

# --- healthy tree ---
out="$("${CHECK}" --repo-root "${REPO_ROOT}" 2>&1)" || fail "healthy check failed: ${out}"
grep -q 'form_app_android_check_ok' <<<"${out}" || fail "healthy missing ok line: ${out}"
pass "healthy repository"

workdir="$(mktemp -d "${REPO_ROOT}/tmp/form-app-android-test.XXXXXX")"
cleanup() { rm -rf "${workdir}"; }
trap cleanup EXIT

seed_tree() {
  local dest="$1"
  mkdir -p "${dest}/form_app/android"
  mkdir -p "${dest}/scripts/process/lib"
  # Exclude local Gradle cache/locks: cp -a fails on Windows when *.lock is busy.
  (
    cd "${REPO_ROOT}/form_app/android"
    tar -cf - --exclude='.gradle' --exclude='build' --exclude='local.properties' .
  ) | (
    cd "${dest}/form_app/android"
    tar -xf -
  )
  cp "${PY}" "${dest}/scripts/process/lib/form_app_android_check.py"
  cp "${CHECK}" "${dest}/scripts/process/check_form_app_android.sh"
}

expect_fail_rule() {
  local name="$1" rule="$2" mutate="$3"
  local case_dir="${workdir}/${name}"
  rm -rf "${case_dir}"
  seed_tree "${case_dir}"
  eval "${mutate}"
  set +e
  out="$(bash "${case_dir}/scripts/process/check_form_app_android.sh" --repo-root "${case_dir}" 2>&1)"
  rc=$?
  set -e
  [[ "${rc}" -ne 0 ]] || fail "${name}: expected non-zero, got 0: ${out}"
  grep -q "rule=${rule}" <<<"${out}" || fail "${name}: expected rule=${rule} in: ${out}"
  pass "${name} (rule=${rule})"
}

expect_fail_rule agp settings-agp \
  'sed -i "s/version \"9.3.1\"/version \"8.9.1\"/" "${case_dir}/form_app/android/settings.gradle.kts"'

expect_fail_rule wrapper wrapper-gradle \
  'sed -i "s/gradle-9.5.0-all.zip/gradle-8.12-all.zip/" "${case_dir}/form_app/android/gradle/wrapper/gradle-wrapper.properties"'

expect_fail_rule kotlin settings-kotlin \
  'sed -i "s/version \"2.4.20\"/version \"2.1.0\"/" "${case_dir}/form_app/android/settings.gradle.kts"'

expect_fail_rule groovy no-groovy \
  'printf "include \":app\"\n" > "${case_dir}/form_app/android/settings.gradle"'

expect_fail_rule appid app-id \
  'sed -i "s/dev.flutter.formApp.form_app/com.example.other/" "${case_dir}/form_app/android/app/build.gradle.kts"'

echo "ALL form_app android check self-tests passed"
