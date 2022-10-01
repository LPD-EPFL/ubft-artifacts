#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

while true; do
	read -p "Did you configure the $(realpath "$SCRIPT_DIR"/../config/consensus.yaml) file?[y/n] " yn
    case $yn in
        [Yy]* ) echo "Great! Continuing with experiment"; break;;
        [Nn]* ) echo "Please, do it and come back!"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

shopt -s extglob

cd "$SCRIPT_DIR"
rm -rf ../payload.zip
rm -rf ../binaries/minbft_ecdsa
rm -rf ../binaries/minbft_noecdsa


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
zip -r ../payload.zip ../binaries/
zip -urj ../payload.zip deploy/*
zip -urj ../payload.zip ../../ubft-build/scripts/deploy/invoker.sh
zip -urj ../payload.zip ../../ubft-build/scripts/deploy/run-invoker.sh
zip -urj ../payload.zip ../../ubft-build/scripts/deploy/invoker-stop.sh
