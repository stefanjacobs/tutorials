# Setup a local registry

- apply .yaml with fixed hostname, use e.g. nip.io service for localhost or multipass ips
- add insecure registry to docker daemon and restart docker

    sudo vim /var/snap/docker/current/config/daemon.json
    ubuntu@dockerhost:~$ sudo systemctl restart snap.docker.dockerd

- docker pull alpine
- docker tag alpine 192-168-64-11.nip.io/alpine:latest
- docker push 192-168-64-11.nip.io/alpine:latest

- docker images

- docker image rm 192-168-64-11.nip.io/alpine
- docker images
- docker run -it 192-168-64-11.nip.io/alpine /bin/sh

## References

- [How to setup a local registry](https://itnext.io/how-to-setup-a-private-registry-on-k3s-d9283906d16)
