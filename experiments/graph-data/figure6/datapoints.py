#!/usr/bin/env python3

PCIE_TRANSACTION = 300

def p2p_latency():
    with open(f'../../decomposition/logs/tail-p2p-ping/m1/logs/tail-p2p-ping.txt') as f:
        latencies = [int(l.split(' ')[-1].replace('ns\n', '')) for l in f if 'measured one-way latency:' in l]
        if not latencies:
            raise Exception(f'No latency found for p2p')
        return sum(latencies) / len(latencies)
P2P_LATENCY = p2p_latency()

def tcb_latency(fast_or_slow):
    if fast_or_slow not in ['slow', 'fast']: raise f'`{fast_or_slow}` path does not exist'
    with open(f'../../decomposition/logs/tcb-latency-{fast_or_slow}path/m1/logs/ubft-tcb-test.txt') as f:
        latencies = [int(l.split(' ')[-1].replace('ns\n', '')) for l in f if 'measured one-way latency:' in l]
        if not latencies:
            raise Exception(f'No latency found for path={fast_or_slow}')
        return sum(latencies) / len(latencies)

def rpc_latency(fast_or_slow):
    if fast_or_slow not in ['slow', 'fast']: raise f'`{fast_or_slow}` path does not exist'
    with open(f'../../decomposition/logs/rpc-latency-{fast_or_slow}path/m1/logs/ubft-rpc-test.txt') as f:
        return next(int(l.split(' ')[-1]) for l in f if 'Mean without extremes' in l)

def hooked_latency(fast_or_slow, report):
    if fast_or_slow not in ['slow', 'fast']: raise f'`{fast_or_slow}` path does not exist'
    with open(f'../../decomposition/logs/ubft-latency-{fast_or_slow}path-hooks/m2/logs/ubft-test.txt') as f:
        line = ''
        while report not in line:
            line = next(f)
        while 'Mean without extremes' not in line:
            line = next(f)
        return int(line.split(' ')[-1])

def e2e_latency(fast_or_slow):
    with open(f'../../decomposition/logs/ubft-latency-{fast_or_slow}path-hooks/m1/logs/ubft-test.txt') as f:
         return next(int(l.split(' ')[-1]) for l in f if '50th-percentile (ns):' in l)

def main():
    components = {
        'p2p': {
            'latency': lambda s: P2P_LATENCY, # 895,
            'display': 'P2P',
        },
        '2-p2p': {
            'latency': lambda s: P2P_LATENCY + PCIE_TRANSACTION,
            'display': 'P2P (2-cast)',
        },
        '3-p2p': {
            'latency': lambda s: P2P_LATENCY + PCIE_TRANSACTION * 2, # scheduling 3 consecutive P2Ps adds a latency penalty of 600 to the last
            'display': 'P2P (3-cast)',
        },
        'crypto': {
            'latency': lambda s: hooked_latency('slow', 'SIG COMPUTATION') + hooked_latency('slow', 'SIG CHECK'), # 57552 + 26361 in the paper
            'display': 'Crypto',
        },
        'swmr': {
            'latency': lambda s: hooked_latency('slow', 'SWMR READ') + hooked_latency('slow', 'SWMR WRITE'),
            'display': 'SWMR',
        },
        'other': {
            'latency': None,
            'display': 'Other',
        },
        'fast-rpc': {
            'latency': lambda s: rpc_latency('fast'), # 4190,
            'subcomponents': lambda s: [('3-p2p', s), ('p2p', s)],
            'path': 'fast',
            'display': 'RPC',
        },
        'fast-tcb': {
            'latency': lambda s: tcb_latency('fast'), # 2325,
            'subcomponents': lambda s: [('2-p2p', s), ('p2p', s)],
            'path': 'fast',
            'display': 'TCB',
        },
        'fast-ubft-replication': {
            'latency': lambda s: hooked_latency('fast', 'SMR LATENCY'), # 5220,
            'subcomponents': lambda s: [('fast-tcb', s), ('2-p2p', 8), ('2-p2p', 8)],
            'path': 'fast',
            'display': 'SMR',
        },
        'fast-ubft': {
            'latency': lambda s: e2e_latency('fast'), # 10400,
            'subcomponents': lambda s: [('fast-rpc', s), ('fast-ubft-replication', s)],
            'path': 'fast',
            'display': 'E2E',
        },
        'slow-ubft-rpc': {
            'latency': lambda s: rpc_latency('slow'), #98131,
            'subcomponents': lambda s: [('crypto', s), ('3-p2p', s), ('p2p', s)],
            'path': 'slow',
            'display': 'RPC',
        },
        'slow-tcb': {
            'latency': lambda s: tcb_latency('slow'), # 104000, # 85000 when measured directly, but this is the missing piece determined by the rest (to explain the overall latency)
            'subcomponents': lambda s: [('crypto', s), ('2-p2p', s), ('swmr', s)],
            'path': 'slow',
            'display': 'TCB',
        },
        'slow-ubft-replication': {
            'latency': lambda s: hooked_latency('slow', 'SMR LATENCY'), # 303415, there is a lot of variance
            'subcomponents': lambda s: [('slow-tcb', s), ('slow-tcb', s), ('crypto', s), ('p2p', s)],
            'path': 'slow',
            'display': 'SMR',
        },
        'slow-ubft': {
            'latency': lambda s: e2e_latency('slow'), # 406900, there is a lot of variance
            'subcomponents': lambda s: [('slow-ubft-rpc', s), ('slow-ubft-replication', s)],
            'path': 'slow',
            'display': 'E2E',
        },
    }

    for path in ['fast', 'slow']:
        print(f'Decomposition of the latency of the {path} path:')
        for comp in components.values():
            if 'path' not in comp or comp['path'] != path:
                continue
            # main component
            payload=8
            latency = comp['latency'](payload) / 1000.
            comp_disp = comp['display']
            print(f'- {comp_disp}: {latency} us')
            if 'subcomponents' not in comp: continue
            for (subcomp_name, subpayload) in comp['subcomponents'](payload):
                subcomp = components[subcomp_name]
                sublatency = subcomp['latency'](subpayload) / 1000.
                subcomp_disp = subcomp['display']
                print(f' \_> {subcomp_disp}: {sublatency} us')

if __name__ == "__main__":
    main()
