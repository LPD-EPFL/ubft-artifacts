#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

SIZE=$1
RESULT=$2
./usig_test libusig.signed.so $SIZE > "$RESULT"
