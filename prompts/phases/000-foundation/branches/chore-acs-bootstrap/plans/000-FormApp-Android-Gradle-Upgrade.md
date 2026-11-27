# 000-FormApp-Android-Gradle-Upgrade

> **Source Specification**: `prompts/phases/000-foundation/branches/chore-acs-bootstrap/ideas/001-FormApp-Android-Gradle-Upgrade.md`

## Goal Description

`form_app/android/` のビルド構成を Flutter 3.50.1 テンプレート相当（Gradle 9.5.0 / AGP 9.3.1 / Kotlin 2.4.20 / Java 17 / Kotlin DSL）へ上げ直し、版と識別子を確かめる検査を `scripts/process/build.sh` から毎回流す。

## User Review Required

None.

## Requirement Traceability

| Requirement (from Spec) | Implementation Point (Section/File) |
| :--- | :--- |
| R1 版の下限（Gradle 9.5.0 / AGP 9.3.1 / KGP 2.4.20 / Java 17） | Proposed Changes > form_app android files; check script constants |
| R2 Kotlin DSL 化と Groovy 削除 | Proposed Changes > NEW `.kts` / DELETE Groovy |
| R3 識別子・MainActivity・res 維持 | `app/build.gradle.kts`, `MainActivity.kt` |
| R4 AndroidManifest taskAffinity / queries | MODIFY `AndroidManifest.xml` |
| R5 `.gitignore` テンプレート合わせ | MODIFY `.gitignore` |
| R6 検査スクリプト + build.sh | NEW check scripts; MODIFY `build.sh` |
| R7 範囲制限 | Step-by-Step; Verification Plan scope check |
| O1 Flutter があるときの APK ビルド | `check_form_app_android.sh`: Flutter が PATH にあれば実行、無ければスキップ（`--require-flutter` で必須化）。自己試験はファイル検査のみ |

先送りなし（仕様の対象外は実装しない）。

### O1 の決定

- 既定: `command -v flutter` が成功し、かつ `flutter --version` が取れるときだけ `flutter pub get` と `flutter build apk --debug` を `form_app` で実行する。無ければ `form_app_android_check_skipped rule=flutter-build detail=flutter-not-on-PATH` を出し、ファイル検査が通っていれば終了コード 0。
- `--require-flutter` を付けたとき、または環境変数 `FORM_APP_ANDROID_REQUIRE_FLUTTER=1` のときは、Flutter が無ければ終了コード 1。
- 自己試験と `build.sh` からの呼び出しは既定（スキップ可）とする。

## Proposed Changes

### scripts/process（検査・TDD 先）

#### [NEW] [scripts/process/lib/form_app_android_check.py](file://scripts/process/lib/form_app_android_check.py)

*   **Description**: `form_app/android` の版・識別子・Manifest・Groovy 不在を検証する。
*   **Technical Design**:
    *   CLI: `python3 form_app_android_check.py --repo-root DIR`
    *   終了コード: 違反があれば 1。違反ごとに 1 行:
        `form_app_android_check_failed rule=<rule> file=<relpath> detail=<text>`
    *   成功時最終行: `form_app_android_check_ok`
*   **Logic** (rules):
    *   `no-groovy`: 次が存在したら失敗 — `settings.gradle`, `build.gradle`, `app/build.gradle`
    *   `settings-agp`: `settings.gradle.kts` に `id("com.android.application") version "9.3.1"` がある
    *   `settings-kotlin`: 同ファイルに `id("org.jetbrains.kotlin.android") version "2.4.20"` がある
    *   `wrapper-gradle`: `gradle/wrapper/gradle-wrapper.properties` の `distributionUrl` が `gradle-9.5.0-all.zip` を含む
    *   `app-id`: `app/build.gradle.kts` に `applicationId = "dev.flutter.formApp.form_app"` と `namespace = "dev.flutter.formApp.form_app"`
    *   `java17`: `app/build.gradle.kts` に `JavaVersion.VERSION_17` と `JvmTarget.JVM_17`（または同等の VERSION_17 / JVM_17）がある
    *   `gradle-properties`: `gradle.properties` に `android.newDsl=false` と `android.builtInKotlin=false`
    *   `manifest-affinity`: main Manifest に `android:taskAffinity=""`
    *   `manifest-queries`: main Manifest に `PROCESS_TEXT` を含む `<queries>`
    *   `main-activity`: `app/src/main/kotlin/dev/flutter/formApp/form_app/MainActivity.kt` が存在する
    *   定数: `EXPECTED_AGP=9.3.1`, `EXPECTED_KOTLIN=2.4.20`, `EXPECTED_GRADLE=9.5.0`, `EXPECTED_APP_ID=dev.flutter.formApp.form_app`

