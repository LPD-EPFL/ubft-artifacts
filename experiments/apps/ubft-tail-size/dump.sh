#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

configs=$(ls -drt logs/e2e-latency-fastpath-flip-replicated-s*-t*-w{256,512})

msg_sz() {
  local str=$1
  echo $str | awk -F "-" '{print $6}' | cut -c2-
}

tail_sz() {
  local str=$1
  echo $str | awk -F "-" '{print $7}' | cut -c2-
}

win_sz() {
  local str=$1
  echo $str | awk -F "-" '{print $8}' | cut -c2-
}

peak_mem() {
  local str=$1
  local mem_in_bytes=$(grep VmPeak ${str}/m1/logs/ubft-server.txt | awk '{print $2}')
  echo $((mem_in_bytes / 1024 / 1024))
}

latency() {
  local str=$1
  local percentile=$2
  local latency_in_ns=$(grep ${percentile}th-percentile ${str}/m4/logs/ubft-client.txt | head -n 1 | awk '{print $3}')
  echo $((latency_in_ns / 1000))
}

echo "MsgSize TailSize WinSize PeakMem(MiB) 50th-Latency(us) 90th-Latency(us)  95th-Latency(us) 99th-Latency(us)"
for c in $configs; do
  echo "$(msg_sz $c) $(tail_sz $c) $(win_sz $c) $(peak_mem $c) $(latency $c 50) $(latency $c 90) $(latency $c 95) $(latency $c 99)"
done
