#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source parser.sh
source ../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

reset_processes
ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ubft_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"

ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ubft_experiment/$(machine2dir machine2)/deployment/invoker.sh binaries/ubft-server-test-hooks ubft-test -l 1 -s 1 -s 2 -s 3 -w 1 $EXECUTION"
ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ubft_experiment/$(machine2dir machine3)/deployment/invoker.sh binaries/ubft-server-test ubft-test -l 2 -s 1 -s 2 -s 3 -w 1 $EXECUTION"
ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ubft_experiment/$(machine2dir machine4)/deployment/invoker.sh binaries/ubft-server-test ubft-test -l 3 -s 1 -s 2 -s 3 -w 1 $EXECUTION"
sleep 10
ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ubft_experiment/$(machine2dir machine1)/deployment/invoker.sh binaries/ubft-client-test ubft-test -l 64 -s 1 -s 2 -s 3 -w 1 $EXECUTION"

if [[ -z $EXECUTION ]]
then
  sleep 80
else
  sleep 15
fi

ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ubft_experiment/$(machine2dir machine1)/deployment/invoker-stop.sh ubft-test"
ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ubft_experiment/$(machine2dir machine2)/deployment/invoker-stop.sh ubft-test"
ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ubft_experiment/$(machine2dir machine3)/deployment/invoker-stop.sh ubft-test"
ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ubft_experiment/$(machine2dir machine4)/deployment/invoker-stop.sh ubft-test"

gather_results "$SCRIPT_DIR"/logs/ubft-latency-${EXECUTION_PATH}-hooks

clear_processes
