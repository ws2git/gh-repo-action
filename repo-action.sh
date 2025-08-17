#!/bin/bash
set -e

ACTION="$1"
OWNER="$2"
REPO_NAME="$3"

if [[ -z "$ACTION" || -z "$OWNER" || -z "$REPO_NAME" ]]; then
  echo "Usage: $0 <action> <owner> <repo_name>"
  exit 1
fi

REPO="${OWNER}/${REPO_NAME}"

echo "Running: gh repo $ACTION $REPO --yes"
OUTPUT=$(gh repo "$ACTION" "$REPO" --yes 2>&1)
STATUS=$?

echo "$OUTPUT"
exit $STATUS
