# Setup a local registry

- apply .yaml with fixed hostname, use e.g. nip.io service for localhost or multipass ips
- add insecure registry to docker daemon and restart docker

    sudo vim /var/snap/docker/current/config/daemon.json

    ```yaml
    {
      ...
      "insecure-registries": [
        "registry.domain.de"
      ]
    }
    ```

    ubuntu@dockerhost:~$ sudo systemctl restart snap.docker.dockerd

- add insecure registry to kubernetes host and restart k3s:

    sudo vim  /etc/rancher/k3s/registries.yaml

    ```yaml
    mirrors:
      "registry.domain.de":
        endpoint:
          - "http://registry.domain.de"
    ```

    sudo systemctl restart k3s

- docker pull alpine
- docker tag alpine registry-192-168-64-11.nip.io/alpine:latest
- docker push registry-192-168-64-11.nip.io/alpine:latest

- docker images

- docker image rm registry-192-168-64-11.nip.io/alpine
- docker images
- docker run -it --rm registry-192-168-64-11.nip.io/alpine /bin/sh

## References

- [How to setup a local registry](https://itnext.io/how-to-setup-a-private-registry-on-k3s-d9283906d16)
