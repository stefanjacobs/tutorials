#!/usr/bin/env bash

# 1. Create the registry
# Replace the registry url in the yaml
cp registry-template.yaml registry.yaml
sed -i '' -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" registry.yaml
# Apply yaml to kubernetes
kubectl apply -f registry.yaml
# Delete the old file
rm registry.yaml

# 2. Add the registry to the dockerhost
DOCKERHOSTNAME="dockerhost"
FILE="/var/snap/docker/current/config/daemon.json"
multipass copy-files dockerhost-daemon-template.json ${DOCKERHOSTNAME}:/home/ubuntu/daemon.json
multipass exec ${DOCKERHOSTNAME} -- bash <<EOF
sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" daemon.json
sudo cp daemon.json ${FILE}
sudo systemctl restart snap.docker.dockerd
EOF

# 3. Add the registry to kubernetes
# TODO: For now the registry is only added to the master, it should be added to all nodes
NODENAME="k3snode-master"
FILE="/etc/rancher/k3s/registries.yaml"
multipass copy-files k3s-registries-template.yaml ${NODENAME}:/home/ubuntu/registries.yaml
multipass exec ${NODENAME} -- bash <<EOF
sed -i -e "s/##REPLACE-WITH-KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" registries.yaml
sudo cp registries.yaml ${FILE}
sudo systemctl restart k3s
EOF