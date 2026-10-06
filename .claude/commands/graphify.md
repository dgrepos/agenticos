---
description: Refresh the code map in memory/system-reference.md
allowed-tools: "Bash,Read"
---

Run `bash scripts/graphify.sh` and report the one-line summary it prints (modules/functions/components counted). If it errors, fix `scripts/graphify.py` — it is stdlib-only by design; do not add dependencies. Do not paste the generated map into the conversation; it lives in `memory/system-reference.md`.
