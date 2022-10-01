#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

MSG_SZ=(2 4 8 16 32 64 128 256 512 1024 2048 4096 8192)

for msg_sz in ${MSG_SZ[@]}; do
    reset_processes
    ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

    ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/invoker.sh binaries/mu-server mu-server -l 1 -r 1 -a flip -c $msg_sz,$((msg_sz+1)) -w 1"
    sleep 5
    ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/invoker.sh binaries/mu-client mu-client -l 64 -s 1 -a flip -c $msg_sz,$((msg_sz+1)) -w 1"

    sleep 10
    
    gather_results "$SCRIPT_DIR"/logs/e2e-latency-flip-unreplicated-s${msg_sz}
done

clear_processes
