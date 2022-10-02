#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

cp ../../../ubft-build/payload.zip ../../tcb

cp ../../../usig-build/payload.zip ../../usig
