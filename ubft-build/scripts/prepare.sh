#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"/..

git clone git@github.com:LPD-EPFL/dory.git
cd dory
git checkout ubft-apps
cp -r ../../mu-build/mu/crash-consensus/libgen/prebuilt-lib/* crash-consensus/src
