#!/usr/bin/env bash

cp registry-template.yaml registry.yaml
sed -i '' -e "s/##KUBERNETES-HOST##/${CLUSTER_HOSTNAME}/g" registry.yaml

kubectl delete -f registry.yaml

rm registry.yaml