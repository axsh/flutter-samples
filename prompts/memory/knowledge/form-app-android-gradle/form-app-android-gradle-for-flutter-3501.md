---
id: form-app-android-gradle-for-flutter-3501
knowledge_id: form-app-android-gradle-for-flutter-3501
title: form_app Android Gradle for Flutter 3.50.1
status: current
category_path: form-app-android-gradle
created_at: 2026-11-28T02:16:48.0317759Z
last_updated: 2026-11-28T02:16:48.0317759Z
source_event_ids:
    - E-01M8DN665FRSP7MKAW5TTN8Q35
---

# form_app Android Gradle for Flutter 3.50.1

## Version minima

Flutter 3.50.1 DependencyVersionChecker rejects Gradle below 9.3.1, AGP below 9.1.1, and Kotlin Gradle Plugin below 2.4.10. The Flutter template defaults are Gradle 9.5.0, AGP 9.3.1, and Kotlin 2.4.20.

## form_app layout

`form_app/android` must use the Flutter 3.50.1 Kotlin DSL Android templates with `applicationId` and `namespace` kept as `dev.flutter.formApp.form_app` so Agent VM Android Viewer can run `flutter run` without DependencyVersionChecker failures.

## Automated checks

Automated form_app Android Gradle checks live in `scripts/process/check_form_app_android.sh` and are invoked from `scripts/process/build.sh`. `flutter build apk` is skipped when Flutter is not on PATH unless `--require-flutter` is set.

Self-test seeds must exclude local `.gradle`, `build`, and `local.properties` (use `tar --exclude`) because `cp -a` fails on Windows when Gradle lock files are busy.
