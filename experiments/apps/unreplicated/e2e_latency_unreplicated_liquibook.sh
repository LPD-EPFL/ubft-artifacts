#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

BUY_PERC=(0 25 50 75 100)

for buy_perc in ${BUY_PERC[@]}; do
    reset_processes
    ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ubft_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

    ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ubft_experiment/$(machine2dir machine1)/deployment/invoker.sh binaries/mu-server mu-server -l 1 -r 1 -a liquibook -c $buy_perc -w 1"
    sleep 5
    ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ubft_experiment/$(machine2dir machine2)/deployment/invoker.sh binaries/mu-client mu-client -l 64 -s 1 -a liquibook -c $buy_perc -w 1"

    sleep 10
    
    gather_results "$SCRIPT_DIR"/logs/e2e-latency-liquibook-unreplicated-b${buy_perc}
done

clear_processes
