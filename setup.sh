#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./setup.sh <claude|codex> [target_project]

Symlinks this llm-skills checkout into a target project.
If target_project is omitted, the current directory is used.
USAGE
}

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
llm="${1:-}"
target_project="${2:-$PWD}"

if [[ -z "$llm" ]]; then
  usage
  exit 1
fi

case "$llm" in
  claude | codex)
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    usage
    echo
    echo "Invalid llm: $llm" >&2
    exit 1
    ;;
esac

if [[ ! -d "$target_project" ]]; then
  echo "Target project does not exist: $target_project" >&2
  exit 1
fi

target_project="$(cd "$target_project" && pwd)"

if [[ "$target_project" == "$repo_dir" ]]; then
  echo "Target project must be different from this llm-skills checkout." >&2
  exit 1
fi

link_path() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" ]]; then
    local current_target
    current_target="$(readlink "$target")"
    if [[ "$current_target" == "$source" ]]; then
      return
    fi
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    echo "Refusing to overwrite existing path: $target" >&2
    exit 1
  fi

  ln -s "$source" "$target"
}

link_skills() {
  mkdir -p "$target_project/.agents"
  ln -sfn "$repo_dir/skills" "$target_project/.agents/skills"
}

case "$llm" in
  codex)
    link_path "$repo_dir/.codex" "$target_project/.codex"
    link_path "$repo_dir/AGENTS.md" "$target_project/AGENTS.md"
    link_skills
    ;;
  claude)
    link_path "$repo_dir/.claude" "$target_project/.claude"
    link_path "$repo_dir/CLAUDE.md" "$target_project/CLAUDE.md"
    link_path "$repo_dir/AGENTS.md" "$target_project/AGENTS.md"
    link_skills
    ;;
esac

echo "Installed $llm setup into $target_project"
