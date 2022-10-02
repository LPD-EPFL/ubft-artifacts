#!/bin/bash

# Use the absolute path
ROOT_DIR='~'

# Set ssh names of the SGX machine
sgxmachine=sgx

UBFT_CPUNODEBIND=0
UBFT_CPUMEMBIND=0

# Do not edit below this line
sgxmachinedir=ubft_sgx

send_payload () {
    local payload=$1

    ssh -o LogLevel=QUIET -t $sgxmachine \
        "rm -rf $ROOT_DIR/ubft_experiment/$sgxmachinedir && \
         mkdir -p $ROOT_DIR/ubft_experiment/$sgxmachinedir/logs"

    scp "$payload" $sgxmachine:$ROOT_DIR/ubft_experiment/$sgxmachinedir/payload.zip

    ssh -o LogLevel=QUIET -t $sgxmachine "cd $ROOT_DIR/ubft_experiment/$sgxmachinedir && unzip -d deployment payload.zip"
}

gather_results () {
    local destdir=$1

    mkdir -p "$destdir"/"$sgxmachinedir"

    scp -r $sgxmachine:$ROOT_DIR/ubft_experiment/$sgxmachinedir/logs "$destdir"/"$sgxmachinedir"
}
