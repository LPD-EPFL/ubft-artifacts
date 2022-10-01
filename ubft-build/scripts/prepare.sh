#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"/..

git clone git@github.com:LPD-EPFL/dory.git ubft
cd ubft
git checkout ubft-replicated-apps

cp -r ../../mu-build/mu/crash-consensus/libgen/prebuilt-lib/include/* crash-consensus/src/include/
cp -r ../../mu-build/mu/crash-consensus/libgen/prebuilt-lib/lib/* crash-consensus/src/lib/
