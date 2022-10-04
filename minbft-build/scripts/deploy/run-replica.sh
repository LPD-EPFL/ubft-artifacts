#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"

REPLICA_ID=$1
CRYPTO=$2 # minbft_ecsda or minbft_noecdsa
VMA=$3 # vma or nothing

cd "$(pwd)"/binaries/$CRYPTO/minbft

export LD_LIBRARY_PATH="$(pwd)/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

if [ "$VMA" == "novma" ]; then
  ./peer run --logging-level error $REPLICA_ID
else
  LD_PRELOAD=libvma.so ./peer run --logging-level error $REPLICA_ID
fi
