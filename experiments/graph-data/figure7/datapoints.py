#!/usr/bin/env python3

import os
tcb_paths = ['slow', 'fast']
def tcb_latency(path, size):
    if path not in tcb_paths:
        raise f'`{path}` path does not exist'
    with open(f'../../tcb/logs/tcb-latency-{path}path-s{size}/m1/logs/ubft-tcb-test.txt') as f:
        latencies = [int(l.split(' ')[-1].replace('ns\n', '')) for l in f if 'measured one-way latency:' in l]
        if not latencies:
            raise f'No latency found for (path={path}, size={size})'
        return sum(latencies) / len(latencies)

def p2p_latency(size):
    with open(f'../../tcb/logs/tail-p2p-ping-s{size}/m1/logs/tail-p2p-ping.txt') as f:
        latencies = [int(l.split(' ')[-1].replace('ns\n', '')) for l in f if 'measured one-way latency:' in l]
        if not latencies:
            raise f'No latency found for size={size}'
        return sum(latencies) / len(latencies)

hash_size=32
def usig_latency(size):
    with open(f'../../usig/logs/usig-latency/ubft_sgx/logs/usig_{size}.txt') as f:
        lines = list(l for l in f)
        create = next(int(l.split(' ')[-1]) for l in lines[:33] if '50th-percentile (ns):' in l)
        verify = next(int(l.split(' ')[-1]) for l in lines[33:] if '50th-percentile (ns):' in l)
        return create + verify + p2p_latency(max(size, hash_size))

def main():
    # getting data
    sizes = [2**p for p in range(1, 14)]

    tcb = dict()
    for path in tcb_paths:
        tcb[f'TCB {path} path'] = list(tcb_latency(path, size) / 1000. for size in sizes)

    usig = dict()
    usig[f'SGX'] = list(usig_latency(size) / 1000. for size in sizes)

    print("The x-axis represents the request size (B)")
    print("The datapoints correspond to the sizes", sizes)
    print("The y-axis represents the latency (µs)")
    print()

    for tcb_mode_name, tcb_mode_values in tcb.items():
        print(tcb_mode_name, tcb_mode_values)

    for sgx_mode_name, sgx_mode_values in usig.items():
        print(sgx_mode_name, sgx_mode_values)

if __name__ == "__main__":
    main()
