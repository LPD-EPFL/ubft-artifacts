#!/bin/bash

source "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/config.sh

export DORY_REGISTRY_IP=$(machine2hostname $REGISTRY_MACHINE)

# For maximum performance, do not print logging messages
export SPDLOG_LEVEL=debug

UBFT_RT_MODE=""
#if  uname -a | grep "rtcore+heartbeat+nohzfull" -q ; then
#    UBFT_RT_MODE="chrt -f 99"
#fi


if [ "$UBFT_HAVE_SUDO_ACCESS" = true ] ; then
    if [ "$UBFT_SUDO_ASKS_PASS" = true ] ; then
        export SUDO_ASKPASS="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/pass.py

        UBFT_SUDO_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -A -E"
        }
        
        UBFT_CMD_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -A -E $UBFT_RT_MODE"
        }
    else
        UBFT_SUDO_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -E"
        }

        UBFT_CMD_PREFIX () {
            echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -E $UBFT_RT_MODE"
        }
    fi
else
    UBFT_SUDO_PREFIX () {
        echo ""
    }
    
    UBFT_CMD_PREFIX () {
        echo ""
    }
fi
