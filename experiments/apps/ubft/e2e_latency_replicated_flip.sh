#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source parser.sh
source ../../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

MSG_SZ=(2 4 8 16 32 64 128 256 512 1024 2048 4096 8192)

for msg_sz in ${MSG_SZ[@]}; do
    reset_processes
    ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

    ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/invoker.sh binaries/ubft-server ubft-server -l 1 -s 1 -s 2 -s 3 -a flip -c $msg_sz,$((msg_sz+1)) -w 1 -b 1 $EXECUTION"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/invoker.sh binaries/ubft-server ubft-server -l 2 -s 1 -s 2 -s 3 -a flip -c $msg_sz,$((msg_sz+1)) -w 1 -b 1 $EXECUTION"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/invoker.sh binaries/ubft-server ubft-server -l 3 -s 1 -s 2 -s 3 -a flip -c $msg_sz,$((msg_sz+1)) -w 1 -b 1 $EXECUTION"
    sleep 10
    ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine4)/deployment/invoker.sh binaries/ubft-client ubft-client -l 64 -s 1 -s 2 -s 3 -a flip -c $msg_sz,$((msg_sz+1)) -w 1 $EXECUTION"

    if [[ -z $EXECUTION ]]
    then
      sleep 80
    else
      sleep 15
    fi
    
    gather_results "$SCRIPT_DIR"/logs/e2e-latency-${EXECUTION_PATH}-flip-replicated-s${msg_sz}
done

clear_processes
