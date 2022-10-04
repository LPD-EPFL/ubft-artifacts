#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"

CRYPTO=$1 # minbft_ecsda or minbft_noecdsa
VMA=$2 # vma or nothing

REQUEST_CNT=$3
REQUEST_LENGTH=$4

cd "$(pwd)"/binaries/$CRYPTO/minbft

export LD_LIBRARY_PATH="$(pwd)/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

if [ "$VMA" == "novma" ]; then
  cat /dev/urandom | tr -dc '[:alpha:]' | fold -w $REQUEST_LENGTH | head -n $REQUEST_CNT | ./peer request --logging-level error
else
  export LD_PRELOAD=libvma.so
  cat /dev/urandom | tr -dc '[:alpha:]' | fold -w $REQUEST_LENGTH | head -n $REQUEST_CNT | ./peer request --logging-level error
fi
