#!/bin/bash
set -e

ACTION="$1"
OWNER="$2"
REPO_NAME="$3"
DESCRIPTION="$4"
VISIBILITY="$5"

if [[ -z "$ACTION" || -z "$OWNER" || -z "$REPO_NAME" ]]; then
  echo "Usage: $0 <action> <owner> <repo_name> [<description>] [<visibility>]"
  exit 1
fi

REPO="${OWNER}/${REPO_NAME}"

# Inicializa o comando base e os argumentos
COMMAND_ARGS=( "$ACTION" "$REPO" )

case "$ACTION" in
  "create")
    if [[ -n "$DESCRIPTION" ]]; then
      COMMAND_ARGS+=( "--description" "$DESCRIPTION" )
    fi
    # Adiciona a flag de visibilidade apenas se necessário
    if [[ "$VISIBILITY" == "private" ]]; then
      COMMAND_ARGS+=( "--private" )
    elif [[ "$VISIBILITY" == "internal" ]]; then
      COMMAND_ARGS+=( "--internal" )
    fi
    ;;
  "archive" | "unarchive" | "delete")
    COMMAND_ARGS+=( "--yes" )
    ;;
  *)
    echo "Error: Unknown action '$ACTION'."
    exit 1
    ;;
esac

# Executa o comando gh com os argumentos do array
echo "Running: gh repo ${COMMAND_ARGS[@]}"
OUTPUT=$(gh repo "${COMMAND_ARGS[@]}" 2>&1)
STATUS=$?

echo "$OUTPUT"
exit $STATUS
