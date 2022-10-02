#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

../../tcb/tcb_latency_fastpath.sh
../../tcb/tcb_latency_slowpath.sh
../../tcb/p2p_latency.sh

../../usig/enclave-latency.sh
