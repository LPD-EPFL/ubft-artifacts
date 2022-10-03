#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"/../ubft

./build.py distclean

./build.py ubft
./build.py ubft-apps
ubft-apps/binaries.sh
