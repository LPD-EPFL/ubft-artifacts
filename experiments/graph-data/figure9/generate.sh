#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

../../decomposition/p2p_latency.sh

../../decomposition/tcb_latency_slowpath.sh
../../decomposition/tcb_latency_fastpath.sh

../../decomposition/rpc_latency_slowpath.sh
../../decomposition/rpc_latency_fastpath.sh

../../decomposition/ubft_latency_hooked.sh --fastpath
../../decomposition/ubft_latency_hooked.sh --slowpath