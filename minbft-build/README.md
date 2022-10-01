# Building MinBFT
The instructions below provide all necessary steps to build MinBFT.

## Preparation
First, download MinBFT from its repository, patch it and create two versions (one with ECDSA and one without)
```sh
scripts/prepare.sh
```

### Compiling
Then, simply run:
```sh
scripts/compile.sh
```

### Packaging
All the necessary binaries are generated. 
Configure the IPs of every MinBFT replica by editing the file `config/consensus.yaml`.
Subsequently, package the binaries by running:
```sh
scripts/payload.sh
```
A `payload.zip` is created that contains all the necessary code that needs to be executed for the experiment.
