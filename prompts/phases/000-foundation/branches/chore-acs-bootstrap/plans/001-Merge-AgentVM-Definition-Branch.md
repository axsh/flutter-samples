# 001-Merge-AgentVM-Definition-Branch

> **Source Specification**: `prompts/phases/000-foundation/branches/chore-acs-bootstrap/ideas/002-Merge-AgentVM-Definition-Branch.md`

## Goal Description

作業ブランチ `chore-acs-bootstrap` に `origin/cardbot/agent-vm-definition` を `git merge` し、Kanban Agent VM 定義 7 ファイルを tip に載せる。定義ブランチは削除・一本化しない。本ブランチの form_app Gradle 上げ直し（仕様 001）は維持する。

## User Review Required

None.

## Requirement Traceability

| Requirement (from Spec) | Implementation Point (Section/File) |
| :--- | :--- |
| R1 merge（手コピー・cherry-pick 禁止） | Step-by-Step > Fetch and Merge; Proposed Changes > Git merge |
| R2 tip に定義 7 ファイル（blob / mode 一致） | Proposed Changes > `.kotoshiro/kanban/**`; Verification > `git ls-tree` |
| R3 form_app Gradle 上げ直しを壊さない | Verification > AGP 9.3.1 / build.sh form_app 検査 |
| R4 定義ハッシュ `08d135fe…`（tip が `5d9d3aa9` のとき） | Step-by-Step > Compute definition hash; Verification |
| R5 1 本化しない（定義ブランチを削除しない） | Step-by-Step > Confirm remote definition branch; 完了条件に削除を入れない |
| R6 `build.sh` 成功・ACS 未追跡を merge コミットに混ぜない | Verification > `build.sh`; Step-by-Step > stage 範囲 |
| O1 push | Step-by-Step > Far-knowledge + push（execute-implementation-plan に従う） |

先送りなし。仕様の対象外（000 の検査スクリプト新設、`.gitattributes` eol=lf、kanban-demo 突き合わせ、定義ブランチの削除）は実装しない。

## Proposed Changes

### Git（取り込み手段）

#### [MERGE] `origin/cardbot/agent-vm-definition` → `chore-acs-bootstrap`

*   **Description**: 定義ブランチを本ブランチへ merge する。履歴に定義コミットを残す（fast-forward のみに限定しない）。
*   **Technical Design**:
    *   作業ブランチ: `chore-acs-bootstrap`
    *   取り込み元: `origin/cardbot/agent-vm-definition`（調査時点 tip `5d9d3aa9`）
    *   コマンド:
        ```bash
        git fetch origin cardbot/agent-vm-definition
        git rev-parse origin/cardbot/agent-vm-definition
        git merge origin/cardbot/agent-vm-definition -m "Merge branch 'cardbot/agent-vm-definition' into chore-acs-bootstrap"
        ```
    *   禁止: ファイルの手コピー、`git cherry-pick` 単体での取り込み（blob・tree・mode `100755` を崩すため）
*   **Logic**:
    *   fetch 後、`origin/cardbot/agent-vm-definition` が `5d9d3aa9` から進んでいれば、仕様 000 の R2（正本と同じか）を確かめてから merge する。進んでいなければそのまま merge する。
    *   未追跡の `.kotoshiro/tokotachi/` 等があっても、merge が追加するのは `.kotoshiro/kanban/` なのでパスは重ならない。衝突したら未追跡を退避して再実行する。
    *   merge コミットに、未コミットの ACS 一式（`.cursor/`、`prompts/manifest/`、`scripts/utils/` など）を `git add` しない。
    *   リモートの `cardbot/agent-vm-definition` を `git push origin --delete` 等で消さない。

### `.kotoshiro/kanban`（merge が tip に載せるファイル）

次の 7 パスが merge 後 HEAD に存在する。定義 tip が `5d9d3aa9` のとき、blob ID と mode は定義 tip と一致する。

