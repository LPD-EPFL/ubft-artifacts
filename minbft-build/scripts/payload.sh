#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# For the version with with ECDSA
cd "$SCRIPT_DIR"/../minbft_ecdsa

rm -rf build
mkdir -p build/minbft
cp sample/bin/peer build/minbft
cp ../config/* build/minbft
cp sample/keys.yaml build/minbft
cp -r sample/lib build/minbft
cp /opt/sgxsdk/sdk_libs/libsgx_urts_sim.so build/minbft/lib
cp /opt/sgxsdk/sdk_libs/libsgx_uae_service_sim.so build/minbft/lib
mv build/minbft ../binaries/minbft_ecdsa

# For the version with with ECDSA
cd "$SCRIPT_DIR"/../minbft_noecdsa

rm -rf build
mkdir -p build/minbft
cp sample/bin/peer build/minbft
cp ../config/* build/minbft
cp sample/keys.yaml build/minbft
cp -r sample/lib build/minbft
cp /opt/sgxsdk/sdk_libs/libsgx_urts_sim.so build/minbft/lib
cp /opt/sgxsdk/sdk_libs/libsgx_uae_service_sim.so build/minbft/lib
mv build/minbft ../binaries/minbft_noecdsa

cd "$SCRIPT_DIR"
rm -rf ../payload.zip
zip -r ../payload.zip ../binaries/
zip -urj ../payload.zip deploy/*