#### [NEW] [scripts/process/check_form_app_android.sh](file://scripts/process/check_form_app_android.sh)

*   **Description**: 入口。Python 検査のあと、条件付きで Flutter APK ビルド。
*   **Logic**:
    *   `REPO_ROOT` は `--repo-root` または git 最上位。
    *   `python3 "$REPO_ROOT/scripts/process/lib/form_app_android_check.py" --repo-root "$REPO_ROOT"`（Windows ではリポジトリ相対パスを渡す）。
    *   Flutter ビルド: 上記 O1 の決定どおり。作業ディレクトリは `$REPO_ROOT/form_app`。コマンドは `flutter pub get` のあと `flutter build apk --debug`。
    *   `set -euo pipefail`。

#### [NEW] [scripts/process/test/check_form_app_android_test.sh](file://scripts/process/test/check_form_app_android_test.sh)

*   **Description**: 一時ディレクトリに最小の `form_app/android` 一式をコピー（または生成）し、正常 1 件と仕様シナリオ 3 の壊し方 5 件を確かめる。
*   **Logic**:
    *   正常: 実装後のリポジトリ実体、または期待どおりの fixtures を `--repo-root` に渡し、検査が 0 で終わる。
    *   失敗ケース（各々検査が非 0 かつ該当 `rule=` を含む）:
        1. AGP を `8.9.1` → `settings-agp`
        2. wrapper を `gradle-8.12-all.zip` → `wrapper-gradle`
        3. Kotlin を `2.1.0` → `settings-kotlin`
        4. Groovy `settings.gradle` を置く → `no-groovy`
        5. `applicationId` を別値 → `app-id`
    *   Flutter ビルドは呼ばない（ファイル検査のみ）。

#### [MODIFY] [scripts/process/build.sh](file://scripts/process/build.sh)

*   **Description**: `build_go` の後に form_app Android 検査と自己試験を呼ぶ。
*   **Logic**:
    *   関数 `check_form_app_android()`:
        *   `bash "$PROJECT_ROOT/scripts/process/check_form_app_android.sh" --repo-root "$PROJECT_ROOT"`
        *   `bash "$PROJECT_ROOT/scripts/process/test/check_form_app_android_test.sh"`
        *   失敗時 `FAILED=true` して return 1
    *   `main` で `build_go` の次に `check_form_app_android || FAILED=true`
    *   ヘルプ文に「form_app Android Gradle 構成の検査」を追記。

### form_app/android

#### [NEW] [form_app/android/settings.gradle.kts](file://form_app/android/settings.gradle.kts)

*   **Logic**: Flutter 3.50.1 テンプレート全文。`{{agpVersion}}` → `9.3.1`、`{{kotlinVersion}}` → `2.4.20`。

```kotlin
pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.3.1" apply false
    id("org.jetbrains.kotlin.android") version "2.4.20" apply false
}

include(":app")
```

#### [NEW] [form_app/android/build.gradle.kts](file://form_app/android/build.gradle.kts)

*   **Logic**: テンプレート `app/android-kotlin.tmpl/build.gradle.kts.tmpl` をそのまま使う（識別子なし）。

#### [NEW] [form_app/android/app/build.gradle.kts](file://form_app/android/app/build.gradle.kts)

*   **Logic**: テンプレート `app/android-kotlin.tmpl/app/build.gradle.kts.tmpl`。`{{androidIdentifier}}` → `dev.flutter.formApp.form_app`。

#### [MODIFY] [form_app/android/gradle.properties](file://form_app/android/gradle.properties)

*   **Logic**: テンプレートどおりに置換:

```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
# This newDsl flag was added by the Flutter template
android.newDsl=false
# This builtInKotlin flag was added by the Flutter template
android.builtInKotlin=false
```

#### [MODIFY] [form_app/android/gradle/wrapper/gradle-wrapper.properties](file://form_app/android/gradle/wrapper/gradle-wrapper.properties)

*   **Logic**: `distributionUrl=https\://services.gradle.org/distributions/gradle-9.5.0-all.zip`

#### [MODIFY] [form_app/android/app/src/main/AndroidManifest.xml](file://form_app/android/app/src/main/AndroidManifest.xml)

