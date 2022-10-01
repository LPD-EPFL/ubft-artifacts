#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export GOPATH="$SCRIPT_DIR"/../gocache
export PATH=$PATH:"$SCRIPT_DIR/../go/bin"

LD_LIBRARY_PATH_ORIG=$LD_LIBRARY_PATH

# Cleanup
find "$GOPATH" -type d -exec chmod 0755 {} \;
rm -rf "$GOPATH"

# Compile with ECDSA
cd "$SCRIPT_DIR"/../minbft_ecdsa

export SGX_MODE=SIM
make install

cd sample
export LD_LIBRARY_PATH="$(pwd)/lib${LD_LIBRARY_PATH_ORIG:+:$LD_LIBRARY_PATH_ORIG}"
bin/keytool generate -u lib/libusig.signed.so


# Compile without ECDSA
cd "$SCRIPT_DIR"/../minbft_noecdsa

export SGX_MODE=SIM
make install

cd sample
export LD_LIBRARY_PATH="$(pwd)/lib${LD_LIBRARY_PATH_ORIG:+:$LD_LIBRARY_PATH_ORIG}"
bin/keytool generate -u lib/libusig.signed.so
