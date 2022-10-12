#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"/..

git clone https://github.com/LPD-EPFL/ubft

cd ubft
sed -i 's/"with_mu": False,/"with_mu": True,/g' ubft-apps/conanfile.py

cp -r ../../mu-build/mu/crash-consensus/libgen/prebuilt-lib/include/* crash-consensus/src/include/
cp -r ../../mu-build/mu/crash-consensus/libgen/prebuilt-lib/lib/* crash-consensus/src/lib/
