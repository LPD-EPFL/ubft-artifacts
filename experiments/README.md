# uBFT's experiments
This directory explains how to automatically run uBFT's experiments

## Configuring the scripts
The file `base-scripts/config.sh` needs to be configured before running the experiments. Several variables need to be set as explained below:
> Note that the deployment scripts need not run from a deployment machine. You can instead run them e.g., from your laptop.

---

```sh
ROOT_DIR
```
It defines the root directory where the scripts deploy the precompiled binaries in the deployment machines.
The default value is the home directory of the user used to access the deployment machines.

---

```sh
machine1
machine2
machine3
machine4
```
These variables define the symbolic names to access the deployment machines over ssh. To setup these symbolic names you need to edit `~/.ssh/config` in the machine you run the deployment scripts from (e.g., your laptop). You can learn how to do this [here](https://linuxize.com/post/using-the-ssh-config-file/).

It is important to be able to access the deployment machines without password. Thus, you need to install ssh keys. You can learn how to do this [here](https://www.cyberciti.biz/faq/ubuntu-18-04-setup-ssh-public-key-authentication/).
If your key contains a passphrase, you can rely on `ssh-agent`, also explained in the above previous link.

For example, the following entry in `~/.ssh/config`
```
Host mymachine
  HostName superlongname.example.com
  User user
  Port 22
  IdentityFile ~/.ssh/id_rsa
  ServerAliveInterval 120
```
Allows you to access the machine by merely typing `ssh mymachine`. 

---

```sh
machine1hostname
machine2hostname
machine3hostname
machine4hostname
```
These variables define the Fully Qualified Domain Names (FQDN) of these machines. Every machine should be able to access every other machine using the corresponding FQDN.
You can learn how to setup the FQDNs [here](https://linuxconfig.org/how-to-change-fqdn-domain-name-on-ubuntu-20-04-focal-fossa-linux).

---

```sh
REGISTRY_MACHINE
```
It defines which machine is going to run the memcached server needed to exchange QP information when setting up RDMA connections.
Make sure that `memcached` is installed in the declared machine and that its port 11211 is open.

---

```sh
UBFT_HAVE_SUDO_ACCESS
UBFT_SUDO_ASKS_PASS
UBFT_SUDO_PASS
```
These parameters define whether the processes launched during the experiments have sudo access.
We do not require root priviledges for our experiments. Leave these variables as is.
If you want to launch the processes with sudo, then (assuming you have sudo access in the deployement machines) set the first variable to `true`. 
If when issuing a command with sudo you need to type your password, set the second variable to `true` and put the password in the third variable.

---

```sh
UBFT_CPUNODEBIND
UBFT_CPUMEMBIND
```
Set the variables, which refer to the deployment machines, to achieve optimal performance. 
In a multi-socket machine, set `UBFT_CPUNODEBIND` to the socket that is closer to the RDMA NIC and `UBFT_CPUMEMBIND` to the memory that is closer to this socket.
The instructions in `mu-build` explain how to retrieve this information.


## Running the experiments
Under [`graph-data`](graph-data/) you will find subdirectories with all the necessary instructions for every experiment.
