# Setup a local registry to use in k3s

Setting up a local registry to push and pull images to involves at least three steps:

  1. Setup the registry itself
  2. Add the registry to the docker daemon
  3. Add the registry to the kubernetes cluster

After those steps you should be able to use your own registry.

## Setup the registry

Because we use the local k3s cluster for this demo and we do not know, which IP adress was assigned to you, we have to use some kind of text replacement. In the following textual examples I point the url to `registry.domain.de`:

  1. Apply the `registry-template.yaml` but replace the `##REPLACE-WITH-KUBERNETES-HOST##` text with the hostname you are using, here in the text I use `registry.domain.de`
  2. Add insecure registry to docker daemon and restart docker:

      ```bash
      sudo vim /var/snap/docker/current/config/daemon.json
      ```

      Insert the following `insecure registry:

      ```yaml
      {
        ...
        "insecure-registries": [
          "registry.domain.de"
        ]
      }
      ```

      And finally restart the docker daemon:

      ```bash
          ubuntu@dockerhost:~$ sudo systemctl restart snap.docker.dockerd
      ```

  3. Add insecure registry to kubernetes host and restart k3s:

      ```bash
      sudo vim  /etc/rancher/k3s/registries.yaml
      ```

      Add the following mirror to the registries:

      ```yaml
      mirrors:
        "registry.domain.de":
          endpoint:
            - "http://registry.domain.de"
      ```

      And restart the k3s service:

      ```bash
      sudo systemctl restart k3s
      ```

Finally we can test if that worked as expected, see the next section. The steps are also automated, if you followed the tutorial steps, see the `Automation` Section for the details.

### Test that the registry is working as expected

First: Pull an arbitrary image:

```bash
> docker pull alpine
```

Tag that image that it will be delivered to the registry:

```bash
> docker tag alpine registry-192-168-64-11.nip.io/alpine:latest
```

And finally push the image to this registry:

```bash
> docker push registry-192-168-64-11.nip.io/alpine:latest
```

Let us have a look, that images we have locally:

```bash
docker images
```

You notice the `alpine` image and you notice the tagged image `registry-192-168-64-11.nip.io/alpine:latest`. To see, if our registry is working, just delete tagged image locally:

```bash
docker image rm registry-192-168-64-11.nip.io/alpine
```

To verify that the image was delete, run the `docker images` command again:

```bash
docker images
```

The tagged image is gone, now for the final verification step: Pull the tagged image again from the registry:

```bash
docker run -it --rm registry-192-168-64-11.nip.io/alpine /bin/sh
```

It works!

## Automation

The whole described process is automated in the script `createRegistry.sh`. The script expects, that both env variables `CLUSTER_HOSTNAME` and `DOCKERHOSTNAME` are set.

## References

- [How to setup a local registry](https://itnext.io/how-to-setup-a-private-registry-on-k3s-d9283906d16)

## Contact

You can contact me using [Twitter](https://twitter.com/intent/tweet?url=https%3a%2f%2fstefanjacobs.github.io%2ftutorials%2f&text=Developing%20with%20Kubernetes%20and%20Docker%20on%20localhost%20without%20messing%20up%20your%20system&via=stefanjacobs&original_referer=https://stefanjacobs.github.io/tutorials/) (my [profile](https://twitter.com/stefanj78)) or if you have comments regarding this tutorial, visit me on [GitHub](https://github.com/stefanjacobs/tutorials) and file an [issue](https://github.com/stefanjacobs/tutorials/issues) or create a [pull requests](https://github.com/stefanjacobs/tutorials/pulls).
