#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"/..

shopt -s extglob

rm -rf payload.zip
rm -v -f binaries/!("placeholder.txt")
unzip ubft/ubft-apps/binaries.zip -d binaries
cp ubft/ubft/build/bin/tail-p2p-ping binaries
cp ubft/ubft/build/bin/tail-cb-ping binaries
zip -r payload.zip binaries/
zip -urj payload.zip scripts/deploy/*
