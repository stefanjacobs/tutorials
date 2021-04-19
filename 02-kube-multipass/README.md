# Tutorial: Kubernetes Multipass Setup



## MicroK8s

asdf

    multipass launch -c 4 -n k8shost


Installing Channel 1.18, because of bug in 1.19 that does not start

    ubuntu@k8shost:~$ sudo snap install microk8s --classic --channel=1.18/stable
    microk8s (1.18/stable) v1.18.16 from Canonical✓ installed
    ubuntu@k8shost:~$ sudo usermod -a -G microk8s $USER
    ubuntu@k8shost:~$ sudo chown -f -R $USER ~/.kube
    ubuntu@k8shost:~$ sudo su - $USER
    ubuntu@k8shost:~$ microk8s status --wait-ready

Bug: https://github.com/ubuntu/microk8s/issues/1570 --> Use 1.18
Channel: https://discuss.kubernetes.io/t/selecting-a-snap-channel/11270


# k3s


## Appendix

The whole process is automated in the shell script [createCluster.sh](createCluster.sh). The
cluster can be given an argument indicating the number of nodes the cluster should have. Default
value is "1" node.

## Contact

You can contact me using [Twitter](https://twitter.com/intent/tweet?url=https%3a%2f%2fstefanjacobs.github.io%2ftutorials%2f&text=Developing%20with%20Kubernetes%20and%20Docker%20on%20localhost%20without%20messing%20up%20your%20system&via=stefanjacobs&original_referer=https://stefanjacobs.github.io/tutorials/) (my [profile](https://twitter.com/stefanj78)) or if you have comments regarding this tutorial, visit me on [GitHub](https://github.com/stefanjacobs/tutorials) and file an [issue](https://github.com/stefanjacobs/tutorials/issues) or create a [pull requests](https://github.com/stefanjacobs/tutorials/pulls).

## References

- https://microk8s.io/docs
- https://github.com/ahmetb/kubectx 
- https://k3s.io/
- https://rancher.com/docs/k3s/latest/en/cluster-access/
- https://betterprogramming.pub/local-k3s-cluster-made-easy-with-multipass-108bf6ce577c
- https://gist.github.com/lucj/5a0e2286b40130d02388a264e6924ed4