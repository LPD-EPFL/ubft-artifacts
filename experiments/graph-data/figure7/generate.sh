#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

# No need to run the following two lines again if you already generated figure 5
../../apps/ubft/e2e_latency_replicated_flip.sh --fastpath
../../apps/ubft/e2e_latency_replicated_flip.sh --slowpath

../../usig/enclave-latency.sh
