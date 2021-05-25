#!/usr/bin/env bash

REGISTRY_HOSTNAME="registry-${CLUSTER_HOSTNAME}"

# 1. Create the registry
# Replace the registry url in the yaml
TEMPFILE="/tmp/registry.yaml"
cp registry-template.yaml ${TEMPFILE}
sed -i '' -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${REGISTRY_HOSTNAME}/g" ${TEMPFILE}
# Apply yaml to kubernetes
kubectl apply -f ${TEMPFILE}
# Delete the old file
rm ${TEMPFILE}

# 2. Add the registry to the dockerhost
DOCKERHOSTNAME=${MULTIPASS_DOCKERHOST}
FILE="/var/snap/docker/current/config/daemon.json"
multipass copy-files dockerhost-daemon-template.json ${DOCKERHOSTNAME}:/home/ubuntu/daemon.json
multipass exec ${DOCKERHOSTNAME} -- bash <<EOF
sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${REGISTRY_HOSTNAME}/g" daemon.json
sudo cp daemon.json ${FILE}
sudo systemctl restart snap.docker.dockerd
EOF

# 3. Add the registry to kubernetes
NODES="${MULTIPASS_K3S_MASTER}"
for NODENAME in ${NODES}; do
    FILE="/etc/rancher/k3s/registries.yaml"
    multipass copy-files k3s-registries-template.yaml ${NODENAME}:/home/ubuntu/registries.yaml
    multipass exec ${NODENAME} -- bash <<EOF
sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${REGISTRY_HOSTNAME}/g" registries.yaml
sudo cp registries.yaml ${FILE}
sudo systemctl restart k3s
EOF
done
NODES="${MULTIPASS_K3S_WORKER}"
for NODENAME in ${NODES}; do
    DIR="/etc/rancher/k3s/"
    FILE="/etc/rancher/k3s/registries.yaml"
    multipass copy-files k3s-registries-template.yaml ${NODENAME}:/home/ubuntu/registries.yaml
    multipass exec ${NODENAME} -- bash <<EOF
sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${REGISTRY_HOSTNAME}/g" registries.yaml
sudo mkdir -p ${DIR}
sudo cp registries.yaml ${FILE}
sudo systemctl restart k3s-agent
EOF
done


replace_or_insert() {
    FILE="../.envrc"
    grep -q "$1" $FILE
    if [ $? -eq 0 ]
    then
        # echo "$FILE contains '$1'"
        sed -i '' "s|.*$1.*|$2|" $FILE
    else
        # echo "$FILE does not contain '$1'"
        echo "$2" >> $FILE
    fi
} 

# export settings to .envrc
touch ../.envrc
replace_or_insert "REGISTRY" "export REGISTRY=${REGISTRY_HOSTNAME}"