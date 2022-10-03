#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

BIN_PATH=$1
WIN_NAME=$2
ARGS="${@:3}"

tmux new-window -t "ubft" -n "$WIN_NAME" "stdbuf -o L -e L ./run-invoker.sh $BIN_PATH $ARGS 2>&1 | tee ../logs/${WIN_NAME}.txt"
