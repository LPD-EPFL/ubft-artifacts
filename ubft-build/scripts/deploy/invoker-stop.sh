#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

WIN_NAME=$1

tmux send-keys -t "ukharon:${WIN_NAME}" C-c
