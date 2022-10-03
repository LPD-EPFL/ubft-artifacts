#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CRYPTOPT=$1
VMAOPT=$2

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

reset_processes

ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ubft_experiment/$(machine2dir machine1)/deployment/invoker.sh ./run-replica.sh minbft-replica 0 $CRYPTOPT $VMAOPT"
ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ubft_experiment/$(machine2dir machine2)/deployment/invoker.sh ./run-replica.sh minbft-replica 1 $CRYPTOPT $VMAOPT"
ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ubft_experiment/$(machine2dir machine3)/deployment/invoker.sh ./run-replica.sh minbft-replica 2 $CRYPTOPT $VMAOPT"

sleep 10

MSG_SZ=(2 4 8 16 32 64 128 256 512 1024 2048 4096 8192)
for msg_sz in ${MSG_SZ[@]}; do
  ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ubft_experiment/$(machine2dir machine4)/deployment/invoker.sh ./run-client.sh minbft-client $CRYPTOPT $VMAOPT 100000 $msg_sz" 
  sleep 60

  gather_results "$SCRIPT_DIR"/logs/e2e-latency-$CRYPTOPT-$VMAOPT-${msg_sz}
done

clear_processes
