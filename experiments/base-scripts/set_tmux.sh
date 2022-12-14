#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source config.sh

M="$1"
MDIR=${M}dir

MACHINE="${!M}" 
MACHINEDIR="${!MDIR}" 

ssh -o LogLevel=QUIET -t $MACHINE \
    "tmux new-session -d -s ubft && \
     tmux set-option -g remain-on-exit on"
