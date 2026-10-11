#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
skill_root="${SKILL_ROOT:-/Users/weiqi/.codex/skills/rokid-aiui-agent}"
mkdir -p "$root/.aiui-evidence"
python3 "$skill_root/scripts/fingerprint_aiui_project.py" "$root" --repository-root "$root" > "$root/.aiui-evidence/fingerprint.txt"
python3 "$skill_root/scripts/inventory_aiui_capabilities.py" "$root" --target-version 0.17.0 --repository-root "$root" > "$root/.aiui-evidence/inventory.json"
python3 "$skill_root/scripts/validate_aiui_project.py" "$root" --target-version 0.17.0 --repository-root "$root" --strict --json > "$root/.aiui-evidence/project-validation.json"
echo "AIUI project structure validated. See .aiui-evidence/inventory.json for the current capability ledger."
