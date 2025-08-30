#!/bin/bash
set -e

ACTION="$1"
OWNER="$2"
REPO_NAME="$3"
DESCRIPTION="$4"
VISIBILITY="$5"
TEAM="$6"
ADD_README="$7"
TEMPLATE="$8"

# Checking mandatory parameters
if [[ -z "$ACTION" || -z "$OWNER" || -z "$REPO_NAME" ]]; then
  echo "Uso: $0 <action> <owner> <repo_name> [<description>] [<visibility>] [<team>] [<add_readme>] [<template>]"
  echo "Exemplos:"
  echo "  ./repo-manager.sh create my-org my-new-repo \"An incredible project!\" public my-team true"
  echo "  ./repo-manager.sh create my-org template-project \"A new description\" -- -- \"\" my-org/my-template-repo"
  exit 1
fi

REPO="${OWNER}/${REPO_NAME}"

# Initializes the base command and arguments
COMMAND_ARGS=( "$ACTION" "$REPO" )

case "$ACTION" in
  "create")

    if [[ -n "$DESCRIPTION" ]]; then
      COMMAND_ARGS+=( "--description" "$DESCRIPTION" )
    fi
    
    # Checking restrictions on the --template parameter
    if [[ -n "$TEMPLATE" ]]; then
      if [[ "$ADD_README" == "true" || -n "$TEAM" ]]; then
        echo "Erro: O parâmetro --template não pode ser usado com --add-readme ou --team."
        exit 1
      fi
      COMMAND_ARGS+=( "--template" "$TEMPLATE" )
    else
      # Add the optional parameters only if you are not using --template
      if [[ "$ADD_README" == "true" ]]; then
        COMMAND_ARGS+=( "--add-readme" )
      fi

      if [[ -n "$TEAM" ]]; then
        COMMAND_ARGS+=( "--team" "$TEAM" )
      fi
    fi

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
    echo "Erro: Ação desconhecida '$ACTION'."
    exit 1
    ;;
esac

# Runs the gh command with the array arguments
echo "Executando: gh repo ${COMMAND_ARGS[@]}"
OUTPUT=$(gh repo "${COMMAND_ARGS[@]}" 2>&1)
STATUS=$?

echo "$OUTPUT"
exit $STATUS
