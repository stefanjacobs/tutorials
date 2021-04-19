#!/usr/bin/env bash

# check, if multipass is installed
MULTIPASS=$(which multipass)
if [ $? -eq 0 ]; then
    echo -e "Multipass is installed, proceeding"
else
    echo -e "Multipass is not installed, exiting"
    exit 1
fi

# check, if docker is installed
DOCKER=$(which docker)
if [ $? -eq 0 ]; then
    echo -e "Docker cli is installed, proceeding"
else
    echo -e "Docker cli is not installed, exiting"
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function message {
    echo -e "${GREEN}$1${NC}"
}

function execute {
    echo -e "${RED}Executing: '${@:1}'${NC}"
    ${@:1}
}

# The number of CPUs that the multipass instance is allowed to use
CPUCOUNT=1
# The memory we assign to the multipass instance
MEM="2G"
# The multipass hostname for the dockerhost
JAVAMEMTEST_HOSTNAME="java-mem-test"

# Launch a multipass instance
multipass launch -c ${CPUCOUNT} -m ${MEM} -n ${JAVAMEMTEST_HOSTNAME}

# Get dockerhosts IP
IP=$(multipass info ${JAVAMEMTEST_HOSTNAME} | grep IPv4 | awk '{print $2}')

# Initialize the dockerhost with docker
multipass exec ${JAVAMEMTEST_HOSTNAME} -- bash <<EOF
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

export DOCKER_HOST="tcp://${IP}:2375"
clear
message "Case 1a, we give docker 1G of memory and let us have a look on the java -mx setting (lets set it to 512m):"
read -p "Press any key to continue... " -n1 
set -x
docker run --cpus 1 -m 1G adoptopenjdk/openjdk11:alpine-jre /bin/sh -c "/opt/java/openjdk/bin/java -XX:+PrintFlagsFinal -Xmx512m -version | grep -Ei 'maxheapsize|maxram'"
set +x
message "Note: MaxHeapSize is 536870912, that is 536870912/1024/1024: 512 MB as expected - we gave the container 1G of memory --> Done!"
read -p "Press any key to continue... " -n1 

clear
message "Case 1b, we give docker 1.5G of memory and let us have a look on the java -mx setting (lets set it again to 512m):"
read -p "Press any key to continue... " -n1 
set -x
docker run --cpus 1 -m 1536M adoptopenjdk/openjdk11:alpine-jre /bin/sh -c "/opt/java/openjdk/bin/java -XX:+PrintFlagsFinal -Xmx512m -version | grep -Ei 'maxheapsize|maxram'"
set +x
message "MaxHeapSize is still 536870912, that is 536870912/1024/1024: 512 MB as expected - we gave the container 1.5G of memory --> Not so good..."
read -p "Press any key to continue... " -n1 

clear
message "Good Case 2a, we give docker 1G of memory and let us have a look on the default java settings:"
read -p "Press any key to continue... " -n1 
set -x
docker run --cpus 1 -m 1G adoptopenjdk/openjdk11:alpine-jre /bin/sh -c "/opt/java/openjdk/bin/java -XX:+PrintFlagsFinal -version | grep -Ei 'maxheapsize|maxram'"
set +x
message "Note: MaxRamPercentage is 25%, MaxHeapSize is 268435456, that is 268435456/1024/1024: 256 MB as expected - we gave the container 1G of memory --> Done!"
read -p "Press any key to continue... " -n1 

clear
message "Good Case 2b, we give docker 1.5G of memory and let us have a look on the default java settings:"
read -p "Press any key to continue... " -n1 
set -x
docker run --cpus 1 -m 1536M adoptopenjdk/openjdk11:alpine-jre /bin/sh -c "/opt/java/openjdk/bin/java -XX:+PrintFlagsFinal -version | grep -Ei 'maxheapsize|maxram'"
set +x
message "Note: MaxRamPercentage is 25%, MaxHeapSize is 402653184, that is 402653184/1024/1024: 384 MB as expected - we gave the container 1.5G of memory --> Nice!"
read -p "Press any key to continue... " -n1 

clear
message "Good Case 2c, we give docker 512M of memory and set the MaxRAMPercentage explicitly to 50%:"
read -p "Press any key to continue... " -n1 
set -x
docker run --cpus 1 -m 512M adoptopenjdk/openjdk11:alpine-jre /bin/sh -c "/opt/java/openjdk/bin/java -XX:+PrintFlagsFinal -XX:MaxRAMPercentage=50 -version | grep -Ei 'maxheapsize|maxram'"
set +x
message "Note: MaxRamPercentage is 50%, MaxHeapSize is 268435456, that is 268435456/1024/1024: 256 MB as expected - we gave the container 512M of memory --> One setting to rule them all!"
read -p "Press any key to continue... " -n1


multipass delete ${JAVAMEMTEST_HOSTNAME}
multipass purge
