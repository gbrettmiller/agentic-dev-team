#!/usr/bin/env bash
#
# dependency-graph.sh — C-DAD agent/skill dependency graph
#
# Reads depends-on: frontmatter fields from all agent and skill files,
# builds a dependency graph, and:
#   1. Emits a Mermaid diagram to stdout (default)
#   2. Detects circular dependencies (exit 1 if found)
#   3. Detects orphaned skills (skills with no used-by entries)
#   4. Updates registry manifests with used-by: arrays (--update-registry)
#
# Usage:
#   scripts/dependency-graph.sh [--format dot|mermaid] [--update-registry] [--check]
#
# Options:
#   --format mermaid   Output as Mermaid flowchart (default)
#   --format dot       Output as DOT language
#   --update-registry  Write used-by: arrays to registry manifests
#   --check            Exit 1 if circular deps or orphaned skills are found

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FORMAT="mermaid"
UPDATE_REGISTRY=false
CHECK_MODE=false
FAILURES=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --format) FORMAT="$2"; shift 2 ;;
    --update-registry) UPDATE_REGISTRY=true; shift ;;
    --check) CHECK_MODE=true; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Parse depends-on: frontmatter from all agents and skills
# ---------------------------------------------------------------------------
declare -A DEPS  # DEPS["node"]="dep1 dep2 ..."

parse_deps() {
  local file="$1"
  local node="$2"
  # Extract lines in the frontmatter block after depends-on:
  local in_front=false
  local in_deps=false
  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      if ! $in_front; then in_front=true; continue; else break; fi
    fi
    if $in_front; then
      if [[ "$line" =~ ^depends-on: ]]; then
        in_deps=true
        DEPS["$node"]=""
        continue
      fi
      if $in_deps; then
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+(.*) ]]; then
          dep="${BASH_REMATCH[1]}"
          DEPS["$node"]="${DEPS[$node]} $dep"
        else
          in_deps=false
        fi
      fi
    fi
  done < "$file"
}

# Collect all agents and skills as nodes
declare -A NODE_TYPE
for f in "$REPO_ROOT"/agents/*.md; do
  name="agents/$(basename "$f" .md)"
  NODE_TYPE["$name"]="agent"
  DEPS["$name"]=""
  parse_deps "$f" "$name"
done
for f in "$REPO_ROOT"/skills/*.md; do
  name="skills/$(basename "$f" .md)"
  NODE_TYPE["$name"]="skill"
  DEPS["$name"]=""
  parse_deps "$f" "$name"
done

# ---------------------------------------------------------------------------
# Build reverse index: used-by
# ---------------------------------------------------------------------------
declare -A USED_BY
for node in "${!DEPS[@]}"; do
  USED_BY["$node"]=""
done
for node in "${!DEPS[@]}"; do
  for dep in ${DEPS[$node]}; do
    if [[ -n "${USED_BY[$dep]+x}" ]]; then
      USED_BY["$dep"]="${USED_BY[$dep]} $node"
    fi
  done
done

# ---------------------------------------------------------------------------
# Detect circular dependencies (DFS)
# ---------------------------------------------------------------------------
declare -A VISITED
declare -A IN_STACK
CYCLES=()

dfs() {
  local node="$1"
  local path="$2"
  VISITED["$node"]=1
  IN_STACK["$node"]=1
  for dep in ${DEPS[$node]}; do
    [[ -n "${DEPS[$dep]+x}" ]] || continue
    if [[ -n "${IN_STACK[$dep]+x}" ]] && [[ "${IN_STACK[$dep]}" == "1" ]]; then
      CYCLES+=("Cycle: ${path} -> ${dep}")
      FAILURES=$((FAILURES + 1))
    elif [[ -z "${VISITED[$dep]+x}" ]] || [[ "${VISITED[$dep]}" == "0" ]]; then
      dfs "$dep" "${path} -> ${dep}"
    fi
  done
  IN_STACK["$node"]=0
}

for node in "${!DEPS[@]}"; do
  VISITED["$node"]=0
  IN_STACK["$node"]=0
done
for node in "${!DEPS[@]}"; do
  if [[ "${VISITED[$node]}" == "0" ]]; then
    dfs "$node" "$node"
  fi
done

# ---------------------------------------------------------------------------
# Detect orphaned skills (skills with no used-by and no explicit depends-on)
# ---------------------------------------------------------------------------
ORPHANS=()
for node in "${!NODE_TYPE[@]}"; do
  if [[ "${NODE_TYPE[$node]}" == "skill" ]]; then
    used="${USED_BY[$node]:-}"
    if [[ -z "$used" ]]; then
      ORPHANS+=("$node")
    fi
  fi
done

# ---------------------------------------------------------------------------
# Output graph
# ---------------------------------------------------------------------------
if [[ "$FORMAT" == "mermaid" ]]; then
  echo '```mermaid'
  echo "flowchart LR"
  for node in "${!DEPS[@]}"; do
    safe_node="${node//\//_}"
    safe_node="${safe_node//-/_}"
    label="$node"
    echo "  ${safe_node}[\"${label}\"]"
  done
  for node in "${!DEPS[@]}"; do
    safe_node="${node//\//_}"
    safe_node="${safe_node//-/_}"
    for dep in ${DEPS[$node]}; do
      safe_dep="${dep//\//_}"
      safe_dep="${safe_dep//-/_}"
      echo "  ${safe_node} --> ${safe_dep}"
    done
  done
  echo '```'
elif [[ "$FORMAT" == "dot" ]]; then
  echo "digraph dependencies {"
  for node in "${!DEPS[@]}"; do
    for dep in ${DEPS[$node]}; do
      echo "  \"${node}\" -> \"${dep}\";"
    done
  done
  echo "}"
fi

# ---------------------------------------------------------------------------
# Update registry manifests with used-by arrays
# ---------------------------------------------------------------------------
if $UPDATE_REGISTRY; then
  for node in "${!USED_BY[@]}"; do
    dir=$(echo "$node" | cut -d/ -f1)   # agents or skills
    name=$(echo "$node" | cut -d/ -f2)
    manifest="$REPO_ROOT/registry/${dir}/${name}.json"
    [ -f "$manifest" ] || continue
    used_list="${USED_BY[$node]}"
    # Build space-separated used-by list into a JSON array and write to manifest
    python3 -c 'import json,sys,pathlib; m=pathlib.Path(sys.argv[1]); items=[x for x in sys.argv[2].split() if x]; d=json.loads(m.read_text()); d["used-by"]=items; m.write_text(json.dumps(d,indent=2)+"\n")' "$manifest" "${used_list:-}"
  done
  echo "Registry manifests updated with used-by arrays." >&2
fi

# ---------------------------------------------------------------------------
# Report issues
# ---------------------------------------------------------------------------
if [[ ${#CYCLES[@]} -gt 0 ]]; then
  echo "" >&2
  echo "== Circular Dependencies ==" >&2
  for c in "${CYCLES[@]}"; do
    echo "  $c" >&2
  done
fi

if [[ ${#ORPHANS[@]} -gt 0 ]]; then
  echo "" >&2
  echo "== Orphaned Skills (no used-by) ==" >&2
  for o in "${ORPHANS[@]}"; do
    echo "  WARN: $o" >&2
  done
fi

if $CHECK_MODE && [[ "$FAILURES" -gt 0 ]]; then
  exit 1
fi

exit 0
