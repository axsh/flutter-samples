---
id: acs-branch-layout-and-windows-git-bash
knowledge_id: acs-branch-layout-and-windows-git-bash
title: ACS branch layout and Windows Git Bash
status: current
category_path: acs-git-tooling
created_at: 2026-11-28T02:16:48.5888946Z
last_updated: 2026-11-28T02:16:48.5888946Z
source_event_ids:
    - E-01M8DACA45AG2FAGH7N0ZPSJ6D
---

# ACS branch layout and Windows Git Bash

## Flat branch names

ACS branch documents live in `prompts/phases/<phase>/branches/<git branch name>/` and `tt kdb backlog` rejects branch names containing a slash, so ACS work branches must use flat names such as `chore-acs-bootstrap`.

## MSYS_NO_PATHCONV scope

In Windows Git Bash, git arguments of the form `<rev>:<path>` are mangled by MSYS path conversion. Set `MSYS_NO_PATHCONV=1` only on those git calls. Do not leave it exported for `scripts/process/build.sh`, because `--repo-root` path resolution then breaks and form_app checks report every rule as missing.
