#!/usr/bin/env bash
set -e

ACTION="$1"
OWNER="$2"
REPO_NAME="$3"
DESCRIPTION="$4"
VISIBILITY="$5"
TEAM="$6"
ADD_README="$7"
TEMPLATE="$8"
NEW_NAME="$9"
HOMEPAGE="${10}"
ADD_TOPICS="${11}"
REMOVE_TOPICS="${12}"

# Checking mandatory parameters
if [[ -z "$ACTION" || -z "$OWNER" || -z "$REPO_NAME" ]]; then
  echo "Uso: $0 <action> <owner> <repo_name> [<description>] [<visibility>] [<team>] [<add_readme>] [<template>] [<new_name>] [<homepage>] [<add_topics>] [<remove_topics>]"
  echo "Exemplos:"
  echo "  ./repo-manager.sh create my-org my-new-repo \"Um projeto incrivel!\""
  echo "  ./repo-manager.sh edit my-org my-repo \"Uma nova descricao\""
  echo "  ./repo-manager.sh rename my-org my-repo my-new-name"
  exit 1
fi

REPO="${OWNER}/${REPO_NAME}"
COMMAND_ARGS=( "$ACTION" )

case "$ACTION" in
  "create")
    COMMAND_ARGS+=( "$REPO" )
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

  "edit")
    COMMAND_ARGS+=( "$REPO" )
    if [[ -n "$DESCRIPTION" ]]; then
      COMMAND_ARGS+=( "--description" "$DESCRIPTION" )
    fi
    
    if [[ -n "$HOMEPAGE" ]]; then
      COMMAND_ARGS+=( "--homepage" "$HOMEPAGE" )
    fi

    if [[ -n "$ADD_TOPICS" ]]; then
      IFS=',' read -r -a TOPICS_ARRAY <<< "$ADD_TOPICS"
      for topic in "${TOPICS_ARRAY[@]}"; do
        COMMAND_ARGS+=( "--add-topic" "$(echo "$topic" | xargs)" )
      done
    fi

    if [[ -n "$REMOVE_TOPICS" ]]; then
      IFS=',' read -r -a TOPICS_ARRAY <<< "$REMOVE_TOPICS"
      for topic in "${TOPICS_ARRAY[@]}"; do
        COMMAND_ARGS+=( "--remove-topic" "$(echo "$topic" | xargs)" )
      done
    fi
    ;;
  
  "rename")
    if [[ -z "$NEW_NAME" ]]; then
      echo "Erro: O parâmetro 'new_name' é obrigatório para a ação 'rename'."
      exit 1
    fi
    COMMAND_ARGS+=( "$NEW_NAME" --repo "$REPO" --yes )
    ;;

  "archive" | "unarchive" | "delete")
    COMMAND_ARGS+=( "$REPO" "--yes" )
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
