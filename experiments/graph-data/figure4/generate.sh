#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

../../apps/unreplicated/e2e_latency_unreplicated_flip.sh
../../apps/unreplicated/e2e_latency_unreplicated_memc.sh
../../apps/unreplicated/e2e_latency_unreplicated_liquibook.sh
../../apps/unreplicated/e2e_latency_unreplicated_redis.sh

../../apps/mu/e2e_latency_replicated_flip.sh
../../apps/mu/e2e_latency_replicated_liquibook.sh
../../apps/mu/e2e_latency_replicated_memc.sh
../../apps/mu/e2e_latency_replicated_redis.sh

../../apps/ubft/e2e_latency_replicated_flip.sh --fastpath
../../apps/ubft/e2e_latency_replicated_liquibook.sh --fastpath
../../apps/ubft/e2e_latency_replicated_memc.sh --fastpath
../../apps/ubft/e2e_latency_replicated_redis.sh --fastpath
