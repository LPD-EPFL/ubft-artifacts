#!/bin/bash

set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
source ../base-scripts/config.sh

send_payload "$SCRIPT_DIR"/payload.zip

export FASTPATH_ON="-f"
export FASTPATH_ON_SERVER="-f -o"
bash rpc_latency_helper.sh
