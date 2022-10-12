#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

unset FASTPATH_ON
unset FASTPATH_ON_SERVER
bash rpc_latency_helper.sh
