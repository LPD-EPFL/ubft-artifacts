#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source config.sh

while true; do
	read -p "Did you appropriately configure $(realpath config.sh)?[y/n] " yn
    case $yn in
        [Yy]* ) echo "Great! Continuing with building"; break;;
        [Nn]* ) echo "Please, configure config.sh continuing"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

send_payload "$SCRIPT_DIR"/payload.zip

for i in 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192; do
    echo "Message size $i bytes"
    ssh -o LogLevel=QUIET -t $sgxmachine "numactl --cpunodebind=$UBFT_CPUNODEBIND --membind=$UBFT_CPUNODEBIND $ROOT_DIR/ubft_experiment/$sgxmachinedir/deployment/run.sh $i ../logs/usig_$i.txt"
done

gather_results "$SCRIPT_DIR"/logs/usig-latency
