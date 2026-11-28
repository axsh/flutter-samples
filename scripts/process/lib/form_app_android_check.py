#!/usr/bin/env python3
"""Validate form_app/android against Flutter 3.50.1 template minima (spec 001)."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

EXPECTED_AGP = "9.3.1"
EXPECTED_KOTLIN = "2.4.20"
EXPECTED_GRADLE = "9.5.0"
EXPECTED_APP_ID = "dev.flutter.formApp.form_app"

GROOVY_FILES = (
    "form_app/android/settings.gradle",
    "form_app/android/build.gradle",
    "form_app/android/app/build.gradle",
)


def fail(failures: list[str], rule: str, file: str, detail: str) -> None:
    line = f"form_app_android_check_failed rule={rule} file={file} detail={detail}"
    failures.append(line)
    print(line)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", required=True)
    args = parser.parse_args()
    root = Path(args.repo_root).resolve()
    android = root / "form_app" / "android"
    failures: list[str] = []

    for rel in GROOVY_FILES:
        if (root / rel).is_file():
            fail(failures, "no-groovy", rel, "groovy-dsl-file-must-be-removed")

    settings = android / "settings.gradle.kts"
    if not settings.is_file():
        fail(failures, "settings-agp", "form_app/android/settings.gradle.kts", "missing")
        fail(failures, "settings-kotlin", "form_app/android/settings.gradle.kts", "missing")
    else:
        text = settings.read_text(encoding="utf-8")
        agp_re = re.compile(
            r'id\(\s*"com\.android\.application"\s*\)\s*version\s*"([^"]+)"'
        )
        kgp_re = re.compile(
            r'id\(\s*"org\.jetbrains\.kotlin\.android"\s*\)\s*version\s*"([^"]+)"'
        )
        agp_m = agp_re.search(text)
        kgp_m = kgp_re.search(text)
        if not agp_m or agp_m.group(1) != EXPECTED_AGP:
            fail(
                failures,
                "settings-agp",
                "form_app/android/settings.gradle.kts",
                f"want={EXPECTED_AGP} got={(agp_m.group(1) if agp_m else 'missing')}",
            )
        if not kgp_m or kgp_m.group(1) != EXPECTED_KOTLIN:
            fail(
                failures,
                "settings-kotlin",
                "form_app/android/settings.gradle.kts",
                f"want={EXPECTED_KOTLIN} got={(kgp_m.group(1) if kgp_m else 'missing')}",
            )

    wrapper = android / "gradle" / "wrapper" / "gradle-wrapper.properties"
    if not wrapper.is_file():
        fail(
            failures,
            "wrapper-gradle",
            "form_app/android/gradle/wrapper/gradle-wrapper.properties",
            "missing",
        )
    else:
        wtext = wrapper.read_text(encoding="utf-8")
        if f"gradle-{EXPECTED_GRADLE}-all.zip" not in wtext:
            fail(
                failures,
                "wrapper-gradle",
                "form_app/android/gradle/wrapper/gradle-wrapper.properties",
                f"want=gradle-{EXPECTED_GRADLE}-all.zip",
            )

    app_build = android / "app" / "build.gradle.kts"
    if not app_build.is_file():
        fail(failures, "app-id", "form_app/android/app/build.gradle.kts", "missing")
        fail(failures, "java17", "form_app/android/app/build.gradle.kts", "missing")
    else:
        atext = app_build.read_text(encoding="utf-8")
        if f'applicationId = "{EXPECTED_APP_ID}"' not in atext:
            fail(
                failures,
                "app-id",
                "form_app/android/app/build.gradle.kts",
                "applicationId-mismatch",
            )
        if f'namespace = "{EXPECTED_APP_ID}"' not in atext:
            fail(
                failures,
                "app-id",
                "form_app/android/app/build.gradle.kts",
                "namespace-mismatch",
            )
        if "JavaVersion.VERSION_17" not in atext or "JVM_17" not in atext:
            fail(
                failures,
                "java17",
                "form_app/android/app/build.gradle.kts",
                "need-VERSION_17-and-JVM_17",
            )

    props = android / "gradle.properties"
    if not props.is_file():
        fail(failures, "gradle-properties", "form_app/android/gradle.properties", "missing")
    else:
        ptext = props.read_text(encoding="utf-8")
        if "android.newDsl=false" not in ptext or "android.builtInKotlin=false" not in ptext:
            fail(
                failures,
                "gradle-properties",
                "form_app/android/gradle.properties",
                "need-newDsl-and-builtInKotlin-false",
            )

    manifest = android / "app" / "src" / "main" / "AndroidManifest.xml"
    if not manifest.is_file():
        fail(
            failures,
            "manifest-affinity",
            "form_app/android/app/src/main/AndroidManifest.xml",
            "missing",
        )
        fail(
            failures,
            "manifest-queries",
            "form_app/android/app/src/main/AndroidManifest.xml",
            "missing",
        )
    else:
        mtext = manifest.read_text(encoding="utf-8")
        if 'android:taskAffinity=""' not in mtext:
            fail(
                failures,
                "manifest-affinity",
                "form_app/android/app/src/main/AndroidManifest.xml",
                "missing-taskAffinity",
            )
        if "PROCESS_TEXT" not in mtext or "<queries>" not in mtext:
            fail(
                failures,
                "manifest-queries",
                "form_app/android/app/src/main/AndroidManifest.xml",
                "missing-PROCESS_TEXT-queries",
            )

    main_activity = (
        android
        / "app"
        / "src"
        / "main"
        / "kotlin"
        / "dev"
        / "flutter"
        / "formApp"
        / "form_app"
        / "MainActivity.kt"
    )
    if not main_activity.is_file():
        fail(
            failures,
            "main-activity",
            "form_app/android/app/src/main/kotlin/dev/flutter/formApp/form_app/MainActivity.kt",
            "missing",
        )

    if failures:
        print(f"form_app_android_check_failed count={len(failures)}")
        return 1
    print("form_app_android_check_ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
