---
apiVersion: agent.meta/v1
kind: capability
id: __far-knowledge-form-app-android-gradle
title: "Far-Knowledge: form_app Android Gradle"
description: >-
  Flutter 3.50.1 Gradle/AGP/Kotlin minima for form_app, Viewer flutter run,
  and scripts/process Android check wiring including Windows self-test seeding.
user_visible: false
manual_only: false
status: current
body: inline
---

# form_app Android Gradle for Flutter 3.50.1

## Version minima

- Flutter 3.50.1 DependencyVersionChecker rejects Gradle below 9.3.1, AGP below 9.1.1, and Kotlin Gradle Plugin below 2.4.10.
- Template defaults to use: Gradle 9.5.0, AGP 9.3.1, Kotlin 2.4.20, Java 17, Kotlin DSL.

## form_app constraints

- Keep `applicationId` and `namespace` as `dev.flutter.formApp.form_app`.
- Agent VM Android Viewer needs these minima so `flutter run` does not fail DependencyVersionChecker.

## Checks

- Entry: `scripts/process/check_form_app_android.sh`, invoked from `scripts/process/build.sh`.
- Skip `flutter build apk` when Flutter is not on PATH unless `--require-flutter` is set.
- Self-test seed must exclude `.gradle`, `build`, and `local.properties` (prefer `tar --exclude`); `cp -a` fails on Windows when Gradle locks are busy.
