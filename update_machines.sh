#!/usr/bin/env bash

declare -a vars=(MULTIPASS_DOCKERHOST MULTIPASS_K3S_MASTER MULTIPASS_K3S_WORKER)
for var_name in "${vars[@]}"
do
        if [ -z "$(eval "echo \$$var_name")" ]; then
                echo "Missing environment variable $var_name"
                exit 1
        fi
done

if [ -z "$(eval "echo \$MULTIPASS_DOCKERHOST")" ]; then
    echo "No Dockerhost set"
else
    multipass exec ${MULTIPASS_DOCKERHOST} -- bash <<EOF
sudo apt update
sudo apt -y dist-upgrade
sudo snap refresh
EOF
    multipass restart ${MULTIPASS_DOCKERHOST}
fi

if [ -z "$(eval "echo \$MULTIPASS_K3S_MASTER")" ]; then
    echo "No K3S Master set"
else
    multipass exec ${MULTIPASS_K3S_MASTER} -- bash <<EOF
sudo apt update
sudo apt -y dist-upgrade
sudo snap refresh
EOF
    multipass restart ${MULTIPASS_K3S_MASTER}
fi

if [ -z "$(eval "echo \$MULTIPASS_K3S_WORKER")" ]; then
    echo "No K3S Worker set"
else
    for NODENAME in ${MULTIPASS_K3S_WORKER}; do
        multipass exec ${NODENAME} -- bash <<EOF
sudo apt update
sudo apt -y dist-upgrade
sudo snap refresh
EOF
        multipass restart ${MULTIPASS_K3S_WORKER}
    done
fi