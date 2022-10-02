# Building uBFT
The instructions below provide all necessary steps to build uBFT.

## Preparation
First, download uBFT from its repository and copy into it Mu's library.
```sh
scripts/prepare.sh
```

### Compiling
Then, simply run:
```sh
scripts/compile.sh
```

### Packaging
All the necessary binaries are generated. Package them by running:
```sh
scripts/payload.sh
```
A `payload.zip` is created that contains all the necessary code that needs to be executed for the experiment.
