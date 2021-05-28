#!/usr/bin/env bash

# check, if multipass is installed
MULTIPASS=$(which multipass)
if [ $? -eq 0 ]; then
    echo -e "Multipass is installed, proceeding"
else
    echo -e "Multipass is not installed, exiting"
    exit 1
fi

# The number of CPUs that the dockerhost ist allowed to use
CPUCOUNT=1
# The multipass hostname for the dockerhost
DOCKERHOSTNAME="dockerhost"

# Launch a multipass instance
multipass launch -c ${CPUCOUNT} -n ${DOCKERHOSTNAME}

# Get dockerhosts IP
IP=$(multipass info ${DOCKERHOSTNAME} | grep IPv4 | awk '{print $2}')

# Initialize the dockerhost with docker
multipass exec ${DOCKERHOSTNAME} -- bash <<EOF
sudo apt update
sudo apt -y upgrade
sudo snap install docker
sudo addgroup --system docker
sudo adduser \$USER docker
newgrp docker
sudo snap disable docker
sudo snap enable docker
sudo cp /var/snap/docker/current/config/daemon.json /var/snap/docker/current/config/daemon.json.backup
sudo sh -c 'echo """{
    \"hosts\": [\"unix:///var/run/docker.sock\", \"tcp://0.0.0.0:2375\"],
    \"log-level\": \"error\",
    \"storage-driver\": \"overlay2\"
}""" > /var/snap/docker/current/config/daemon.json'
sudo systemctl restart snap.docker.dockerd
EOF

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

touch ../.envrc
replace_or_insert "MULTIPASS_DOCKERHOST" "export MULTIPASS_DOCKERHOST=${DOCKERHOSTNAME}"
replace_or_insert "DOCKER_HOST" "export DOCKER_HOST=\"tcp://${IP}:2375\""

# We are done!
echo
echo "Dockerhost is ready!"
echo "Run the following command to set the dockerhost:"
echo "$ export DOCKER_HOST='tcp://${IP}:2375'"
echo 
echo "Recommended: Add the following three lines to your .bashr file"
echo
echo "    export DOCKER_HOST='tcp://${IP}:2375'"
echo "    alias stop-dockerhost='multipass stop dockerhost'"
echo "    alias start-dockerhost='multipass start dockerhost'"
