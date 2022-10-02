# Effect of lease duration, network and memory load on timely lease renewal
End-to-end latency of different applications when either not replicated or replicated via Mu and uBFT’s fast path.

## Payload
Run `copy.sh` to copy the `ubft-build/payload.zip` to `../apps`.
```sh
./copy.sh
```

Generate the raw data by running `generate.sh`.

Finally, run `datapoints.py` to get the data points present in the figure.
