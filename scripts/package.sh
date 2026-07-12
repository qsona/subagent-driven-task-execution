#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
name="subagent-driven-task-execution"
dist="$root/dist"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

rm -rf "$dist"
mkdir -p "$dist" "$stage/$name/agents"

cp "$root/SKILL.md" "$stage/$name/SKILL.md"
cp "$root/LICENSE" "$stage/$name/LICENSE"
cp "$root/THIRD_PARTY_NOTICES.md" "$stage/$name/THIRD_PARTY_NOTICES.md"
cp "$root/agents/openai.yaml" "$stage/$name/agents/openai.yaml"
(
  cd "$stage"
  zip -X -q -r "$dist/$name-codex.zip" "$name"
)

rm -rf "$stage/$name/agents"
(
  cd "$stage"
  zip -X -q -r "$dist/$name-claude.zip" "$name"
)

(
  cd "$dist"
  shasum -a 256 "$name-codex.zip" "$name-claude.zip" > SHA256SUMS
)

echo "Created release assets in $dist"
