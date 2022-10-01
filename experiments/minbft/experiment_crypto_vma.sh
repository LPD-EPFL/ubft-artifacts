#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"

mkdir -p logs

while true; do
        read -p "Did you binaries have crypto enabled?[y/n] " yn
    case $yn in
        [Yy]* ) echo "Great! Continuing with experiment"; break;;
        [Nn]* ) echo "Please, do it and come back!"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
        read -p "Did you edit the consensus.yaml file?[y/n] " yn
    case $yn in
        [Yy]* ) echo "Great! Continuing with experiment"; break;;
        [Nn]* ) echo "Please, do it and come back!"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
        read -p "Did you start the replicas with VMA?[y/n] " yn
    case $yn in
        [Yy]* ) echo "Great! Continuing with experiment"; break;;
        [Nn]* ) echo "Please, do it and come back!"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

MSG_SZ=(2 4 8 16 32 64 128 256 512 1024 2048 4096 8192)
for msg_sz in ${MSG_SZ[@]}; do
  LD_PRELOAD=libvma.so ./run-client.sh 100000 $msg_sz > logs/minbft_crypto_vma_s${msg_sz}.txt
done
