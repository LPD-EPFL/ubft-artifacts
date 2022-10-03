# Use the absolute path
ROOT_DIR='~'

# Set ssh names of the machines
machine1=w1
machine2=w2
machine3=w3
machine4=w4

# Set fqdn names of the machines (use `hostname -f`)
machine1hostname=w1
machine2hostname=w2
machine3hostname=w3
machine4hostname=w4

REGISTRY_MACHINE=machine1

# Memcached does not run with root access
UBFT_HAVE_SUDO_ACCESS=false
UBFT_SUDO_ASKS_PASS=false
UBFT_SUDO_PASS="MyPass"

UBFT_CPUNODEBIND=0
UBFT_CPUMEMBIND=0

# Do not edit below this line
machine1dir=m1
machine2dir=m2
machine3dir=m3
machine4dir=m4

machine2ssh () {
    local m=$1
    echo "${!m}" 
}

machine2dir () {
    local m=$1
    local m_dir=${m}dir
    echo "${!m_dir}" 
}

machine2hostname () {
    local m=$1
    local m_hn=${m}hostname
    echo "${!m_hn}" 
}

clear_processes_helper() {
    local sd=$1
    local mid=$2

    echo "Clearing processes in machine $mid"
    "$sd"/kill_tmux.sh machine$mid > /dev/null
}
export -f clear_processes_helper

clear_processes() {
    local sd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    for i in {1..4}; do
        printf "%s\0%s\0" $sd $i
    done | xargs -0 -n 2 -P 4 bash -c 'clear_processes_helper "$@"' --
}

set_processes_helper() {
    local sd=$1
    local mid=$2

    echo "Setting processes in machine $mid"
    "$sd"/set_tmux.sh machine$mid > /dev/null
}
export -f set_processes_helper

set_processes() {
    local sd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    for i in {1..4}; do
        printf "%s\0%s\0" $sd $i
    done | xargs -0 -n 2 -P 4 bash -c 'set_processes_helper "$@"' --
}

reset_processes() {
    clear_processes
    set_processes
}

send_payload_helper() {
    local payload=$1
    local sd=$2
    local mid=$3
    echo "Uploading to machine $mid"

    "$sd"/prepare_env.sh machine$mid > /dev/null
    "$sd"/upload_payload.sh machine$mid "$payload" >/dev/null
    "$sd"/deploy_payload.sh machine$mid > /dev/null
}
export -f send_payload_helper

send_payload () {
    local payload=$1
    local sd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    for i in {1..4}; do
        printf "%s\0%s\0%s\0" $payload $sd $i
    done | xargs -0 -n 3 -P 4 bash -c 'send_payload_helper "$@"' --
}

gather_results () {
    local destdir=$1
    local sd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    for i in {1..4}; do
        "$sd"/gather_logs.sh machine$i "$destdir"
    done
}
