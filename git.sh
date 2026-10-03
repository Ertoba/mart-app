#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

MESSAGE="${1:-}"
if [ -z "$MESSAGE" ]; then
  printf 'Commit message: '
  IFS= read -r MESSAGE </dev/tty
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)

git add -A
git commit -m "$MESSAGE"
git push -u origin "$BRANCH"

printf '\nBranch : %s\n' "$BRANCH"
printf 'Commit : %s\n' "$(git rev-parse --short HEAD)"
printf 'Changes:\n'
# git pages --stat past a screenful and the script would sit at (END)
git --no-pager show --stat --format= HEAD

# SUMMARY
# Commits and pushes the current branch in one step. Takes the commit message as an
# argument or prompts for it, stages everything, commits, pushes to origin, then prints
# the branch name, the new commit id and the files the commit changed.
