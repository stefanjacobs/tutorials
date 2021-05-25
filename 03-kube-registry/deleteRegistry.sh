#!/usr/bin/env bash

REGISTRY_HOSTNAME="registry-${CLUSTER_HOSTNAME}"

cp registry-template.yaml /tmp/registry.yaml
sed -i '' -e "s/##KUBERNETES-HOST##/${REGISTRY_HOSTNAME}/g" /tmp/registry.yaml

kubectl delete -f /tmp/registry.yaml

rm /tmp/registry.yaml