| Path | Expected mode |
| :--- | :--- |
| `.kotoshiro/kanban/lane_templates.yaml` | `100644` |
| `.kotoshiro/kanban/agent-vm/image.yaml` | `100644` |
| `.kotoshiro/kanban/agent-vm/install/10-flutter-sdk.sh` | `100755` |
| `.kotoshiro/kanban/agent-vm/install/20-android-sdk.sh` | `100755` |
| `.kotoshiro/kanban/agent-vm/install/30-emulator.sh` | `100755` |
| `.kotoshiro/kanban/agent-vm/verify/10-flutter-doctor.sh` | `100755` |
| `.kotoshiro/kanban/agent-vm/warmup/10-pub-get.sh` | `100755` |

#### [NEW via merge] [`.kotoshiro/kanban/lane_templates.yaml`](file://.kotoshiro/kanban/lane_templates.yaml)

*   **Description**: Kanban レーンテンプレート。ボード作成時に必要。
*   **Logic**: 定義ブランチの blob をそのまま残す。内容を編集しない。

#### [NEW via merge] [`.kotoshiro/kanban/agent-vm/image.yaml`](file://.kotoshiro/kanban/agent-vm/image.yaml)

*   **Description**: Agent VM イメージ定義。
*   **Logic**: 定義ブランチの blob をそのまま残す。内容を編集しない。

#### [NEW via merge] install / verify / warmup シェル（5 本）

*   **Description**: Flutter SDK / Android SDK / Emulator の install、`flutter doctor` の verify、`pub get` の warmup。
*   **Logic**: mode `100755` を保つ。中身を編集しない。

### 定義ハッシュ（検証用の式。コード変更なし）

定義 tip が `5d9d3aa9` のとき、次が成立すること。

```bash
export MSYS_NO_PATHCONV=1   # Git Bash on Windows: prevent path mangling of rev:path
img=$(git rev-parse 'HEAD:.kotoshiro/kanban/agent-vm/image.yaml')
ins=$(git rev-parse 'HEAD:.kotoshiro/kanban/agent-vm/install')
ver=$(git rev-parse 'HEAD:.kotoshiro/kanban/agent-vm/verify')
printf 'image.yaml=%s|install=%s|verify=%s' "$img" "$ins" "$ver" | sha256sum
```

期待値:

```text
08d135fe9c9fb355d2c9028cd65039d072dff675b37de46f60e451a5c82ef82d
```

tip が進んでいた場合は、正本との一致を確かめたうえで期待値を更新する判断を仕様 000 に従う（本計画の既定は tip `5d9d3aa9`）。

### form_app / 検査スクリプト

変更しない。merge 後も次が残ることだけ確認する。

*   `form_app/android/settings.gradle.kts` に `id("com.android.application") version "9.3.1"`
*   `scripts/process/check_form_app_android.sh` および関連検査が消えず、`build.sh` から呼ばれる

## Step-by-Step Implementation Guide

1. **[ ] Fetch definition tip**:
    *   Run `git fetch origin cardbot/agent-vm-definition`.
    *   Record `git rev-parse --short origin/cardbot/agent-vm-definition`.
    *   If tip is still `5d9d3aa9`, proceed with expected hash `08d135fe…`. If advanced, stop and apply 仕様 000 R2 before merging.
2. **[ ] Merge (or confirm already merged)**:
    *   If `git merge-base --is-ancestor origin/cardbot/agent-vm-definition HEAD` succeeds, skip creating a new merge commit and proceed to verification.
    *   Otherwise run `git merge origin/cardbot/agent-vm-definition` with a merge commit message that states the branch names. Do not stage ACS untracked paths.
3. **[ ] Confirm seven paths**:
    *   Run `git ls-tree -r HEAD -- .kotoshiro/kanban` and verify the 7 paths and modes above.
4. **[ ] Compute definition hash**:
    *   Run the hash commands in Proposed Changes. Expect `08d135fe…` when tip is `5d9d3aa9`.
