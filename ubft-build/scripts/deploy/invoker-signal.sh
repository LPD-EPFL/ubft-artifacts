#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

WIN_NAME=$1
PID=$2

if [ -z $PID ] ; then
  PID=$(tmux capture-pane -t ukharon:${WIN_NAME} -pS -10000 | grep -Po "PID\\d+PID" | sed -r 's/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/')
  if [ -z $PID ] ; then
    echo "Could not fetch PID of the $WIN_NAME"
  else
    kill -SIGUSR1 $PID
  fi
else
  kill -SIGUSR1 $PID
fi
