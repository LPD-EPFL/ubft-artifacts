#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source parser.sh
source ../../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

MSG_SZ=(64 2048)
TTCB_SZ=(16 32 64 128)
WIN_SZ=(256)

for msg_sz in ${MSG_SZ[@]}; do
    for ttcb_sz in ${TTCB_SZ[@]}; do
        for win_sz in ${WIN_SZ[@]}; do
            reset_processes
            ssh -o LogLevel=QUIET -t $(machine2ssh $REGISTRY_MACHINE) "$ROOT_DIR/ubft_experiment/$(machine2dir $REGISTRY_MACHINE)/memc.sh"
        
            ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ubft_experiment/$(machine2dir machine1)/deployment/invoker.sh binaries/ubft-server ubft-server -l 1 -s 1 -s 2 -s 3 --dump-vm-consumption -a flip -c $msg_sz,$((msg_sz+1)) -w 1 -b 1 -t $ttcb_sz -W $win_sz $EXECUTION"
            ssh -o LogLevel=QUIET -t $(machine2ssh machine2) "$ROOT_DIR/ubft_experiment/$(machine2dir machine2)/deployment/invoker.sh binaries/ubft-server ubft-server -l 2 -s 1 -s 2 -s 3 --dump-vm-consumption -a flip -c $msg_sz,$((msg_sz+1)) -w 1 -b 1 -t $ttcb_sz -W $win_sz $EXECUTION"
            ssh -o LogLevel=QUIET -t $(machine2ssh machine3) "$ROOT_DIR/ubft_experiment/$(machine2dir machine3)/deployment/invoker.sh binaries/ubft-server ubft-server -l 3 -s 1 -s 2 -s 3 --dump-vm-consumption -a flip -c $msg_sz,$((msg_sz+1)) -w 1 -b 1 -t $ttcb_sz -W $win_sz $EXECUTION"
            sleep 5

            # Warning: ssh -t introduces a carriage return into the string
            M1PID=$(ssh -o LogLevel=QUIET $(machine2ssh machine1) "$ROOT_DIR/ubft_experiment/$(machine2dir machine1)/deployment/invoker-getpid.sh ubft-server")

            ssh -o LogLevel=QUIET -t $(machine2ssh machine4) "$ROOT_DIR/ubft_experiment/$(machine2dir machine4)/deployment/invoker.sh binaries/ubft-client ubft-client -l 64 -s 1 -s 2 -s 3 --dump-percentiles -a flip -c $msg_sz,$((msg_sz+1)) -w 1 $EXECUTION"
        
            if [[ -z $EXECUTION ]]
            then
              sleep 80
            else
              sleep 15
            fi

            if [ -z $M1PID ] ; then
              echo "Could not fetch PID"
            else
              ssh -o LogLevel=QUIET -t $(machine2ssh machine1) "$ROOT_DIR/ubft_experiment/$(machine2dir machine1)/deployment/invoker-signal.sh ubft-server $M1PID"
            fi

            sleep 5
        
            gather_results "$SCRIPT_DIR"/logs/e2e-latency-${EXECUTION_PATH}-flip-replicated-s${msg_sz}-t${ttcb_sz}-w${win_sz}
        done
    done
done

clear_processes
