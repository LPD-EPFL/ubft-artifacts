#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"/../usig

make clean

make V=1 SGX_MODE=HW SGX_DEBUG=1 test
# Alternative binaries:
# make V=1 SGX_MODE=SIM SGX_DEBUG=1 test
# or
# make V=1 SGX_MODE=SIM SGX_DEBUG=0 test
