#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

MSG_SZ=(1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192)

if [ -z $FASTPATH_ON ]; then 
   logname="slowpath"
   sleepfor=120
   req_cnt=10000
else
   logname="fastpath"
   sleepfor=10
   req_cnt=100000
fi

for msg_sz in ${MSG_SZ[@]}; do
    reset_processes
    ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ukharon_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

    ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/invoker.sh binaries/tail-cb-ping ubft-tcb-test -l 1 $FASTPATH_ON -s ${msg_sz}"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/invoker.sh binaries/tail-cb-ping ubft-tcb-test -l 2 $FASTPATH_ON -s ${msg_sz}"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/invoker.sh binaries/tail-cb-ping ubft-tcb-test -l 3 $FASTPATH_ON -s ${msg_sz}"

    sleep $sleepfor

    ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine1)/deployment/invoker-stop.sh ubft-tcb-test"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine2)/deployment/invoker-stop.sh ubft-tcb-test"
    ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ukharon_experiment/$(machine2dir machine3)/deployment/invoker-stop.sh ubft-tcb-test"
    
    gather_results "$SCRIPT_DIR"/logs/tcb-latency-${logname}-s${msg_sz}
done

clear_processes
