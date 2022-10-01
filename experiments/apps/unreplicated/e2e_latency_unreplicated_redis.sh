#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

# Disabled
MSG_SZ=(0)

key_sz=16
value_sz=32
get_percentage=30
succ_gets=80

for msg_sz in ${MSG_SZ[@]}; do
    reset_processes
    ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

    ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/invoker.sh binaries/mu-server mu-server -l 1 -r 1 -a redis -c $key_sz,$value_sz,$get_percentage,$succ_gets -w 1"
    sleep 5
    ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/invoker.sh binaries/mu-client mu-client -l 64 -s 1 -a redis -c $key_sz,$value_sz,$get_percentage,$succ_gets -w 1"

    sleep 10
    
    gather_results "$SCRIPT_DIR"/logs/e2e-latency-redis-unreplicated-k${key_sz}-v${value_sz}-g${get_percentage}-s${succ_gets}
done

clear_processes
