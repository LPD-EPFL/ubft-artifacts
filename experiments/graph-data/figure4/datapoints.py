#!/usr/bin/env python3

import os

def latency(smr, app, params, percentile):
    replicated = 'un' if smr == 'unreplicated' else ''
    machine = 2 if smr == 'unreplicated' else 4
    client = 'mu' if smr == 'unreplicated' else smr
    path = 'fastpath-' if smr == 'ubft' else ''
    with open(f'../../apps/{smr}/logs/e2e-latency-{path}{app}-{replicated}replicated-{params}/m{machine}/logs/{client}-client.txt') as f:
        return next(int(l.split(' ')[-1]) for l in f if f'{percentile}th-percentile (ns):' in l) / 1000.

def main():
    apps = {
        'flip': {
            'params': 's32',
        },
        'memc': {
            'params': 'k16-v32-g30-s80',
        },
        'liquibook': {
            'params': 'b50',
        },
        'redis': {
            'params': 'k16-v32-g30-s80'
        }
    }

    smrs = {
        'unreplicated': {
            'display': 'Unreplicated',
        },
        'mu': {
            'display': 'Mu',
        },
        'ubft': {
            'display': 'uBFT fast path',
        },
    }

    print("All numbers represent latency (µs)")

    for (app_name, app) in apps.items():
        for smr in smrs:
            ps = [latency(smr, app_name, app['params'], p) for p in (50, 90, 95)]
            print("{} ({}): 90th %-ile = {}, 50th %ile = {}, 95th %-ile = {}".format(app_name.capitalize(), smr, ps[1], ps[0], ps[2]))
            
if __name__ == "__main__":
    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)

    main()
