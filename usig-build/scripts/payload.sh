#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"/..

rm -rf payload.zip
zip -rj payload.zip usig/test/usig_test
zip -urj payload.zip usig/enclave/libusig.signed.so
cd usig
zip -ur ../payload.zip shim/libusig_shim.so
zip -urj ../payload.zip ../scripts/run.sh
