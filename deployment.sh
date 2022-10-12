#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

rm -rf deployment.zip
zip -r deployment.zip minbft-build/payload.zip
zip -r deployment.zip ubft-build/payload.zip
zip -r deployment.zip usig-build/payload.zip
zip -r deployment.zip experiments
