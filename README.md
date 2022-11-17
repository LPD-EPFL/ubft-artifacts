# Overview
uBFT is a BFT SMR system for microsecond applications.

This repository contains the artifacts and instructions needed to reproduce the experiments in our [ASPLOS paper](https://arxiv.org/abs/2210.17174v2).
More precisely, it contains:
* Instructions on how to build the payloads for the different experiments.
* Instructions on how to launch the experiments and obtain the results.

By running the experiments, you should be able to reproduce the numbers shown in:
* **Figure 7**: End-to-end latency of different applications when either not replicated or replicated via Mu and uBFT’s fast path.
* **Figure 8**: Median end-to-end latency for different request sizes of an unreplicated no-op application, as well as its latency when replicated with Mu, uBFT and MinBFT.
* **Figure 9**: Decomposition of the latency of UBFT's fast and slow paths.
* **Figure 10**: Median latency of multiple non-equivocation mechanisms for different message sizes.
* **Figure 11**: uBFT's tail latency for different TCB tails t and different request sizes of 64B and 2KiB.
* **Table 2**: uBFT replica memory usage for different TCB tails t and different request sizes.

# Detailed instructions

This section will guide you on how to build, configure, and run all experiments, **from scratch**, in order to reproduce the results presented in our paper.

## Cluster prerequisites

Running all experiments requires:
* a cluster of 4 machines connected via an InfiniBand fabric,
* Ubuntu 20.04 (different systems may work, but they have not been tested),
* all machines to have FQDNs (further instructions on this matter will be given when needed),
* all machines having the following ports open: 7000-7100, 11211, 18515, 9998
* a machine with Intel SGX (could be the one with Inifiniband).

## Deployment
The artifacts are built and packaged into binaries. Subsequently these binaries are deployed from a *gateway* machine (e.g., your laptop).
The gateway machine requires the following depencencies installed to be able to execute the deployment scripts:
```sh
sudo apt install -y coreutils gawk python3 zip tmux
```
The cluster machines, assuming they are already setup for Infiniband+RDMA and Intel SGX, require the following dependencies to be able to execute the binaries:
```sh
sudo apt install -y coreutils gawk python3 zip tmux gcc numactl libmemcached-dev memcached redis
```

## Generating the artifacts

### Installing dependencies
The first step in generating the artifacts is building and packaging the binaries. To do so, you need the dependencies below.
> *Note*: You can build and package the binaries in a cluster machine, the gateway or another machine. It is important, however, that you build the binaries in a machine with the same distro/version as the cluster's machines, otherwise the binaries may not work. For example, you can use a docker container to build and package the binaries. Alternatively, you can use one of the machines in the cluster.

#### Apt and PIP dependecies
Install the required dependencies on a vanilla Ubuntu 20.04 installation by running:
```sh
sudo apt-get -y install \
    python3 python3-pip \
    gawk build-essential cmake ninja-build \
    libmemcached-dev \
    libibverbs-dev # only if Mellanox OFED is not installed (see below).

pip3 install --upgrade "conan>=1.52.0"
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
* build all the necessary binaries, for example in a deployment machine,
* package them and deploy them in all 4 machines.

The building process is long. Follow the instructions in each one of the following sub-directories:
* Build Mu (on a deployment machine), as explained in [`mu-build`](mu-build/).
* Build uBFT (on a deployment machine), as explained in [`ubft-build`](ubft-build/).
* Build MinBFT (on a deployment machine), as explained in [`minbft-build`](minbft-build/).
* Build the Enclave code for MinBFT (on a deployment machine), as explained in [`usig-build`](usig-build/).

Once you have finished with the above steps, the binaries will be packaged in `payload.zip` files.

Execute `./deployment.sh` to generate the `deployment.zip`.

# Deploying and running the tests
Transfer the `deployment.zip` to the gateway machine and extract its content.
```sh
unzip deployment.zip -d deployment
cd deployment
```
To run the experiments, follow the instructions under [`experiments`](experiments/).

__Gateway:__ To run the experiments we assume the existence of gateway machine that has access to the 4-cluster machines and the sgx machine. This machine may be one of the deployment machines or e.g., your laptop. The gateway orchestrates the execution and gathers the experimental results.
