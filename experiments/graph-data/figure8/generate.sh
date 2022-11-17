#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

# No need to run the following three lines again if you already generated figure 7
../../apps/unreplicated/e2e_latency_unreplicated_flip.sh
../../apps/mu/e2e_latency_replicated_flip.sh
../../apps/ubft/e2e_latency_replicated_flip.sh --fastpath

../../apps/ubft/e2e_latency_replicated_flip.sh --slowpath

# The numbers in figure 8 were generated using the following
# We comment them out, since VMA does not work within docker deployments, such as the one provided to the artifact reviewers
#../../minbft/e2e-latency-ecdsa-vma.sh
#../../minbft/e2e-latency-noecdsa-vma.sh

# Instead, use the following:
../../minbft/e2e-latency-ecdsa-novma.sh
../../minbft/e2e-latency-noecdsa-novma.sh
