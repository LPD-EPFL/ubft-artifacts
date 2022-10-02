#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

MSG_SZ=(2 4 8 16 32 64 128 256 512 1024 2048 4096 8192)

for msg_sz in ${MSG_SZ[@]}; do
    reset_processes
    ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

    ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/invoker.sh binaries/tail-p2p-ping tail-p2p-ping -l 1 -s $msg_sz"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/invoker.sh binaries/tail-p2p-ping tail-p2p-ping -l 2 -s $msg_sz"

    sleep 10
    
    ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/invoker-stop.sh tail-p2p-ping"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/invoker-stop.sh tail-p2p-ping"
    
    gather_results "$SCRIPT_DIR"/logs/tail-p2p-ping-s${msg_sz}
done

clear_processes
