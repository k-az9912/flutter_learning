#!/bin/sh
set -eu

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "Run this script from inside the Git repository." >&2
  exit 1
}

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "Gitleaks is required. Install it with: brew install gitleaks" >&2
  exit 1
fi

git -C "$repo_root" config core.hooksPath .githooks
echo "Git hooks enabled: .githooks (Gitleaks $(gitleaks version))"
