#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

cp ../../../ubft-build/payload.zip ../../apps/mu/
cp ../../../ubft-build/payload.zip ../../apps/ubft/
cp ../../../ubft-build/payload.zip ../../apps/unreplicated/

cp ../../../minbft-build/payload.zip ../../minbft
