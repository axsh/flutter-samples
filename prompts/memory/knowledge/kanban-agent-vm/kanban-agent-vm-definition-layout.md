---
id: kanban-agent-vm-definition-layout
knowledge_id: kanban-agent-vm-definition-layout
title: Kanban Agent VM definition layout
status: current
category_path: kanban-agent-vm
created_at: 2026-11-28T02:16:48.3839267Z
last_updated: 2026-11-28T02:16:48.3839267Z
source_event_ids:
    - E-01M8DGQTHCY4T6994191WY28X3
    - E-01M8DACA45AG2FAGH7N0ZPSJ6D
---

# Kanban Agent VM definition layout

## Install scripts location

Kanban's repository-definition bake hands the builder only a copy of `.kotoshiro/kanban/agent-vm/`, so package lists and install/verify scripts must live there. Scripts placed under `scripts/` are invisible to the bake. Work that needs the source tree belongs in `warmup/`.

## Lane templates

Kanban's pin-layer bake fails unless `.kotoshiro/kanban/lane_templates.yaml` exists at the pinned commit, so every branch used as a Kanban board target must carry that file.

## Definition content hash

Kanban keys the repository-definition layer AMI by sha256 of the `image.yaml` blob ID and the `install/` and `verify/` tree IDs (file modes included), joined as `image.yaml=<oid>|install=<oid>|verify=<oid>`. Keeping `.kotoshiro/kanban/agent-vm/` byte- and mode-identical to the kanban-demo canonical copy lets boards reuse an already baked AMI.

For tip `5d9d3aa9`, the expected hash is `08d135fe9c9fb355d2c9028cd65039d072dff675b37de46f60e451a5c82ef82d`.

## Canonical source and merge policy

The canonical Agent VM definition for this fork is kanban-demo `scripts/infra-aws3/agent-vm/examples/flutter-samples/`. Definition changes should be made there first and then brought into this repository via `git merge` of `cardbot/agent-vm-definition` (not hand copy or cherry-pick alone). Do not delete `origin/cardbot/agent-vm-definition` as part of bringing the definition onto a work branch.
