#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

WIN_NAME=$1

tmux capture-pane -t ubft:${WIN_NAME} -pS -10000 | grep -Po "PID\\d+PID" | sed -r 's/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/'
