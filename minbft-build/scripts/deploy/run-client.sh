#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"

REQUEST_CNT=$1
REQUEST_LENGTH=$2

export LD_LIBRARY_PATH="$(pwd)/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
cat /dev/urandom | tr -dc '[:alpha:]' | fold -w $REQUEST_LENGTH | head -n $REQUEST_CNT | ./peer request --logging-level error