*   **Logic**: activity に `android:taskAffinity=""` を追加。`</application>` の後にテンプレートの `<queries>`（PROCESS_TEXT）を追加。`android:label="form_app"` は維持。

#### [MODIFY] [form_app/android/app/src/main/kotlin/dev/flutter/formApp/form_app/MainActivity.kt](file://form_app/android/app/src/main/kotlin/dev/flutter/formApp/form_app/MainActivity.kt)

*   **Logic**:

```kotlin
package dev.flutter.formApp.form_app

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

#### [MODIFY] [form_app/android/.gitignore](file://form_app/android/.gitignore)

*   **Logic**: テンプレートどおり（`.cxx/` 追加、keystore コメント URL を `https://flutter.dev/to/reference-keystore`）。

#### [DELETE] Groovy

*   `form_app/android/settings.gradle`
*   `form_app/android/build.gradle`
*   `form_app/android/app/build.gradle`

### Documentation

`prompts/specifications` は存在しない。更新対象なし。

## Step-by-Step Implementation Guide

1. **[ ] Red: 自己試験スケルトン**: `scripts/process/test/check_form_app_android_test.sh` と空の `check_form_app_android.sh` / `form_app_android_check.py` を置き、自己試験が「検査がまだ足りない」で失敗することを確認する（または検査未実装で非 0）。
2. **[ ] Green: Python 検査**: `form_app_android_check.py` に R6 のルールを実装する。
3. **[ ] Green: 入口シェル**: `check_form_app_android.sh` に O1 分岐を実装する。
4. **[ ] form_app Kotlin DSL**: `settings.gradle.kts` / `build.gradle.kts` / `app/build.gradle.kts` を新規作成し、`gradle.properties`・wrapper・Manifest・MainActivity・`.gitignore` を更新する。
5. **[ ] Delete Groovy**: 3 つの `.gradle` を削除する。
6. **[ ] 自己試験完成**: シナリオ 3 の 5 壊し方を一時コピーで実行するよう書く。正常ケースはリポジトリ実体を `--repo-root` に渡す。
7. **[ ] build.sh 組み込み**: `check_form_app_android` を `main` に追加する。
8. **[ ] Verification Plan 実行**: 下記コマンドを実行し、失敗したら修正ループ。
9. **[ ] コミット分割**: 検査スクリプト → android 構成 → build.sh 連携、の論理単位でコミット（または android+検査をまとめても可。関係ない ACS 未追跡は含めない）。
10. **[ ] Far-knowledge + push**: record-far-knowledge のあと `git push`。

## Verification Plan

### Automated Verification

1. **Build & Unit / Config Checks**:

```bash
./scripts/process/build.sh
```

期待: form_app Android 検査が `form_app_android_check_ok`、自己試験 PASS、パイプライン成功。

2. **検査の単体実行**:

```bash
./scripts/process/check_form_app_android.sh
./scripts/process/test/check_form_app_android_test.sh
```

3. **Integration Tests**:

本変更では実行しない。理由: `scripts/process/integration_test.sh` は `tests/go.mod` が無いと何も流さず、`--categories` にも対応していない。仕様も統合試験を対象外としている。構成の回帰は自己試験（一時ディレクトリでの壊し方）で賄う。

4. **E2E Tests**:

不要。理由: GUI や新規ユーザー操作は無く、Gradle 設定ファイルと検査スクリプトのみの変更である。

5. **Scope check** (実装後):

```bash
git diff --name-only main...HEAD
```

`form_app/android/`・`scripts/process/`・仕様/計画のパス以外にサンプルディレクトリが無いこと。

6. **総合判定** (testing-rules の趣旨に合わせる):

*   検査と自己試験がすべて成功したか。
*   Groovy が残っていないか。
*   版が期待値どおりか。
*   未追跡の ACS 一式をコミットに混ぜていないか。

### テスト項目設計のセルフレビュー

*   ボトムアップ: ファイル規則（Python）→ 入口シェル → build.sh →（任意）flutter build。
*   網羅: R1〜R6 の版・DSL・Manifest・gitignore・識別子。R7 は diff 確認。
*   証拠: 検査の `rule=` 行と自己試験の期待 rule。
*   迂回排除: Groovy 併存を `no-groovy` で落とす。
*   依存: Flutter ビルドは O1 で明示的に任意/必須を切り替え。

## Documentation

更新対象なし（`prompts/specifications` 不在）。
