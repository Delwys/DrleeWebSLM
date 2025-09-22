#!/usr/bin/env zsh
# macOS/zsh equivalent of git-push.bat
# This script sets the remote to your GitHub repo, shows status, stages changes,
# commits with a message (or a default), and optionally force-pushes to main.

set -o errexit
set -o pipefail
set -o nounset

REPO_URL="https://github.com/Delwys/DrleeWebSLM.git"
BRANCH="main"

echo "Running Git Push Script for DrleeWebSLM (zsh)"
echo "=========================================="

echo "Setting remote repository to ${REPO_URL}..."
# Remove origin if it exists (ignore errors)
git remote remove origin 2>/dev/null || true
git remote add origin "${REPO_URL}"

echo
echo "Checking current status..."
git status

echo
echo "Adding all files except those in .gitignore..."
git add .

echo
# Prompt for commit message; default if empty
read -r "commit_msg?Enter commit message (or press Enter for default message): "
if [[ -z "${commit_msg}" ]]; then
  commit_msg="Fixed TypeScript errors and added Google Analytics integration"
fi

echo "Committing changes..."
# If there are no staged changes, 'git commit' will fail; handle gracefully
if git diff --cached --quiet; then
  echo "No staged changes to commit. Skipping commit."
else
  git commit -m "${commit_msg}"
fi

echo
cat <<'WARN'
WARNING: This will FORCE PUSH to the repository, potentially overwriting remote changes.
This makes the remote repository match your local repository exactly.
WARN

read -r "confirm?Are you sure you want to force push? (Y/N): "
if [[ "${confirm:l}" == "y" ]]; then
  echo "Pushing to GitHub repository: ${REPO_URL}"
  # Ensure branch exists locally
  if ! git rev-parse --verify "${BRANCH}" >/dev/null 2>&1; then
    echo "Local branch '${BRANCH}' does not exist. Creating it..."
    git checkout -b "${BRANCH}"
  fi
  git push -f -u origin "${BRANCH}"
else
  echo "Force push canceled."
  exit 1
fi

echo
echo "Done!"
echo "=========================================="
