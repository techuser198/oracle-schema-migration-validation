#!/bin/bash

usage() {
  cat <<EOF

Usage:
  ./schema-migration-validation.sh <operation> <config>
  operations:
    - compare-counts: Compare table counts between source and target databases.
    - validate-schema: Validate schema consistency between source and target databases.

  config:
    - Path to the configuration file containing database connection details.
    - Example: ./vars/migration-CM.yml
    - Example: ./vars/migration-VB.yml

EOF
}

runPlaybook() {
    local playbook="$1"
    local operation="$2"
    local config="$3"
    ansible-playbook "$playbook" --extra-vars "operation=$operation config=$config"
}

TASK="$1"
CONFIG="$2"
PLAYBOOK="schema-migration-validation.yml"

if [[ -z "$TASK" || -z "$CONFIG" ]]; then
  usage
  exit 1
fi

case "$TASK" in
  compare-counts|validate-schema)
    OPERATION="$TASK"
    ;;
  *)
    echo "Invalid operation: $TASK"
    usage
    exit 1
    ;;
esac

runPlaybook "$PLAYBOOK" "$OPERATION" "$CONFIG"
