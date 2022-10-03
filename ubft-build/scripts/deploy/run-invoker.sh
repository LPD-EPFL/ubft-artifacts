#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

[ -f "$SCRIPT_DIR"/binaries/config.sh ] && source "$SCRIPT_DIR"/binaries/config.sh "$SCRIPT_DIR"/binaries

source "$SCRIPT_DIR"/../registry.sh

BIN_PATH=$1
ARGS="${@:2}"

echo "Executing \`$(UBFT_CMD_PREFIX) numactl --cpunodebind=$UBFT_CPUNODEBIND --membind=$UBFT_CPUMEMBIND $BIN_PATH $ARGS\`"

$(UBFT_CMD_PREFIX) numactl --cpunodebind=$UBFT_CPUNODEBIND --membind=$UBFT_CPUMEMBIND "$BIN_PATH" $ARGS
