#!/bin/bash
set -e

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Havppen PM Skills..."
mkdir -p "$SKILLS_DIR"

for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  dest="$SKILLS_DIR/$skill_name"

  if [ -d "$dest" ]; then
    echo "  updating: $skill_name"
  else
    echo "  installing: $skill_name"
    mkdir -p "$dest"
  fi

  cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
done

echo ""
echo "✅ Done. Restart Claude Code to activate the skills."
echo ""
echo "Available skills:"
for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  desc=$(grep '^description:' "$skill_dir/SKILL.md" | head -1 | sed 's/description: //' | tr -d '"' | cut -c1-60)
  echo "  /$skill_name — $desc..."
done
