# Tutorial: Kubernetes Multipass Setup

After using [docker-for-mac](https://docs.docker.com/docker-for-mac/install/)
a lot for working with Kubernetes I decided to search for an replacement that
fulfills the following requirements:

- Startup and shutdown in a matter of seconds
- Fairly low CPU consumption
- Ability to throw away and restart from scratch within minutes using simple script(s)

Some experiments and several distributions later I found MicroK8s and K3s.

## MicroK8s

I followed this [installation guide](https://microk8s.io/docs).

To be honest, I did not experiment a lot with MicroK8s, because of
[this issue](https://github.com/ubuntu/microk8s/issues/1570). It worked
when creating the old version manually
([select an old snap channel](https://discuss.kubernetes.io/t/selecting-a-snap-channel/11270)),
but the CPU load seemed to be higher than k3s when doing nothing (no
pods deployed). That may differ for you, so please check out for yourself.

For documentation reasons I keep the documentation in place - but I
deleted those instances after playing with them.

    multipass launch -c 4 -n k8shost

Installing Channel 1.18, because of bug in 1.19 that does not start

    ubuntu@k8shost:~$ sudo snap install microk8s --classic --channel=1.18/stable
    microk8s (1.18/stable) v1.18.16 from Canonical✓ installed
    ubuntu@k8shost:~$ sudo usermod -a -G microk8s $USER
    ubuntu@k8shost:~$ sudo chown -f -R $USER ~/.kube
    ubuntu@k8shost:~$ sudo su - $USER
    ubuntu@k8shost:~$ microk8s status --wait-ready

After that step the installation was done and the cluster was accessible using

    microk8s kubectl get nodes

It is obvious that an alias can be used to map `kubectl="microk8s kubectl"` to
ease access within the virtual machine.

## K3s

Again, I followed the available [installation guide](https://k3s.io/).

Installation consists of one command:

    ubuntu@k3s-master:~$ curl -sfL https://get.k3s.io | sh -

Get the token for this master node with the following command:

    ubuntu@k3s-master:~$ sudo cat /var/lib/rancher/k3s/server/node-token

And register each worker node with the following command using the given token:

    ubuntu@k3s-worker:~$ curl -sfL https://get.k3s.io | K3S_URL="https://$IP:6443" K3S_TOKEN="$TOKEN" sh -

You can get access to the cluster using the following command:

    ubuntu@k3s-master:~$ sudo cat /etc/rancher/k3s/k3s.yaml > k3s.yaml
    export KUBECONFIG=${PWD}/k3s.yaml

I use .envrc ([direnv](https://direnv.net/)) to work with different clusters.

### Automated provisioning

The whole process is automated in the shell script [createCluster.sh](createCluster.sh) using virtual multipass instances. The
cluster can be given an argument indicating the number of nodes the cluster should have. Default
value is "1" node. The kubeconfig file is saved to the local directory with name `k3s.yaml`.

The cluster can be created in multipass in a matter of minutes, can be started and stopped
in seconds and can be simply deleted by deleting (and purging) its virtual multipass nodes.

### Different Kubernetes Contexts

You can work with several Kubernetes contexts in different ways.

One way is to define each context in its own file and set the according
environment variable `KUBECONFIG`.

A second way is to merge two different configuration files into one using
the command:

    KUBECONFIG=~/.kube/config.backup:k3s.yaml kubectl config view --flatten > ~/.kube/config

**Be aware** that you should backup a working config before merging and that you should not overwrite an active configuration. Because of that I switched to working with different Kubernetes config files using [direnv](https://direnv.net/).

## Contact

You can contact me using [Twitter](https://twitter.com/intent/tweet?url=https%3a%2f%2fstefanjacobs.github.io%2ftutorials%2f&text=Developing%20with%20Kubernetes%20and%20Docker%20on%20localhost%20without%20messing%20up%20your%20system&via=stefanjacobs&original_referer=https://stefanjacobs.github.io/tutorials/) (my [profile](https://twitter.com/stefanj78)) or if you have comments regarding this tutorial, visit me on [GitHub](https://github.com/stefanjacobs/tutorials) and file an [issue](https://github.com/stefanjacobs/tutorials/issues) or create a [pull requests](https://github.com/stefanjacobs/tutorials/pulls).

## References

- [https://microk8s.io/docs](https://microk8s.io/docs)
- [https://github.com/ahmetb/kubectx](https://github.com/ahmetb/kubectx)
- [https://k3s.io/](https://k3s.io/)
- [Rancher doc for cluster access](https://rancher.com/docs/k3s/latest/en/cluster-access/)
- [Inspiration for this tutorial](https://betterprogramming.pub/local-k3s-cluster-made-easy-with-multipass-108bf6ce577c)
- [Basic gist that the script ./createCluster.sh was derived from](https://gist.github.com/lucj/5a0e2286b40130d02388a264e6924ed4)
