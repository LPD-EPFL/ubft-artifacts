# Figure 5
Median end-to-end latency for different request sizes of an unreplicated no-op application, as well as its latency when replicated with Mu, uBFT and MinBFT.

## Payload
Run `copy.sh` to copy the `ubft-build/payload.zip` to `../apps` and `minbft-build/payload.zip` to `../minbft`.
```sh
./copy.sh
```

Generate the raw data by running `./generate.sh`.
> **Note**: Currently, this scripts generates all data necessary for figure 5. Due to some overlap with figure 4, you can avoid some work (see the comments inside the script) if you already generated the data for figure 4.

> **Note**: The numbers for MinBFT were generated with VMA. The experiments using VMA are currently disabled, as VMA does not work inside docker containers. See inside `generate.sh` on how to run the minBFT experiments with VMA.

Finally, run `./datapoints.py --no-vma` to get the data points present in the figure.
> **Note**: If you edited `generate.sh` to use VMA, run `./datapoints.py --vma` instead.
