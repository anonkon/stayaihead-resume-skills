#!/usr/bin/env bash
# Installs the stayaihead-resume-skills Claude Code skills into ~/.claude/skills/
# Usage: ./install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/skills"
DEST_DIR="$HOME/.claude/skills"
SKILLS=(build-profile tailor-job)

mkdir -p "$DEST_DIR"

for skill in "${SKILLS[@]}"; do
  target="$DEST_DIR/$skill"
  if [ -d "$target" ]; then
    read -r -p "Skill '$skill' already exists at $target. Overwrite? [y/N] " ans
    if [[ ! "$ans" =~ ^[Yy]$ ]]; then
      echo "Skipping $skill"
      continue
    fi
    rm -rf "$target"
  fi
  cp -r "$SRC_DIR/$skill" "$target"
  echo "Installed $skill -> $target"
done

mkdir -p "$HOME/.claude/resume"

echo ""
echo "Done. In Claude Code, run:"
echo "  /build-profile   to set up your career profile"
echo "  /tailor-job      to generate a tailored CV + cover letter for a job description"
