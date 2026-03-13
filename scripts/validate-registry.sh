#!/usr/bin/env bash
#
# validate-registry.sh — C-DAD registry integrity check
#
# Validates that every agent and skill markdown file has a matching
# registry manifest, that version and lifecycle fields are in sync,
# and that all artifact paths in manifests resolve to real files.
#
# Exit 0: all checks pass
# Exit 1: one or more failures

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAILURES=0
WARNINGS=0

fail() {
  echo "  FAIL: $1"
  FAILURES=$((FAILURES + 1))
}

warn() {
  echo "  WARN: $1"
  WARNINGS=$((WARNINGS + 1))
}

# ---------------------------------------------------------------------------
# 1. Every agent in agents/*.md must have a registry entry
# ---------------------------------------------------------------------------
echo ""
echo "== Check 1: Registry entry existence =="
for agent_file in "$REPO_ROOT"/agents/*.md; do
  name=$(basename "$agent_file" .md)
  manifest="$REPO_ROOT/registry/agents/${name}.json"
  if [ ! -f "$manifest" ]; then
    fail "agents/${name}.md has no registry entry (expected registry/agents/${name}.json)"
  fi
done

# ---------------------------------------------------------------------------
# 2. Registry version matches frontmatter version
# ---------------------------------------------------------------------------
echo ""
echo "== Check 2: Version sync (frontmatter == registry) =="
for manifest in "$REPO_ROOT"/registry/agents/*.json; do
  name=$(basename "$manifest" .json)
  agent_file="$REPO_ROOT/agents/${name}.md"
  if [ ! -f "$agent_file" ]; then
    warn "registry/agents/${name}.json has no corresponding agents/${name}.md"
    continue
  fi
  fm_version=$(grep -m1 '^version:' "$agent_file" | awk '{print $2}')
  reg_version=$(python3 -c "import json,sys; d=json.load(open('$manifest')); print(d.get('version',''))" 2>/dev/null)
  if [ -z "$fm_version" ]; then
    fail "agents/${name}.md is missing 'version:' frontmatter field"
  elif [ "$fm_version" != "$reg_version" ]; then
    fail "agents/${name}.md version mismatch: frontmatter=${fm_version}, registry=${reg_version}"
  fi
done

# Also check skills
for manifest in "$REPO_ROOT"/registry/skills/*.json; do
  [ -f "$manifest" ] || continue
  name=$(basename "$manifest" .json)
  skill_file="$REPO_ROOT/skills/${name}.md"
  if [ ! -f "$skill_file" ]; then
    warn "registry/skills/${name}.json has no corresponding skills/${name}.md"
    continue
  fi
  fm_version=$(grep -m1 '^version:' "$skill_file" | awk '{print $2}')
  reg_version=$(python3 -c "import json,sys; d=json.load(open('$manifest')); print(d.get('version',''))" 2>/dev/null)
  if [ -z "$fm_version" ]; then
    fail "skills/${name}.md is missing 'version:' frontmatter field"
  elif [ "$fm_version" != "$reg_version" ]; then
    fail "skills/${name}.md version mismatch: frontmatter=${fm_version}, registry=${reg_version}"
  fi
done

# ---------------------------------------------------------------------------
# 3. Registry lifecycle matches frontmatter status
# ---------------------------------------------------------------------------
echo ""
echo "== Check 3: Lifecycle sync (frontmatter status == registry lifecycle) =="
for manifest in "$REPO_ROOT"/registry/agents/*.json; do
  name=$(basename "$manifest" .json)
  agent_file="$REPO_ROOT/agents/${name}.md"
  [ -f "$agent_file" ] || continue
  fm_status=$(grep -m1 '^status:' "$agent_file" | awk '{print $2}')
  reg_lifecycle=$(python3 -c "import json,sys; d=json.load(open('$manifest')); print(d.get('lifecycle',''))" 2>/dev/null)
  if [ -z "$fm_status" ]; then
    warn "agents/${name}.md is missing 'status:' frontmatter field"
  elif [ "$fm_status" != "$reg_lifecycle" ]; then
    fail "agents/${name}.md lifecycle mismatch: status=${fm_status}, registry.lifecycle=${reg_lifecycle}"
  fi
done

# ---------------------------------------------------------------------------
# 4. All artifact paths in manifests resolve to real files
# ---------------------------------------------------------------------------
echo ""
echo "== Check 4: Artifact paths exist =="
for manifest in "$REPO_ROOT"/registry/agents/*.json "$REPO_ROOT"/registry/skills/*.json "$REPO_ROOT"/registry/commands/*.json; do
  [ -f "$manifest" ] || continue
  name=$(basename "$manifest" .json)
  dir=$(basename "$(dirname "$manifest")")
  source_path=$(python3 -c "import json,sys; d=json.load(open('$manifest')); print(d.get('artifacts',{}).get('source',''))" 2>/dev/null)
  if [ -n "$source_path" ] && [ ! -f "$REPO_ROOT/$source_path" ]; then
    fail "${dir}/${name}.json artifacts.source '${source_path}' does not exist"
  fi
done

# ---------------------------------------------------------------------------
# 5. Index completeness — all active manifests appear in registry/index.json
# ---------------------------------------------------------------------------
echo ""
echo "== Check 5: Index completeness =="
INDEX="$REPO_ROOT/registry/index.json"
if [ ! -f "$INDEX" ]; then
  fail "registry/index.json is missing"
else
  for manifest in "$REPO_ROOT"/registry/agents/*.json; do
    name=$(basename "$manifest" .json)
    id="agents/${name}"
    if ! python3 -c "import json,sys; d=json.load(open('$INDEX')); ids=[e['id'] for e in d.get('entries',[])]; sys.exit(0 if '$id' in ids else 1)" 2>/dev/null; then
      warn "registry/index.json missing entry for '${id}'"
    fi
  done
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "== Registry Validation Summary =="
echo "  Failures: $FAILURES"
echo "  Warnings: $WARNINGS"
echo ""

if [ "$FAILURES" -gt 0 ]; then
  echo "RESULT: FAIL"
  exit 1
else
  echo "RESULT: PASS"
  exit 0
fi
