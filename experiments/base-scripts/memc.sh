#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

tmux new-session -d -s "ubft" &>/dev/null || true
tmux new-window -t "ubft" -n "memc" "LD_PRELOAD=$SCRIPT_DIR/libreparent.so memcached -vv"
