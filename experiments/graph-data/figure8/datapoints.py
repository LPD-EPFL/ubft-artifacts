#!/usr/bin/env python3

import os
import math
import re

def convert_size(size_bytes):
   if size_bytes == 0:
       return "0B"
   size_name = ("B", "KiB", "MiB", "GiB")
   i = 3 # int(math.floor(math.log(size_bytes, 1024)))
   p = math.pow(1024, i)
   s = round(size_bytes / p, 2 if (size_bytes / p) < 1 else 1)
   return "{}{}".format(s, size_name[i]) #.replace('0.', '.')


def leader_memory(path):
    p = os.path.join(path, 'm1/logs/ubft-server.txt')

    with open(p) as file:
        for line in file.readlines():
            if line.startswith('VmPeak'):
                return convert_size(int(line.split()[1]))

def client_latency(path):
    p = os.path.join(path, 'm4/logs/ubft-client.txt')
    latency = []

    regex = re.compile(r'^[1-9][0-9]*th\-percentile')

    with open(p) as file:
        for line in file.readlines():
            if regex.match(line):
                latency.append(int(line.split()[2]) /1000. )

    # Latency from 1st to 99th percentile
    return latency

def parse_logs(path):
    msg_size = [64, 2048]
    ttcb_size = [16, 32, 64, 128]
    win_sz = [256]

    data = {} # the latency is in us

    for m in msg_size:
        data[m] = {}
        for t in ttcb_size:
            data[m][t] = {}
            for w in win_sz:
                run = os.path.join(path, 'logs', f'e2e-latency-fastpath-flip-replicated-s{m}-t{t}-w{w}')
                data[m][t] = {'mem' : leader_memory(run), 'latency' : client_latency(run)}
    return data

def main():
    data = parse_logs('../../apps/ubft-tail-size/')
    percentiles = list(range(1, 100))
    print("Data points in list represent the percentiles 1st-%ile, 2nd-%ile, ..., 99th-%ile")
    print()

    for req_size, percentiles in data.items():
       print(f"Request size: {req_size} B")
       for t, p in percentiles.items():
           latency = p['latency']
           print(f"\tt = {t}, latency(%iles in µs) = {latency}")
       print()

if __name__ == "__main__":
    main()
