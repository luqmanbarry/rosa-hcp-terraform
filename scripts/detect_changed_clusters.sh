#!/usr/bin/env bash

set -euo pipefail

BASE_REF="${1:-origin/main}"
HEAD_REF="${2:-HEAD}"

git diff --name-only "${BASE_REF}" "${HEAD_REF}" \
  | grep -E '^clusters/[^/]+/[^/]+' \
  | cut -d/ -f1-3 \
  | sort -u
