#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

if [ -z $FASTPATH_ON ]; then
   logname="slowpath"
   sleepfor=120
   req_cnt=10000
else
   logname="fastpath"
   sleepfor=10
   req_cnt=100000
fi

reset_processes
ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ubft_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ubft_experiment/$(machine2dir machine2)/deployment/invoker.sh binaries/rpc-server-test ubft-rpc-test -l 1 $FASTPATH_ON_SERVER -s 1 -s 2 -s 3 -w 1"
ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ubft_experiment/$(machine2dir machine3)/deployment/invoker.sh binaries/rpc-server-test ubft-rpc-test -l 2 $FASTPATH_ON_SERVER -s 1 -s 2 -s 3 -w 1"
ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ubft_experiment/$(machine2dir machine4)/deployment/invoker.sh binaries/rpc-server-test ubft-rpc-test -l 3 $FASTPATH_ON_SERVER -s 1 -s 2 -s 3 -w 1"

sleep 5

ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ubft_experiment/$(machine2dir machine1)/deployment/invoker.sh binaries/rpc-client-test ubft-rpc-test -l 65 $FASTPATH_ON -s 1 -s 2 -s 3 -w 1"

sleep $sleepfor

ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ubft_experiment/$(machine2dir machine1)/deployment/invoker-stop.sh ubft-rpc-test"
ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ubft_experiment/$(machine2dir machine2)/deployment/invoker-stop.sh ubft-rpc-test"
ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ubft_experiment/$(machine2dir machine3)/deployment/invoker-stop.sh ubft-rpc-test"
ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ubft_experiment/$(machine2dir machine4)/deployment/invoker-stop.sh ubft-rpc-test"

gather_results "$SCRIPT_DIR"/logs/rpc-latency-${logname}

clear_processes
