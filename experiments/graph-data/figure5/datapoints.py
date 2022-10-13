#!/usr/bin/env python3

import os
import argparse

def minbft_latency(size, crypto, vma):
    vma_str = "vma" if vma else "novma"
    sgx_sig_latency = (4 * 9) if not crypto else 0
    crypto = 'no' if not crypto else ''
    def to_us(s): return float(s.split('µs')[0]) if 'µs' in s else float(s.split('ms')[0]) * 1000
    with open(f'../../minbft/logs/e2e-latency-minbft_{crypto}ecdsa-{vma_str}-{size}/m4/logs/minbft-client.txt') as f:
        next(f);next(f) # skip the first two lines
        latencies = []
        for l in f:
            try:
                latencies.append(to_us(l))
            except:
                pass
        #latencies = [to_us(l) for l in f]

        latencies.sort()
        return latencies[len(latencies) // 2] + sgx_sig_latency

def flip_latency(smr, size, client=None, replicated=True, path=None):
    if client is None: client = smr
    machine = 4 if replicated else 2
    path = {None: '', 'fast': 'fastpath-', 'slow': 'slowpath-'}[path]
    replicated = 'replicated' if replicated else 'unreplicated'
    with open(f'../../apps/{smr}/logs/e2e-latency-{path}flip-{replicated}-s{size}/m{machine}/logs/{client}-client.txt') as f:
        return next(int(l.split(' ')[-1]) for l in f if '50th-percentile (ns):' in l) / 1000.

def main(vma):
    # getting data
    sizes = [2**p for p in range(1, 14)]

    smrs = {
        'unreplicated': {
            'display': 'Unrepl.',
            'latency': lambda s: flip_latency('unreplicated', s, client='mu', replicated=False)
        },
        'mu': {
            'display': 'Mu',
            'latency': lambda s: flip_latency('mu', s)
        },
        'fast-ubft': {
            'display': 'uBFT fast path',
            'latency': lambda s: flip_latency('ubft', s, path='fast')
        },
        'slow-ubft': {
            'display': 'uBFT slow path',
            'latency': lambda s: flip_latency('ubft', s, path='slow')
        },
        'hmac-minbft': {
            'display': 'MinBFT HMAC',
            'latency': lambda s: minbft_latency(s, False, vma)
        },
        'ecdsa-minbft': {
            'display': 'MinBFT (Vanilla)',
            'latency': lambda s: minbft_latency(s, True, vma)
        }
    }

    # ploting

    print("The x-axis represents the request size (B)")
    print("The datapoints correspond to the sizes", sizes)
    print("The y-axis represents the latency (µs)")
    print("The cost of SGX is estimated (using another machine) to be 4*9=36µs end-to-end for MinBFT HMAC")
    print()
    
    for smr in smrs.values():
        y = list(smr['latency'](size) for size in sizes)
        print(smr['display'], y)

    # Reporting % changes
    filtered_smrs = [smr for smr in smrs if smr != 'slow-ubft']
    for a, b in zip(['hmac-minbft'], ['slow-ubft']):
        print(f'{a} -> {b}: ' + ' - '.join(f's={s}: +' + str(int((smrs[b]['latency'](s) - smrs[a]['latency'](s))/smrs[a]['latency'](s)*100)) + '%' for s in sizes))

if __name__ == "__main__":
    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)
    
    parser = argparse.ArgumentParser()

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--vma', action='store_true')
    group.add_argument('--no-vma', dest='vma', action='store_false')

    parser.set_defaults(vma=False)

    results = parser.parse_args()
    main(results.vma)