5. **[ ] Confirm form_app Gradle intact**:
    *   `git show HEAD:form_app/android/settings.gradle.kts` contains AGP `9.3.1`.
6. **[ ] Confirm definition branch still on remote**:
    *   `git ls-remote --heads origin cardbot/agent-vm-definition` returns a ref. Do not delete it.
7. **[ ] Run Verification Plan**:
    *   Execute Automated Verification below (build.sh + checks).
8. **[ ] Far-knowledge + push**:
    *   Run pre-push knowledge check / `record.sh` as required, then `git push` for `chore-acs-bootstrap`.

## Verification Plan

### Automated Verification

1. **Build & Unit / Config Checks**:

```bash
./scripts/process/build.sh
```

期待: form_app Android 検査が `form_app_android_check_ok`、自己試験 PASS、パイプライン成功。

2. **Definition tree presence**:

```bash
export MSYS_NO_PATHCONV=1
git ls-tree -r HEAD -- .kotoshiro/kanban
```

期待: 上記 7 パス。`install/*.sh`・`verify/*.sh`・`warmup/*.sh` が `100755`。

3. **Definition hash**:

```bash
export MSYS_NO_PATHCONV=1
img=$(git rev-parse 'HEAD:.kotoshiro/kanban/agent-vm/image.yaml')
ins=$(git rev-parse 'HEAD:.kotoshiro/kanban/agent-vm/install')
ver=$(git rev-parse 'HEAD:.kotoshiro/kanban/agent-vm/verify')
printf 'image.yaml=%s|install=%s|verify=%s' "$img" "$ins" "$ver" | sha256sum
```

期待（tip `5d9d3aa9`）: `08d135fe9c9fb355d2c9028cd65039d072dff675b37de46f60e451a5c82ef82d`

4. **form_app AGP**:

```bash
export MSYS_NO_PATHCONV=1
git show HEAD:form_app/android/settings.gradle.kts | grep 'com.android.application'
```

期待: `version "9.3.1"`

5. **Definition branch retained**:

```bash
git ls-remote --heads origin cardbot/agent-vm-definition
```

期待: 1 行以上の refs/heads/cardbot/agent-vm-definition。

6. **Integration Tests**:

本変更では実行しない。理由: `scripts/process/integration_test.sh` は本リポジトリでは実質 no-op（仕様 002 と同じ）であり、git merge による定義ファイル追加の影響範囲外である。

7. **E2E Tests**:

不要。理由: GUI・ユーザー操作・新規実行バイナリは無く、git merge で定義ファイルを tip に載せるだけである。

8. **総合判定** (testing-rules §9):

全検証コマンド成功後に実施する。

*   スキップされた必須検査が無いか（form_app の flutter-build スキップは O1 任意であり必須ではない）。
*   `build.sh` ログに form_app FAIL が無いか。
*   定義ハッシュが手計算と一致し、迂回（手コピー後の編集）が無いか（merge 祖先確認）。
*   定義ブランチがリモートに残っているか。
*   ACS 未追跡が merge コミットに混入していないか（`git show --name-only` で merge コミットを確認）。

### テスト項目設計のセルフレビュー

*   ボトムアップ: tip 祖先確認 → ls-tree（存在・mode）→ 定義ハッシュ → form_app AGP → build.sh → リモート定義ブランチ残存。
*   網羅: R1〜R6 と O1。検証シナリオ 1〜7 を Automated Verification に対応付け。
*   証拠: merge 祖先、`ls-tree` の mode/blob、sha256 1 行、AGP grep、`ls-remote`、`build.sh` PASS。
*   迂回排除: 手コピー禁止を merge 祖先と blob 一致で担保。1 本化しないことを `ls-remote` で担保。
*   依存: Windows では `MSYS_NO_PATHCONV=1` を git `rev:path` に付ける。

## Documentation

`prompts/specifications` は存在しない。更新対象なし。
