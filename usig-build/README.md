# Building the SGX enclave binary
The instructions below provide all necessary steps to build SGX enclave binary.
We use this binary to evaluate the cost that the enclave brings to MinBFT.

### Compiling
The enclave code includes the Blake3 hashing algorithm for optimal performance when generating the HMACs.
However, Blake3 requires vectorized instructions to work efficiently. Thus, to compile the enclave code, it is necessary to include the intrinsic compiler headers (`immintrin.h`).

Find this header in the compiler directory and copy it (along with all its includes) to the include directory:
```sh
find /usr -iname immintrin.h
```

This header includes many other intrinsic headers. Something like this will help you include most headers.
```sh
cat /usr/lib/gcc/x86_64-linux-gnu/9/include/immintrin.h | grep include
```
For the rest, follow the compiler errors.

> We already provide the compiler headers for gcc-9 on Ubuntu 20.04 in `using/includes`. You may want to replace these headers if you have a different compiler version and/or distro.

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
