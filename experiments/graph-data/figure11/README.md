# Figure 8
uBFT's tail latency for different TCB tails t for 2KiB requests and 64B requests.

## Payload
Run `copy.sh` to copy the `ubft-build/payload.zip` to `../apps/ubft-tcb-tail`.
```sh
./copy.sh
```

Generate the raw data by running `./generate.sh`.

Finally, run `./datapoints.py` to get the data points present in the figure.
