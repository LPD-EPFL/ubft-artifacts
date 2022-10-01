#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"/..

rm -rf minbft_ecdsa minbft_noecdsa go
rm -f go1.16.15.linux-amd64.tar.gz

git clone https://github.com/hyperledger-labs/minbft minbft_ecdsa
cd minbft_ecdsa
git checkout 1521018ab0bbc809c2f478ab5b50c9a5bfc2fdfd

patch -p 1 < ../patches/fix_linker_warnings.patch
patch -p 1 < ../patches/add_timing_measurements.patch
patch -p 1 < ../patches/remove_ledger_print.patch
patch -p 1 < ../patches/nullify_usig_create_ui.patch

cd ..
cp -r minbft_ecdsa minbft_noecdsa
cd minbft_noecdsa
patch -p 1 < ../patches/remove_ecdsa.patch

# Install Golang for MinBFT
cd ..
curl -L --proto '=https' --tlsv1.2 -O https://go.dev/dl/go1.16.15.linux-amd64.tar.gz
tar xf go1.16.15.linux-amd64.tar.gz
