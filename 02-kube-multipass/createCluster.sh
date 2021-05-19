#!/usr/bin/env bash
# Original gist: https://gist.github.com/lucj/5a0e2286b40130d02388a264e6924ed4

# A name for each node and the master node
CLUSTERNAME="k3s-cluster"
NODENAME="k3snode"
MASTERNODE="${NODENAME}-master"

# The number of CPUs for each k3s node
CPU_PER_NODE=2
MEM_PER_NODE=2G
DISC_PER_NODE=10G

if [ $# -ge 1 ]; then
    NODECOUNT=$1
    echo -e "Creating a cluster with ${NODECOUNT} nodes"
    NODES=""
    for ((i = 2 ; i <= ${NODECOUNT} ; i++ ))
    do
        NODES="${NODES} ${NODENAME}-$i"
    done
else
    NODECOUNT=1
    echo -e "Creating a cluster with only 1 node"
    NODES=""
fi

# check, if multipass is installed
MULTIPASS=$(which multipass)
if [ $? -eq 0 ]; then
    echo -e "Multipass is installed, proceeding"
else
    echo -e "Multipass is not installed, exiting"
    exit 1
fi

# Create master node
multipass launch -n ${MASTERNODE} -c ${CPU_PER_NODE} -m ${MEM_PER_NODE} -d ${DISC_PER_NODE}

# Create cluster member
for NODE in ${NODES}; do
    multipass launch -n ${NODE} -c ${CPU_PER_NODE} -m ${MEM_PER_NODE} -d ${DISC_PER_NODE}
done

# Init cluster on node1
multipass exec ${MASTERNODE} -- bash -c "curl -sfL https://get.k3s.io | sh -"

# Get master's IP
IP=$(multipass info ${MASTERNODE} | grep IPv4 | awk '{print $2}')

# Get Token used to join nodes
TOKEN=$(multipass exec ${MASTERNODE} sudo cat /var/lib/rancher/k3s/server/node-token)

# Join nodes
for NODE in ${NODES}; do
    multipass exec ${NODE} -- \
bash -c "curl -sfL https://get.k3s.io | K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
done

# Get cluster's configuration
multipass exec ${MASTERNODE} sudo cat /etc/rancher/k3s/k3s.yaml > k3s.yaml

# Set the external IP in the configuration file
sed -i '' "s/127.0.0.1/$IP/" k3s.yaml

# Give the cluster a name in the configuration file
sed -i '' "s/default/${CLUSTERNAME}/g" k3s.yaml

# We are set
echo
echo "K3s cluster is ready !"
echo
echo "Run the following command to set the current context:"
echo "$ export KUBECONFIG=$PWD/k3s.yaml"
echo
echo "and start to use the cluster:"
echo  "$ kubectl get nodes"
echo
echo "Alternatively, merge your cluster contexts (be aware that you should not load the config to overwrite it):"
echo "$ KUBECONFIG=~/.kube/config.backup:k3s.yaml kubectl config view --flatten > ~/.kube/config"
