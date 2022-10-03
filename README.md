# Overview
uBFT is a BFT SMR system for microsecond applications.

This repository contains the artifacts and instructions needed to reproduce the experiments in our [ASPLOS paper]().
More precisely, it contains:
* Instructions on how to build the payloads for the different experiments.
* Instructions on how to launch the experiments and obtain the results.

By running the experiments, you should be able to reproduce the numbers shown in:
* **Figure 4**: End-to-end latency of different applications when either not replicated or replicated via Mu and uBFT’s fast path.
* **Figure 5**: Median end-to-end latency for different request sizes of an unreplicated no-op application, as well as its latency when replicated with Mu, uBFT and MinBFT.
* **Figure 7**: Median latency of multiple non-equivocation mechanisms for different message sizes.
* **Figure 9**: uBFT's tail latency for different TCB tails t and different request sizes of 64B and 2KiB.
* **Table 2**: uBFT replica and disaggregated memory usage for different TCB tails t and different request sizes.

# Detailed instructions

This section will guide you on how to build, configure, and run all experiments, **from scratch**, in order to reproduce the results presented in our paper.

## Cluster prerequisites

Running all experiments requires:
* a cluster of 4 machines connected via an InfiniBand fabric,
* Ubuntu 20.04 (different systems may work, but they have not been tested),
* all machines to have FQDNs (further instructions on this matter will be given when needed),
* all machines having the following ports open: 7000-7100, 11211, 18515, 9998
* A machine with Intel SGX (could be the one with Inifiniband).

### Dependencies

Prepare the machines on your cluster by installing the following dependencies:
```sh
apt install -y sudo coreutils gawk python3 zip tmux gcc numactl memcached redis
```

## Generating the artifacts

### Installing dependencies

#### Apt and PIP dependecies
Install the required dependency on a vanilla Ubuntu 20.04 installation by running:
```sh
sudo apt-get -y install \
    python3 python3-pip \
    gawk build-essential cmake ninja-build \
    libmemcached-dev \
    libibverbs-dev # only if Mellanox OFED is not installed (see below).

pip3 install --upgrade "conan>=1.47.0"
```

#### Mellanox OFED dependency

Install the appropriate OFED driver by running:

```sh
wget http://www.mellanox.com/downloads/ofed/MLNX_OFED-5.3-1.0.0.1/MLNX_OFED_LINUX-5.3-1.0.0.1-ubuntu20.04-x86_64.tgz
tar xf MLNX_OFED_LINUX-5.3-1.0.0.1-ubuntu20.04-x86_64.tgz
sudo ./mlnxofedinstall
```

#### Intel SGX dependency
```sh
sudo echo 'deb [trusted=yes arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main' > /etc/apt/sources.list.d/intel-sgx.list
sudo apt-get -y install wget build-essential python pkg-config \
                                        libsgx-epid libsgx-quote-ex libsgx-dcap-ql \
                                        libsgx-enclave-common-dev libsgx-dcap-ql-dev libsgx-dcap-default-qpl-dev

cd /opt
sudo wget https://download.01.org/intel-sgx/sgx-dcap/1.12.1/linux/distro/ubuntu20.04-server/sgx_linux_x64_sdk_2.15.101.1.bin
sudo chmod +x /opt/sgx_linux_x64_sdk_2.15.101.1.bin 
sudo ./sgx_linux_x64_sdk_2.15.101.1.bin --prefix /opt
echo 'source /opt/sgxsdk/environment' | sudo tee -a /etc/profile
echo '/opt/sgxsdk/sdk_libs' | sudo tee /etc/ld.so.conf.d/sgx-sdk.conf
sudo ldconfig
```

### Building the artifacts

Assuming all the machines in your cluster have the same configuration, you need to:
* build all the necessary binaries in one deployment machine,
* package them and deploy them in all 8 machines.

The building process is long. Follow the instructions in each one of the following sub-directories:
* Build Mu (on a deployment machine), as explained in [`mu-build`](mu-build/).
* Build uBFT (on a deployment machine), as explained in [`ubft-build`](ubft-build/).
* Build MinBFT (on a deployment machine), as explained in [`minbft-build`](minbft-build/).
* Build the Enclave code for MinBFT (on a deployment machine), as explained in [`usig-build`](usig-build/).

Once you have finished with the above steps, the binaries will be packaged in `payload.zip` files.

# Deploying and running the tests
In order to configure the deployment and run the experiments, follow the instructions under [`experiments`](experiments/).

__Note:__ For brevity, the parameter space explored by the scripts has been reduced drastically so that each experiment runs in a few minutes. Feel free to edit the scripts to explore more and reproduce all the results. We do not provide the scripts that generate the figures themselves.

__Gateway:__ To run the experiments we assume the existence of gateway machine that has access to all 8 machines. This machine may be one of the deployment machines or e.g., your laptop. The gateway orchestrates the execution and gathers the experimental results.

### Reproducing Figure 3

From the gateway, run:
```sh
ukharon-artifacts/experiments/stress/stress.sh
```

> Note: Edit stress.sh to run more/different configurations.

Find the generated data under `ukharon-artifacts/experiments/stress/logs/inactivity_maj${LEASE_DURATION}_net${NETWORK_LOAD}_mem${MEMRATE}/m4/logs/active-renewer.txt`.

