# Figure 10
Median latency of multiple non-equivocation mechanisms for different message sizes.

## Payload
Run `copy.sh` to copy the `ubft-build/payload.zip` to `../tcb` and `usig-build/payload.zip` to `../usig`.
```sh
./copy.sh
```

Generate the raw data by running `./generate.sh`.
>The SGX part of the experiment runs in a different machine. Set the appropriate configuration in `../../usig/config.sh` before executing `./generate.sh`.

Finally, run `./datapoints.py` to get the data points present in the figure.
