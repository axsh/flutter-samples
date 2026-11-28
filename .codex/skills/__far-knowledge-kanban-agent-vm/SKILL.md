---
apiVersion: agent.meta/v1
kind: capability
id: __far-knowledge-kanban-agent-vm
title: "Far-Knowledge: Kanban Agent VM"
description: >-
  Where Agent VM install/verify scripts live, lane_templates requirement,
  definition content hash, canonical source, and merge-without-delete policy.
user_visible: false
manual_only: false
status: current
body: inline
---

# Kanban Agent VM definition

## Layout

- Bake sees only `.kotoshiro/kanban/agent-vm/`. Put install/verify scripts there, not under `scripts/`.
- Source-tree work belongs in `warmup/`.
- Board pin bake needs `.kotoshiro/kanban/lane_templates.yaml` at the pinned commit.

## Definition hash

- AMI key is sha256 of `image.yaml=<blob>|install=<tree>|verify=<tree>` (modes included).
- Tip `5d9d3aa9` expects `08d135fe9c9fb355d2c9028cd65039d072dff675b37de46f60e451a5c82ef82d`.

## Canonical source and merge

- Canonical copy: kanban-demo `scripts/infra-aws3/agent-vm/examples/flutter-samples/`.
- Bring into this repo with `git merge` of `cardbot/agent-vm-definition` (preserve blob/tree/mode). Do not hand-copy as the primary method.
- Do not delete `origin/cardbot/agent-vm-definition` when merging onto a work branch.