For each (`LEASE_DURATION`, `NETWORK_LOAD`, `MEMRATE`), the inactivity rate is computed with the following formula: `inactivity_rate = (inactive_samples - first_active_sample + 1)/(number_of_samples - first_active_sample + 1)`.

The `MEMRATE` can be translated to a memory load according to the following table:

| Memrate | Memory Load |
|---------|-------------|
| 3       | ~50%        |
| 4       | ~65%        |
| 5       | ~85%        |
| 6       | ~100%       |

> Note: We estimated the memory load by running multiple `stress-ng` commands and crosscheckking the numbers with the [zsmith](https://zsmith.co/bandwidth.php) memory-bandwidth tool.

### Reproducing Figure 4

#### Evaluating stock Herd
From the gateway, run:
```sh
ukharon-artifacts/experiments/herd/herd_stock.sh
```
> Note: Running the full experiments takes ~2h. By default, only a subset of the parameter space is evaluated. Edit `herd_stock.sh` to run more configurations.

Find the generated data under `ukharon-artifacts/experiments/herd/logs/stock_w${WORKERS}_p${BATCH_SIZE}/m1/logs/workers.txt`.

Each worker reports its average throughput. Each bar in the figure is the average of the throughput accross workers.

#### Evaluating uKharon's overhead
From the gateway, run:
```sh
ukharon-artifacts/experiments/herd/herd_isactive.sh
```
> Note: Running the full experiments takes ~2h. By default, only a subset of the parameter space is evaluated. Edit `herd_isactive.sh` to run more configurations.

Find the generated data under `ukharon-artifacts/experiments/herd/logs/isactive_w${WORKERS}_p${BATCH_SIZE}/m4/logs/workers.txt`.

Each worker reports its average throughput. Each bar in the figure is the average of the throuhgput accross workers.

### Reproducing Table 2

The live environment we provide is slightly different from the one we used to run the evaluation in our paper.
Notably, the cluster we provide is not perfectly symmetrical (i.e., only half of the machines are booted with the custom kernel), resulting in increased variance in failover evaluation.
You should thus expect slightly degraded results (i.e., higher failover times).

> Note: For brevity, the scripts run only 1 iteration. Edit them for better results.

#### First column

From the gateway, run:
```sh
ukharon-artifacts/experiments/failover/failover_app.sh
```

Find the generated data under `ukharon-artifacts/experiments/failover/logs/failover_app/latency_{maj,cache}_{no,}deadbeat.txt`.
The number you are interested in is `s->a`, which measures the time difference between when the *kill **S**ignal* is sent over the network and the new membership becomes **A**ctive.

#### Second column

From the gateway, run:
```sh
ukharon-artifacts/experiments/failover/failover_app_coord.sh
```

Find the generated data under `ukharon-artifacts/experiments/failover/logs/failover_app_coord/latency_{maj,cache}_{no,}deadbeat.txt`.

#### Third column

From the gateway, run:
```sh
ukharon-artifacts/experiments/failover/failover_app_leasecache.sh
```

Find the generated data under `ukharon-artifacts/experiments/failover/logs/failover_app_leasecache/latency_{no,}deadbeat.txt`.

#### Fourth column

From the gateway, run:
```sh
ukharon-artifacts/experiments/failover/failover_app_leasecache_coord.sh
```

Find the generated data under `ukharon-artifacts/experiments/failover/logs/failover_app_leasecache_coord/latency_{no,}deadbeat.txt`.

### Reproducing Figure 5

#### Evaluating HERD
From the gateway, run:
```sh
ukharon-artifacts/experiments/kvstore/vanilla_herd.sh
```
Find the generated data under `ukharon-artifacts/experiments/kvstore/logs/vanilla_herd/latency_{put,get}/m4/logs/herd-client.txt`.

#### Evaluating dynamic HERD 
From the gateway, run:
```sh
ukharon-artifacts/experiments/kvstore/dynamic_herd.sh
```
Find the generated data under `ukharon-artifacts/experiments/kvstore/logs/dynamic_herd/latency_{put,get}_majority/m4/logs/herd-client.txt`.

#### Evaluating HERD+Mu
From the gateway, run:
```sh
ukharon-artifacts/experiments/kvstore/herd_mu.sh
```
Find the generated information under `ukharon-artifacts/experiments/kvstore/logs/herd_mu/latency_{put,get}/m4/logs/herd-client.txt`.
The failover time is gathered in `ukharon-artifacts/experiments/kvstore/logs/herd_mu/put_failover.txt`.
> Note: Edit `herd_mu.sh` to increase the number of samples for failover.

> Note: In order to be as fair as possible with Mu, we aggressively lowered its failure detection threshold. This may cause oscillations/failures and you may have to re-run the test.

#### Evaluating uKharon-KV
From the gateway, run:
```sh
ukharon-artifacts/experiments/kvstore/herd_ukharon.sh
```
Find the generated information under `ukharon-artifacts/experiments/kvstore/logs/herd_ukharon/latency_{get,put}_majority/m4/logs/herd-client.txt`.
The failover time is gathered in `ukharon-artifacts/experiments/kvstore/logs/herd_ukharon/ukharonkv_failover_with{,out}_cache.txt`.
> Note: Edit `herd_ukharon.sh` to increase the number of samples for failover.

