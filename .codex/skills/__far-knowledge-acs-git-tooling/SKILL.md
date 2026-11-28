---
apiVersion: agent.meta/v1
kind: capability
id: __far-knowledge-acs-git-tooling
title: "Far-Knowledge: ACS Git tooling"
description: >-
  Flat ACS branch naming for phases paths and tt kdb backlog, and scoped
  MSYS_NO_PATHCONV usage on Windows Git Bash.
user_visible: false
manual_only: false
status: current
body: inline
---

# ACS branch layout and Windows Git Bash

## Flat branch names

- ACS docs live under `prompts/phases/<phase>/branches/<git branch name>/`.
- `tt kdb backlog` rejects branch names containing `/`. Use flat names such as `chore-acs-bootstrap`.

## MSYS_NO_PATHCONV

- Git Bash mangles `<rev>:<path>` arguments. Set `MSYS_NO_PATHCONV=1` only for those git calls.
- Do not leave it exported when running `scripts/process/build.sh`; `--repo-root` breaks and form_app checks report every rule as missing.
